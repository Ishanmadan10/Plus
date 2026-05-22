import os, json, re
import google.generativeai as genai
from github import Github

REPO = os.environ["GITHUB_REPOSITORY"]
gh = Github(os.environ["GITHUB_TOKEN"])
repo = gh.get_repo(REPO)

genai.configure(api_key=os.environ["GEMINI_API_KEY"])
model = genai.GenerativeModel("gemini-1.5-pro")

with open("backlog.json") as f:
    backlog = json.load(f)

pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

if len(pending) < 3:
    priority_files = [
        "positive/App/ContentView.swift",
        "positive/Features/Home/Views/HomeView.swift",
        "positive/Features/Home/Views/GreetingView.swift",
        "positive/Features/Home/Components/ContentCards.swift",
        "positive/Features/Home/Components/PillButton.swift",
        "positive/Features/Habits/Views/HabitChecklistView.swift",
        "positive/Features/Habits/Views/TaskListView.swift",
        "positive/Features/Emotion/Views/EmotionalPage.swift",
        "positive/Features/SectionDetail/Views/GenericSectionView.swift",
        "positive/Features/SectionDetail/Views/JournalSectionView.swift",
        "positive/Features/SectionDetail/Views/GymSectionView.swift",
        "positive/Shared/Components/BackgroundView.swift",
    ]

    swift_files = []
    for path in priority_files:
        if os.path.exists(path):
            with open(path) as f:
                swift_files.append(f"// FILE: {path}\n{f.read()}")

    codebase = "\n\n".join(swift_files)

    with open("agents/prompts/product_prompt.txt") as f:
        prompt = f.read()

    response = model.generate_content(
        prompt + "\n\n" + codebase,
        generation_config=genai.GenerationConfig(
            temperature=0.4,
            max_output_tokens=2048,
        )
    )

    raw = response.text.strip()
    raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()
    new_suggestions = json.loads(raw)

    existing_ids = {s["id"] for s in backlog["suggestions"]}
    for s in new_suggestions:
        if s["id"] not in existing_ids:
            backlog["suggestions"].append(s)

    with open("backlog.json", "w") as f:
        json.dump(backlog, f, indent=2)

    pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

if not pending:
    print("Backlog empty.")
    exit(0)

today = pending[0]

body = f"""## Today's suggestion from the Product Agent

**What:** {today['what']}

**Why:** {today['why']}

**File to change:** `{today['file']}`

**Effort:** {today['effort']}

---

Add the `approved` label to implement this. Close the issue to skip it.

<!-- suggestion_id: {today['id']} -->
"""

issue = repo.create_issue(
    title=f"💡 {today['what']}",
    body=body,
    labels=["agent-suggestion"]
)

for s in backlog["suggestions"]:
    if s["id"] == today["id"]:
        s["status"] = "suggested"
        s["issue"] = issue.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

# Commit updated backlog back to repo
os.system('git config user.email "agent@users.noreply.github.com"')
os.system('git config user.name "Product Agent"')
os.system('git add backlog.json')
os.system('git commit -m "chore: update backlog after daily suggestion"')
os.system('git push origin main')

print(f"Issue #{issue.number} opened.")
