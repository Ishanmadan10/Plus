import os, json, re, time, subprocess
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
            print(f"Model {model} failed: {e}")
            time.sleep(1)
        except Exception as e:
            print(f"Unexpected error {model}: {e}")
            time.sleep(1)
    return None

# -----------------------------
# Load backlog
# -----------------------------
with open("backlog.json") as f:
    backlog = json.load(f)

pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

print(f"Pending suggestions: {len(pending)}")

if len(pending) >= 3:
    print("Backlog healthy — no new suggestions needed")
    exit(0)

# -----------------------------
# Priority files to scan
# -----------------------------
priority_files = [
    # App
    "positive/App/ContentView.swift",
    "positive/App/positiveApp.swift",
    # Home
    "positive/Features/Home/Views/HomeView.swift",
    "positive/Features/Home/Views/GreetingView.swift",
    "positive/Features/Home/Components/ContentCards.swift",
    "positive/Features/Home/Components/PillButton.swift",
    # Habits
    "positive/Features/Habits/Views/HabitChecklistView.swift",
    "positive/Features/Habits/Views/TaskListView.swift",
    # Emotion
    "positive/Features/Emotion/Views/EmotionalPage.swift",
    # Section detail views
    "positive/Features/SectionDetail/Views/JournalSectionView.swift",
    "positive/Features/SectionDetail/Views/GymSectionView.swift",
    "positive/Features/SectionDetail/Views/GroceriesSectionView.swift",
    "positive/Features/SectionDetail/Views/SpiritualitySectionView.swift",
    "positive/Features/SectionDetail/Views/WorkSectionView.swift",
    "positive/Features/SectionDetail/Views/GenericSectionView.swift",
    "positive/Features/SectionDetail/Views/SectionDetailView.swift",
    # Shared
    "positive/Shared/Components/BackgroundView.swift",
]

swift_files = []
for path in priority_files:
    if os.path.exists(path):
        with open(path) as f:
            swift_files.append(f"// FILE: {path}\n{f.read()}")
    else:
        print(f"Skipping missing file: {path}")

codebase = "\n\n".join(swift_files)
print(f"Loaded {len(swift_files)} files for analysis")

# -----------------------------
# Load prompt
# -----------------------------
with open("agents/prompts/product_prompt.txt") as f:
    prompt_template = f.read()

prompt = prompt_template + "\n\nCODEBASE:\n" + codebase

# -----------------------------
# Generate suggestions
# -----------------------------
raw = call_gemini(
    prompt,
    types.GenerateContentConfig(
        temperature=0.4,
        max_output_tokens=8192,
    )
)

if raw is None:
    print("Gemini unavailable — using fallback suggestion")
    raw = json.dumps([{
        "id": "fallback_001",
        "title": "Improve empty states across app",
        "what": "Add descriptive empty state views with icons and helpful text wherever lists or content areas can be empty.",
        "why": "Blank screens confuse users and reduce perceived quality of the app.",
        "ui_impact": "Empty state views added to habit list, task list, and emotion log.",
        "backend_impact": "None — purely presentational.",
        "file": "positive/Features/Habits/Views/HabitChecklistView.swift",
        "effort": "small",
        "priority": 2,
        "status": "pending"
    }])

# Strip markdown fences
raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()

# Extract just the JSON array
start = raw.find("[")
end = raw.rfind("]")
if start == -1 or end == -1:
    print("No JSON array found in response")
    print(raw)
    exit(1)

raw = raw[start:end + 1]

# Fix trailing commas before ] or } (common Gemini mistake)
raw = re.sub(r',\s*([\]\}])', r'\1', raw)

try:
    new_suggestions = json.loads(raw)
except Exception as e:
    print(f"JSON parse failed: {e}")
    print(raw)
    exit(1)

# -----------------------------
# Merge into backlog (no duplicates)
# -----------------------------
existing_ids = {s["id"] for s in backlog["suggestions"]}
added = 0

for s in new_suggestions:
    if s.get("id") not in existing_ids:
        s.setdefault("status", "pending")
        s.setdefault("priority", 5)
        s.setdefault("ui_impact", "")
        s.setdefault("backend_impact", "")
        backlog["suggestions"].append(s)
        added += 1

if added == 0:
    print("No new suggestions to add — all already exist in backlog")
    exit(0)

print(f"Generated {added} new suggestions")

# -----------------------------
# Write updated backlog locally
# -----------------------------
with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

# -----------------------------
# Raise a PR with the updated backlog
# -----------------------------
branch = f"agent/backlog-update-{int(time.time())}"

subprocess.run(["git", "config", "user.email", "agent@users.noreply.github.com"], check=True)
subprocess.run(["git", "config", "user.name", "Code Agent"], check=True)
subprocess.run(["git", "checkout", "-b", branch], check=True)
subprocess.run(["git", "add", "backlog.json"], check=True)

diff_check = subprocess.run(["git", "diff", "--cached", "--quiet"], check=False)
if diff_check.returncode == 0:
    print("No changes to backlog.json — skipping PR")
    exit(0)

subprocess.run(["git", "commit", "-m", "chore: add new product suggestions to backlog"], check=True)
subprocess.run(["git", "push", "origin", branch], check=True)

# Build PR body listing all new suggestions
suggestion_lines = "\n".join(
    f"- **[P{s.get('priority', '?')}] {s.get('title', s.get('id'))}** — {s.get('what', '')}"
    for s in new_suggestions
    if s.get("id") not in existing_ids or True
)

pr_body = f"""## Product Agent — Backlog Update

The product agent analyzed the codebase and generated **{added} new suggestions**.

Review the suggestions below, then merge this PR so the code agent can start implementing them.

---

### New Suggestions

{suggestion_lines}

---

> After merging, trigger the code agent to implement the highest priority item.
"""

pr = repo.create_pull(
    title=f"[Product Agent] {added} new suggestions added to backlog",
    body=pr_body,
    head=branch,
    base="main"
)

print(f"PR #{pr.number} opened: {pr.html_url}")
print(f"Review and merge to add suggestions to backlog")