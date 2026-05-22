import os, json, re, subprocess, anthropic
from github import Github

REPO = os.environ["GITHUB_REPOSITORY"]
ISSUE_NUMBER = int(os.environ["ISSUE_NUMBER"])
ISSUE_BODY = os.environ["ISSUE_BODY"]

gh = Github(os.environ["GITHUB_TOKEN"])
repo = gh.get_repo(REPO)
client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])

match = re.search(r'suggestion_id: (.+?) -->', ISSUE_BODY)
suggestion_id = match.group(1).strip() if match else f"issue-{ISSUE_NUMBER}"

# Read the file mentioned in the issue
file_match = re.search(r'\*\*File to change:\*\* `(.+?)`', ISSUE_BODY)
target_file = file_match.group(1) if file_match else None

swift_files = []
priority = [target_file] if target_file else []

# Always include key context files
context_files = [
    "positive/App/ContentView.swift",
    "positive/Features/Home/Views/HomeView.swift",
    "positive/Shared/Components/BackgroundView.swift",
]

for path in priority + context_files:
    if path and os.path.exists(path) and path not in [f.split("\n")[0].replace("// FILE: ", "") for f in swift_files]:
        with open(path) as f:
            swift_files.append(f"// FILE: {path}\n{f.read()}")

codebase = "\n\n".join(swift_files)

with open("agents/prompts/code_prompt.txt") as f:
    prompt = f.read()

prompt = prompt.replace("{{SUGGESTION}}", ISSUE_BODY).replace("{{CODEBASE}}", codebase)

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1000,
    messages=[{"role": "user", "content": prompt}]
)

raw = response.content[0].text.strip()
raw = re.sub(r'^```json|```$', '', raw, flags=re.MULTILINE).strip()
result = json.loads(raw)

# Write changed files
for change in result["changes"]:
    os.makedirs(os.path.dirname(change["file"]), exist_ok=True)
    with open(change["file"], "w") as f:
        f.write(change["content"])

print(f"Written {len(result['changes'])} file(s)")

# Git — create branch and PR
branch = f"agent/{suggestion_id}"
subprocess.run(["git", "config", "user.email", "agent@users.noreply.github.com"])
subprocess.run(["git", "config", "user.name", "Code Agent"])
subprocess.run(["git", "checkout", "-b", branch], check=True)
subprocess.run(["git", "add", "-A"], check=True)
subprocess.run(["git", "commit", "-m", f"feat: {result['summary']}"], check=True)
subprocess.run(["git", "push", "origin", branch], check=True)

pr = repo.create_pull(
    title=result["summary"],
    body=f"Closes #{ISSUE_NUMBER}\n\n{result['description']}",
    head=branch,
    base="main"
)

# Update backlog status
with open("backlog.json") as f:
    backlog = json.load(f)

for s in backlog["suggestions"]:
    if s["id"] == suggestion_id:
        s["status"] = "implemented"
        s["pr"] = pr.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

print(f"PR #{pr.number} opened: {pr.html_url}")
