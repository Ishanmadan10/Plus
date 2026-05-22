import os, json, re, subprocess
from google import genai
from google.genai import types
from github import Github, Auth

REPO = os.environ["GITHUB_REPOSITORY"]
ISSUE_NUMBER = int(os.environ["ISSUE_NUMBER"])
ISSUE_BODY = os.environ["ISSUE_BODY"]

gh = Github(auth=Auth.Token(os.environ["GITHUB_TOKEN"]))
repo = gh.get_repo(REPO)

client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])

match = re.search(r'suggestion_id: (.+?) -->', ISSUE_BODY)
suggestion_id = match.group(1).strip() if match else f"issue-{ISSUE_NUMBER}"

file_match = re.search(r'\*\*File to change:\*\* `(.+?)`', ISSUE_BODY)
target_file = file_match.group(1) if file_match else None

swift_files = []
priority = [target_file] if target_file else []

context_files = [
    "positive/positive/App/ContentView.swift",
    "positive/positive/Features/Home/Views/HomeView.swift",
    "positive/positive/Shared/Components/BackgroundView.swift",
]

seen = set()
for path in priority + context_files:
    if path and os.path.exists(path) and path not in seen:
        seen.add(path)
        with open(path) as f:
            swift_files.append(f"// FILE: {path}\n{f.read()}")

codebase = "\n\n".join(swift_files)

with open("agents/prompts/code_prompt.txt") as f:
    prompt = f.read()

prompt = prompt.replace("{{SUGGESTION}}", ISSUE_BODY).replace("{{CODEBASE}}", codebase)

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=prompt,
    config=types.GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=8192,
    )
)

raw = response.text.strip()
raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()
result = json.loads(raw)

for change in result["changes"]:
    os.makedirs(os.path.dirname(change["file"]), exist_ok=True)
    with open(change["file"], "w") as f:
        f.write(change["content"])

print(f"Written {len(result['changes'])} file(s)")

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

with open("backlog.json") as f:
    backlog = json.load(f)

for s in backlog["suggestions"]:
    if s["id"] == suggestion_id:
        s["status"] = "implemented"
        s["pr"] = pr.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

print(f"PR #{pr.number} opened: {pr.html_url}")