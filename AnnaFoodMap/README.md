# Anna Food Map — Native macOS & iOS App

A SwiftUI rewrite of the Low FODMAP guide, sharing one codebase across a
native macOS app (sidebar navigation) and an iOS app (tab bar navigation,
targeting iOS 26.5). Data is persisted with SwiftData; phase progress uses
`@AppStorage`.

## One-time setup (on your Mac)

You need Xcode 26+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
installed:

```bash
brew install xcodegen
```

## Generate and open the Xcode project

From this directory (`AnnaFoodMap/`):

```bash
xcodegen generate
open AnnaFoodMap.xcworkspace 2>/dev/null || open AnnaFoodMap.xcodeproj
```

This reads `project.yml` and produces `AnnaFoodMap.xcodeproj` with two
targets:

- **AnnaFoodMap-macOS** — native Mac app, deployment target macOS 26.0
- **AnnaFoodMap-iOS** — native iOS app, deployment target iOS 26.5

The generated `.xcodeproj` is not committed to git (see `.gitignore`) —
regenerate it any time the project structure changes by re-running
`xcodegen generate`.

## Build & run

1. In Xcode, pick the **AnnaFoodMap-macOS** or **AnnaFoodMap-iOS** scheme
   from the scheme selector.
2. Select a run destination (your Mac, or an iOS Simulator / device).
3. Go to the target's **Signing & Capabilities** tab and choose your
   Apple ID / Team — `project.yml` leaves `DEVELOPMENT_TEAM` blank since
   that's personal to your Apple account.
4. Press **⌘R**.

## Project layout

```
AnnaFoodMap/
  project.yml              XcodeGen spec — defines both app targets
  Sources/
    AnnaFoodMapApp.swift    App entry point + SwiftData container
    Models/                 Food, DiaryEntry, ReintroTest, Phase
    Data/
      FoodDatabase.swift    77 foods across 5 categories
    Theme/
      Theme.swift           Shared green/white color palette
    Views/
      RootView.swift        Platform-adaptive navigation shell
      FoodsView.swift        Food traffic light search + detail sheet
      PhaseView.swift        Elimination/Reintroduction/Personalization tracker
      DiaryView.swift        Symptom & food diary (SwiftData)
      ReintroView.swift      Reintroduction challenge tracker (SwiftData)
      ReferenceView.swift    Safe foods quick reference by category
  Resources/
    Assets.xcassets/         Accent color + app icon placeholder
```

Both targets compile the same `Sources/` folder; platform differences
(sidebar vs. tab bar, window sizing, etc.) are handled with `#if os(...)`
in `RootView.swift` and a few sheet-sizing tweaks.

## Notes

- **App icon**: `Resources/Assets.xcassets/AppIcon.appiconset` ships with
  the slot defined (universal 1024×1024 for both platforms) but no image
  — drop a 1024×1024 PNG into Xcode's asset editor to set it.
- **SwiftData storage**: diary entries and reintroduction tests persist
  on-device automatically; no setup needed. Each platform target has its
  own local store (data does not sync between Mac and iPhone unless you
  add CloudKit sync later).
- **Re-running XcodeGen**: safe to re-run anytime; it regenerates the
  `.xcodeproj` from `project.yml` without touching your source files.
