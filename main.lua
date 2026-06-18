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
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    World = Window:AddTab('World'),
    Player = Window:AddTab('Player'),
    Settings = Window:AddTab('Settings')
}

-- GitHub Repository URL (User's repo)
local GitHubRepo = "https://raw.githubusercontent.com/heasang-real/LunarHUB/refs/heads/main/"

-- Modules to load dynamically
local modules = {
    "Combat",
    "Visuals",
    "World",
    "LocalPlayer",
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
            local initFunc = loadedFunc()
            if type(initFunc) == "function" then
                initFunc(Library, Window, Tabs, ThemeManager, SaveManager)
            end
        end
    else
        warn("🌙 LunarHUB: Failed to load module " .. mod .. "\nError: " .. tostring(result))
    end
end

Library:SetWatermark('🌙 LunarHUB | Universal Mode Ready')
Library.KeybindFrame.Visible = true