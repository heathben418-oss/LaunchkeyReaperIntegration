-- launchkey_config.lua
-- User configuration for the Launchkey MK4 Reaper integration.
-- Edit this file to match your system if auto-detection picks the wrong ports.

Config = {
  -- Partial name used to find the Launchkey's MIDI ports (case-insensitive).
  -- On Windows the DAW port appears as the 2nd interface:
  --   MIDI port:  "Launchkey MK4 61"
  --   DAW port:   "MIDIOUT2 (Launchkey MK4 61)" / "MIDIIN2 (Launchkey MK4 61)"
  device_name = "Launchkey MK4",

  -- Override port indices (0-based) to skip auto-detection.
  -- Set to nil to use auto-detection (recommended).
  daw_out_override = nil,
  daw_in_override  = nil,

  -- Seconds to show the handshake popup. 0 = wait for user to dismiss.
  popup_timeout = 0,

  -- Print every incoming DAW MIDI byte to the console (for verifying button mappings).
  debug_midi = true,
}
