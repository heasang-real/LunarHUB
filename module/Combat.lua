return function(Library, Window, Tabs)
    local CombatGroup = Tabs.Combat:AddLeftGroupbox('Aimbot')
    CombatGroup:AddToggle('Aimbot_Enabled', { Text = 'Enable Aimbot', Default = false })
    CombatGroup:AddToggle('SilentAim_Enabled', { Text = 'Enable Silent Aim', Default = false })
    CombatGroup:AddDropdown('Aimbot_Target', { Values = {'Head', 'HumanoidRootPart'}, Default = 1, Text = 'Target Part' })
    CombatGroup:AddSlider('Aimbot_Smoothing', { Text = 'Smoothing', Default = 1, Min = 1, Max = 10, Rounding = 1 })
    
    local FOVGroup = Tabs.Combat:AddRightGroupbox('FOV Settings')
    FOVGroup:AddToggle('FOV_Show', { Text = 'Show FOV Circle', Default = false })
    FOVGroup:AddSlider('FOV_Radius', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 500, Rounding = 0 })
    FOVGroup:AddColorPicker('FOV_Color', { Default = Color3.new(1, 1, 1), Title = 'FOV Color' })

    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    
    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = Options.FOV_Radius.Value
        local mouseLocation = UserInputService:GetMouseLocation()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = player.Character:FindFirstChild(Options.Aimbot_Target.Value)
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    RunService.RenderStepped:Connect(function()
        if Library.Unloaded then
            FOVCircle:Remove()
            return
        end
        
        FOVCircle.Visible = Toggles.FOV_Show.Value
        FOVCircle.Radius = Options.FOV_Radius.Value
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Color = Options.FOV_Color.Value
        
        if Toggles.Aimbot_Enabled.Value and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(Options.Aimbot_Target.Value) then
                local targetPos = target.Character[Options.Aimbot_Target.Value].Position
                -- Smooth aim
                local smooth = Options.Aimbot_Smoothing.Value / 10
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smooth)
            end
        end
    end)
end
