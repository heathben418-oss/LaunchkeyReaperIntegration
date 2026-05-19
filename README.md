# Launchkey MK4 Reaper Integration

Full DAW integration for the Novation Launchkey MK4 (49/61) in Reaper, matching Cubase-level control plus a custom "Safe Reconnect" feature.

## Files

- `launchkey_mk4.lua` — Main control surface script
- `launchkey_config.lua` — User configuration (ports, mappings, button assignments)
- `launchkey_oled.lua` — OLED screen helpers (text, layout, bitmap)

---

## Features

### Transport Buttons
- **Play** — Start playback. Shift+Play = Pause/continue.
- **Stop** — Stop playback. Second press returns playhead to project start.
- **Record** — Toggle Reaper's main record function.
- **Loop** — Toggle loop on/off.

### Workflow Buttons
- **Capture MIDI** — Retrospective MIDI record.
- **Undo** — Triggers Reaper undo. Shift+Undo = Redo.
- **Quantize** — Quantizes last recorded or selected MIDI clip.
- **Metronome** — Toggle metronome on/off.

### Faders — Volume Mode
- Faders 1–8: track volume for the current 8-track bank.
- Fader 9: master output level.
- OLED shows track name and dB value on move.

### Fader Buttons — Select / Arm Mode
Nine buttons directly below the nine faders. Toggle between two modes via fader button 9.
- **Select mode**: press a button to select that track. Buttons light track color; selected track lights white.
- **Arm mode** (default): press a button to toggle record arm. Dim red = unarmed, bright red = armed.

### Track Navigation
- **< Track / Track >**: move one track at a time. OLED shows new track name.
- **Shift + < Track / Track >**: bank by 8 tracks. OLED shows new bank range (e.g. "Tracks 9–16").

---

## Encoders

Encoder mode is selected by holding Shift and pressing one of the top row pads (pads 1–8). The current mode pad lights bright pink; available modes light dim pink.

### Plugin Mode (default)
- Controls 8 parameters at a time on the currently focused FX/instrument.
- Encoder bank buttons page through additional parameters.
- OLED shows track name, parameter name, and value on move.

### Mixer Mode
Three pages accessed via encoder bank buttons:
- **Page 1**: track Volume (8 tracks in current bank).
- **Page 2**: track Pan.
- **Page 3 (EQ)**: 4 EQ bands — odd encoders = frequency, even encoders = gain.

### Sends Mode
- Controls send levels for the 8 tracks in the current bank.
- OLED shows send name and level on move.

### Transport Mode
Relative encoder output (pivot = 64).

| Encoder | Function | OLED label |
|---------|----------|------------|
| 1 | Scrub (playhead position) | Scrb |
| 2 | Zoom | Zoom |
| 3 | Loop Start point | LPS |
| 4 | Loop End point | LPE |
| 5 | Marker select | Mark |
| 6 | N/A | — |
| 7 | N/A | — |
| 8 | Tempo (BPM) | BPM |

---

## Pads

Pad mode is selected by holding Shift and pressing one of the bottom row pads (pads 9–16). The current mode pad lights bright blue; available modes light dim blue.

### DAW Mode (default)
16 pads control 8 tracks simultaneously across two pages. Switch pages with the pad bank ▲/▼ buttons to the left of the pads.

- **Page 1 — Select + Arm**
  - Top row (pads 1–8): Track Select. Pads light track color; selected track lights white.
  - Bottom row (pads 9–16): Record Arm. Bright red = armed, dim red = unarmed.
- **Page 2 — Solo + Mute**
  - Top row (pads 1–8): Solo. Bright pink = soloed, dim pink = unsoloed.
  - Bottom row (pads 9–16): Mute. Bright yellow = muted, dim yellow = unmuted.

OLED briefly shows the active page name when switching.

### Drum Mode
- Pads trigger MIDI notes C1–D#2 (bottom-left to top-right) on MIDI channel 10.
- Outside a DAW, pads light blue. In DAW, pads light the currently selected track's color.

### User Chord Mode
- Each pad plays a user-assigned chord of up to 6 notes.
- **Assign**: press and hold a blank pad, then play the notes on the keyboard; release the pad to save.
- **Transpose**: pad bank ▲/▼ buttons transpose the whole bank by semitone; Shift + ▲/▼ transposes by octave (±3 octaves max).
- **Delete**: hold Function button and press a chord pad. Pads with chords light red and OLED shows "Delete Chord!".

