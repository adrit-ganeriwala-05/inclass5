# Petchi – Digital Pet App
**Adrit Ganeriwala | aganeriwala1 | 002703111**
MAD – Mobile Application Development | In-Class Activity #5

---

## Overview
Petchi is a Flutter-based digital pet simulation app where users care for a
virtual pet by managing its happiness, hunger, and energy levels through
real-time interactions and a timer-driven game loop. The app demonstrates
core Flutter state management concepts using StatefulWidget, setState(),
and Timer from dart:async.

---

## Features

### Part 1 – Required
- **Dynamic Color Change** – Pet image tinted green/yellow/red based on happiness using `ColorFiltered`
- **Mood Indicator** – Emoji and label (Happy 😄 / Neutral 😐 / Unhappy 😢) displayed beneath the pet
- **Pet Name Customization** – Dedicated onboarding screen to name your pet on first launch
- **Auto-Increasing Hunger** – `Timer.periodic` increases hunger every 30 seconds automatically
- **Win/Loss Conditions** – Win by keeping happiness above 80 for 3 minutes; lose when hunger hits 100 and happiness drops to 10

### Part 2 – Advanced
- **Energy Bar Widget** – Animated `LinearProgressIndicator` showing current energy with color coding
- **Energy Level Logic** – Energy decreases when playing, increases when feeding; play is blocked below 20 energy
- **Activity Selection** – Scrollable chip menu with 5 activities: Run 🏃, Sleep 😴, Bath 🛁, Train 💪, Nap 💤
- **Activity-Based Pet State** – Each activity uniquely affects happiness, hunger, and energy (e.g. Sleep restores +60 energy, Train gives +25 happiness but costs 40 energy)

### Bonus
- Onboarding screen with fade + slide animation
- Settings page – rename pet, reset stats, or start a new game
- Tap-to-pet interaction with bounce animation and emoji reactions
- Idle floating animation on the pet
- Haptic feedback on all interactions
- Win progress bar that appears when close to winning

---

## DEMO

![Recording 2026-02-18 175459](https://github.com/user-attachments/assets/58923863-dab1-4202-848d-c7690b54226d)



---

## Git Commits

<img width="2559" height="1390" alt="Screenshot 2026-02-18 173540" src="https://github.com/user-attachments/assets/0c75e3ea-0aae-4b5c-9e16-ff4ce2871fa3" />

<img width="1512" height="333" alt="Screenshot 2026-02-18 173551" src="https://github.com/user-attachments/assets/92c4b6ea-e732-4aeb-bcde-0f0a87de8462" />


## Tech Stack
- Flutter / Dart
- dart:async (Timer)
- flutter/cupertino.dart (iOS-style UI)
- StatefulWidget + setState for state management

