import os, json, re, time
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
    # Section detail views (journal, gym, groceries, spirituality, work)
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

codebase = "\n\n".join(swift_files)

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
        max_output_tokens=4096,
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
        "file": "positive/positive/Features/Habits/Views/HabitChecklistView.swift",
        "effort": "small",
        "priority": 2,
        "status": "pending"
    }])

raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()

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
        # Ensure required fields exist
        s.setdefault("status", "pending")
        s.setdefault("priority", 5)
        s.setdefault("ui_impact", "")
        s.setdefault("backend_impact", "")
        backlog["suggestions"].append(s)
        added += 1

with open("backlog.json", "w") as f:
    json.dump(backlog, f, indent=2)

print(f"Added {added} new suggestions to backlog")