-- launchkey_mk4.lua
-- Launchkey MK4 61 x Reaper Integration
-- Step 1: DAW mode handshake

-- ── Load siblings ──────────────────────────────────────────────────────────────
local script_path = ({reaper.get_action_context()})[2]:match('^(.+[/\\])')
dofile(script_path .. 'launchkey_config.lua')
dofile(script_path .. 'launchkey_oled.lua')

-- ── MIDI constants ─────────────────────────────────────────────────────────────
local MSG_ENABLE  = string.char(0x9F, 0x0C, 0x7F)
local MSG_DISABLE = string.char(0x9F, 0x0C, 0x00)

-- ── State ──────────────────────────────────────────────────────────────────────
local daw_out_idx   = nil
local daw_in_idx    = nil
local connected     = false
local out_port_name = 'Not found'
local in_port_name  = 'Not found'

-- ── MIDI send helper ───────────────────────────────────────────────────────────
local function midiSend(msg)
  if daw_out_idx then
    reaper.SendMIDIMessageToHardware(daw_out_idx, msg)
  end
end

-- ── Port detection ─────────────────────────────────────────────────────────────
local function scanPorts(isInput, pattern)
  local count = isInput and reaper.GetNumMIDIInputs() or reaper.GetNumMIDIOutputs()
  local matches = {}
  for i = 0, count - 1 do
    local ok, name
    if isInput then
      ok, name = reaper.GetMIDIInputName(i, '')
    else
      ok, name = reaper.GetMIDIOutputName(i, '')
    end
    if ok and name and name:lower():find(pattern:lower(), 1, true) then
      table.insert(matches, { idx = i, name = name })
    end
  end
  return matches
end

-- On Windows the DAW port is the 2nd Launchkey interface (MIDIOUT2 / MIDIIN2).
local function pickDAWPort(matches)
  if #matches == 0 then return nil end
  for _, m in ipairs(matches) do
    local n = m.name:lower()
    if n:find('midiout2') or n:find('midiin2') or n:find('daw') then
      return m
    end
  end
  return matches[2] or matches[1]
end

-- ── Connect ────────────────────────────────────────────────────────────────────
local function connect()
  if Config.daw_out_override then
    daw_out_idx = Config.daw_out_override
    local _, n = reaper.GetMIDIOutputName(daw_out_idx, '')
    out_port_name = n or ('Output ' .. daw_out_idx)
  else
    local m = pickDAWPort(scanPorts(false, Config.device_name))
    if m then daw_out_idx = m.idx; out_port_name = m.name end
  end

  if Config.daw_in_override then
    daw_in_idx = Config.daw_in_override
    local _, n = reaper.GetMIDIInputName(daw_in_idx, '')
    in_port_name = n or ('Input ' .. daw_in_idx)
  else
    local m = pickDAWPort(scanPorts(true, Config.device_name))
    if m then daw_in_idx = m.idx; in_port_name = m.name end
  end

  if daw_out_idx then
    midiSend(MSG_ENABLE)
    connected = true
  end
end

-- ── Disconnect ─────────────────────────────────────────────────────────────────
local function disconnect()
  if connected then
    midiSend(MSG_DISABLE)
  end
  daw_out_idx = nil
  daw_in_idx  = nil
  connected   = false
end

