return function(Library, Window, Tabs)
    local WorldGroup = Tabs.World:AddLeftGroupbox('World ESP')
    WorldGroup:AddToggle('World_ItemESP', { Text = 'Item ESP', Default = false })
    WorldGroup:AddToggle('World_ChestESP', { Text = 'Chest ESP', Default = false })
    WorldGroup:AddToggle('World_NPCESP', { Text = 'NPC ESP', Default = false })
    WorldGroup:AddToggle('World_ShowDistance', { Text = 'Show Distance', Default = false })
    
    local LightingGroup = Tabs.World:AddRightGroupbox('Lighting')
    LightingGroup:AddToggle('World_Fullbright', { Text = 'Fullbright', Default = false })
    LightingGroup:AddToggle('World_XRay', { Text = 'X-Ray (Material Chams)', Default = false })
    
    local Lighting = game:GetService("Lighting")
    local OriginalAmbient = Lighting.Ambient
    local OriginalBrightness = Lighting.Brightness
    
    Toggles.World_Fullbright:OnChanged(function()
        if Toggles.World_Fullbright.Value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = OriginalAmbient
            Lighting.Brightness = OriginalBrightness
        end
    end)

    local xRayObjects = {}
    Toggles.World_XRay:OnChanged(function()
        if Toggles.World_XRay.Value then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                    xRayObjects[obj] = obj.Transparency
                    obj.Transparency = 0.5
                end
            end
        else
            for obj, origTrans in pairs(xRayObjects) do
                if obj and obj.Parent then
                    obj.Transparency = origTrans
                end
            end
            table.clear(xRayObjects)
        end
    end)
    
    Library:OnUnload(function()
        Lighting.Ambient = OriginalAmbient
        Lighting.Brightness = OriginalBrightness
        for obj, origTrans in pairs(xRayObjects) do
            if obj and obj.Parent then obj.Transparency = origTrans end
        end
    end)
end
