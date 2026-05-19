# Launchkey MK4 Reaper Integration

Full DAW integration for the Novation Launchkey MK4 (49/61) in Reaper, matching Cubase-level control plus a custom "Safe Reconnect" feature.

## Files

- `launchkey_mk4.lua` — Main control surface script
- `launchkey_config.lua` — User configuration (ports, mappings, button assignments)
- `launchkey_oled.lua` — OLED screen helpers (text, layout, bitmap)

## Features

### Transport
- Play, Stop, Record, Loop
- Double-press Stop returns playhead to project start
- Shift + Play = Pause

### Workflow Buttons
- Capture MIDI (retrospective record)
- Undo / Shift+Undo = Redo
- Quantize selected MIDI clip
- Metronome toggle

### Faders (Volume Mode)
- Faders 1–8: track volume for current 8-track bank
- Fader 9: master output level
- OLED shows track name and dB value on move

### Fader Buttons (Select / Arm Mode)
- Toggle between Select mode and Arm mode via fader button 9
- Select mode: press to select track, buttons light track color, selected track lights white
- Arm mode: press to toggle record arm, dim red = unarmed, bright red = armed

### Track Navigation
- Track < / > buttons: move one track at a time, OLED shows track name
- Shift + Track < / >: bank by 8 tracks

### Encoders — Plugin Mode
- Controls the focused FX/instrument's parameters (8 at a time)
- Encoder bank buttons page through additional parameters

### Encoders — Mixer Mode
- Page 1: track Volume
- Page 2: track Pan
- Page 3: ReaEQ band frequency and gain (4 bands)

### Encoders — Sends Mode
- Controls send levels for the current track

### Encoders — Transport Mode
- Encoder 1: Scrub (playhead position)
- Encoder 2: Zoom
- Encoder 3: Loop Start point
- Encoder 4: Loop End point
- Encoder 5: Marker select
- Encoder 8: Tempo (BPM)

### Pads — DAW Mode
- Page 1 (default): top row = Track Select, bottom row = Record Arm
- Page 2: top row = Solo, bottom row = Mute
- Pad up/down buttons switch between pages
- Pad colors match track colors; state colors match Cubase convention

### OLED Screen
- Stationary display: current mode and track name
- Temporary display on control touch: parameter name and value
- Mode name shown on mode change

---

## Extra Feature: Safe Reconnect

Solves the hardware fader pickup problem without motorized faders.

### The Problem
When a physical fader is at a different position than the on-screen value, reconnecting causes a jump — either a loud level spike or an unintended cut. Standard "pickup mode" fails when the fader is maxed out and can't approach the target from above.

### The Solution
A dedicated button that decouples hardware from software, lets you reposition freely, then reconnects with zero jump and zero audio artifact.

### Flow
1. **Press Safe Reconnect button**
   - Track mutes silently in Reaper
   - Script stops forwarding fader/encoder MIDI (hardware decoupled, Reaper sees nothing)
   - OLED shows: `TARGET: -3.2dB / CURRENT: +4.1dB / Move fader ↓`
2. **Reposition the fader or encoder freely** — nothing on screen moves
3. **Press Safe Reconnect button again**
   - Script enters pickup mode: watches for physical position to cross through the target value
   - The instant the fader passes through the target → track unmutes and control reconnects simultaneously
   - Zero jump, zero audible artifact

### Why This Works
- The track stays frozen at its exact level while decoupled (muted, not changed)
- You can approach the target from any direction — no stuck-at-max problem
- Pickup mode guarantees reconnection happens at the exact right value

---

## Build Plan (Incremental Steps)

Each step is independently testable before moving to the next.

| Step | Feature | Test |
|------|---------|------|
| 1 | DAW mode handshake — find DAW MIDI port, enable on start, disable on exit | Launchkey LEDs switch to DAW mode |
| 2 | Transport buttons — Play, Stop (×2=home), Record, Loop | Buttons control Reaper transport |
| 3 | Workflow buttons — Capture MIDI, Undo/Redo, Quantize, Metronome | Each button triggers correct Reaper action |
| 4 | Faders (Volume mode) — tracks 1–8 + master, OLED dB readout | Move fader, track level changes, OLED updates |
| 5 | Fader buttons — Select/Arm toggle, LED colors | Buttons select or arm tracks correctly |
| 6 | Track navigation — single and bank-of-8, OLED track name | Navigate tracks, fader/encoder bank follows |
| 7 | Encoders: Mixer mode — Vol, Pan, EQ pages | Encoders adjust vol/pan/EQ on current bank |
| 8 | Encoders: Plugin mode — focused FX params, bank paging | Encoders move plugin knobs |
| 9 | Encoders: Sends mode — send levels per track | Encoders control send amounts |
| 10 | Encoders: Transport mode — scrub, zoom, loop points, BPM | Encoders scrub timeline and adjust loop |
| 11 | Pads DAW mode — Select/Arm and Solo/Mute pages | Pads control 8 tracks, colors match state |
| 12 | OLED polish — stationary display, mode names, temp display on touch | Screen always shows useful context |
| 13 | Safe Reconnect — decouple, mute, OLED guidance, pickup reconnect | Full flow: no jump, no audible artifact |

## Technical Notes

- Communication uses the Launchkey's **DAW In/Out** USB interface (second interface on Windows)
- DAW mode enabled via `9Fh 0Ch 7Fh`, disabled via `9Fh 0Ch 00h`
- SysEx header (regular SKUs): `F0h 00h 20h 29h 02h 14h`
- LED coloring: channel 1 = static, channel 2 = flashing, channel 3 = pulsing
- Encoder absolute mode (Plugin/Mixer/Sends): CC on channel 16, indices 21–28
- Encoder relative mode (Transport): pivot value 64, above = clockwise, below = anticlockwise
- Fader Volume mode: CC on channel 16, indices 5–13
- OLED display: 128×64 px, supports text layouts and raw bitmap
