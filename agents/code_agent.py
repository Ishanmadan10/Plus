import os, json, re, subprocess, time
from google import genai
from google.genai import types
from google.genai.errors import ClientError
from github import Github, Auth

# -----------------------------
# GitHub setup
# -----------------------------
REPO = os.environ["GITHUB_REPOSITORY"]

gh = Github(auth=Auth.Token(os.environ["GITHUB_TOKEN"]))
repo = gh.get_repo(REPO)

# -----------------------------
# Gemini client
# -----------------------------
client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

MODELS = [
    "gemini-2.5-flash",
    "gemini-2.5-pro", 
    "gemini-2.5-flash-lite",
]

def call_gemini(prompt: str, config):
    for model in MODELS:
        try:
            print(f"Trying model: {model}")
            response = client.models.generate_content(
                model=model,
                contents=prompt,
                config=config
            )
            if response.text:
                return response.text.strip()
        except ClientError as e:
            if "RESOURCE_EXHAUSTED" in str(e):
                print(f"Model {model} quota exhausted — trying next")
                continue
            print(f"Model {model} failed: {e}")
            time.sleep(1)
        except Exception as e:
            print(f"Unexpected error {model}: {e}")
            time.sleep(1)
    return None

def parse_json_response(raw_text: str):
    if not raw_text:
        raise ValueError("Empty response")
    cleaned = raw_text.replace("```json", "").replace("```", "").strip()
    start = cleaned.find("{")
    end = cleaned.rfind("}")
    if start == -1 or end == -1:
        raise ValueError("No JSON object found")
    return json.loads(cleaned[start:end + 1])

# -----------------------------
# Load backlog — pick highest priority pending suggestion
# -----------------------------
with open("backlog.json") as f:
    backlog = json.load(f)

pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

if not pending:
    print("No pending suggestions — nothing to implement")
    exit(0)

# Sort by priority (lower number = higher priority), pick first
pending.sort(key=lambda s: s.get("priority", 99))
suggestion = pending[0]

print(f"Implementing: [{suggestion.get('priority', '?')}] {suggestion.get('title', suggestion.get('id'))}")
print(f"File: {suggestion.get('file', 'unknown')}")

suggestion_id = suggestion["id"]
suggestion_text = json.dumps(suggestion, indent=2)

# -----------------------------
# Load full repo
# -----------------------------
def load_repo():
    repo_map = {}
    for root, _, files in os.walk("."):
        if any(skip in root for skip in [".git", "Pods", "build", ".build", "DerivedData"]):
            continue
        for file in files:
            if file.endswith(".swift"):
                path = os.path.normpath(os.path.join(root, file))
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        repo_map[path] = f.read()
                except Exception:
                    continue
    return repo_map

repo_map = load_repo()
EXISTING_FILES = set(repo_map.keys())

# Send the target file in full + repo summary for context
target_file = os.path.normpath(suggestion.get("file", ""))
target_content = repo_map.get(target_file, "")

repo_summary = "\n".join(
    f"{path} | {len(content.splitlines())} lines"
    for path, content in repo_map.items()
)

print(f"Loaded {len(repo_map)} Swift files")

# -----------------------------
# Load code prompt
# -----------------------------
with open("agents/prompts/code_prompt.txt", "r", encoding="utf-8") as f:
    base_prompt = f.read()

# -----------------------------
# Build generation prompt
# Send the target file in full, repo summary for wider context
# -----------------------------
generation_prompt = f"""
{base_prompt}

SUGGESTION TO IMPLEMENT:
{suggestion_text}

REPOSITORY STRUCTURE:
{repo_summary}

TARGET FILE (implement changes here):
// FILE: {target_file}
{target_content}
"""

# -----------------------------
# Generate
# -----------------------------
raw = call_gemini(
    generation_prompt,
    types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=8192,
        response_mime_type="application/json",
    )
)

if raw is None:
    print("Generation failed — all models exhausted")
    exit(0)

try:
    result = parse_json_response(raw)
except Exception as e:
    print(f"JSON parse failed: {e}")
    print(raw)
    exit(1)

if not result.get("changes"):
    print("No changes returned by model")
    exit(0)

# -----------------------------
# Apply changes safely
# -----------------------------
written_files = 0
written_paths = []

for change in result["changes"]:
    file_path = change.get("file")
    content = change.get("content")

    if not file_path or content is None:
        print("Skipping malformed change")
        continue

    file_path = os.path.normpath(file_path)

    if os.path.isabs(file_path) or ".." in file_path.split(os.sep):
        print(f"Skipping dangerous path: {file_path}")
        continue

    if not file_path.endswith(".swift"):
        print(f"Skipping non-Swift file: {file_path}")
        continue

    if file_path not in EXISTING_FILES:
        print(f"New file will be created: {file_path}")

    dir_path = os.path.dirname(file_path)
    if dir_path:
        os.makedirs(dir_path, exist_ok=True)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

    written_files += 1
    written_paths.append(file_path)
    print(f"Updated: {file_path}")

print(f"Written {written_files} files")

if written_files == 0:
    print("No valid file changes applied")
    exit(0)

# -----------------------------
# Git ops
# -----------------------------
branch = f"agent/{suggestion_id}"

subprocess.run(["git", "config", "user.email", "agent@users.noreply.github.com"], check=True)
subprocess.run(["git", "config", "user.name", "Code Agent"], check=True)
subprocess.run(["git", "checkout", "-b", branch], check=True)
subprocess.run(["git", "add", "-A"], check=True)

# Check if there's actually anything to commit
diff_check = subprocess.run(["git", "diff", "--cached", "--quiet"], check=False)
if diff_check.returncode == 0:
    print("No actual changes detected after writing files — skipping commit")
    exit(0)

commit_message = result.get("summary", suggestion.get("title", "AI generated changes"))
subprocess.run(["git", "commit", "-m", f"feat: {commit_message}"], check=True)
subprocess.run(["git", "push", "origin", branch], check=True)

# -----------------------------
# Build PR body with UI + backend impact
# -----------------------------
ui_impact = suggestion.get("ui_impact", "")
backend_impact = suggestion.get("backend_impact", "")
description = result.get("description", "")

pr_body = f"""## {suggestion.get('title', suggestion_id)}

**Why:** {suggestion.get('why', '')}

---

### UI Changes
{ui_impact if ui_impact else '_No UI changes_'}

### Backend / Logic Changes
{backend_impact if backend_impact else '_No backend changes_'}

---

### Implementation Notes
{description}

---
> Generated by Code Agent from backlog suggestion `{suggestion_id}`
"""

pr = repo.create_pull(
    title=f"[Agent] {result.get('summary', suggestion.get('title', 'AI Generated Update'))}",
    body=pr_body,
    head=branch,
    base="main"
)

# -----------------------------
# Mark suggestion as implemented in backlog
# -----------------------------
for s in backlog["suggestions"]:
    if s["id"] == suggestion_id:
        s["status"] = "implemented"
        s["pr"] = pr.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

print(f"PR #{pr.number} opened: {pr.html_url}")
print(f"Suggestion '{suggestion_id}' marked as implemented")