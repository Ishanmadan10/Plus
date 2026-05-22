import os
import json
import re
import subprocess
import time

from google import genai
from google.genai import types
from google.genai.errors import ClientError
from github import Github, Auth

# -----------------------------
# ENV / GITHUB SETUP
# -----------------------------
REPO = os.environ["GITHUB_REPOSITORY"]

issue_number_raw = os.environ.get("ISSUE_NUMBER", "").strip()
ISSUE_NUMBER = int(issue_number_raw) if issue_number_raw else None

ISSUE_BODY = os.environ.get("ISSUE_BODY", "")

gh = Github(auth=Auth.Token(os.environ["GITHUB_TOKEN"]))
repo = gh.get_repo(REPO)

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

MODELS = [
    "gemini-2.5-flash",
    "gemini-2.5-flash-lite",
]

# -----------------------------
# GEMINI CALL
# -----------------------------
def call_gemini(prompt: str, config):
    for model in MODELS:
        try:
            print(f"Trying model: {model}")

            response = client.models.generate_content(
                model=model,
                contents=prompt,
                config=config
            )

            return response.text.strip()

        except ClientError as e:
            print(f"Model {model} failed: {e}")
            time.sleep(1)

        except Exception as e:
            print(f"Unexpected error {model}: {e}")
            time.sleep(1)

    return None

# -----------------------------
# EXTRACT IDS
# -----------------------------
match = re.search(r'suggestion_id: (.+?) -->', ISSUE_BODY)

suggestion_id = (
    match.group(1).strip()
    if match
    else f"manual-{int(time.time())}"
)

# -----------------------------
# LOAD FULL REPO
# -----------------------------
def load_repo():
    repo_map = {}

    for root, _, files in os.walk("."):
        for file in files:
            if file.endswith(".swift"):
                path = os.path.join(root, file)

                try:
                    with open(path, "r") as f:
                        repo_map[path] = f.read()
                except Exception:
                    continue

    return repo_map

repo_map = load_repo()

codebase = "\n\n".join(
    f"// FILE: {path}\n{content}"
    for path, content in repo_map.items()
)

ALLOWED_FILES = set(repo_map.keys())

# -----------------------------
# DECISION STEP
# -----------------------------
decision_prompt = f"""
You are a senior iOS architect.

Decide whether this change should be implemented.

Return ONLY JSON:
{{
  "should_change": true/false,
  "reason": "string"
}}

SUGGESTION:
{ISSUE_BODY}

CODEBASE:
{codebase}
"""

decision_raw = call_gemini(
    decision_prompt,
    types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=1024,
    )
)

if decision_raw is None:
    print("Decision fallback triggered")
    exit(0)

try:
    decision = json.loads(decision_raw)
except Exception:
    print("Decision JSON parse failed")
    exit(1)

print("Decision:", decision)

if not decision.get("should_change", False):
    print("No change required")
    exit(0)

# -----------------------------
# LOAD CODE PROMPT
# -----------------------------
with open("agents/prompts/code_prompt.txt") as f:
    base_prompt = f.read()

prompt = base_prompt.replace("{{SUGGESTION}}", ISSUE_BODY)

# -----------------------------
# MAIN GENERATION
# -----------------------------
raw = call_gemini(
    prompt + "\n\nCODEBASE:\n" + codebase,
    types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=8192,
    )
)

if raw is None:
    raw = json.dumps({
        "summary": "no-op fallback",
        "description": "AI unavailable",
        "changes": []
    })

raw = re.sub(
    r'^```json|^```|```$',
    '',
    raw,
    flags=re.MULTILINE
).strip()

try:
    result = json.loads(raw)
except Exception:
    print("JSON parse failed")
    print(raw)
    exit(1)

if not result.get("changes"):
    print("No changes")
    exit(0)

# -----------------------------
# APPLY CHANGES SAFELY
# -----------------------------
for change in result["changes"]:
    file_path = change["file"]

    if file_path not in ALLOWED_FILES:
        print(f"Skipping unauthorized file: {file_path}")
        continue

    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    with open(file_path, "w") as f:
        f.write(change["content"])

print(f"Written {len(result['changes'])} files")

# -----------------------------
# GIT OPS
# -----------------------------
branch = f"agent/{suggestion_id}"

subprocess.run(
    ["git", "config", "user.email", "agent@users.noreply.github.com"],
    check=True
)

subprocess.run(
    ["git", "config", "user.name", "Code Agent"],
    check=True
)

subprocess.run(
    ["git", "checkout", "-b", branch],
    check=True
)

subprocess.run(
    ["git", "add", "-A"],
    check=True
)

subprocess.run(
    ["git", "commit", "-m", f"feat: {result['summary']}"],
    check=True
)

subprocess.run(
    ["git", "push", "origin", branch],
    check=True
)

# -----------------------------
# PR
# -----------------------------
pr_body = (
    f"Closes #{ISSUE_NUMBER}\n\n{result['description']}"
    if ISSUE_NUMBER
    else result["description"]
)

pr = repo.create_pull(
    title=result["summary"],
    body=pr_body,
    head=branch,
    base="main"
)

# -----------------------------
# BACKLOG UPDATE
# -----------------------------
if os.path.exists("backlog.json"):
    with open("backlog.json") as f:
        backlog = json.load(f)

    for s in backlog.get("suggestions", []):
        if s.get("id") == suggestion_id:
            s["status"] = "implemented"
            s["pr"] = pr.number

    with open("backlog.json", "w") as f:
        json.dump(backlog, f, indent=2)

print(f"PR #{pr.number} opened: {pr.html_url}")