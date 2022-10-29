-- ============ UTILITY ============

-- dictionary length, only way to get it
function dlen(map)
  local l = 0
  for _, _ in pairs(map) do
    l = l + 1
  end

  return l
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function Set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

hs.application.enableSpotlightForNameSearches(true)

-- ============ RELOAD ============
hs.hotkey.bind({"alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- ============ BASICS ============

function mainDisplay()
  local screen = hs.screen.find("built.in retina display")

  if not screen then
    screen = hs.screen.mainScreen()
  end

  return screen
end

currentDisplay = mainDisplay()

function getDisplay(n)
  local screen = mainDisplay()
  for i = 2,n do
    screen = screen:next()
  end

  return screen
end

function gotoDisplay(n)
  currentDisplay = getDisplay(n)
  centerMouseOnScreen(currentDisplay)
end

function visibleSpaceWindowsFilter()
  return hs.window.filter.default
      :setAppFilter('Hammerspoon',{visible=true, allowTitles=1, rejectTitles="Hammerspoon"})
      :setAppFilter('Finder',{visible=true})
      :setSortOrder(hs.window.filter.sortByCreated)
      :setCurrentSpace(true)
      -- :setScreens(currentDisplay:getUUID())
end

function fullscreenWindow(win, screen)
    local f = win:frame()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
    hs.alert.show("Fullscreen " .. win:application():name())
end

hs.hotkey.bind({"alt"}, "f", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    fullscreenWindow(win, screen)
end)

hs.hotkey.bind("alt", "return", function() hs.application.launchOrFocus("Terminal") end)

hs.hotkey.bind({"alt"}, "q", function()
    local app = hs.application.frontmostApplication()
    app:kill()
end)

-- ============ TILING ============

allFullscreen = true

hs.hotkey.bind({"alt"}, "space", function()
    allFullscreen = not allFullscreen
    local wf = visibleSpaceWindowsFilter()
    local windows = wf:getWindows()
    local screen = hs.screen.mainScreen()
    local max = screen:frame()

    if allFullscreen then
      for _, win in ipairs(windows) do
        local f = win:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = max.h
        win:setFrame(f)
      end
      hs.alert.show("Fullscreen all")
    else
      hs.window.tiling.tileWindows(windows, max)
      hs.alert.show("Tiling")
    end
end)

-- ============ WINDOW SWITCHING ============
function centerMouseOnFrame(frame)
  local pt = hs.geometry.rectMidPoint(frame)
  hs.mouse.absolutePosition(pt)
end

function centerMouseOnWindow(window)
  centerMouseOnFrame(window:frame())
end

function centerMouseOnScreen(screen)
  centerMouseOnFrame(screen:frame())
end

focusIndex = 1

function resetFocus()
  focusIndex = 1
end

function focusWindowN(n)
  print('========= FOCUS WINDOW =========')

  local spaceFilter = visibleSpaceWindowsFilter()

  local wins = spaceFilter:getWindows()
  focusIndex = focusIndex + n
  -- print("Visible windows == ", #wins)

  print("Got windows filtered")
  print('========================')
  for i, win in ipairs(wins) do
    local name = win:application():name()
    print(name)
  end
  print('========================')

  if focusIndex > #wins then
    focusIndex = 1
  end

  if focusIndex < 1 then
    focusIndex = #wins
  end

  for i, win in ipairs(wins) do
    local name = win:application():name()
    print("i -> name ", i, name)

    if i == focusIndex and win then
      print("Focusing window #", focusIndex, name)
      win:focus()
      centerMouseOnWindow(win)
    end
  end

  print('========= END FOCUS WINDOW =========')
end

hs.hotkey.bind("alt", "h", function() focusWindowN(1) end)
hs.hotkey.bind("alt", "t", function() focusWindowN(-1) end)


-- ============ LAYOUTS ============

function layouts()
  return {
    {},
    {
      { name="Spotify", screen=1 },
    },
    {
      { name="Calendar", screen=1 },
      { name="Mail", screen=1 },
    },
    {
      { name="Telegram Desktop", screen=1 },
      { name="Telegram", screen=1 },
      { name="Signal", screen=1 },
      { name="FaceTime", screen=1 },
      { name="Messages", screen=1 },
    },
    {
      { name="Notion", screen=1 },
    },
    {
      { name="Slack", screen=1 },
      { name="Discord", screen=1 },
    },
    {},
    {
      { name="Terminal", screen=1 },
    },
    {
      { name="Emacs", screen=2 },
    },
    {
      { name="Brave Browser", screen=2 },
    },
  }
end

function layoutFor(name)
  for i, layout in ipairs(layouts()) do
    for _, cfg in ipairs(layout) do
      if cfg.name == name  then
        return {layout=i, screen=cfg.screen}
      end
    end
  end

  return nil
end

spaceRegistry = {}

function registerSpaces()
  local spaces = hs.spaces.missionControlSpaceNames()

  print("------------SPACES-------------")

  for screenID, screenSpaces in pairs(spaces) do
    local spaceNames = {}
    local spaceNameToID = {}
    print(screenID)

    for spaceID, spaceName in pairs(screenSpaces) do
      local name = spaceName:gsub("[a-zA-Z ]*", "")
      name = tonumber(name)
      table.insert(spaceNames, name)
      spaceNameToID[name] = spaceID
    end

    table.sort(spaceNames)
    print(dump(spaceNames))
    print(dump(spaceNameToID))

    for i, spaceName in ipairs(spaceNames) do
      local space = spaceNameToID[spaceName]

      if not spaceRegistry[screenID] then
        spaceRegistry[screenID] = {}
      end
      if not spaceRegistry[screenID][i] then
        spaceRegistry[screenID][i] = space
      end
    end
  end


  print(dump(spaceRegistry))
  for id, spaces in pairs(hs.spaces.missionControlSpaceNames()) do
    print(id, "has #", dlen(spaces), "spaces")
  end

  print("------------END SPACES-------------")
end

function initSpaces()
  local limit = 10
  print("Init spaces")
  local spaces = hs.spaces.missionControlSpaceNames()
  print(dump(spaces))

  for id, screenSpaces in pairs(spaces) do
    local diff = limit - dlen(screenSpaces)

    print("Need to create #", diff, " spaces for ", id)
    for i = 1,diff do
      print("Creating space on ", id)
      hs.spaces.addSpaceToScreen(id)
      hs.timer.usleep(1000000)
    end
  end
end

function moveWindowsToSpaces()
  local running_apps = hs.application.runningApplications()
  local screen = currentDisplay
  local screenid = screen:getUUID()

  for _, app in ipairs(running_apps) do
    local cfg = layoutFor(app:name())

    if cfg then
      local i = cfg.layout
      if cfg.screen then
        screen = getDisplay(cfg.screen)
        screenid = screen:getUUID()
      end
      local windows = app:allWindows()

      for _, win in ipairs(windows) do
        local spaceid = spaceRegistry[screenid][i]
        print("Moving " .. win:application():name() .. " to " .. spaceid)
        hs.spaces.moveWindowToSpace(win, spaceid)
      end
    end
  end
end

initSpaces()
registerSpaces()
moveWindowsToSpaces()

ftr = hs.window.filter.new(true)
ftr:subscribe(hs.window.filter.windowCreated, moveWindowsToSpaces)

hs.hotkey.bind({"alt", "ctrl"}, "M", function()
    hs.alert.show("Shuffling windows on " .. currentDisplay:name())
    moveWindowsToSpaces()
end)

currentLayout = {}
for _, screen in ipairs(hs.screen.allScreens()) do
  currentLayout[screen:getUUID()] = 1
end

function layoutForCurrentDisplay()
  return currentLayout[currentDisplay:getUUID()]
end

function setLayoutForCurrentDisplay(id)
  currentLayout[currentDisplay:getUUID()] = id
end

function changeToSpace(idx)
  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 1
  end

  setLayoutForCurrentDisplay(idx)

  local screen = currentDisplay:getUUID()
  local space = spaceRegistry[screen][idx]
  print("Go to space # " .. idx .. " (" .. space  .. ") " .. " on screen " .. currentDisplay:name())
  hs.spaces.gotoSpace(space)
end

function moveToSpace(idx)
  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 0
  end

  local screen = currentDisplay:getUUID()
  local space = spaceRegistry[screen][idx]
  local win = hs.window.focusedWindow()
  hs.spaces.moveWindowToSpace(win, space)
  print("Move window " .. win:title() .. " to space " .. idx .. " on screen " .. currentDisplay:name())
end

hs.hotkey.bind("alt", "d", function() changeToSpace(layoutForCurrentDisplay() - 1)  end)
hs.hotkey.bind("alt", "n", function() changeToSpace(layoutForCurrentDisplay() + 1)  end)
hs.hotkey.bind({"alt", "ctrl"}, "d", function() moveToSpace(layoutForCurrentDisplay() - 1)  end)
hs.hotkey.bind({"alt", "ctrl"}, "n", function() moveToSpace(layoutForCurrentDisplay() + 1)  end)

hs.hotkey.bind("alt", "&", function() changeToSpace(1)  end)
hs.hotkey.bind("alt", "[", function() changeToSpace(2)  end)
hs.hotkey.bind("alt", "{", function() changeToSpace(3)  end)
hs.hotkey.bind("alt", "}", function() changeToSpace(4)  end)
hs.hotkey.bind("alt", "(", function() changeToSpace(5)  end)
hs.hotkey.bind("alt", "=", function() changeToSpace(6)  end)
hs.hotkey.bind("alt", "*", function() changeToSpace(7)  end)
hs.hotkey.bind("alt", ")", function() changeToSpace(8)  end)
hs.hotkey.bind("alt", "+", function() changeToSpace(9)  end)
hs.hotkey.bind("alt", "]", function() changeToSpace(10) end)

-- TODO look up why keys arent working, maybe need to use COMMAND key
hs.hotkey.bind({"alt", "ctrl"}, "&", function() moveToSpace(1)  end)
hs.hotkey.bind({"alt", "ctrl"}, "[", function() moveToSpace(2)  end)
hs.hotkey.bind({"alt", "ctrl"}, "{", function() moveToSpace(3)  end)
hs.hotkey.bind({"alt", "ctrl"}, "}", function() moveToSpace(4)  end)
hs.hotkey.bind({"alt", "ctrl"}, "(", function() moveToSpace(5)  end)
hs.hotkey.bind({"alt", "ctrl"}, "=", function() moveToSpace(6)  end)
hs.hotkey.bind({"alt", "ctrl"}, "*", function() moveToSpace(7)  end)
hs.hotkey.bind({"alt", "ctrl"}, ")", function() moveToSpace(8)  end)
hs.hotkey.bind({"alt", "ctrl"}, "+", function() moveToSpace(9)  end)
hs.hotkey.bind({"alt", "ctrl"}, "]", function() moveToSpace(10) end)

function targetSpace(n)
  local screen = getDisplay(n)
  return hs.spaces.activeSpaceOnScreen(screen:getUUID())
end

function focusScreen(n)
  local screen = getDisplay(n)
  local fspace = targetSpace(n)
  hs.alert.show("Focus  " .. screen:name())
  gotoDisplay(n)
  hs.spaces.gotoSpace(fspace)
  focusWindowN(0)
end

function moveToScreen(n)
  gotoDisplay(n)

  local screen = getDisplay(n)
  local screenid = screen:getUUID()
  local fspace = targetSpace(n)
  local win = hs.window.focusedWindow()
  local cfg = layoutFor(win:application():name())
  print("fspace " .. fspace)

  if cfg then
    local layoutIdx = cfg.layout
    fspace = spaceRegistry[screenid][layoutIdx]
    print("Found layout idx " .. layoutIdx .. " for " .. win:application():name() .. " fspace #" .. fspace)
  end

  hs.spaces.gotoSpace(fspace)
  hs.timer.doAfter(0.5,
                   function()
                     hs.spaces.moveWindowToSpace(win, fspace)
                     win:focus()
                     fullscreenWindow(win, screen)
                     centerMouseOnScreen(screen)
                     hs.alert.show("Move win " .. win:application():name() .. " to " .. screen:name())
                   end)
end

hs.screen.watcher.new(function()
    hs.alert.show("Scheen change detected")
    gotoDisplay(1)
end):start()

hs.hotkey.bind("alt", ";", function() focusScreen(1)  end)
hs.hotkey.bind("alt", ",", function() focusScreen(2)  end)
hs.hotkey.bind("alt", ".", function() focusScreen(3)  end)

hs.hotkey.bind({"alt", "ctrl"}, ";", function() moveToScreen(1)  end)
hs.hotkey.bind({"alt", "ctrl"}, ",", function() moveToScreen(2)  end)
hs.hotkey.bind({"alt", "ctrl"}, ".", function() moveToScreen(3)  end)
