--[[
    LunarHUB - Settings Module
    Handles: Menu keybind, configuration management, theme management,
             rainbow UI mode, and license display.

    All UI built on Tabs['Script Settings'].
    Uses LinoriaLib + ThemeManager + SaveManager addons.
]]

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local HttpService = game:GetService('HttpService')
    local RunService = game:GetService('RunService')

    local SettingsTab = Tabs['Script Settings']

    ---------------------------------------------------------------------------
    -- Utility: Base64 Encode / Decode
    ---------------------------------------------------------------------------
    local Base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    local function Base64Encode(data)
        local result = {}
        local padding = ''
        local dataLen = #data

        -- Pad input so length is a multiple of 3
        local remainder = dataLen % 3
        if remainder > 0 then
            for _ = 1, 3 - remainder do
                padding = padding .. '='
                data = data .. '\0'
            end
        end

        for i = 1, #data, 3 do
            local b1 = string.byte(data, i)
            local b2 = string.byte(data, i + 1)
            local b3 = string.byte(data, i + 2)

            local n = b1 * 65536 + b2 * 256 + b3

            local c1 = math.floor(n / 262144) % 64
            local c2 = math.floor(n / 4096) % 64
            local c3 = math.floor(n / 64) % 64
            local c4 = n % 64

            table.insert(result, string.sub(Base64Chars, c1 + 1, c1 + 1))
            table.insert(result, string.sub(Base64Chars, c2 + 1, c2 + 1))
            table.insert(result, string.sub(Base64Chars, c3 + 1, c3 + 1))
            table.insert(result, string.sub(Base64Chars, c4 + 1, c4 + 1))
        end

        local encoded = table.concat(result)

        -- Replace trailing characters with padding
        if #padding > 0 then
            encoded = string.sub(encoded, 1, #encoded - #padding) .. padding
        end

        return encoded
    end

    local function Base64Decode(data)
        -- Remove any whitespace / newlines
        data = data:gsub('%s', '')

        -- Build reverse lookup table
        local lookup = {}
        for i = 1, #Base64Chars do
            lookup[string.sub(Base64Chars, i, i)] = i - 1
        end

        -- Strip padding and remember how many pad chars there were
        local paddingCount = 0
        if string.sub(data, -2) == '==' then
            paddingCount = 2
            data = string.sub(data, 1, -3) .. 'AA'
        elseif string.sub(data, -1) == '=' then
            paddingCount = 1
            data = string.sub(data, 1, -2) .. 'A'
        end

        local result = {}
        for i = 1, #data, 4 do
            local c1 = lookup[string.sub(data, i, i)] or 0
            local c2 = lookup[string.sub(data, i + 1, i + 1)] or 0
            local c3 = lookup[string.sub(data, i + 2, i + 2)] or 0
            local c4 = lookup[string.sub(data, i + 3, i + 3)] or 0

            local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4

            local b1 = math.floor(n / 65536) % 256
            local b2 = math.floor(n / 256) % 256
            local b3 = n % 256

            table.insert(result, string.char(b1))
            table.insert(result, string.char(b2))
            table.insert(result, string.char(b3))
        end

        local decoded = table.concat(result)

        -- Remove padding null bytes
        if paddingCount > 0 then
            decoded = string.sub(decoded, 1, #decoded - paddingCount)
        end

        return decoded
    end

    ---------------------------------------------------------------------------
    -- Utility: XOR Encryption
    ---------------------------------------------------------------------------
    local function XOREncrypt(data, key)
        local result = {}
        for i = 1, #data do
            local keyByte = string.byte(key, ((i - 1) % #key) + 1)
            local dataByte = string.byte(data, i)
            table.insert(result, string.char(bit32.bxor(dataByte, keyByte)))
        end
        return table.concat(result)
    end

    ---------------------------------------------------------------------------
    -- Utility: Encrypt / Decrypt pipelines
    ---------------------------------------------------------------------------
    local EncryptionKey = 'LunarHUB'

    local function EncryptData(rawData)
        -- Pipeline: Base64Encode(rawData) -> XOR -> Base64Encode
        local firstEncode = Base64Encode(rawData)
        local xored = XOREncrypt(firstEncode, EncryptionKey)
        local finalEncode = Base64Encode(xored)
        return finalEncode
    end

    local function DecryptData(encryptedData)
        -- Pipeline: Base64Decode -> XOR -> Base64Decode
        local firstDecode = Base64Decode(encryptedData)
        local xored = XOREncrypt(firstDecode, EncryptionKey)
        local finalDecode = Base64Decode(xored)
        return finalDecode
    end

    ---------------------------------------------------------------------------
    -- Utility: Gather current config as JSON string (mirrors SaveManager:Save)
    ---------------------------------------------------------------------------
    local function GetCurrentConfigJSON()
        local data = { objects = {} }

        for idx, toggle in next, Toggles do
            if SaveManager.Ignore[idx] then continue end
            local parser = SaveManager.Parser[toggle.Type]
            if parser then
                table.insert(data.objects, parser.Save(idx, toggle))
            end
        end

        for idx, option in next, Options do
            if not SaveManager.Parser[option.Type] then continue end
            if SaveManager.Ignore[idx] then continue end
            table.insert(data.objects, SaveManager.Parser[option.Type].Save(idx, option))
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return nil
        end
        return encoded
    end

    ---------------------------------------------------------------------------
    -- Utility: Load config from raw JSON string (mirrors SaveManager:Load)
    ---------------------------------------------------------------------------
    local function LoadConfigFromJSON(jsonString)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, jsonString)
        if not success or not decoded or not decoded.objects then
            return false, 'Failed to decode config data'
        end

        for _, option in next, decoded.objects do
            if SaveManager.Parser[option.type] then
                task.spawn(function()
                    SaveManager.Parser[option.type].Load(option.idx, option)
                end)
            end
        end

        return true
    end

    ---------------------------------------------------------------------------
    -- Utility: Gather current theme as JSON string
    ---------------------------------------------------------------------------
    local function GetCurrentThemeJSON()
        local theme = {}
        local fields = { 'FontColor', 'MainColor', 'AccentColor', 'BackgroundColor', 'OutlineColor' }

        for _, field in next, fields do
            if Options[field] then
                theme[field] = Options[field].Value:ToHex()
            elseif Library[field] then
                theme[field] = Library[field]:ToHex()
            end
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, theme)
        if not success then
            return nil
        end
        return encoded
    end

    ---------------------------------------------------------------------------
    -- Utility: Apply theme from raw JSON string
    ---------------------------------------------------------------------------
    local function ApplyThemeFromJSON(jsonString)
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, jsonString)
        if not success or type(decoded) ~= 'table' then
            return false, 'Failed to decode theme data'
        end

        for field, hexColor in next, decoded do
            local colorSuccess, color = pcall(Color3.fromHex, hexColor)
            if colorSuccess then
                Library[field] = color
                if Options[field] then
                    Options[field]:SetValueRGB(color)
                end
            end
        end

        Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
        Library:UpdateColorsUsingRegistry()

        return true
    end

    ---------------------------------------------------------------------------
    -- LEFT SIDE: Group - Menu
    ---------------------------------------------------------------------------
    local MenuGroup = SettingsTab:AddLeftGroupbox('Menu')

    MenuGroup:AddButton({
        Text = 'Unload LunarHUB',
        Func = function()
            Library:Unload()
        end,
        DoubleClick = true,
        Tooltip = 'Double-click to unload the entire script hub'
    })

    MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('SettingsMenuKeybind', {
        Default = 'End',
        NoUI = true,
        Text = 'Menu Toggle Keybind'
    })

    Library.ToggleKeybind = Options.SettingsMenuKeybind

    ---------------------------------------------------------------------------
    -- Configure SaveManager
    ---------------------------------------------------------------------------
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'SettingsMenuKeybind' })
    SaveManager:SetFolder('LunarHUB/configs')

    -- BuildConfigSection creates a RIGHT groupbox named 'Configuration' automatically
    SaveManager:BuildConfigSection(SettingsTab)

    ---------------------------------------------------------------------------
    -- LEFT SIDE: Group - Configuration (Extra Features)
    ---------------------------------------------------------------------------
    local ConfigExtrasGroup = SettingsTab:AddLeftGroupbox('Configuration Tools')

    -- Auto Save Toggle
    ConfigExtrasGroup:AddToggle('SettingsAutoSave', {
        Text = 'Auto Save Configuration',
        Default = false,
        Tooltip = 'Automatically saves the currently selected config at a set interval'
    })

    -- DependencyBox for auto-save interval
    local AutoSaveDepbox = ConfigExtrasGroup:AddDependencyBox()

    AutoSaveDepbox:AddSlider('SettingsAutoSaveInterval', {
        Text = 'Auto Save Interval (seconds)',
        Default = 60,
        Min = 10,
        Max = 300,
        Rounding = 0,
        Suffix = 's'
    })

    AutoSaveDepbox:SetupDependencies({
        { Toggles.SettingsAutoSave, true }
    })

    -- Auto-save background loop
    task.spawn(function()
        while true do
            local interval = 60
            if Options.SettingsAutoSaveInterval then
                interval = Options.SettingsAutoSaveInterval.Value
            end

            task.wait(interval)

            if Library.Unloaded then break end

            if Toggles.SettingsAutoSave and Toggles.SettingsAutoSave.Value then
                local configName = nil
                if Options.SaveManager_ConfigList then
                    configName = Options.SaveManager_ConfigList.Value
                end

                if configName and configName ~= '' then
                    local success, err = SaveManager:Save(configName)
                    if success then
                        Library:Notify(string.format('Auto-saved config %q', configName), 2)
                    else
                        Library:Notify('Auto-save failed: ' .. tostring(err), 3)
                    end
                end
            end
        end
    end)

    -- Apply Recommended Settings button
    ConfigExtrasGroup:AddButton({
        Text = 'Apply Recommended Settings',
        Func = function()
            -- Reset commonly-used settings to sensible defaults
            -- Toggle off potentially dangerous or performance-heavy features
            if Toggles.SettingsAutoSave then
                Toggles.SettingsAutoSave:SetValue(false)
            end
            if Options.SettingsAutoSaveInterval then
                Options.SettingsAutoSaveInterval:SetValue(60)
            end
            if Toggles.SettingsRainbowEnabled then
                Toggles.SettingsRainbowEnabled:SetValue(false)
            end
            if Options.SettingsRainbowSpeed then
                Options.SettingsRainbowSpeed:SetValue(3)
            end
            if Toggles.SettingsRainbowGradient then
                Toggles.SettingsRainbowGradient:SetValue(false)
            end

            -- Apply the Default theme
            if Options.ThemeManager_ThemeList then
                Options.ThemeManager_ThemeList:SetValue('Default')
            end

            Library:Notify('Recommended settings applied!', 3)
        end,
        Tooltip = 'Resets UI settings to sensible defaults'
    })

    ConfigExtrasGroup:AddDivider()

    -- Export Config to Clipboard
    ConfigExtrasGroup:AddButton({
        Text = 'Export Config to Clipboard',
        Func = function()
            local jsonData = GetCurrentConfigJSON()
            if not jsonData then
                Library:Notify('Failed to serialize config', 3)
                return
            end

            local encrypted = EncryptData(jsonData)

            local clipboardFunc = setclipboard or toclipboard or (Clipboard and Clipboard.set)
            if clipboardFunc then
                clipboardFunc(encrypted)
                Library:Notify('Config exported to clipboard!', 3)
            else
                Library:Notify('Clipboard API not available', 3)
            end
        end,
        Tooltip = 'Copies your current config as an encrypted string'
    })

    -- Import Config Input
    ConfigExtrasGroup:AddInput('SettingsImportInput', {
        Default = '',
        Text = 'Import Config',
        Placeholder = 'Paste encrypted config here...',
        Finished = false
    })

    -- Import Config from Clipboard
    ConfigExtrasGroup:AddButton({
        Text = 'Import Config from Clipboard',
        Func = function()
            local encryptedText = ''
            if Options.SettingsImportInput then
                encryptedText = Options.SettingsImportInput.Value
            end

            if encryptedText == '' then
                Library:Notify('No config data provided. Paste into the input box above.', 3)
                return
            end

            local decryptSuccess, decryptedData = pcall(DecryptData, encryptedText)
            if not decryptSuccess or not decryptedData or decryptedData == '' then
                Library:Notify('Failed to decrypt config data. Invalid format.', 3)
                return
            end

            local loadSuccess, loadErr = LoadConfigFromJSON(decryptedData)
            if loadSuccess then
                Library:Notify('Config imported successfully!', 3)
            else
                Library:Notify('Failed to import config: ' .. tostring(loadErr), 3)
            end
        end,
        Tooltip = 'Imports a config from the encrypted string above'
    })

    ---------------------------------------------------------------------------
    -- LEFT SIDE: Group - Theme (Enhanced ThemeManager)
    ---------------------------------------------------------------------------
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder('LunarHUB')

    -- Add custom LunarHUB themes to the built-in themes table
    local nextIndex = 0
    for _, themeData in next, ThemeManager.BuiltInThemes do
        if themeData[1] > nextIndex then
            nextIndex = themeData[1]
        end
    end

    ThemeManager.BuiltInThemes['Lunar Dark'] = {
        nextIndex + 1,
        HttpService:JSONDecode('{"FontColor":"e0e0ff","MainColor":"0d0d1a","AccentColor":"7c3aed","BackgroundColor":"09091a","OutlineColor":"1e1e3a"}')
    }
    ThemeManager.BuiltInThemes['Lunar Neon'] = {
        nextIndex + 2,
        HttpService:JSONDecode('{"FontColor":"ffffff","MainColor":"121218","AccentColor":"00e5ff","BackgroundColor":"0a0a10","OutlineColor":"2a2a3a"}')
    }
    ThemeManager.BuiltInThemes['Midnight Purple'] = {
        nextIndex + 3,
        HttpService:JSONDecode('{"FontColor":"f0e6ff","MainColor":"1a0e2e","AccentColor":"9b59b6","BackgroundColor":"130a24","OutlineColor":"2d1b4e"}')
    }

    -- ApplyToTab creates a LEFT groupbox named 'Themes' automatically
    ThemeManager:ApplyToTab(SettingsTab)

    -- Extra theme features - add to a new groupbox below themes
    local ThemeExtrasGroup = SettingsTab:AddLeftGroupbox('Theme Tools')

    -- Export Theme to Clipboard
    ThemeExtrasGroup:AddButton({
        Text = 'Export Theme to Clipboard',
        Func = function()
            local jsonData = GetCurrentThemeJSON()
            if not jsonData then
                Library:Notify('Failed to serialize theme', 3)
                return
            end

            local encrypted = EncryptData(jsonData)

            local clipboardFunc = setclipboard or toclipboard or (Clipboard and Clipboard.set)
            if clipboardFunc then
                clipboardFunc(encrypted)
                Library:Notify('Theme exported to clipboard!', 3)
            else
                Library:Notify('Clipboard API not available', 3)
            end
        end,
        Tooltip = 'Copies your current theme colors as an encrypted string'
    })

    -- Import Theme Input
    ThemeExtrasGroup:AddInput('SettingsImportThemeInput', {
        Default = '',
        Text = 'Import Theme',
        Placeholder = 'Paste encrypted theme here...',
        Finished = false
    })

    -- Import Theme from Clipboard
    ThemeExtrasGroup:AddButton({
        Text = 'Import Theme from Clipboard',
        Func = function()
            local encryptedText = ''
            if Options.SettingsImportThemeInput then
                encryptedText = Options.SettingsImportThemeInput.Value
            end

            if encryptedText == '' then
                Library:Notify('No theme data provided. Paste into the input box above.', 3)
                return
            end

            local decryptSuccess, decryptedData = pcall(DecryptData, encryptedText)
            if not decryptSuccess or not decryptedData or decryptedData == '' then
                Library:Notify('Failed to decrypt theme data. Invalid format.', 3)
                return
            end

            local applySuccess, applyErr = ApplyThemeFromJSON(decryptedData)
            if applySuccess then
                Library:Notify('Theme imported successfully!', 3)
            else
                Library:Notify('Failed to import theme: ' .. tostring(applyErr), 3)
            end
        end,
        Tooltip = 'Imports a theme from the encrypted string above'
    })

    ---------------------------------------------------------------------------
    -- RIGHT SIDE: Group - Rainbow UI
    ---------------------------------------------------------------------------
    local RainbowGroup = SettingsTab:AddRightGroupbox('Rainbow UI')

    RainbowGroup:AddToggle('SettingsRainbowEnabled', {
        Text = 'Rainbow Mode',
        Default = false,
        Tooltip = 'Cycles the UI accent color through a smooth rainbow spectrum'
    })

    local RainbowDepbox = RainbowGroup:AddDependencyBox()

    RainbowDepbox:AddSlider('SettingsRainbowSpeed', {
        Text = 'Rainbow Speed',
        Default = 3,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Tooltip = 'Controls how fast the rainbow color cycles'
    })

    RainbowDepbox:AddToggle('SettingsRainbowGradient', {
        Text = 'Rainbow Gradient',
        Default = false,
        Tooltip = 'Applies a smooth, shifting rainbow gradient across the entire UI'
    })

    RainbowDepbox:SetupDependencies({
        { Toggles.SettingsRainbowEnabled, true }
    })

    -- Store original accent color so we can restore when rainbow is turned off
    local OriginalAccentColor = Library.AccentColor

    -- Track state for restoration
    Toggles.SettingsRainbowEnabled:OnChanged(function()
        if not Toggles.SettingsRainbowEnabled.Value then
            -- Restore original accent color when rainbow is disabled
            Library.AccentColor = OriginalAccentColor
            Library.AccentColorDark = Library:GetDarkerColor(OriginalAccentColor)
            Library:UpdateColorsUsingRegistry()

            -- Re-sync the AccentColor color picker if it exists
            if Options.AccentColor then
                Options.AccentColor:SetValueRGB(OriginalAccentColor)
            end
        else
            -- Snapshot the current accent before rainbow takes over
            OriginalAccentColor = Library.AccentColor
        end
    end)

    -- Rainbow RenderStepped connection
    local RainbowConnection = RunService.RenderStepped:Connect(function()
        if Library.Unloaded then return end

        if not Toggles.SettingsRainbowEnabled or not Toggles.SettingsRainbowEnabled.Value then
            return
        end

        local speed = 3
        if Options.SettingsRainbowSpeed then
            speed = Options.SettingsRainbowSpeed.Value
        end

        local useGradient = false
        if Toggles.SettingsRainbowGradient then
            useGradient = Toggles.SettingsRainbowGradient.Value
        end

        local baseHue = (tick() * speed * 0.1) % 1

        if useGradient then
            -- Gradient mode: shift hue per registry element for a wave effect
            local totalElements = #Library.Registry
            if totalElements > 0 then
                for idx, object in next, Library.Registry do
                    for property, colorIdx in next, object.Properties do
                        if type(colorIdx) == 'string' and colorIdx == 'AccentColor' then
                            local elementHue = (baseHue + (idx / totalElements) * 0.5) % 1
                            local gradientColor = Color3.fromHSV(elementHue, 0.8, 1.0)
                            object.Instance[property] = gradientColor
                        elseif type(colorIdx) == 'string' and colorIdx == 'AccentColorDark' then
                            local elementHue = (baseHue + (idx / totalElements) * 0.5) % 1
                            local gradientColor = Color3.fromHSV(elementHue, 0.8, 1.0)
                            local darkerColor = Library:GetDarkerColor(gradientColor)
                            object.Instance[property] = darkerColor
                        end
                    end
                end
            end

            -- Still update the Library color values for consistency
            local rainbowColor = Color3.fromHSV(baseHue, 0.8, 1.0)
            Library.AccentColor = rainbowColor
            Library.AccentColorDark = Library:GetDarkerColor(rainbowColor)
        else
            -- Solid rainbow mode: single color applied uniformly
            local rainbowColor = Color3.fromHSV(baseHue, 0.8, 1.0)
            Library.AccentColor = rainbowColor
            Library.AccentColorDark = Library:GetDarkerColor(rainbowColor)
            Library:UpdateColorsUsingRegistry()
        end
    end)

    -- Clean up rainbow connection on unload
    Library:GiveSignal(RainbowConnection)

    ---------------------------------------------------------------------------
    -- RIGHT SIDE: Group - License Information
    ---------------------------------------------------------------------------
    local LicenseGroup = SettingsTab:AddRightGroupbox('License Information')

    LicenseGroup:AddLabel('Your key remain:')
    LicenseGroup:AddLabel('Lifetime (Beta)')
    LicenseGroup:AddLabel('')
    LicenseGroup:AddLabel('✅ You have been whitelisted by the developer.')

    ---------------------------------------------------------------------------
    -- Auto-load config at the very end
    ---------------------------------------------------------------------------
    SaveManager:LoadAutoloadConfig()
end
