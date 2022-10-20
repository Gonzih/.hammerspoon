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

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
hs.alert.show("Config loaded")

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

function centerMouseOnWindow(window)
  local pt = hs.geometry.rectMidPoint(window:frame())
  hs.mouse.absolutePosition(pt)
end


focusIndex = 1
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

function hideAll(exceptions)
  local st = Set(exceptions)
  for _, app in ipairs(hs.application.runningApplications()) do
    local app_name = app:name()
    if not app:isHidden() and not st[app_name] then
      print('Hiding ', app_name)
      app:hide()
    end
  end
end

screenLayouts = {}
for i, screen in ipairs(hs.screen.allScreens()) do
  screenLayouts[screen:getUUID()] = i
end

function changeLayout(idx)
  if idx < 0 then
    idx = 10
  end

  if idx > #layouts() then
    idx = 0
  end

  print("========================")

  local screen = hs.screen.mainScreen():getUUID()
  screenLayouts[screen] = idx
  local layout = layouts()[idx]

  print("Setting index ", idx)
  print("Screen ", screen)
  print("Layout count", #layout)
  print("Layout ", dump(layout))

  hideAll(layout)

  for _, app in ipairs(layout) do
    if hs.application.find(app) then
      print("Focusing ", app)
      hs.application.launchOrFocus(app)
    end
  end
end

function currentLayout()
  local screen = hs.screen.mainScreen():getUUID()
  return screenLayouts[screen]
end

hs.hotkey.bind("alt", "d", function() changeLayout(currentLayout() - 1)  end)
hs.hotkey.bind("alt", "n", function() changeLayout(currentLayout() + 1)  end)

hs.hotkey.bind("alt", "&", function() changeLayout(1)  end)
hs.hotkey.bind("alt", "[", function() changeLayout(2)  end)
hs.hotkey.bind("alt", "{", function() changeLayout(3)  end)
hs.hotkey.bind("alt", "}", function() changeLayout(4)  end)
hs.hotkey.bind("alt", "(", function() changeLayout(5)  end)
hs.hotkey.bind("alt", "=", function() changeLayout(6)  end)
hs.hotkey.bind("alt", "*", function() changeLayout(7)  end)
hs.hotkey.bind("alt", ")", function() changeLayout(8)  end)
hs.hotkey.bind("alt", "+", function() changeLayout(9)  end)
hs.hotkey.bind("alt", "]", function() changeLayout(10) end)
