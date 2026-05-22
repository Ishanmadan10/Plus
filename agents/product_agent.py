import os, json, re
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

# -----------------------------
# Load backlog
# -----------------------------
with open("backlog.json") as f:
    backlog = json.load(f)

pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

# -----------------------------
# Priority generation block
# -----------------------------
def call_gemini(prompt: str) -> str:
    """
    Gemini-only fallback chain:
    1. gemini-2.5-flash
    2. gemini-2.5-flash-lite
    3. safe fallback JSON
    """

    MODELS = [
        "gemini-2.5-flash",
        "gemini-2.5-flash-lite",
    ]

    last_error = None

    for model in MODELS:
        try:
            print(f"Trying model: {model}")

            response = client.models.generate_content(
                model=model,
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.4,
                    max_output_tokens=8192,
                )
            )

            if response and response.text:
                return response.text

        except ClientError as e:
            print(f"[{model} failed] {e}")
            last_error = e
            continue

    # Final safe fallback (no API dependency)
    print("All Gemini models failed. Using static fallback.")

    return json.dumps({
        "summary": "Fallback suggestion",
        "description": "Gemini unavailable due to quota/rate limits.",
        "changes": []
    })


# -----------------------------
# Generate suggestions if needed
# -----------------------------
if len(pending) < 3:
    priority_files = [
        "positive/positive/App/ContentView.swift",
        "positive/positive/Features/Home/Views/HomeView.swift",
        "positive/positive/Features/Home/Views/GreetingView.swift",
        "positive/positive/Features/Home/Components/ContentCards.swift",
        "positive/positive/Features/Home/Components/PillButton.swift",
        "positive/positive/Features/Habits/Views/HabitChecklistView.swift",
        "positive/positive/Features/Habits/Views/TaskListView.swift",
        "positive/positive/Features/Emotion/Views/EmotionalPage.swift",
        "positive/positive/Features/SectionDetail/Views/GenericSectionView.swift",
        "positive/positive/Features/SectionDetail/Views/JournalSectionView.swift",
        "positive/positive/Features/SectionDetail/Views/GymSectionView.swift",
        "positive/positive/Shared/Components/BackgroundView.swift",
    ]

    swift_files = []
    seen = set()

    for path in priority_files:
        if path and os.path.exists(path) and path not in seen:
            seen.add(path)
            with open(path) as f:
                swift_files.append(f"// FILE: {path}\n{f.read()}")

    codebase = "\n\n".join(swift_files)

    with open("agents/prompts/product_prompt.txt") as f:
        prompt = f.read()

    full_prompt = prompt + "\n\n" + codebase

    raw = call_gemini(full_prompt).strip()

    # -----------------------------
    # Safe JSON parsing
    # -----------------------------
    try:
        raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()
        new_suggestions = json.loads(raw)
    except Exception as e:
        print(f"JSON parse failed: {e}")
        new_suggestions = []

    # -----------------------------
    # Merge suggestions
    # -----------------------------
    existing_ids = {s["id"] for s in backlog["suggestions"]}

    for s in new_suggestions:
        if s.get("id") not in existing_ids:
            backlog["suggestions"].append(s)

    with open("backlog.json", "w") as f:
        json.dump(backlog, f, indent=2)

    pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

# -----------------------------
# Exit if nothing to do
# -----------------------------
if not pending:
    print("Backlog empty.")
    exit(0)

# -----------------------------
# Pick today's suggestion
# -----------------------------
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

# -----------------------------
# Create GitHub issue
# -----------------------------
issue = repo.create_issue(
    title=f"💡 {today['what']}",
    body=body,
    labels=["agent-suggestion"]
)

# -----------------------------
# Update backlog status
# -----------------------------
for s in backlog["suggestions"]:
    if s["id"] == today["id"]:
        s["status"] = "suggested"
        s["issue"] = issue.number

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

# -----------------------------
# Commit backlog update
# -----------------------------
os.system('git config user.email "agent@users.noreply.github.com"')
os.system('git config user.name "Product Agent"')
os.system('git add backlog.json')
os.system('git commit -m "chore: update backlog after daily suggestion"')
os.system('git push origin main')

print(f"Issue #{issue.number} opened.")