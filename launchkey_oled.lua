-- launchkey_oled.lua
-- OLED screen helpers for the Launchkey MK4.
-- Stub only — fully implemented in Step 17.

OLED = {}

local SYSEX_HDR = { 0xF0, 0x00, 0x20, 0x29, 0x02, 0x14 }

local TARGET_STATIONARY = 0x20
local TARGET_TEMP       = 0x21

-- Send raw SysEx to the DAW output port.
local function sendSysEx(daw_out, bytes)
  if not daw_out then return end
  -- Placeholder: full SysEx sending implemented in Step 17.
end

-- Display a temporary message on the OLED (stub).
function OLED.temp(daw_out, line1, line2)
  -- Implemented in Step 17.
end

-- Set the stationary (always-on) display text (stub).
function OLED.stationary(daw_out, line1, line2)
  -- Implemented in Step 17.
end
