# Chronometer-TWoW

**Lightweight combat timers for Turtle WoW (Vanilla 1.12).**  
Chronometer-TWoW shows clear, per-target bars for short-duration effects you apply in combat—damage over time, debuffs, crowd control, and weapon/shot procs—so you always know what’s active and when it expires.

## What it does
- **Per-target timers:** Each enemy gets its own bars; swapping targets won’t lose your timing.
- **Clean grouping:** Related effects are grouped so your UI stays readable during hectic pulls.
- **Smart refresh behavior:** Bars extend when an effect is successfully re-applied and tick down naturally between applications.
- **Pet & ranged support:** Works with pet-applied effects and ranged abilities common in Vanilla gameplay.
- **Compact & efficient:** Minimal footprint, no bloated configuration, fits classic UI layouts.
- **Works out of the box:** Class data modules cover the most common short-duration effects used in Vanilla.

## Compatibility
- **Client:** Turtle WoW (1.12-era client; SuperWoW compatible).
- **Framework:** Includes embedded Ace2/ParserLib; no extra downloads required.

## Installation
1. Download the latest release and extract to:
   ```
   Interface/AddOns/Chronometer-TWoW/
   ```
2. Ensure the `.toc` and the `Core`, `Data`, and `libs` folders are inside that single directory.
3. Launch the game (or `/reload`).

## Usage
- Timers appear automatically as you apply effects in combat.
- Bars are grouped by type and anchored to stay legible even with multiple targets.
- No configuration is required; play and watch durations at a glance.

> For detailed update notes, see the **Changelog (fork)** section in this repository.

## Credits
- Original **Chronometer** by its respective authors (Ace2 ecosystem).
- Contributors:
  - Judo101 — <https://github.com/Judo101/Chronometer>
  - MrBoxie88 — <https://github.com/MrBoxie88/Chronometer-TWoW>
- This fork: maintenance and Turtle/SuperWoW targeting for modern private-server clients.

---

### FAQ
**Does it show stack counts on bars?**  
Not by default. A future enhancement may add optional “(xN)” stack text for certain effects.

**Will it work on other 1.12 servers?**  
It’s designed for Turtle/SuperWoW. It should run on most Vanilla 1.12 clients that provide standard combat log messages, but only Turtle is officially tested.

