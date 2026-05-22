import os, json, re, subprocess, time
from google import genai
from google.genai import types
from google.genai.errors import ClientError
from github import Github, Auth

# -----------------------------
# ENV / GITHUB SETUP
# -----------------------------
REPO = os.environ["GITHUB_REPOSITORY"]
ISSUE_NUMBER = int(os.environ["ISSUE_NUMBER"])
ISSUE_BODY = os.environ["ISSUE_BODY"]

gh = Github(auth=Auth.Token(os.environ["GITHUB_TOKEN"]))
repo = gh.get_repo(REPO)

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

MODELS = [
    "gemini-2.5-flash",
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
suggestion_id = match.group(1).strip() if match else f"issue-{ISSUE_NUMBER}"

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
                except:
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

decision = json.loads(decision_raw)

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

raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()

try:
    result = json.loads(raw)
except:
    print("JSON parse failed")
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
        print(f"Skipping: {file_path}")
        continue

    os.makedirs(os.path.dirname(file_path), exist_ok=True)

    with open(file_path, "w") as f:
        f.write(change["content"])

print(f"Written {len(result['changes'])} files")

# -----------------------------
# GIT OPS
# -----------------------------
branch = f"agent/{suggestion_id}"

subprocess.run(["git", "config", "user.email", "agent@users.noreply.github.com"])
subprocess.run(["git", "config", "user.name", "Code Agent"])

subprocess.run(["git", "checkout", "-b", branch], check=True)
subprocess.run(["git", "add", "-A"], check=True)
subprocess.run(["git", "commit", "-m", f"feat: {result['summary']}"], check=True)
subprocess.run(["git", "push", "origin", branch], check=True)

# -----------------------------
# PR
# -----------------------------
pr = repo.create_pull(
    title=result["summary"],
    body=f"Closes #{ISSUE_NUMBER}\n\n{result['description']}",
    head=branch,
    base="main"
)

# -----------------------------
# BACKLOG UPDATE
# -----------------------------
with open("backlog.json") as f:
    backlog = json.load(f)

for s in backlog["suggestions"]:
    if s["id"] == suggestion_id:
        s["status"] = "implemented"
        s["pr"] = pr.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

print(f"PR #{pr.number} opened: {pr.html_url}")