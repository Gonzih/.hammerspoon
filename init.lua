-- ============ UTILITY ============

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
hs.hotkey.bind({"alt"}, "f", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h
    win:setFrame(f)
end)

hs.hotkey.bind("alt", "return", function() hs.application.launchOrFocus("Terminal") end)

hs.hotkey.bind({"alt"}, "q", function()
    local app = hs.application.frontmostApplication()
    app:kill()
end)

-- ============ WINDOW SWITCHING ============
function centerMouseOnWindow(window)
  local pt = hs.geometry.rectMidPoint(window:frame())
  hs.mouse.absolutePosition(pt)
end


focusIndex = 1

function resetFocus()
  focusIndex = 1
end

-- ftr = hs.window.filter.new(true)
-- ftr:subscribe(hs.window.filter.windowCreated, resetFilter)

function focusWindowN(n)
  print('========= FOCUS WINDOW =========')

  local spaceFilter = hs.window.filter.default
    :setAppFilter('Hammerspoon',{visible=true, allowTitles=1, rejectTitles="Hammerspoon"})
    :setAppFilter('Finder',{visible=true})
    :setSortOrder(hs.window.filter.sortByCreated)
    :setCurrentSpace(true)

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
end

hs.hotkey.bind("alt", "h", function() focusWindowN(1) end)
hs.hotkey.bind("alt", "t", function() focusWindowN(-1) end)


-- ============ LAYOUTS ============

function layouts()
  return {
    {},
    {
      "Spotify",
    },
    {
      "Mail",
    },
    {
      "Telegram Desktop",
      "Signal",
    },
    {
      "Notion",
    },
    {},
    {},
    {
      "Terminal",
    },
    {
      "Emacs",
    },
    {
      "Brave Browser",
    },
  }
end

spaceRegistry = {}

function registerSpaces()
  -- TODO extract space ids from this, sort em by name of space
  local spaces = hs.spaces.missionControlSpaceNames()
  print("SPACES")
  print(dump(spaces))

  print("-------------------------------")

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
      print(spaceName, " is ",  space)

      if not spaceRegistry[screenID] then
        spaceRegistry[screenID] = {}
      end
      if not spaceRegistry[screenID][i] then
        spaceRegistry[screenID][i] = space
      end
    end
  end

  print(dump(spaceRegistry))

  print("-------------------------------")
end

function initSpaces()
  for _, screen in ipairs(hs.screen.allScreens()) do
    local id = screen:getUUID()
    local spaces = hs.spaces.spacesForScreen(id)
    local diff = #layouts() - #spaces

    for i = 1,diff do
      hs.spaces.addSpaceToScreen(id)
      hs.timer.usleep(1000000)
    end
  end
end

function moveWindowsToSpaces()
  local running_apps = hs.application.runningApplications()

  for i, layout in ipairs(layouts()) do
    for _, screen in ipairs(hs.screen.allScreens()) do
      local screenid = screen:getUUID()

      for _, appname in ipairs(layout) do
        for _, app in ipairs(running_apps) do

          if app:name() == appname then
            local windows = app:allWindows()

            for _, win in ipairs(windows) do
              local spaceid = spaceRegistry[screenid][i]
              print(win:application():name(), spaceid)
              hs.spaces.moveWindowToSpace(win, spaceid)
            end
          end
        end
      end
    end
  end
end

initSpaces()
registerSpaces()
moveWindowsToSpaces()

ftr = hs.window.filter.new(true)
ftr:subscribe(hs.window.filter.windowCreated, moveWindowsToSpaces)

print(dump(spaceRegistry))

currentLayout = 1

function changeToSpace(idx)
  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 1
  end

  currentLayout = idx

  print("Go to space #", currentLayout)
  local screen = hs.screen.mainScreen():getUUID()
  local space = spaceRegistry[screen][idx]
  hs.spaces.gotoSpace(space)
end

function moveToSpace(idx)
  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 0
  end

  print("Move to space #", idx)
  local screen = hs.screen.mainScreen():getUUID()
  local space = spaceRegistry[screen][idx]
  hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), space)

  -- resetFocus()
  -- focusWindowN(0)
end

hs.hotkey.bind("alt", "d", function() changeToSpace(currentLayout - 1)  end)
hs.hotkey.bind("alt", "n", function() changeToSpace(currentLayout + 1)  end)

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

hs.hotkey.bind({"ctrl", "alt"}, "&", function() moveToSpace(1)  end)
hs.hotkey.bind({"ctrl", "alt"}, "[", function() moveToSpace(2)  end)
hs.hotkey.bind({"ctrl", "alt"}, "{", function() moveToSpace(3)  end)
hs.hotkey.bind({"ctrl", "alt"}, "}", function() moveToSpace(4)  end)
hs.hotkey.bind({"ctrl", "alt"}, "(", function() moveToSpace(5)  end)
hs.hotkey.bind({"ctrl", "alt"}, "=", function() moveToSpace(6)  end)
hs.hotkey.bind({"ctrl", "alt"}, "*", function() moveToSpace(7)  end)
hs.hotkey.bind({"ctrl", "alt"}, ")", function() moveToSpace(8)  end)
hs.hotkey.bind({"ctrl", "alt"}, "+", function() moveToSpace(9)  end)
hs.hotkey.bind({"ctrl", "alt"}, "]", function() moveToSpace(10) end)
