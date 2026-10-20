# Project Summary

## Overall Goal
Redesign the main (home) screen of the "Питомец Финни" (Finny Pet) Flutter app to a new HUD v2 layout — a 70%-enlarged pet in the center with 6 orbiting action buttons around it — add per-character pet animations, fix data consistency, and build release APKs for on-device verification.

## Key Knowledge

**Project:** `/Users/alexander/Calculator` — Flutter app, package name `finny_pet`. Child financial-literacy virtual pet app (7–11 y.o., offline, RuStore, no real money/accounts). Distinct from the user's separate InvestCoach project.

**Architecture:** Feature-first, 4 layers (game economy / educational content / data storage / UI). State: BLoC/Cubit, storage: Hive, navigation: go_router (StatefulShellRoute with persistent NavigationBar, 7 tabs), models: freezed + json_serializable (Hive typeId 0 for PlayerProfile).

**Theme:** `lib/app/theme.dart` — "Funny Ugly Monster" (FUM) palette. HUD colors: `hudBg #FFF9ED`, `hudRingCenter #FFEFA5`, `hudRingEdge #FFE58F`, `hudGreen #4CCB7B`, `hudOrange #F59E0B`, `hudBlue #4F95FF`, `hudBadgeBg #E0F7FA`. FUM building blocks in `lib/widgets/fum.dart` (`FumCard`, `FumTag`, `FumProgress`, `FumPetCircle`, etc.).

**Reestyle guardrail (critical):** The 12-test suite is the only guardrail and couples to UI via exact Russian strings and widget types. When restyling, change decorations only; preserve exact Russian text strings and widget types tests find (e.g., `FumPetCircle` as the pet avatar, `FeedbackCard`, season `Dialog`). Note: this project has 12 tests (not 122 — that count belongs to the separate `financial_pet` project in the guardrail memory).

**Key models/services:**
- `PlayerProfile` (Hive): balance, savings, currentPeriod (1–5), petStage (1–3), petHunger/petFun/petCleanliness (0–100), goalName/goalTarget, activeTaskTitle/Reward/Completed, growthScore. `startingBalance = 200`.
- `PetCharacter` enum: 4 characters (gapTooth, oogahBoogah, wideEyedWeirdo, reeko), each with `svgAssetForStage(stage)` → `assets/characters/{prefix}_l{stage}.svg`.
- `GameEngine` (singleton): `grantDailyBonus` (+10), `purchase` (with `effectOnPet` string like "Сытость +15"), `depositToSavings`, `withdrawFromSavings`, `startNewPeriod`, `evaluatePeriod`.
- `StorageService().activeProfile` — current profile.

**Build/test commands:**
- `flutter analyze <file>`
- `flutter test` (12 tests, all passing)
- `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` (~53 MB)

**Reference files in project root:** `HUD.html` (old layout), `HUD2.html` (new layout — the design target), `HUD.md`, `Design.md`, `LevelsFUM.md` (per-character animation/behavior specs), `characters_level.html`, `items.md`, `tsak.md` (task examples), `QWEN.md` (dev rules).

**Flutter gotchas learned:**
- `math.abs` (from `dart:math as math`) failed to resolve in analyzer even though `math.sin`/`math.cos` worked — replaced with equivalent `(1 - cos(phase)) / 2` formula.
- An `AnimationController` read in `build` does NOT trigger per-frame rebuilds unless the widget subscribes (via `AnimatedBuilder`/`AnimatedWidget`). Reading `_controller.value` directly only re-renders when the parent calls `setState`.

## Recent Actions

1. **Created `HUD2.html`** — new HTML mockup: pet enlarged 70% (110px→170px), 6 orbiting buttons, simplified header, 7-tab bottom nav.

2. **Rewrote `lib/features/home/home_screen.dart`** to match HUD2: pet 132px→224px centered, 6 orbiting buttons, simplified header (greeting + stage badge + help).

3. **Fixed button overlap** — replaced fixed corner positions with a true circular layout: `LayoutBuilder` + trigonometry (`cx + R·cos(θ)`, `cy + R·sin(θ)`, 60° steps, start at top). Radius = `clamp(156, maxRadius)` so buttons never overlap or leave screen.

4. **Fixed wallet/budget mismatch** — budget "Доступно" was `balance + totalAllocated` with `.clamp(30, 999)` (double-counting + artificial clamping). Changed `_budget` getter to just `_profile.balance` so home wallet and budget show the same number.

5. **Created `lib/widgets/animated_pet.dart`** (`AnimatedPet` widget) — per-character Level 1 (Малыш) animations from LevelsFUM.md:
   - GapTooth — bounces in place (vertical jump + squash-stretch, 900ms)
   - Oogah — spins in place (energetic ±40° rotation, 1600ms)
   - Weirdo — slowly sways head (gentle ±8°, 2600ms)
   - Reeko — shifts foot to foot (horizontal shift + slight tilt, 1400ms)
   - Other stages — base "breathing" (scale pulse 0.98–1.02)
   - Uses built-in Flutter transforms (no Lottie), offline. `SvgPicture` preserved inside `FumPetCircle`.

6. **Fixed animation not playing continuously** — wrapped the animated part in `AnimatedBuilder(animation: _controller, ...)` so the pet re-renders every frame and animates on its own, not only on parent `setState` (button tap).

7. **Added press-scale animation to orbit buttons** — converted buttons to StatefulWidget `_OrbitButton` with `AnimatedScale`: scales to 1.2 (+20%) on `onTapDown`, back to 1.0 on `onTapUp`/`onTapCancel`, 120ms easeOut.

**Verification after each change:** `flutter analyze` clean, all 12 tests pass, release APK rebuilt (53 MB).

## Current Plan

1. [DONE] Create HUD2.html mockup with enlarged pet + orbiting buttons
2. [DONE] Rewrite home_screen.dart to match HUD2 design
3. [DONE] Circular orbit layout (no overlap)
4. [DONE] Fix wallet/budget balance consistency
5. [DONE] Per-character Level 1 pet animations (continuous, via AnimatedBuilder)
6. [DONE] Press-scale (+20%) animation on orbit buttons
7. [IN PROGRESS] User verifying latest APK on physical device
8. [TODO] Await user feedback (button positions/sizes/colors, animation feel)
9. [TODO] Possibly add Level 2 and Level 3 pet animations (currently only Level 1 has per-character behavior; others use base breathing)

**Note:** The bottom NavigationBar (7 tabs) lives in `MainShell` in `lib/app/routes.dart` and was intentionally left unchanged. If the user wants orbiting buttons to replace bottom-nav tabs, that's a separate change.

---

## Summary Metadata
**Update time**: 2026-10-20T09:35:55.886Z
