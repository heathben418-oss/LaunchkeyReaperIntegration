-- launchkey_mk4.lua
-- Launchkey MK4 61 x Reaper Integration
-- Step 1: DAW mode handshake

-- ── Load siblings ──────────────────────────────────────────────────────────────
local script_path = ({reaper.get_action_context()})[2]:match('^(.+[/\\])')
dofile(script_path .. 'launchkey_config.lua')
dofile(script_path .. 'launchkey_oled.lua')

-- ── MIDI constants ─────────────────────────────────────────────────────────────
local MSG_ENABLE  = { 0x9F, 0x0C, 0x7F }
local MSG_DISABLE = { 0x9F, 0x0C, 0x00 }

-- ── State ──────────────────────────────────────────────────────────────────────
local daw_out       = nil
local daw_in        = nil
local connected     = false
local out_port_name = 'Not found'
local in_port_name  = 'Not found'

-- ── Port detection ─────────────────────────────────────────────────────────────
local function scanPorts(isInput, pattern)
  local count = isInput and reaper.GetNumMIDIInputs() or reaper.GetNumMIDIOutputs()
  local matches = {}
  for i = 0, count - 1 do
    local ok, name = isInput
      and reaper.GetMIDIInputName(i, '')
      or  reaper.GetMIDIOutputName(i, '')
    if ok and name:lower():find(pattern:lower(), 1, true) then
      table.insert(matches, { idx = i, name = name })
    end
  end
  return matches
end

-- On Windows the DAW port is the 2nd Launchkey interface (MIDIOUT2 / MIDIIN2).
-- Prefer any match containing "2" or "daw"; fall back to 2nd match, then 1st.
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
  local out_idx, in_idx

  if Config.daw_out_override then
    out_idx = Config.daw_out_override
    local _, n = reaper.GetMIDIOutputName(out_idx, '')
    out_port_name = n or ('Output ' .. out_idx)
  else
    local m = pickDAWPort(scanPorts(false, Config.device_name))
    if m then out_idx = m.idx; out_port_name = m.name end
  end

  if Config.daw_in_override then
    in_idx = Config.daw_in_override
    local _, n = reaper.GetMIDIInputName(in_idx, '')
    in_port_name = n or ('Input ' .. in_idx)
  else
    local m = pickDAWPort(scanPorts(true, Config.device_name))
    if m then in_idx = m.idx; in_port_name = m.name end
  end

  if out_idx then
    daw_out = reaper.CreateMIDIOutput(out_idx, false, nil)
  end
  if in_idx then
    daw_in = reaper.CreateMIDIInput(in_idx)
  end

  if daw_out then
    daw_out:Send(MSG_ENABLE[1], MSG_ENABLE[2], MSG_ENABLE[3], -1)
    connected = true
  end
end

-- ── Disconnect ─────────────────────────────────────────────────────────────────
local function disconnect()
  if daw_out then
    daw_out:Send(MSG_DISABLE[1], MSG_DISABLE[2], MSG_DISABLE[3], -1)
    daw_out = nil
  end
  daw_in  = nil
  connected = false
end

-- ── ImGui popup ────────────────────────────────────────────────────────────────
local ctx        = reaper.ImGui_CreateContext('LK MK4')
local popup_open = true
local open_time  = reaper.time_precise()

-- Colours: 0xRRGGBBAA
local C_BG      = 0x1A1A2EFF
local C_GREEN   = 0x44FF88FF
local C_RED     = 0xFF5555FF
local C_YELLOW  = 0xFFCC44FF
local C_ACCENT  = 0x88CCFFFF
local C_WHITE   = 0xFFFFFFFF
local C_DIM     = 0x888888FF

local WIN_W, WIN_H = 460, 240

local function drawPopup()
  if not popup_open then return end

  if Config.popup_timeout > 0 and
     reaper.time_precise() - open_time > Config.popup_timeout then
    popup_open = false
    return
  end

  reaper.ImGui_SetNextWindowSize(ctx, WIN_W, WIN_H, reaper.ImGui_Cond_Always())
  reaper.ImGui_SetNextWindowPos(ctx, 200, 200, reaper.ImGui_Cond_FirstUseEver())

  local flags = reaper.ImGui_WindowFlags_NoResize()
              | reaper.ImGui_WindowFlags_NoScrollbar()
              | reaper.ImGui_WindowFlags_NoCollapse()

  local visible, open = reaper.ImGui_Begin(
    ctx, 'Launchkey MK4  —  Reaper Integration##lk', true, flags)
  popup_open = open

  if visible then
    -- Header
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_TextColored(ctx, C_ACCENT, '  LAUNCHKEY MK4 61')
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_TextColored(ctx, C_DIM, '  x  REAPER')
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- Connection status
    if connected then
      reaper.ImGui_TextColored(ctx, C_GREEN,  '  ●  DAW MODE ACTIVE')
    else
      reaper.ImGui_TextColored(ctx, C_RED,    '  ●  DEVICE NOT FOUND')
    end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Spacing(ctx)

    -- Port info
    reaper.ImGui_TextColored(ctx, C_DIM,   '  DAW OUT  ')
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_TextColored(ctx, daw_out and C_WHITE or C_RED, out_port_name)

    reaper.ImGui_TextColored(ctx, C_DIM,   '  DAW IN   ')
    reaper.ImGui_SameLine(ctx)
    reaper.ImGui_TextColored(ctx, daw_in and C_WHITE or C_YELLOW, in_port_name)

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing(ctx)

    -- Hint or status line
    if not connected then
      reaper.ImGui_TextColored(ctx, C_YELLOW,
        '  Edit Config.device_name in launchkey_config.lua')
    else
      reaper.ImGui_TextColored(ctx, C_DIM,
        '  Script will keep running after you dismiss this.')
    end

    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Spacing(ctx)

    -- Dismiss button
    reaper.ImGui_SetCursorPosX(ctx, WIN_W / 2 - 50)
    if reaper.ImGui_Button(ctx, connected and '    OK    ' or '   Close   ', 100, 28) then
      popup_open = false
    end

    reaper.ImGui_End(ctx)
  end
end

-- ── Main loop ──────────────────────────────────────────────────────────────────
local function loop()
  drawPopup()
  -- Future steps: read incoming MIDI and dispatch here.
  reaper.defer(loop)
end

-- ── Cleanup ────────────────────────────────────────────────────────────────────
local function cleanup()
  disconnect()
  reaper.ImGui_DestroyContext(ctx)
end

-- ── Entry point ────────────────────────────────────────────────────────────────
connect()
reaper.defer(loop)
reaper.atexit(cleanup)
