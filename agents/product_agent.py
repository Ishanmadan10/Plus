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
# Load backlog
# -----------------------------
with open("backlog.json") as f:
    backlog = json.load(f)

pending = [s for s in backlog["suggestions"] if s["status"] == "pending"]

needs_more = len(pending) < 3

# -----------------------------
# PRIORITY FILES
# -----------------------------
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
    "positive/positive/Shared/Components/BackgroundView.swift",
]

swift_files = []
for path in priority_files:
    if os.path.exists(path):
        with open(path) as f:
            swift_files.append(f"// FILE: {path}\n{f.read()}")

codebase = "\n\n".join(swift_files)

# -----------------------------
# LOAD PROMPT
# -----------------------------
with open("agents/prompts/product_prompt.txt") as f:
    prompt_template = f.read()

prompt = prompt_template + "\n\nCODEBASE:\n" + codebase

# -----------------------------
# GENERATE
# -----------------------------
if needs_more:
    raw = call_gemini(
        prompt,
        types.GenerateContentConfig(
            temperature=0.4,
            max_output_tokens=4096,
        )
    )

    if raw is None:
        raw = json.dumps([
            {
                "id": "fallback_001",
                "what": "Improve empty states across app",
                "why": "Avoids blank screens and improves UX clarity",
                "file": "positive/positive/App/ContentView.swift",
                "effort": "small",
                "status": "pending"
            }
        ])

    raw = re.sub(r'^```json|^```|```$', '', raw, flags=re.MULTILINE).strip()

    try:
        new_suggestions = json.loads(raw)
    except:
        new_suggestions = []

    existing_ids = {s["id"] for s in backlog["suggestions"]}

    for s in new_suggestions:
        if s.get("id") not in existing_ids:
            backlog["suggestions"].append(s)

    with open("backlog.json", "w") as f:
        json.dump(backlog, f, indent=2)

    print(f"Added {len(new_suggestions)} suggestions")

else:
    print("Backlog healthy — no new suggestions")
    exit(0)