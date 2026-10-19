# Project Summary

## Overall Goal
Redesign the main (home) screen of the "Питомец Финни" (Finny Pet) Flutter app to a new HUD v2 layout: a 70%-enlarged pet in the center with 6 orbiting action buttons around it, then build a release APK for on-device verification.

## Key Knowledge

**Project:** `/Users/alexander/Calculator` — Flutter app, package name `finny_pet`. Child financial-literacy virtual pet app (7–11 y.o., offline, RuStore, no real money/accounts).

**Architecture:** Feature-first, 4 layers (game economy / educational content / data storage / UI). State: BLoC/Cubit, storage: Hive, navigation: go_router (StatefulShellRoute with persistent NavigationBar, 7 tabs), models: freezed + json_serializable (Hive typeId 0 for PlayerProfile).

**Theme:** `lib/app/theme.dart` — "Funny Ugly Monster" (FUM) palette. HUD colors: `hudBg #FFF9ED`, `hudRingCenter #FFEFA5`, `hudRingEdge #FFE58F`, `hudGreen #4CCB7B`, `hudOrange #F59E0B`, `hudBlue #4F95FF`, `hudBadgeBg #E0F7FA`. FUM building blocks in `lib/widgets/fum.dart` (`FumCard`, `FumTag`, `FumPetCircle`, etc.).

**Reestyle guardrail (critical):** The 12-test suite is the only guardrail and couples to UI via exact Russian strings and widget types. When restyling, change decorations only; preserve exact Russian text strings and widget types tests find (e.g., `FumPetCircle` as the pet avatar, `FeedbackCard`, season `Dialog`).

**Key models/services:**
- `PlayerProfile` (Hive): balance, savings, currentPeriod (1–5), petStage (1–3), petHunger/petFun/petCleanliness (0–100), goalName/goalTarget, activeTaskTitle/Reward/Completed, growthScore. `startingBalance = 200`.
- `PetCharacter` enum: 4 characters (gapTooth, oogahBoogah, wideEyedWeirdo, reeko), each with `svgAssetForStage(stage)` → `assets/characters/{prefix}_l{stage}.svg`.
- `GameEngine` (singleton): `grantDailyBonus` (+10), `purchase` (with `effectOnPet` string like "Сытость +15"), `depositToSavings`, `withdrawFromSavings`, `startNewPeriod`, `evaluatePeriod`.
- `StorageService().activeProfile` — current profile.

**Build/test commands:**
- `flutter analyze lib/features/home/home_screen.dart`
- `flutter test` (12 tests, all passing)
- `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` (~53 MB)

**Reference files in project root:** `HUD.html` (old layout), `HUD2.html` (new layout — the design target), `HUD.md`, `Design.md`, `LevelsFUM.md`, `characters_level.html`, `items.md`, `tsak.md` (task examples), `QWEN.md` (dev rules).

## Recent Actions

1. **Created `HUD2.html`** — new HTML mockup: pet enlarged 70% (110px→170px), 6 orbiting buttons (balance top-left, tasks top-right, period right, play bottom-right, feed bottom-left, wash left), simplified header, 7-tab bottom nav.

2. **Rewrote `lib/features/home/home_screen.dart`** to match HUD2:
   - Pet: 132px → **224px** (`FumPetCircle`), centered, with breathing animation (0.98–1.02) and name badge below.
   - Removed old profile bar, metric cards, state row, progress card, goal card.
   - Added 6 orbiting buttons via `_buildOrbitButton` + `_OrbitPos` enum with Dart 3 records for Positioned values.
   - Button actions: 💰→`/budget`, 📝→`/tasks` (with red badge), 📅→`/progress`, 🍎 feed (−10, Сытость+15), 🎮 play (−10, Веселье+15), 🫧 wash (−10, Чистота+15). Insufficient funds → explanatory SnackBar.
   - Header simplified to Row: greeting + stage badge + help button.
   - Fixed analyzer errors (removed invalid extension on private enum, inlined switch for positions).

3. **Verification:** `flutter analyze` clean, all 12 tests pass, release APK built successfully (53.0 MB).

## Current Plan

1. [DONE] Create HUD2.html mockup with enlarged pet + orbiting buttons
2. [DONE] Rewrite home_screen.dart to match HUD2 design
3. [DONE] Pass analyzer + all 12 tests
4. [DONE] Build release APK
5. [IN PROGRESS] User is verifying the new APK on a physical device
6. [TODO] Await user feedback on the new home screen layout (button positions, sizes, colors may need tuning)

**Note:** The bottom NavigationBar (7 tabs) lives in `MainShell` in `lib/app/routes.dart` and was intentionally left unchanged. If the user wants orbiting buttons to replace bottom-nav tabs, that's a separate change.

---

## Summary Metadata
**Update time**: 2026-10-19T17:54:34.750Z
