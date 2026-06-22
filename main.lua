-- 🌙 LunarHUB Main Loader
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = '🌙 LunarHUB | Premium Universal',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Troll = Window:AddTab('Troll'),
    Visual = Window:AddTab('Visual'),
    World = Window:AddTab('World'),
    Player = Window:AddTab('Player'),
    ['Script Settings'] = Window:AddTab('Script Settings')
}

-- GitHub Repository URL (User's repo)
local GitHubRepo = "https://raw.githubusercontent.com/heasang-real/LunarHUB/refs/heads/main/"

-- Modules to load dynamically
local modules = {
    "Main",
    "Troll",
    "Visual",
    "World",
    "Player",
    "Settings"
}

-- Load all modules securely
for _, mod in ipairs(modules) do
    local url = GitHubRepo .. "module/" .. mod .. ".lua"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local loadedFunc = loadstring(result)
        if loadedFunc then
            local initSuccess, initResult = pcall(loadedFunc)
            if initSuccess and type(initResult) == "function" then
                local runSuccess, runError = pcall(initResult, Library, Window, Tabs, ThemeManager, SaveManager)
                if not runSuccess then
                    warn("🌙 LunarHUB: Module '" .. mod .. "' runtime error:\n" .. tostring(runError))
                end
            elseif not initSuccess then
                warn("🌙 LunarHUB: Module '" .. mod .. "' initialization error:\n" .. tostring(initResult))
            end
        else
            warn("🌙 LunarHUB: Failed to parse module '" .. mod .. "'")
        end
    else
        warn("🌙 LunarHUB: Failed to download module '" .. mod .. "'\nError: " .. tostring(result))
    end
end

Library:SetWatermark('🌙 LunarHUB | Universal Mode Ready')
Library.KeybindFrame.Visible = true
