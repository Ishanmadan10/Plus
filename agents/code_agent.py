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

ISSUE_BODY = os.environ.get("ISSUE_BODY", "").strip()

if not ISSUE_BODY:
    ISSUE_BODY = """
Perform one meaningful improvement to the iOS app.

Priority order:
1. Fix compile/runtime issues
2. Reduce duplicated code
3. Improve architecture
4. Improve SwiftUI performance
5. Improve accessibility
6. Improve maintainability

Do not make cosmetic-only changes.
Do not rewrite the whole app.
Return only high-impact improvements.
"""

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

            if not response.text:
                continue

            return response.text.strip()

        except ClientError as e:
            print(f"Model {model} failed: {e}")
            time.sleep(1)

        except Exception as e:
            print(f"Unexpected error {model}: {e}")
            time.sleep(1)

    return None

# -----------------------------
# SAFE JSON PARSER
# -----------------------------
# -----------------------------
# SAFE JSON PARSER
# -----------------------------
def parse_json_response(raw_text: str):

    if not raw_text:
        raise ValueError("Empty response")

    # remove markdown fences
    cleaned = raw_text.replace("```json", "")
    cleaned = cleaned.replace("```", "")
    cleaned = cleaned.strip()

    # find first {
    start = cleaned.find("{")

    # find last }
    end = cleaned.rfind("}")

    if start == -1 or end == -1:
        raise ValueError("No JSON object found")

    json_str = cleaned[start:end + 1]

    return json.loads(json_str)
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

        # skip junk folders
        if any(skip in root for skip in [
            ".git",
            "Pods",
            "build",
            ".build",
            "DerivedData"
        ]):
            continue

        for file in files:
            if file.endswith(".swift"):
                path = os.path.join(root, file)

                try:
                    with open(path, "r", encoding="utf-8") as f:
                        repo_map[path] = f.read()
                except Exception:
                    continue

    return repo_map

repo_map = load_repo()

# YES:
# this scans ALL swift files recursively
# across the whole repository

codebase = "\n\n".join(
    f"// FILE: {path}\n{content}"
    for path, content in repo_map.items()
)

# lightweight architectural summary
repo_summary = "\n".join(
    f"{path} | {len(content.splitlines())} lines"
    for path, content in repo_map.items()
)

ALLOWED_FILES = set(repo_map.keys())

print(f"Loaded {len(repo_map)} Swift files")

# -----------------------------
# DECISION STEP
# -----------------------------
decision_prompt = f"""
You are a senior iOS architect.

Decide whether this feature request should be implemented.

You are given the repository structure
to understand the architecture.

Return ONLY valid JSON.

Format:
{{
  "should_change": true,
  "reason": "short reason"
}}

FEATURE REQUEST:
{ISSUE_BODY}

REPOSITORY STRUCTURE:
{repo_summary}
"""

decision_raw = call_gemini(
    decision_prompt,
    types.GenerateContentConfig(
        temperature=0.1,
        max_output_tokens=256,
        response_mime_type="application/json",
    )
)

if decision_raw is None:
    print("Decision fallback triggered")
    exit(0)

try:
    decision = parse_json_response(decision_raw)
except Exception as e:
    print("Decision JSON parse failed")
    print(decision_raw)
    print(e)
    exit(1)

print("Decision:", decision)

if not decision.get("should_change", False):
    print("No change required")
    exit(0)

# -----------------------------
# LOAD CODE PROMPT
# -----------------------------
with open("agents/prompts/code_prompt.txt", "r", encoding="utf-8") as f:
    base_prompt = f.read()

prompt = base_prompt.replace("{{SUGGESTION}}", ISSUE_BODY)

# -----------------------------
# MAIN GENERATION
# -----------------------------
generation_prompt = f"""
{prompt}

FULL CODEBASE:
{codebase}
"""

raw = call_gemini(
    generation_prompt,
    types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=8192,
        response_mime_type="application/json",
    )
)

if raw is None:
    raw = json.dumps({
        "summary": "no-op fallback",
        "description": "AI unavailable",
        "changes": []
    })

try:
    result = parse_json_response(raw)
except Exception as e:
    print("JSON parse failed")
    print(raw)
    print(e)
    exit(1)

if not result.get("changes"):
    print("No changes")
    exit(0)

# -----------------------------
# APPLY CHANGES SAFELY
# -----------------------------
written_files = 0

for change in result["changes"]:

    file_path = change.get("file")
    content = change.get("content")

    if not file_path or content is None:
        print("Skipping malformed change")
        continue

    # safety restriction
    if file_path not in ALLOWED_FILES:
        print(f"Skipping unauthorized file: {file_path}")
        continue

    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

    written_files += 1
    print(f"Updated: {file_path}")

print(f"Written {written_files} files")

if written_files == 0:
    print("No valid file changes")
    exit(0)

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

commit_message = result.get(
    "summary",
    "AI generated changes"
)

subprocess.run(
    ["git", "commit", "-m", f"feat: {commit_message}"],
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
    f"Closes #{ISSUE_NUMBER}\n\n{result.get('description', '')}"
    if ISSUE_NUMBER
    else result.get("description", "")
)

pr = repo.create_pull(
    title=result.get("summary", "AI Generated Update"),
    body=pr_body,
    head=branch,
    base="main"
)

# -----------------------------
# BACKLOG UPDATE
# -----------------------------
if os.path.exists("backlog.json"):

    try:
        with open("backlog.json", "r", encoding="utf-8") as f:
            backlog = json.load(f)

        for s in backlog.get("suggestions", []):

            if s.get("id") == suggestion_id:
                s["status"] = "implemented"
                s["pr"] = pr.number

        with open("backlog.json", "w", encoding="utf-8") as f:
            json.dump(backlog, f, indent=2)

    except Exception as e:
        print("Failed to update backlog.json")
        print(e)

print(f"PR #{pr.number} opened: {pr.html_url}")