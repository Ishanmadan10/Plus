import os
import json
import re
import subprocess
import time

from openai import OpenAI, RateLimitError, APIError
from github import Github, Auth

# -----------------------------
# ENV / GITHUB SETUP
# -----------------------------
REPO = os.environ["GITHUB_REPOSITORY"]

issue_number_raw = os.environ.get("ISSUE_NUMBER", "").strip()
ISSUE_NUMBER = int(issue_number_raw) if issue_number_raw else None

ISSUE_BODY = os.environ.get("ISSUE_BODY", "").strip()

DEFAULT_BODY = """
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

IS_DEFAULT_BODY = not ISSUE_BODY

if not ISSUE_BODY:
    ISSUE_BODY = DEFAULT_BODY

GITHUB_TOKEN = os.environ["GITHUB_TOKEN"]

gh = Github(auth=Auth.Token(GITHUB_TOKEN))
repo = gh.get_repo(REPO)

# -----------------------------
# GITHUB MODELS CLIENT
# GitHub Models uses the OpenAI SDK pointed at GitHub's endpoint.
# Authentication is your existing GITHUB_TOKEN — no new secrets needed.
# Free limits: 150 req/day for GPT-4o, 15 req/min
# -----------------------------
client = OpenAI(
    base_url="https://models.inference.ai.azure.com",
    api_key=GITHUB_TOKEN,
)

# Model fallback order — all free with GitHub token
MODELS = [
    "gpt-4o",           # strongest, 150 req/day
    "gpt-4o-mini",      # lighter, higher limits
    "meta-llama-3.3-70b-instruct",  # open source fallback
]

# -----------------------------
# MODEL CALL
# -----------------------------
def call_model(prompt: str, max_tokens: int = 8192, json_mode: bool = False) -> str | None:
    for model in MODELS:
        try:
            print(f"Trying model: {model}")

            kwargs = {
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "max_tokens": max_tokens,
                "temperature": 0.2,
            }

            if json_mode:
                kwargs["response_format"] = {"type": "json_object"}

            response = client.chat.completions.create(**kwargs)

            text = response.choices[0].message.content
            if not text:
                print(f"Model {model} returned empty response, trying next")
                continue

            return text.strip()

        except RateLimitError as e:
            print(f"Model {model} rate limited: {e}")
            # Don't sleep and retry same model — move to next
            continue

        except APIError as e:
            print(f"Model {model} API error: {e}")
            time.sleep(1)
            continue

        except Exception as e:
            print(f"Model {model} unexpected error: {e}")
            time.sleep(1)
            continue

    print("All models failed")
    return None

# -----------------------------
# SAFE JSON PARSER
# -----------------------------
def parse_json_response(raw_text: str):
    if not raw_text:
        raise ValueError("Empty response")

    # Remove markdown fences
    cleaned = raw_text.replace("```json", "").replace("```", "").strip()

    # Find outermost JSON object
    start = cleaned.find("{")
    end = cleaned.rfind("}")

    if start == -1 or end == -1:
        raise ValueError("No JSON object found")

    return json.loads(cleaned[start:end + 1])

# -----------------------------
# EXTRACT SUGGESTION ID
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

        if any(skip in root for skip in [
            ".git", "Pods", "build", ".build", "DerivedData"
        ]):
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

# Truncate large files to stay within token limits
MAX_FILE_LINES = 200

codebase = "\n\n".join(
    f"// FILE: {path}\n" + (
        content
        if len(content.splitlines()) <= MAX_FILE_LINES
        else "\n".join(content.splitlines()[:MAX_FILE_LINES]) + "\n// ... truncated (file continues)"
    )
    for path, content in repo_map.items()
)

repo_summary = "\n".join(
    f"{path} | {len(content.splitlines())} lines"
    for path, content in repo_map.items()
)

EXISTING_FILES = set(repo_map.keys())

print(f"Loaded {len(repo_map)} Swift files")

# -----------------------------
# DECISION STEP
# Skip entirely for autonomous runs — we always want an improvement
# -----------------------------
if IS_DEFAULT_BODY:
    print("Autonomous run (no issue body) — skipping decision gate")
else:
    decision_prompt = f"""
You are a senior iOS architect.

Decide whether this feature request or improvement should be implemented.
The codebase is real and in active development.
Err on the side of YES — only return should_change: false if the request
is completely impossible, nonsensical, or dangerous.

Return ONLY valid JSON with no other text.

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

    decision_raw = call_model(decision_prompt, max_tokens=256, json_mode=True)

    if decision_raw is None:
        print("Decision call failed — proceeding anyway")
    else:
        try:
            decision = parse_json_response(decision_raw)
            print("Decision:", decision)

            if not decision.get("should_change", True):
                print("No change required:", decision.get("reason", ""))
                exit(0)

        except Exception as e:
            print(f"Decision JSON parse failed ({e}) — proceeding anyway")

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

raw = call_model(generation_prompt, max_tokens=8192, json_mode=True)

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
# APPLY CHANGES SAFELY
# -----------------------------
written_files = 0

for change in result["changes"]:

    file_path = change.get("file")
    content = change.get("content")

    if not file_path or content is None:
        print("Skipping malformed change (missing file or content)")
        continue

    # Normalize path separators
    file_path = os.path.normpath(file_path)

    # Block path traversal and absolute paths
    if os.path.isabs(file_path) or ".." in file_path.split(os.sep):
        print(f"Skipping dangerous path: {file_path}")
        continue

    # Swift files only
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
    print(f"Updated: {file_path}")

print(f"Written {written_files} files")

if written_files == 0:
    print("No valid file changes applied")
    exit(0)

# -----------------------------
# GIT OPS
# -----------------------------
branch = f"agent/{suggestion_id}"

subprocess.run(["git", "config", "user.email", "agent@users.noreply.github.com"], check=True)
subprocess.run(["git", "config", "user.name", "Code Agent"], check=True)
subprocess.run(["git", "checkout", "-b", branch], check=True)
subprocess.run(["git", "add", "-A"], check=True)

commit_message = result.get("summary", "AI generated changes")
subprocess.run(["git", "commit", "-m", f"feat: {commit_message}"], check=True)
subprocess.run(["git", "push", "origin", branch], check=True)

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
        print(f"Failed to update backlog.json: {e}")

print(f"PR #{pr.number} opened: {pr.html_url}")