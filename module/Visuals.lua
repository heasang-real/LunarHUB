return function(Library, Window, Tabs)
    local ESPGroup = Tabs.Visuals:AddLeftGroupbox('Player ESP')
    ESPGroup:AddToggle('ESP_Enabled', { Text = 'Enable ESP', Default = false })
    ESPGroup:AddToggle('ESP_Boxes', { Text = 'Show Boxes', Default = false })
    ESPGroup:AddToggle('ESP_Names', { Text = 'Show Names', Default = false })
    ESPGroup:AddToggle('ESP_Tracers', { Text = 'Show Tracers', Default = false })
    ESPGroup:AddColorPicker('ESP_Color', { Default = Color3.new(1, 0, 0), Title = 'ESP Color' })
    
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local espObjects = {}

    local function createESP(player)
        local objects = {
            box = Drawing.new("Square"),
            name = Drawing.new("Text"),
            tracer = Drawing.new("Line")
        }
        
        objects.box.Thickness = 1
        objects.box.Filled = false
        
        objects.name.Size = 16
        objects.name.Center = true
        objects.name.Outline = true
        
        objects.tracer.Thickness = 1

        espObjects[player] = objects
    end

    local function removeESP(player)
        if espObjects[player] then
            for _, obj in pairs(espObjects[player]) do
                obj:Remove()
            end
            espObjects[player] = nil
        end
    end

    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then createESP(player) end
    end

    RunService.RenderStepped:Connect(function()
        if Library.Unloaded then
            for player, _ in pairs(espObjects) do removeESP(player) end
            return
        end

        for player, objects in pairs(espObjects) do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if Toggles.ESP_Enabled.Value and rootPart and humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local headPos, _ = Camera:WorldToViewportPoint(character:FindFirstChild("Head") and character.Head.Position + Vector3.new(0, 0.5, 0) or rootPart.Position + Vector3.new(0, 2, 0))
                local legPos, _ = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight * 0.6
                
                if onScreen then
                    objects.box.Visible = Toggles.ESP_Boxes.Value
                    objects.box.Size = Vector2.new(boxWidth, boxHeight)
                    objects.box.Position = Vector2.new(pos.X - boxWidth / 2, headPos.Y)
                    objects.box.Color = Options.ESP_Color.Value
                    
                    objects.name.Visible = Toggles.ESP_Names.Value
                    objects.name.Text = player.Name
                    objects.name.Position = Vector2.new(pos.X, headPos.Y - 18)
                    objects.name.Color = Options.ESP_Color.Value
                    
                    objects.tracer.Visible = Toggles.ESP_Tracers.Value
                    objects.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.tracer.To = Vector2.new(pos.X, legPos.Y)
                    objects.tracer.Color = Options.ESP_Color.Value
                else
                    objects.box.Visible = false
                    objects.name.Visible = false
                    objects.tracer.Visible = false
                end
            else
                objects.box.Visible = false
                objects.name.Visible = false
                objects.tracer.Visible = false
            end
        end
    end)
end