-- ── Handshake HTA popup ───────────────────────────────────────────────────────
-- .hta = Windows HTML Application — opens in mshta.exe with just a title-bar
-- X button, no browser chrome of any kind. window.resizeTo() is respected.
local function showHandshakePopup()
  local status_color = connected and '#44FF88' or '#FF5555'
  local status_text  = connected and '&#9679;  DAW MODE ACTIVE' or '&#9679;  DEVICE NOT FOUND'
  local hint_color   = connected and '#555566' or '#FFCC44'
  local hint_text    = connected
    and 'Script is running in Reaper. Close this window when ready.'
    or  'Check Config.device_name in launchkey_config.lua'

  local html = string.format([[<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=11">
  <title>Launchkey MK4 — Reaper</title>
  <HTA:APPLICATION ID="LKHandshake"
    APPLICATIONNAME="Launchkey MK4"
    WINDOWSTATE="normal"
    SHOWINTASKBAR="yes"
    SYSMENU="yes"
    CAPTION="yes"
    BORDER="thin"
    SCROLL="no"
    SINGLEINSTANCE="yes"
  />
  <script type="text/javascript">
    window.onload = function() {
      var w = 540, h = 440;
      window.resizeTo(w, h);
      window.moveTo(
        Math.round((screen.availWidth  - w) / 2),
        Math.round((screen.availHeight - h) / 2)
      );
    };
  </script>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%%; }
    body {
      background: #0d0d1a;
      color: #ccccdd;
      font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
      display: -ms-flexbox;
      display: flex;
      -ms-flex-align: center;
      align-items: center;
      -ms-flex-pack: center;
      justify-content: center;
    }
    .card {
      background: #14142a;
      border: 1px solid #2a2a50;
      border-radius: 16px;
      padding: 48px 56px;
      width: 500px;
      text-align: center;
      box-shadow: 0 24px 64px rgba(0,0,0,0.6);
    }
    .device {
      font-size: 11px;
      letter-spacing: 5px;
      text-transform: uppercase;
      color: #88aaff;
      margin-bottom: 4px;
    }
    .daw {
      font-size: 10px;
      letter-spacing: 4px;
      text-transform: uppercase;
      color: #333355;
      margin-bottom: 36px;
    }
    .status {
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: %s;
      margin-bottom: 32px;
    }
    .ports {
      background: #0a0a18;
      border: 1px solid #1e1e3e;
      border-radius: 10px;
      padding: 18px 24px;
      margin-bottom: 28px;
      text-align: left;
    }
    .port-row {
      display: -ms-flexbox;
      display: flex;
      -ms-flex-pack: justify;
      justify-content: space-between;
      -ms-flex-align: center;
      align-items: center;
      padding: 7px 0;
      font-size: 11px;
    }
    .port-row + .port-row { border-top: 1px solid #1a1a36; }
    .port-label { color: #444466; letter-spacing: 2px; text-transform: uppercase; -ms-flex-negative: 0; flex-shrink: 0; margin-right: 16px; }
    .port-name  { color: #9999bb; text-align: right; font-size: 11px; }
    .hint {
      font-size: 11px;
      color: %s;
      letter-spacing: 1px;
      margin-bottom: 32px;
      min-height: 16px;
    }
    .btn {
      background: transparent;
      color: #88aaff;
      border: 1px solid #2a2a60;
      border-radius: 8px;
      padding: 11px 40px;
      font-size: 11px;
      letter-spacing: 3px;
      text-transform: uppercase;
      cursor: pointer;
      transition: background 0.2s, border-color 0.2s;
    }
    .btn:hover { background: #1e1e4e; border-color: #5555aa; }
  </style>
</head>
<body>
  <div class="card">
    <div class="device">Launchkey MK4 61</div>
    <div class="daw">&#215; Reaper Integration</div>
    <div class="status">%s</div>
    <div class="ports">
      <div class="port-row">
        <span class="port-label">DAW OUT</span>
        <span class="port-name">%s</span>
      </div>
      <div class="port-row">
        <span class="port-label">DAW IN</span>
        <span class="port-name">%s</span>
      </div>
    </div>
    <div class="hint">%s</div>
    <button class="btn" onclick="window.close()">Dismiss</button>
  </div>
</body>
</html>
]], status_color, hint_color, status_text, out_port_name, in_port_name, hint_text)

  local html_path = script_path .. 'handshake.hta'
  local f = io.open(html_path, 'w')
  if f then
    f:write(html)
    f:close()
    reaper.ShowConsoleMsg('LK MK4: Opening popup at ' .. html_path .. '\n')
    if reaper.CF_ShellExecute then
      reaper.CF_ShellExecute(html_path)
    else
      os.execute('start "" "' .. html_path .. '"')
    end
  else
    reaper.ShowConsoleMsg('LK MK4: ERROR - could not write ' .. html_path .. '\n')
  end
end

-- ── Main loop ──────────────────────────────────────────────────────────────────
local function loop()
  -- Future steps: read incoming MIDI via MIDI_GetRecentInputEvent and dispatch here.
  reaper.defer(loop)
end

-- ── Cleanup ────────────────────────────────────────────────────────────────────
local function cleanup()
  disconnect()
end

-- ── Entry point ────────────────────────────────────────────────────────────────
connect()
showHandshakePopup()
reaper.defer(loop)
reaper.atexit(cleanup)
