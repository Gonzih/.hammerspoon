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
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
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

function focusWindowN(n)
  focusIndex = focusIndex + n
  local wins = hs.window.visibleWindows()
  -- print("Visible windows == ", #wins)

  if focusIndex > #wins then
    focusIndex = 1
  end

  if focusIndex < 1 then
    focusIndex = #wins
  end

  for i, win in ipairs(wins) do
    print(win)
    print(i)

    if i == focusIndex and win then
      win:focus()
      -- print("Focusing window #", i)
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

function initSpaces()
  for _, screen in ipairs(hs.screen.allScreens()) do
    local id = screen:getUUID()
    local spaces = hs.spaces.spacesForScreen(id)
    local diff = #layouts() - #spaces
    for i = 1,diff do
      hs.spaces.addSpaceToScreen(id)
      hs.timer.usleep(1000000)
    end

    local spaces = hs.spaces.spacesForScreen(id)
    for i, space in ipairs(spaces) do
      print(space)
      if not spaceRegistry[id] then
        spaceRegistry[id] = {}
      end
      if not spaceRegistry[id][i] then
        spaceRegistry[id][i] = space
      end
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
              print(win)
              print(spaceid)
              hs.spaces.moveWindowToSpace(win, spaceid)
            end
          end
        end
      end
    end
  end
end

initSpaces()
moveWindowsToSpaces()

ftr = hs.window.filter.new(true)
ftr:subscribe(hs.window.filter.windowCreated, moveWindowsToSpaces)

print(dump(spaceRegistry))

currentLayout = 1

function changeToSpace(idx)
  resetFocus()

  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 1
  end

  currentLayout = idx

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

  currentLayout = idx

  local screen = hs.screen.mainScreen():getUUID()
  local space = spaceRegistry[screen][idx]
  hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), space)
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
