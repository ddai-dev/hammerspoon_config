local application = require "hs.application"
local hotkey = require "hs.hotkey"
local window = require "hs.window"
local layout = require "hs.layout"
local grid = require "hs.grid"
local hints = require "hs.hints"
local screen = require "hs.screen"
local alert = require "hs.alert"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local mouse = require "hs.mouse"

-- hyper key
local hyper = {"cmd", "ctrl", "alt"}
local hyperCmd = {'cmd'}
local hyperShift = {"alt", "shift"}
local hyperCtrl = {"alt", "ctrl"}
local hyperAlt = {"ctrl", "alt", "shift"}

----------------------------------------------------------------------------------------------------
-- function define
----------------------------------------------------------------------------------------------------
--Predicate that checks if a window belongs to a screen
function isInScreen(screen, win)
    return win:screen() == screen
end

-- todo 
function nextScreen(win)
    local screen = hs.mouse.getCurrentScreen()    
    if not isInScreen(screen, win) then 
       screen:next()
    end
end

-- call after focusedWindow else do nothing
function setMouseToMid() 
    local win = window.focusedWindow()
    if not win then
        return 
    end

    local screen = hs.mouse.getCurrentScreen()    
    if not isInScreen(screen, win) then 
        local rect = win:frame()
        -- local pt = {x=rect.x/2, y=rect.y/2}
        local center = hs.geometry.rectMidPoint(rect)
        hs.mouse.setAbsolutePosition(center)
        mouse.setAbsolutePosition(pt)
    end

end

function toggle_application(bundleID)
    local app = hs.application.get(bundleID)
    if not app then
        hs.application.launchOrFocusByBundleID(bundleID)
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == hs.window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
            -- must call after focus
            setMouseToMid()
        end
    end
end

function define_hotkey(prefix, app_list) 
    for _, v in ipairs(app_list) do
        -- local located_name = hs.application.nameForBundleID(v.id)
        hs.hotkey.bind(prefix, v.key , v.id, function()
            -- hs.application.launchOrFocus('iTerm')
            toggle_application(v.id)
        end)
    end
end


----------------------------------------------------------------------------------------------------
-- 定义 windowHints 快捷键
hswhints_keys = hswhints_keys or {"alt", "tab"}
if string.len(hswhints_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hswhints_keys[1], hswhints_keys[2], 'WindowHints 快速切换应用', function()
        spoon.ModalMgr:deactivateAll()
        hs.hints.windowHints()
    end)
end

-- move cursor to other screen's center
hs.hotkey.bind(hyper, '.', function()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:next()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.setAbsolutePosition(center)
end)

----------------------------------------------------------------------------------------------------
-- get app id => mdls -name kMDItemCFBundleIdentifier -r /Applications/IntelliJ\ IDEA.app
-- define  shortcut --------> cmd
----------------------------------------------------------------------------------------------------
local app_list_cmd = {
    {key = '0', id='com.google.Chrome'},
    {key = '1', id='org.gnu.Emacs'},
    {key = '2', id='com.readdle.PDFExpert-Mac'},
    {key = '3', id='com.microsoft.VSCode'},
    {key = '4', id='com.jetbrains.intellij'},
    {key = 'space', id='com.googlecode.iterm2'},
}
define_hotkey(hyperCmd, app_list_cmd)


--------------------------------------- appM 快速打开应用 ---------------------------------------------
-- Toggle an application between being the frontmost app, and being hidden
-- appM 模式 快速打开应用
spoon.ModalMgr:new("appM")
local cmodal = spoon.ModalMgr.modal_list["appM"]
cmodal:bind('', 'escape', '退出 ', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'Q', '退出 ', function() spoon.ModalMgr:deactivate({"appM"}) end)
--cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
if not hsapp_list then
    hsapp_list = {
        {key = 'f', name = 'Finder'},
        {key = 's', name = 'Safari'},
        {key = 'y', id = 'com.apple.systempreferences'},
    }
end
for _, v in ipairs(hsapp_list) do
    if v.id then
        local located_name = hs.application.nameForBundleID(v.id)
        if located_name then
            cmodal:bind('', v.key, located_name, function()
                hs.application.launchOrFocusByBundleID(v.id)
                spoon.ModalMgr:deactivate({"appM"})
            end)
        end
    elseif v.name then
        cmodal:bind('', v.key, v.name, function()
            hs.application.launchOrFocus(v.name)
            spoon.ModalMgr:deactivate({"appM"})
        end)
    end
end

-- 绑定快捷键
hsappM_keys = hsappM_keys or {"alt", "A"}
if string.len(hsappM_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsappM_keys[1], hsappM_keys[2], " 进入 AppM 模式，快速打开应用", function()
        spoon.ModalMgr:deactivateAll()
        spoon.ModalMgr:activate({"appM"}, "#FFBD2E", true)
    end)
end