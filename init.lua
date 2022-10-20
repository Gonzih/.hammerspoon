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
  print("Got # visible windows ", #wins)

  if focusIndex >= #wins then
    focusIndex = 1
  end

  if focusIndex < 1 then
    focusIndex = #wins - 1
  end

  for i, win in ipairs(wins) do
    if i == focusIndex then
      win:focus()
      centerMouseOnWindow(win)
    end
  end
end

hs.hotkey.bind("alt", "h", function() focusWindowN(1) end)
hs.hotkey.bind("alt", "t", function() focusWindowN(-1) end)


screenLayouts = {}
for i, screen in ipairs(hs.screen.allScreens()) do
  screenLayouts[screen:getUUID()] = i
end

function layouts(screen)
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
    },
    {},
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

currentLayout = 1
function changeLayout(idx)
  print("========================")
  currentLayout = idx
  local screen = hs.screen.mainScreen():getUUID()
  local layout = layouts(screen)[idx]
  print("Setting index ", idx)
  print("Screen ", screen)
  print("Layout count", #layout)
  print("Layout ", dump(layout))
  screenLayouts[screen] = idx
  hideAll(layout)
  for _, app in ipairs(layout) do
    if hs.application.find(app) then
      print("Focusing ", app)
      hs.application.launchOrFocus(app)
    end
  end
end

hs.hotkey.bind("alt", "d", function() changeLayout(currentLayout - 1)  end)
hs.hotkey.bind("alt", "n", function() changeLayout(currentLayout + 1)  end)

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