### Arp Pattern Mode
Brings the arpeggiator's step sequence onto the pads for interactive editing.
- **Top row (pads 1–8)**: active/inactive steps. Lit blue = active, unlit = inactive. Current step position lights white during playback.
- **Bottom row (pads 9–16)**: per-step functions. Press the Function button to cycle through three sub-modes:
  - **Tie** (Function lights red): ties a step to the next, extending gate to 110%.
  - **Accent** (Function lights orange): raises step velocity by +30 (capped at 127).
  - **Ratchet** (Function lights yellow): plays two triggers for that step (e.g. two 1/32 notes at 1/16 rate).
- Pad bank ▲/▼ buttons move between bars of the sequence.
- Function + ▼ duplicates the current bar to create a longer clip.

### Chord Map Mode
Activated by pressing the Chord Map button. Pads 1–5 are chord pads; pads 6–8 and 14–16 are performance pads.

- **Chord pads (1–5)**: trigger chords that fit the selected scale. 40 chord banks available, navigated by Adventure and Explore encoders.
- **Performance pads** (hold then press a chord pad):

| Pad | Function |
|-----|----------|
| 6 | Manual Arp Up — each press cycles through chord notes low→high |
| 7 | Inversion Up — each press raises lowest note by an octave |
| 8 | Split: Bass + Chord — press 1 = bass note, press 2 = rest of chord |
| 14 | Manual Arp Down — each press cycles through chord notes high→low |
| 15 | Inversion Down — each press lowers highest note by an octave |
| 16 | Split: Left + Right — press 1 = two lowest notes, press 2 = rest |

- **Scene Launch button (>)**: enables latch mode so performance pads stay active without holding. Press again to disable latch.
- Only one performance pad can be active at a time.

### Custom Pad Modes 1–4
User-defined MIDI messages configured in Novation Components. OLED shows parameter name and value on press.

---

## Shift + Pads: Mode Selection

When Shift is held, pads 1–16 become mode selectors (no notes sent).

| Pads | Selects |
|------|---------|
| Shift + Pad 1 | Encoder Mode: Plugin |
| Shift + Pad 2 | Encoder Mode: Mixer |
| Shift + Pad 3 | Encoder Mode: Sends |
| Shift + Pad 4 | Encoder Mode: Transport |
| Shift + Pad 5 | Encoder Mode: Custom 1 |
| Shift + Pad 6 | Encoder Mode: Custom 2 |
| Shift + Pad 7 | Encoder Mode: Custom 3 |
| Shift + Pad 8 | Encoder Mode: Custom 4 |
| Shift + Pad 9 | Pad Mode: DAW |
| Shift + Pad 10 | Pad Mode: Drum |
| Shift + Pad 11 | Pad Mode: User Chord |
| Shift + Pad 12 | Pad Mode: Arp Pattern |
| Shift + Pad 13 | Pad Mode: Custom 1 |
| Shift + Pad 14 | Pad Mode: Custom 2 |
| Shift + Pad 15 | Pad Mode: Custom 3 |
| Shift + Pad 16 | Pad Mode: Custom 4 |

Current encoder mode pad lights bright pink; current pad mode pad lights bright blue. Available modes light dim; unavailable (DAW-only modes when no DAW) are unlit.

---

## OLED Display

- **Stationary display**: current mode and track name.
- **Temporary display** (persists for user-configured timeout): shown on any control move or touch — parameter name + value.
- **Mode change**: briefly shows mode name on encoder or pad mode switch.
- **Track navigation**: briefly shows new track name on track change, or bank range on bank change.
- Screen is 128×64 px and supports text layouts and raw bitmap graphics.

---

## Extra Feature: Safe Reconnect

Solves the hardware fader pickup problem without motorized faders.

### The Problem
When a physical fader is at a different position than the on-screen value, reconnecting causes a level jump. Standard "pickup mode" fails when the fader is maxed out and can't approach the target from above — you're stuck.

### The Solution
A dedicated button that decouples hardware from software, lets you reposition freely, then reconnects with zero jump and zero audio artifact.

