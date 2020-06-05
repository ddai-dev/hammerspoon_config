----------------------------------------------------------------------------------------------------

-- author: zuorn
-- mail: zuorn@qq.com
-- github: https://github.com/zuorn/hammerspoon_config 

----------------------------------------------------------------------------------------------------






hs.logger.defaultLogLevel='debug'
-- window management
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

----------------------------------------------------------------------------------------------------
hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

----------------------------------------------------------------------------------------------------
------------------------------------------ 配置设置 -------------------------------------------------
-- 配置文件
-- 使用自定义配置 （如果存在的话）
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
if custom_config then
    print("加载自定义配置文件。")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privatepath then
        hs.alert("已发现你的私有配置，将优先使用它。")
    end
else
    -- 否则使用默认配置
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private')
        -- 如果没有 `~/.hammerspoon/private` 目录，则创建它。
        hs.fs.mkdir(hs.configdir .. '/private')
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privateconf then
        -- 加载自定义配置，如果存在的话
        require('private/config')
    end
end

-- reload config 
hsreload_keys = hsreload_keys or {{"cmd", "option", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], function() hs.reload() end)
    hs.alert.show("config reloaded")
end

----------------------------------------------------------------------------------------------------
---------------------------------------- Spoons 加载项 ----------------------------------------------
-- 加载 Spoon
hs.loadSpoon("ModalMgr")

-- 定义默认加载的 Spoons
if not hspoon_list then
    hspoon_list = {
        "WinWin",
    }
end

-- 加载 Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end

----------------------------------------------------------------------------------------------------
-- 定义各种模式快捷键绑定
----------------------------------------------------------------------------------------------------
-- 定义 windowHints 快捷键
hswhints_keys = hswhints_keys or {"alt", "tab"}
if string.len(hswhints_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hswhints_keys[1], hswhints_keys[2], 'WindowHints 快速切换应用', function()
        spoon.ModalMgr:deactivateAll()
        hs.hints.windowHints()
    end)
end

--------------------------------------- appM 快速打开应用 ---------------------------------------------
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

-- get app id => mdls -name kMDItemCFBundleIdentifier -r /Applications/IntelliJ\ IDEA.app
local app_list_cmd = {
    {key = '0', id='com.google.Chrome'},
    {key = '1', id='org.gnu.Emacs'},
    {key = '2', id='com.readdle.PDFExpert-Mac'},
    {key = '3', id='com.microsoft.VSCode'},
    {key = '4', id='com.jetbrains.intellij'},
}

define_hotkey({'cmd'}, app_list_cmd)

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


require "private/window"
require "private/other"

----------------------------------------------------------------------------------------------------
-- 初始化 modalMgr
spoon.ModalMgr.supervisor:enter()
