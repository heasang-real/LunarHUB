return function(Library, Window, Tabs)
    local MoveGroup = Tabs.Player:AddLeftGroupbox('Movement')
    MoveGroup:AddToggle('Player_WalkSpeedToggle', { Text = 'Enable WalkSpeed', Default = false })
    MoveGroup:AddSlider('Player_WalkSpeed', { Text = 'WalkSpeed', Default = 16, Min = 16, Max = 150, Rounding = 0 })
    
    MoveGroup:AddToggle('Player_JumpPowerToggle', { Text = 'Enable JumpPower', Default = false })
    MoveGroup:AddSlider('Player_JumpPower', { Text = 'JumpPower', Default = 50, Min = 50, Max = 300, Rounding = 0 })
    
    local UtilityGroup = Tabs.Player:AddRightGroupbox('Utility')
    UtilityGroup:AddToggle('Player_NoClip', { Text = 'NoClip', Default = false })
    UtilityGroup:AddToggle('Player_InfiniteJump', { Text = 'Infinite Jump', Default = false })
    
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    
    RunService.RenderStepped:Connect(function()
        if Library.Unloaded then return end
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if humanoid then
            if Toggles.Player_WalkSpeedToggle.Value then
                humanoid.WalkSpeed = Options.Player_WalkSpeed.Value
            end
            if Toggles.Player_JumpPowerToggle.Value then
                humanoid.JumpPower = Options.Player_JumpPower.Value
            end
        end
        
        if Toggles.Player_NoClip.Value and character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    UserInputService.JumpRequest:Connect(function()
        if Toggles.Player_InfiniteJump.Value then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end
