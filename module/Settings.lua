return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
    Library.ToggleKeybind = Options.MenuKeybind
    
    local RainbowGroup = Tabs.Settings:AddRightGroupbox('Effects')
    RainbowGroup:AddToggle('UI_Rainbow', { Text = 'Rainbow UI Effect', Default = false })
    RainbowGroup:AddSlider('UI_RainbowSpeed', { Text = 'Rainbow Speed', Default = 1, Min = 0.1, Max = 5, Rounding = 1 })
    
    local RunService = game:GetService("RunService")
    local hue = 0
    RunService.RenderStepped:Connect(function(deltaTime)
        if Library.Unloaded then return end
        if Toggles.UI_Rainbow.Value then
            hue = hue + (deltaTime * Options.UI_RainbowSpeed.Value * 0.1)
            if hue > 1 then hue = 0 end
            local rainbowColor = Color3.fromHSV(hue, 1, 1)
            -- Apply Rainbow to Linoria Accent Color
            if Options.AccentColor then
                Options.AccentColor:SetValueRGB(rainbowColor)
            end
        end
    end)
    
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'UI_Rainbow', 'UI_RainbowSpeed' })
    
    ThemeManager:SetFolder('LunarHUB')
    SaveManager:SetFolder('LunarHUB/Universal')
    
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()
end
