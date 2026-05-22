# Positive — iOS App

A calm, positive daily companion app built with **SwiftUI** for iOS.
AIzaSyA3uCPdV1WnTh3Dn7WtJDFVcVnyU_4L3eA

## Project Structure

```
PositiveApp/
├── PositiveApp.swift              # App entry point
├── Extensions/
│   └── Color+Hex.swift            # Hex colour support
├── Models/
│   ├── TimeOfDay.swift            # Time detection + all theming
│   └── DailyContent.swift         # Thoughts, reminders, jokes
├── ViewModels/
│   └── HomeViewModel.swift        # All state + animation phases
└── Views/
    ├── HomeView.swift             # Main screen orchestrator
    └── Components/
        ├── BackgroundView.swift   # Animated time-of-day backgrounds
        ├── GreetingView.swift     # Hero → header transition
        ├── ScratchCardView.swift  # Real canvas scratch interaction
        ├── ContentCards.swift     # Reminder + Joke cards
        ├── PaginationAndHint.swift# Dots + swipe hint
        └── PillButton.swift       # Pill-shaped + → × button
```

## Features

- **Time-aware**: Different background, greeting, and palette for Morning / Afternoon / Evening / Night
- **Animated greeting**: Full-screen hero → shrinks to header after 3.5s
- **Real scratch card**: Canvas-based scratch mechanic, persists state daily via UserDefaults
- **Swipe flow**: Scratch Card → Reminder → Joke with native spring transitions
- **Pill button**: Capsule-shaped with spring rotation from + to ×
- **MVVM**: Clean separation — Views own no business logic

## Setup

1. Open Xcode → **File → New → Project → App**
2. Set:
   - Product Name: `Positive`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Minimum Deployments: `iOS 16`
3. Delete the default `ContentView.swift`
4. Drag all folders (`Models`, `ViewModels`, `Views`, `Extensions`) into the Xcode project navigator
5. Make sure **"Copy items if needed"** is checked
6. `PositiveApp.swift` replaces the default app entry file
7. Run on simulator or device ▶

## Requirements

- Xcode 15+
- iOS 16+ (for Canvas compositingGroup + TabView page style)
- No third-party dependencies

## Next Steps (when ready to build)

- [ ] Add push notifications for daily reminders
- [ ] Backend API to rotate content (instead of local arrays)
- [ ] "Already scratched" check via server date (prevents clock manipulation)
- [ ] Settings screen (notification time, theme preference)
- [ ] Haptic feedback on scratch reveal and pill tap
