local function Chinese()
    hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
end

local function English()
    -- hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
    hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
end

-- app to expected ime config
-- todo only set to pinyin swtich with SHIFT key for now
local app2Ime = {
    {'/Applications/iTerm.app', 'English'},
    {'/Applications/Xcode.app', 'English'},
    {'/Applications/IntelliJ IDEA.app', 'English'},
    {'/Applications/Visual Studio Code.app', 'English'},
    {'/System/Library/CoreServices/Finder.app', 'English'},
    {'/Applications/WeChat.app', 'Chinese'},
    {'/Applications/1Password 7.app', 'Chinese'},
    {'/Applications/Safari.app', 'Chinese'},
    {'/Applications/System Preferences.app', 'English'},
}

function updateFocusAppInputMethod()
    local focusAppPath = hs.window.frontmostWindow():application():path()
    for index, app in pairs(app2Ime) do
        local appPath = app[1]
        local expectedIme = app[2]

        if focusAppPath == appPath then
            if expectedIme == 'English' then
                English()
            else
                Chinese()
            end
            break
        end
    end
end

-- Handle cursor focus and application's screen manage.
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        updateFocusAppInputMethod()
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