### Flow
1. **Press Safe Reconnect button**
   - Track mutes silently in Reaper (no visible mute change to listeners)
   - Script stops forwarding fader/encoder MIDI to Reaper — nothing on screen moves
   - OLED shows: `TARGET: -3.2dB / CURRENT: +4.1dB / Move fader ↓`
2. **Reposition the fader or encoder freely** — Reaper sees nothing
3. **Press Safe Reconnect button again**
   - Script enters pickup mode: watches for the physical position to cross through the target value
   - The instant the fader passes through the target → track unmutes and control reconnects simultaneously
   - Zero jump, zero audible artifact

---

## Build Plan

Each step is independently testable before moving to the next.

| Step | Feature | Test |
|------|---------|------|
| 1 | DAW mode handshake — find DAW MIDI port, enable on start, disable on exit | Launchkey LEDs switch to DAW mode |
| 2 | Transport buttons — Play, Stop (×2=home), Record, Loop, Shift+Play=Pause | Buttons control Reaper transport |
| 3 | Workflow buttons — Capture MIDI, Undo/Redo, Quantize, Metronome | Each button triggers correct Reaper action |
| 4 | Faders (Volume mode) — tracks 1–8 + master, OLED dB readout | Move fader, track level changes, OLED updates |
| 5 | Fader buttons — Select/Arm toggle via button 9, LED colors | Buttons select or arm tracks correctly |
| 6 | Track navigation — single and bank-of-8, OLED track name | Navigate tracks, fader/encoder bank follows |
| 7 | Encoders: Mixer mode — Vol, Pan, and EQ pages | Encoders adjust vol/pan/EQ on current bank |
| 8 | Encoders: Plugin mode — focused FX params, bank paging | Encoders move plugin knobs |
| 9 | Encoders: Sends mode — send levels per track | Encoders control send amounts |
| 10 | Encoders: Transport mode — scrub, zoom, loop points, BPM | Encoders scrub timeline and adjust loop |
| 11 | Pads: DAW mode — page 1 (Select+Arm), page 2 (Solo+Mute), pad bank buttons switch pages | Pads reflect track state, colors correct |
| 12 | Pads: Drum mode — MIDI notes C1–D#2 on ch10, track color LEDs in DAW | Pads trigger drums, light track color |
| 13 | Pads: User Chord mode — assign, play, transpose, delete chords | Chords assign and play correctly |
| 14 | Pads: Arp Pattern mode — step on/off, Tie/Accent/Ratchet via Function cycle | Steps toggle, per-step functions apply |
| 15 | Pads: Chord Map mode — chord pads, performance pads, latch via Scene Launch | Chords and performance effects trigger correctly |
| 16 | Shift+pads mode selection — encoder modes (pads 1–8), pad modes (pads 9–16), LED feedback | Modes switch correctly, LEDs reflect state |
| 17 | OLED polish — stationary display, mode names, temp display on control touch | Screen always shows useful context |
| 18 | Safe Reconnect — decouple + mute, OLED guidance, pickup mode, unmute on crossing target | Full flow: no jump, no audible artifact |

---

## Technical Notes

- Communication uses the Launchkey's **DAW In/Out** USB interface (second interface on Windows)
- DAW mode enabled via `9Fh 0Ch 7Fh`, disabled via `9Fh 0Ch 00h`
- SysEx header (regular SKUs): `F0h 00h 20h 29h 02h 14h`
- LED coloring channels: 1 = static, 2 = flashing, 3 = pulsing (drum mode: 10/11/12)
- Encoder absolute mode (Plugin/Mixer/Sends): CC on ch16, indices 21–28
- Encoder relative mode (Transport): pivot 64, above = clockwise, below = anticlockwise
- Fader Volume mode: CC on ch16, indices 5–13
- Pad mode select: CC 29 on ch7 — Drum=1, DAW=2, User Chords=4, Custom 1–4=5–8, Arp Pattern=13, Chord Map=14
- Encoder mode select: CC 30 on ch7 — Mixer=1, Plugin=2, Sends=4, Transport=5, Custom 1–4=6–9
- Fader mode select: CC 31 on ch7 — Volume=1, Custom 1–4=6–9
- OLED: 128×64 px, text via SysEx configure+set-text commands, raw bitmap supported
