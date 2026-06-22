-- 🌙 LunarHUB | Troll Module
-- Fling, Noclip, Fly, Teleport, Annoy, Orbit, Character Troll

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')
    local UserInputService = game:GetService('UserInputService')
    local Workspace = game:GetService('Workspace')
    local LocalPlayer = Players.LocalPlayer

    -- ═══════════════════════════════════════════
    -- STATE & CONNECTION MANAGEMENT
    -- ═══════════════════════════════════════════
    local Connections = {}
    local FlyKeys = {
        W = false,
        A = false,
        S = false,
        D = false,
        Space = false,
        LeftShift = false,
    }
    local FlyBodyVelocity = nil
    local FlyBodyGyro = nil
    local FlyActive = false
    local FlingRunning = false
    local OrbitAngle = 0
    local CharSpinAngle = 0
    local CurrentAnimationTrack = nil
    local OriginalTransparencies = {}
    local OriginalCanCollide = {}
    local TrailAttachment0 = nil
    local TrailAttachment1 = nil
    local TrailInstance = nil
    local SitLoopRunning = false

    -- Animation ID table
    local AnimationIds = {
        ['Zombie Walk'] = 'rbxassetid://616163682',
        ['Ninja Run'] = 'rbxassetid://656118852',
        ['Superhero Fly'] = 'rbxassetid://616003713',
        ['Toy Walk'] = 'rbxassetid://616088211',
        ['Vampire Walk'] = 'rbxassetid://616252966',
        ['Werewolf Run'] = 'rbxassetid://1083462077',
        ['Levitation'] = 'rbxassetid://616006778',
        ['Dance 1'] = 'rbxassetid://182435998',
        ['Dance 2'] = 'rbxassetid://182491277',
        ['Dance 3'] = 'rbxassetid://182436842',
        ['Wave'] = 'rbxassetid://128777973',
        ['Cheer'] = 'rbxassetid://129423030',
        ['Laugh'] = 'rbxassetid://129423131',
        ['Point'] = 'rbxassetid://128853357',
    }

    local AnimationNames = {}
    for name, _ in pairs(AnimationIds) do
        table.insert(AnimationNames, name)
    end
    table.sort(AnimationNames)

    -- ═══════════════════════════════════════════
    -- UTILITY FUNCTIONS
    -- ═══════════════════════════════════════════
    local function getCharacter(player)
        player = player or LocalPlayer
        return player and player.Character
    end

    local function getHumanoidRootPart(player)
        local character = getCharacter(player)
        if not character then
            return nil
        end
        return character:FindFirstChild('HumanoidRootPart')
    end

    local function getHumanoid(player)
        local character = getCharacter(player)
        if not character then
            return nil
        end
        return character:FindFirstChildOfClass('Humanoid')
    end

    local function notify(text, duration)
        pcall(function()
            Library:Notify(text, duration or 3)
        end)
    end

    local function cleanupConnection(name)
        if Connections[name] then
            pcall(function()
                Connections[name]:Disconnect()
            end)
            Connections[name] = nil
        end
    end

    local function cleanupAllConnections()
        for name, connection in pairs(Connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(Connections)
    end

    local function getSelectedFlingTargets()
        if Toggles.FlingSelectAll and Toggles.FlingSelectAll.Value then
            local targets = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    table.insert(targets, player)
                end
            end
            return targets
        end

        local targets = {}
        if Options.FlingTargetPlayers then
            for playerName, isSelected in pairs(Options.FlingTargetPlayers.Value) do
                if isSelected then
                    local player = Players:FindFirstChild(playerName)
                    if player and player ~= LocalPlayer then
                        table.insert(targets, player)
                    end
                end
            end
        end
        return targets
    end

    local function safeSetCFrame(part, cframe)
        pcall(function()
            if part and part.Parent then
                part.CFrame = cframe
            end
        end)
    end

    local function safeSetVelocity(part, velocity)
        pcall(function()
            if part and part.Parent then
                part.Velocity = velocity
            end
        end)
    end

    local function createBodyMover(className, parent, properties)
        local mover = Instance.new(className)
        for property, value in pairs(properties) do
            mover[property] = value
        end
        mover.Parent = parent
        return mover
    end

    local function destroyBodyMover(mover)
        if mover then
            pcall(function()
                mover:Destroy()
            end)
        end
    end

    -- ═══════════════════════════════════════════
    -- GROUPBOX LAYOUT
    -- ═══════════════════════════════════════════

    -- Left side: heavy features
    local FlingGroup = Tabs.Troll:AddLeftGroupbox('Fling Player')
    local NoclipGroup = Tabs.Troll:AddLeftGroupbox('Noclip')
    local FlyGroup = Tabs.Troll:AddLeftGroupbox('Fly')

    -- Right side: lighter features
    local TpGroup = Tabs.Troll:AddRightGroupbox('Teleport to Player')
    local AnnoyGroup = Tabs.Troll:AddRightGroupbox('Annoy Player')
    local OrbitGroup = Tabs.Troll:AddRightGroupbox('Orbit Player')
    local CharGroup = Tabs.Troll:AddRightGroupbox('Character Troll')

    -- ═══════════════════════════════════════════
    -- 1. FLING PLAYER
    -- ═══════════════════════════════════════════
    FlingGroup:AddToggle('FlingEnabled', {
        Text = 'Enable Fling',
        Default = false,
        Tooltip = 'Enable player flinging system',
    })

    local FlingDepbox = FlingGroup:AddDependencyBox()

    FlingDepbox:AddDropdown('FlingTargetPlayers', {
        SpecialType = 'Player',
        Text = 'Target Players',
        Multi = true,
        Tooltip = 'Select which players to fling',
    })

    FlingDepbox:AddToggle('FlingSelectAll', {
        Text = 'Select All Players',
        Default = false,
        Tooltip = 'Overrides dropdown - targets every player',
    })

    FlingDepbox:AddDropdown('FlingMethod', {
        Values = { 'Teleport', 'Spin', 'Glitch Spin', 'All' },
        Default = 1,
        Multi = false,
        Text = 'Fling Method',
        Tooltip = 'Method used to fling targets',
    })

    FlingDepbox:AddSlider('FlingInterval', {
        Text = 'Fling Interval (s)',
        Default = 0.5,
        Min = 0.01,
        Max = 10,
        Rounding = 2,
        Suffix = 's',
    })

    FlingDepbox:AddSlider('FlingForce', {
        Text = 'Fling Force',
        Default = 10000,
        Min = 500,
        Max = 50000,
        Rounding = 0,
    })

    FlingDepbox:AddSlider('FlingDuration', {
        Text = 'Fling Duration (s)',
        Default = 0.5,
        Min = 0.1,
        Max = 5,
        Rounding = 1,
        Suffix = 's',
    })

    FlingDepbox:AddToggle('FlingAutoRetarget', {
        Text = 'Auto Re-target on Respawn',
        Default = false,
        Tooltip = 'Automatically re-target when a target respawns',
    })

    FlingDepbox:AddToggle('FlingOnTouch', {
        Text = 'Only Fling on Touch',
        Default = false,
        Tooltip = 'Only fling when you physically touch a target',
    })

    FlingDepbox:AddToggle('FlingNotify', {
        Text = 'Show Notification',
        Default = true,
        Tooltip = 'Show a notification when a player is flung',
    })

    FlingDepbox:SetupDependencies({
        { Toggles.FlingEnabled, true },
    })

    -- Fling Logic
    local function performFlingMethod(hrp, targetHrp, method, force, duration)
        if not hrp or not hrp.Parent then
            return
        end
        if not targetHrp or not targetHrp.Parent then
            return
        end

        local originalCFrame = hrp.CFrame

        if method == 'Teleport' then
            local bodyVelocity = createBodyMover('BodyVelocity', hrp, {
                MaxForce = Vector3.new(math.huge, math.huge, math.huge),
                Velocity = (targetHrp.Position - hrp.Position).Unit * force,
            })
            safeSetCFrame(hrp, targetHrp.CFrame * CFrame.new(0, 0, -1))
            task.wait(duration)
            destroyBodyMover(bodyVelocity)
            safeSetCFrame(hrp, originalCFrame)
            safeSetVelocity(hrp, Vector3.new(0, 0, 0))
        elseif method == 'Spin' then
            local bodyAngular = createBodyMover('BodyAngularVelocity', hrp, {
                MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
                AngularVelocity = Vector3.new(0, force, 0),
            })
            safeSetCFrame(hrp, targetHrp.CFrame * CFrame.new(0, 0, 2))
            task.wait(duration)
            destroyBodyMover(bodyAngular)
            safeSetCFrame(hrp, originalCFrame)
            safeSetVelocity(hrp, Vector3.new(0, 0, 0))
        elseif method == 'Glitch Spin' then
            local bodyAngular = createBodyMover('BodyAngularVelocity', hrp, {
                MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
                AngularVelocity = Vector3.new(force * 0.5, force, force * 0.5),
            })
            local elapsed = 0
            while elapsed < duration do
                if not hrp or not hrp.Parent then
                    break
                end
                if not targetHrp or not targetHrp.Parent then
                    break
                end
                safeSetCFrame(hrp, targetHrp.CFrame * CFrame.new(
                    math.random(-3, 3),
                    math.random(0, 2),
                    math.random(-3, 3)
                ))
                task.wait(0.05)
                elapsed = elapsed + 0.05
            end
            destroyBodyMover(bodyAngular)
            safeSetCFrame(hrp, originalCFrame)
            safeSetVelocity(hrp, Vector3.new(0, 0, 0))
        end
    end

    local function performFlingOnTarget(targetPlayer)
        local success, err = pcall(function()
            local character = getCharacter()
            local targetCharacter = getCharacter(targetPlayer)
            if not character or not targetCharacter then
                return
            end

            local hrp = getHumanoidRootPart()
            local targetHrp = getHumanoidRootPart(targetPlayer)
            if not hrp or not targetHrp then
                return
            end

            local method = Options.FlingMethod.Value
            local force = Options.FlingForce.Value
            local duration = Options.FlingDuration.Value

            if method == 'All' then
                local methods = { 'Teleport', 'Spin', 'Glitch Spin' }
                for _, currentMethod in ipairs(methods) do
                    if not Toggles.FlingEnabled.Value then
                        break
                    end
                    if not hrp or not hrp.Parent then
                        break
                    end
                    if not targetHrp or not targetHrp.Parent then
                        break
                    end
                    performFlingMethod(hrp, targetHrp, currentMethod, force, duration * 0.35)
                    task.wait(0.1)
                end
            else
                performFlingMethod(hrp, targetHrp, method, force, duration)
            end

            if Toggles.FlingNotify.Value then
                notify('Flung ' .. targetPlayer.Name .. ' using ' .. method, 2)
            end
        end)

        if not success then
            warn('[LunarHUB Troll] Fling error: ' .. tostring(err))
        end
    end

    local function startFlingLoop()
        if FlingRunning then
            return
        end
        FlingRunning = true

        task.spawn(function()
            while FlingRunning and Toggles.FlingEnabled.Value do
                if not Toggles.FlingOnTouch.Value then
                    local targets = getSelectedFlingTargets()
                    for _, targetPlayer in ipairs(targets) do
                        if not Toggles.FlingEnabled.Value then
                            break
                        end
                        performFlingOnTarget(targetPlayer)
                    end
                end
                task.wait(Options.FlingInterval.Value)
            end
            FlingRunning = false
        end)
    end

    local function stopFlingLoop()
        FlingRunning = false
    end

    local function setupFlingOnTouch()
        cleanupConnection('FlingTouch')

        if not Toggles.FlingEnabled.Value then
            return
        end
        if not Toggles.FlingOnTouch.Value then
            return
        end

        local character = getCharacter()
        if not character then
            return
        end
        local hrp = getHumanoidRootPart()
        if not hrp then
            return
        end

        Connections.FlingTouch = hrp.Touched:Connect(function(hit)
            if not Toggles.FlingEnabled.Value then
                return
            end
            if not Toggles.FlingOnTouch.Value then
                return
            end

            local hitPlayer = Players:GetPlayerFromCharacter(hit.Parent)
            if not hitPlayer then
                hitPlayer = Players:GetPlayerFromCharacter(hit.Parent and hit.Parent.Parent)
            end
            if not hitPlayer or hitPlayer == LocalPlayer then
                return
            end

            local targets = getSelectedFlingTargets()
            local isTarget = false
            for _, target in ipairs(targets) do
                if target == hitPlayer then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                task.spawn(function()
                    performFlingOnTarget(hitPlayer)
                end)
            end
        end)
    end

    Toggles.FlingEnabled:OnChanged(function()
        if Toggles.FlingEnabled.Value then
            startFlingLoop()
            setupFlingOnTouch()
        else
            stopFlingLoop()
            cleanupConnection('FlingTouch')
        end
    end)

    Toggles.FlingOnTouch:OnChanged(function()
        if Toggles.FlingEnabled.Value then
            setupFlingOnTouch()
        end
    end)

    -- Auto re-target on respawn
    Connections.FlingAutoRetarget = Players.PlayerAdded:Connect(function(player)
        if not Toggles.FlingAutoRetarget.Value then
            return
        end
        if not Toggles.FlingEnabled.Value then
            return
        end

        player.CharacterAdded:Connect(function()
            if Toggles.FlingAutoRetarget.Value and Toggles.FlingEnabled.Value then
                task.wait(1)
                if Toggles.FlingOnTouch.Value then
                    setupFlingOnTouch()
                end
            end
        end)
    end)

    -- ═══════════════════════════════════════════
    -- 2. NOCLIP
    -- ═══════════════════════════════════════════
    NoclipGroup:AddToggle('NoclipEnabled', {
        Text = 'Enable Noclip',
        Default = false,
        Tooltip = 'Walk through walls and objects',
    })

    Toggles.NoclipEnabled:AddKeyPicker('NoclipKeybind', {
        Default = 'N',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Noclip',
        NoUI = false,
    })

    local NoclipDepbox = NoclipGroup:AddDependencyBox()

    NoclipDepbox:AddSlider('NoclipTransparency', {
        Text = 'Character Transparency',
        Default = 0,
        Min = 0,
        Max = 0.9,
        Rounding = 1,
        Tooltip = 'Make your character transparent while noclipping',
    })

    NoclipDepbox:AddToggle('NoclipAffectAccessories', {
        Text = 'Affect Accessories',
        Default = true,
        Tooltip = 'Also apply noclip and transparency to accessories',
    })

    NoclipDepbox:SetupDependencies({
        { Toggles.NoclipEnabled, true },
    })

    -- Noclip Logic
    local function applyNoclip()
        local character = getCharacter()
        if not character then
            return
        end

        local transparency = Options.NoclipTransparency.Value
        local affectAccessories = Toggles.NoclipAffectAccessories.Value

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA('BasePart') then
                local isAccessory = part.Parent:IsA('Accessory') or (part.Parent.Parent and part.Parent.Parent:IsA('Accessory'))
                local isHead = part.Name == 'Head'

                if isAccessory then
                    if affectAccessories then
                        part.CanCollide = false
                        if transparency > 0 then
                            if OriginalTransparencies[part] == nil then
                                OriginalTransparencies[part] = part.Transparency
                            end
                            part.Transparency = math.max(part.Transparency, transparency)
                        end
                    end
                else
                    part.CanCollide = false
                    if transparency > 0 and not isHead then
                        if OriginalTransparencies[part] == nil then
                            OriginalTransparencies[part] = part.Transparency
                        end
                        part.Transparency = math.max(part.Transparency, transparency)
                    end
                end
            end
        end
    end

    local function restoreNoclipTransparency()
        for part, originalTransparency in pairs(OriginalTransparencies) do
            pcall(function()
                if part and part.Parent then
                    part.Transparency = originalTransparency
                end
            end)
        end
        table.clear(OriginalTransparencies)
    end

    Toggles.NoclipEnabled:OnChanged(function()
        if Toggles.NoclipEnabled.Value then
            Connections.NoclipStepped = RunService.Stepped:Connect(function()
                if Toggles.NoclipEnabled.Value then
                    applyNoclip()
                end
            end)
        else
            cleanupConnection('NoclipStepped')
            restoreNoclipTransparency()
        end
    end)

    -- ═══════════════════════════════════════════
    -- 3. FLY
    -- ═══════════════════════════════════════════
    FlyGroup:AddToggle('FlyEnabled', {
        Text = 'Enable Fly',
        Default = false,
        Tooltip = 'Fly around the map freely',
    })

    Toggles.FlyEnabled:AddKeyPicker('FlyKeybind', {
        Default = 'F',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Fly',
        NoUI = false,
    })

    local FlyDepbox = FlyGroup:AddDependencyBox()

    FlyDepbox:AddSlider('FlySpeed', {
        Text = 'Fly Speed',
        Default = 50,
        Min = 10,
        Max = 500,
        Rounding = 0,
    })

    FlyDepbox:AddToggle('FlySmoothCamera', {
        Text = 'Smooth Camera',
        Default = true,
        Tooltip = 'Smooth camera movement while flying',
    })

    FlyDepbox:AddToggle('FlyAutoAltitude', {
        Text = 'Auto Altitude',
        Default = false,
        Tooltip = 'Automatically maintain a set altitude',
    })

    local FlyAltDepbox = FlyDepbox:AddDependencyBox()

    FlyAltDepbox:AddSlider('FlyAltitude', {
        Text = 'Target Altitude',
        Default = 50,
        Min = 10,
        Max = 500,
        Rounding = 0,
        Suffix = ' studs',
    })

    FlyAltDepbox:SetupDependencies({
        { Toggles.FlyAutoAltitude, true },
    })

    FlyDepbox:SetupDependencies({
        { Toggles.FlyEnabled, true },
    })

    -- Fly Logic
    local function startFly()
        local character = getCharacter()
        if not character then
            return
        end
        local hrp = getHumanoidRootPart()
        if not hrp then
            return
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = true
        end

        FlyBodyVelocity = Instance.new('BodyVelocity')
        FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.P = 9000
        FlyBodyVelocity.Parent = hrp

        FlyBodyGyro = Instance.new('BodyGyro')
        FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        FlyBodyGyro.D = 200
        FlyBodyGyro.P = 40000
        FlyBodyGyro.CFrame = hrp.CFrame
        FlyBodyGyro.Parent = hrp

        FlyActive = true

        Connections.FlyInputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end
            if input.KeyCode == Enum.KeyCode.W then
                FlyKeys.W = true
            elseif input.KeyCode == Enum.KeyCode.A then
                FlyKeys.A = true
            elseif input.KeyCode == Enum.KeyCode.S then
                FlyKeys.S = true
            elseif input.KeyCode == Enum.KeyCode.D then
                FlyKeys.D = true
            elseif input.KeyCode == Enum.KeyCode.Space then
                FlyKeys.Space = true
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                FlyKeys.LeftShift = true
            end
        end)

        Connections.FlyInputEnded = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                FlyKeys.W = false
            elseif input.KeyCode == Enum.KeyCode.A then
                FlyKeys.A = false
            elseif input.KeyCode == Enum.KeyCode.S then
                FlyKeys.S = false
            elseif input.KeyCode == Enum.KeyCode.D then
                FlyKeys.D = false
            elseif input.KeyCode == Enum.KeyCode.Space then
                FlyKeys.Space = false
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                FlyKeys.LeftShift = false
            end
        end)

        Connections.FlyUpdate = RunService.RenderStepped:Connect(function()
            if not FlyActive then
                return
            end
            if not FlyBodyVelocity or not FlyBodyVelocity.Parent then
                return
            end
            if not FlyBodyGyro or not FlyBodyGyro.Parent then
                return
            end

            local camera = Workspace.CurrentCamera
            if not camera then
                return
            end

            local speed = Options.FlySpeed.Value
            local direction = Vector3.new(0, 0, 0)
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector

            if FlyKeys.W then
                direction = direction + lookVector
            end
            if FlyKeys.S then
                direction = direction - lookVector
            end
            if FlyKeys.A then
                direction = direction - rightVector
            end
            if FlyKeys.D then
                direction = direction + rightVector
            end
            if FlyKeys.Space then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if FlyKeys.LeftShift then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit
            end

            local targetVelocity = direction * speed

            -- Auto altitude enforcement
            if Toggles.FlyAutoAltitude.Value then
                local currentHrp = getHumanoidRootPart()
                if currentHrp then
                    local targetAlt = Options.FlyAltitude.Value
                    local currentAlt = currentHrp.Position.Y
                    local altDiff = targetAlt - currentAlt

                    if math.abs(altDiff) > 1 and not FlyKeys.Space and not FlyKeys.LeftShift then
                        local altCorrection = math.clamp(altDiff, -speed, speed)
                        targetVelocity = targetVelocity + Vector3.new(0, altCorrection, 0)
                    end
                end
            end

            FlyBodyVelocity.Velocity = targetVelocity

            if Toggles.FlySmoothCamera.Value then
                FlyBodyGyro.CFrame = camera.CFrame
            else
                if direction.Magnitude > 0 then
                    FlyBodyGyro.CFrame = CFrame.lookAt(Vector3.new(0, 0, 0), direction)
                end
            end
        end)
    end

    local function stopFly()
        FlyActive = false

        cleanupConnection('FlyInputBegan')
        cleanupConnection('FlyInputEnded')
        cleanupConnection('FlyUpdate')

        destroyBodyMover(FlyBodyVelocity)
        destroyBodyMover(FlyBodyGyro)
        FlyBodyVelocity = nil
        FlyBodyGyro = nil

        -- Reset key states
        FlyKeys.W = false
        FlyKeys.A = false
        FlyKeys.S = false
        FlyKeys.D = false
        FlyKeys.Space = false
        FlyKeys.LeftShift = false

        local humanoid = getHumanoid()
        if humanoid then
            pcall(function()
                humanoid.PlatformStand = false
            end)
        end
    end

    Toggles.FlyEnabled:OnChanged(function()
        if Toggles.FlyEnabled.Value then
            startFly()
        else
            stopFly()
        end
    end)

    -- Reconnect fly on character respawn
    Connections.FlyCharacterAdded = LocalPlayer.CharacterAdded:Connect(function()
        if Toggles.FlyEnabled.Value then
            stopFly()
            task.wait(0.5)
            if Toggles.FlyEnabled.Value then
                startFly()
            end
        end
    end)

    -- ═══════════════════════════════════════════
    -- 4. TELEPORT TO PLAYER
    -- ═══════════════════════════════════════════
    TpGroup:AddDropdown('TpTargetPlayer', {
        SpecialType = 'Player',
        Text = 'Target Player',
        Tooltip = 'Select the player to teleport to',
    })

    TpGroup:AddToggle('TpBehind', {
        Text = 'Teleport Behind Target',
        Default = false,
        Tooltip = 'Appear behind the target player',
    })

    TpGroup:AddSlider('TpOffsetDistance', {
        Text = 'Offset Distance',
        Default = 5,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Suffix = ' studs',
    })

    TpGroup:AddToggle('TpNotify', {
        Text = 'Show Notification',
        Default = true,
        Tooltip = 'Notify when teleport completes',
    })

    TpGroup:AddButton({
        Text = 'Teleport Now',
        Func = function()
            pcall(function()
                local targetName = Options.TpTargetPlayer.Value
                if not targetName or targetName == '' then
                    notify('No target player selected!', 2)
                    return
                end

                local targetPlayer = Players:FindFirstChild(targetName)
                if not targetPlayer then
                    notify('Target player not found!', 2)
                    return
                end

                local hrp = getHumanoidRootPart()
                local targetHrp = getHumanoidRootPart(targetPlayer)
                if not hrp or not targetHrp then
                    notify('Character not found!', 2)
                    return
                end

                local offset = Options.TpOffsetDistance.Value
                local targetCFrame = targetHrp.CFrame

                if Toggles.TpBehind.Value then
                    targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, offset)
                elseif offset > 0 then
                    targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, -offset)
                end

                safeSetCFrame(hrp, targetCFrame)

                if Toggles.TpNotify.Value then
                    notify('Teleported to ' .. targetPlayer.Name, 2)
                end
            end)
        end,
        Tooltip = 'Teleport to the selected player',
    })

    TpGroup:AddDivider()

    TpGroup:AddToggle('TpLoop', {
        Text = 'Loop Teleport',
        Default = false,
        Tooltip = 'Continuously teleport to the target',
    })

    local TpLoopDepbox = TpGroup:AddDependencyBox()

    TpLoopDepbox:AddSlider('TpLoopInterval', {
        Text = 'Loop Interval (s)',
        Default = 0.5,
        Min = 0.1,
        Max = 5,
        Rounding = 1,
        Suffix = 's',
    })

    TpLoopDepbox:SetupDependencies({
        { Toggles.TpLoop, true },
    })

    -- Teleport Loop Logic
    local TpLoopRunning = false

    Toggles.TpLoop:OnChanged(function()
        if Toggles.TpLoop.Value then
            if TpLoopRunning then
                return
            end
            TpLoopRunning = true

            task.spawn(function()
                while TpLoopRunning and Toggles.TpLoop.Value do
                    pcall(function()
                        local targetName = Options.TpTargetPlayer.Value
                        if not targetName or targetName == '' then
                            return
                        end

                        local targetPlayer = Players:FindFirstChild(targetName)
                        if not targetPlayer then
                            return
                        end

                        local hrp = getHumanoidRootPart()
                        local targetHrp = getHumanoidRootPart(targetPlayer)
                        if not hrp or not targetHrp then
                            return
                        end

                        local offset = Options.TpOffsetDistance.Value
                        local targetCFrame = targetHrp.CFrame

                        if Toggles.TpBehind.Value then
                            targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, offset)
                        elseif offset > 0 then
                            targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, -offset)
                        end

                        safeSetCFrame(hrp, targetCFrame)
                    end)
                    task.wait(Options.TpLoopInterval.Value)
                end
                TpLoopRunning = false
            end)
        else
            TpLoopRunning = false
        end
    end)

    -- ═══════════════════════════════════════════
    -- 5. ANNOY PLAYER
    -- ═══════════════════════════════════════════
    AnnoyGroup:AddToggle('AnnoyEnabled', {
        Text = 'Enable Annoy',
        Default = false,
        Tooltip = 'Follow and annoy the target player',
    })

    local AnnoyDepbox = AnnoyGroup:AddDependencyBox()

    AnnoyDepbox:AddDropdown('AnnoyTarget', {
        SpecialType = 'Player',
        Text = 'Target Player',
        Tooltip = 'Select the player to annoy',
    })

    AnnoyDepbox:AddSlider('AnnoyDistance', {
        Text = 'Follow Distance',
        Default = 3,
        Min = 1,
        Max = 15,
        Rounding = 1,
        Suffix = ' studs',
    })

    AnnoyDepbox:AddToggle('AnnoyAutoJump', {
        Text = 'Auto Jump',
        Default = false,
        Tooltip = 'Automatically jump while following',
    })

    AnnoyDepbox:AddToggle('AnnoyFaceTarget', {
        Text = 'Face Target',
        Default = true,
        Tooltip = 'Always face toward the target player',
    })

    AnnoyDepbox:AddToggle('AnnoyMatchSpeed', {
        Text = 'Match Speed',
        Default = false,
        Tooltip = 'Match the target player movement speed',
    })

    AnnoyDepbox:SetupDependencies({
        { Toggles.AnnoyEnabled, true },
    })

    -- Annoy Logic
    Toggles.AnnoyEnabled:OnChanged(function()
        if Toggles.AnnoyEnabled.Value then
            Connections.AnnoyHeartbeat = RunService.Heartbeat:Connect(function()
                if not Toggles.AnnoyEnabled.Value then
                    return
                end

                pcall(function()
                    local targetName = Options.AnnoyTarget.Value
                    if not targetName or targetName == '' then
                        return
                    end

                    local targetPlayer = Players:FindFirstChild(targetName)
                    if not targetPlayer or targetPlayer == LocalPlayer then
                        return
                    end

                    local humanoid = getHumanoid()
                    local hrp = getHumanoidRootPart()
                    local targetHrp = getHumanoidRootPart(targetPlayer)

                    if not humanoid or not hrp or not targetHrp then
                        return
                    end

                    local distance = Options.AnnoyDistance.Value
                    local targetPosition = targetHrp.Position
                    local direction = (targetPosition - hrp.Position)
                    local currentDistance = direction.Magnitude

                    -- Move toward target if too far away
                    if currentDistance > distance then
                        local moveTarget = targetPosition - direction.Unit * distance
                        humanoid:MoveTo(moveTarget)

                        -- Match target speed
                        if Toggles.AnnoyMatchSpeed.Value then
                            local targetHumanoid = getHumanoid(targetPlayer)
                            if targetHumanoid then
                                humanoid.WalkSpeed = targetHumanoid.WalkSpeed
                            end
                        end
                    end

                    -- Face target
                    if Toggles.AnnoyFaceTarget.Value and currentDistance > 1 then
                        local lookCFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPosition.X, hrp.Position.Y, targetPosition.Z))
                        safeSetCFrame(hrp, lookCFrame)
                    end

                    -- Auto jump
                    if Toggles.AnnoyAutoJump.Value then
                        if currentDistance > distance * 1.5 then
                            humanoid.Jump = true
                        end
                    end
                end)
            end)
        else
            cleanupConnection('AnnoyHeartbeat')
        end
    end)

    -- ═══════════════════════════════════════════
    -- 6. ORBIT PLAYER
    -- ═══════════════════════════════════════════
    OrbitGroup:AddToggle('OrbitEnabled', {
        Text = 'Enable Orbit',
        Default = false,
        Tooltip = 'Orbit around a target player',
    })

    local OrbitDepbox = OrbitGroup:AddDependencyBox()

    OrbitDepbox:AddDropdown('OrbitTarget', {
        SpecialType = 'Player',
        Text = 'Target Player',
        Tooltip = 'Select the player to orbit around',
    })

    OrbitDepbox:AddSlider('OrbitRadius', {
        Text = 'Orbit Radius',
        Default = 15,
        Min = 5,
        Max = 50,
        Rounding = 0,
        Suffix = ' studs',
    })

    OrbitDepbox:AddSlider('OrbitSpeed', {
        Text = 'Orbit Speed',
        Default = 5,
        Min = 1,
        Max = 20,
        Rounding = 1,
    })

    OrbitDepbox:AddDropdown('OrbitAxis', {
        Values = { 'Horizontal', 'Vertical', 'Diagonal' },
        Default = 1,
        Multi = false,
        Text = 'Orbit Axis',
        Tooltip = 'The axis to orbit around',
    })

    OrbitDepbox:AddToggle('OrbitAutoHeight', {
        Text = 'Auto Height',
        Default = true,
        Tooltip = 'Match the target player height while orbiting',
    })

    OrbitDepbox:AddToggle('OrbitTrail', {
        Text = 'Show Trail',
        Default = false,
        Tooltip = 'Display a trail effect while orbiting',
    })

    OrbitDepbox:SetupDependencies({
        { Toggles.OrbitEnabled, true },
    })

    -- Orbit Trail management
    local function destroyOrbitTrail()
        pcall(function()
            if TrailInstance then
                TrailInstance:Destroy()
                TrailInstance = nil
            end
            if TrailAttachment0 then
                TrailAttachment0:Destroy()
                TrailAttachment0 = nil
            end
            if TrailAttachment1 then
                TrailAttachment1:Destroy()
                TrailAttachment1 = nil
            end
        end)
    end

    local function createOrbitTrail()
        pcall(function()
            local character = getCharacter()
            if not character then
                return
            end
            local hrp = getHumanoidRootPart()
            if not hrp then
                return
            end

            destroyOrbitTrail()

            TrailAttachment0 = Instance.new('Attachment')
            TrailAttachment0.Position = Vector3.new(0, 1, 0)
            TrailAttachment0.Parent = hrp

            TrailAttachment1 = Instance.new('Attachment')
            TrailAttachment1.Position = Vector3.new(0, -1, 0)
            TrailAttachment1.Parent = hrp

            TrailInstance = Instance.new('Trail')
            TrailInstance.Attachment0 = TrailAttachment0
            TrailInstance.Attachment1 = TrailAttachment1
            TrailInstance.Lifetime = 0.5
            TrailInstance.MinLength = 0.1
            TrailInstance.LightEmission = 1
            TrailInstance.FaceCamera = true
            TrailInstance.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 112, 219)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 149, 237)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(147, 112, 219)),
            })
            TrailInstance.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            TrailInstance.WidthScale = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            TrailInstance.Parent = hrp
        end)
    end

    -- Orbit Logic
    Toggles.OrbitEnabled:OnChanged(function()
        if Toggles.OrbitEnabled.Value then
            OrbitAngle = 0

            if Toggles.OrbitTrail.Value then
                createOrbitTrail()
            end

            Connections.OrbitHeartbeat = RunService.Heartbeat:Connect(function(deltaTime)
                if not Toggles.OrbitEnabled.Value then
                    return
                end

                pcall(function()
                    local targetName = Options.OrbitTarget.Value
                    if not targetName or targetName == '' then
                        return
                    end

                    local targetPlayer = Players:FindFirstChild(targetName)
                    if not targetPlayer or targetPlayer == LocalPlayer then
                        return
                    end

                    local hrp = getHumanoidRootPart()
                    local targetHrp = getHumanoidRootPart(targetPlayer)
                    if not hrp or not targetHrp then
                        return
                    end

                    local radius = Options.OrbitRadius.Value
                    local speed = Options.OrbitSpeed.Value
                    local axis = Options.OrbitAxis.Value

                    OrbitAngle = OrbitAngle + (speed * deltaTime * 2)
                    if OrbitAngle > math.pi * 2 then
                        OrbitAngle = OrbitAngle - math.pi * 2
                    end

                    local targetPos = targetHrp.Position
                    local orbitPos

                    if axis == 'Horizontal' then
                        local offsetX = math.cos(OrbitAngle) * radius
                        local offsetZ = math.sin(OrbitAngle) * radius
                        local heightOffset = 0
                        if Toggles.OrbitAutoHeight.Value then
                            heightOffset = 0
                        else
                            heightOffset = hrp.Position.Y - targetPos.Y
                        end
                        orbitPos = Vector3.new(
                            targetPos.X + offsetX,
                            targetPos.Y + heightOffset,
                            targetPos.Z + offsetZ
                        )
                    elseif axis == 'Vertical' then
                        local offsetX = math.cos(OrbitAngle) * radius
                        local offsetY = math.sin(OrbitAngle) * radius
                        orbitPos = Vector3.new(
                            targetPos.X + offsetX,
                            targetPos.Y + offsetY,
                            targetPos.Z
                        )
                    elseif axis == 'Diagonal' then
                        local offsetX = math.cos(OrbitAngle) * radius
                        local offsetY = math.sin(OrbitAngle) * radius * 0.5
                        local offsetZ = math.sin(OrbitAngle) * radius
                        orbitPos = Vector3.new(
                            targetPos.X + offsetX,
                            targetPos.Y + offsetY,
                            targetPos.Z + offsetZ
                        )
                    end

                    if orbitPos then
                        local lookCFrame = CFrame.lookAt(orbitPos, targetPos)
                        safeSetCFrame(hrp, lookCFrame)
                    end
                end)
            end)
        else
            cleanupConnection('OrbitHeartbeat')
            destroyOrbitTrail()
            OrbitAngle = 0
        end
    end)

    Toggles.OrbitTrail:OnChanged(function()
        if Toggles.OrbitEnabled.Value then
            if Toggles.OrbitTrail.Value then
                createOrbitTrail()
            else
                destroyOrbitTrail()
            end
        end
    end)

    -- ═══════════════════════════════════════════
    -- 7. CHARACTER TROLL
    -- ═══════════════════════════════════════════
    CharGroup:AddToggle('CharSpinEnabled', {
        Text = 'Spin Character',
        Default = false,
        Tooltip = 'Spin your character continuously',
    })

    local CharSpinDepbox = CharGroup:AddDependencyBox()

    CharSpinDepbox:AddSlider('CharSpinSpeed', {
        Text = 'Spin Speed',
        Default = 10,
        Min = 1,
        Max = 100,
        Rounding = 0,
    })

    CharSpinDepbox:SetupDependencies({
        { Toggles.CharSpinEnabled, true },
    })

    CharGroup:AddDivider()

    CharGroup:AddToggle('CharHeadless', {
        Text = 'Headless Mode',
        Default = false,
        Tooltip = 'Hide your character head',
    })

    CharGroup:AddDivider()

    CharGroup:AddToggle('CharSitLoop', {
        Text = 'Sit Loop',
        Default = false,
        Tooltip = 'Repeatedly sit and stand',
    })

    local CharSitDepbox = CharGroup:AddDependencyBox()

    CharSitDepbox:AddSlider('CharSitInterval', {
        Text = 'Sit Interval (s)',
        Default = 0.5,
        Min = 0.1,
        Max = 2,
        Rounding = 1,
        Suffix = 's',
    })

    CharSitDepbox:SetupDependencies({
        { Toggles.CharSitLoop, true },
    })

    CharGroup:AddDivider()

    CharGroup:AddDropdown('CharAnimation', {
        Values = AnimationNames,
        Default = 1,
        Multi = false,
        Text = 'Animation',
        Tooltip = 'Select an animation to play',
    })

    CharGroup:AddButton({
        Text = 'Play Animation',
        Func = function()
            pcall(function()
                local selectedAnim = Options.CharAnimation.Value
                if not selectedAnim or selectedAnim == '' then
                    notify('No animation selected!', 2)
                    return
                end

                local animId = AnimationIds[selectedAnim]
                if not animId then
                    notify('Animation ID not found!', 2)
                    return
                end

                local humanoid = getHumanoid()
                if not humanoid then
                    notify('Humanoid not found!', 2)
                    return
                end

                local animator = humanoid:FindFirstChildOfClass('Animator')
                if not animator then
                    animator = Instance.new('Animator')
                    animator.Parent = humanoid
                end

                -- Stop current animation
                if CurrentAnimationTrack then
                    pcall(function()
                        CurrentAnimationTrack:Stop()
                    end)
                    CurrentAnimationTrack = nil
                end

                local animation = Instance.new('Animation')
                animation.AnimationId = animId

                local track = animator:LoadAnimation(animation)
                track.Priority = Enum.AnimationPriority.Action
                track.Looped = true
                track:Play()
                CurrentAnimationTrack = track

                animation:Destroy()

                notify('Playing animation: ' .. selectedAnim, 2)
            end)
        end,
        Tooltip = 'Play the selected animation',
    })

    CharGroup:AddButton({
        Text = 'Reset Character',
        Func = function()
            pcall(function()
                -- Stop animation
                if CurrentAnimationTrack then
                    pcall(function()
                        CurrentAnimationTrack:Stop()
                    end)
                    CurrentAnimationTrack = nil
                end

                -- Reset headless
                if Toggles.CharHeadless.Value then
                    Toggles.CharHeadless:SetValue(false)
                end

                -- Reset spin
                if Toggles.CharSpinEnabled.Value then
                    Toggles.CharSpinEnabled:SetValue(false)
                end

                -- Reset sit loop
                if Toggles.CharSitLoop.Value then
                    Toggles.CharSitLoop:SetValue(false)
                end

                -- Respawn character
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid.Health = 0
                end

                notify('Character has been reset', 2)
            end)
        end,
        DoubleClick = true,
        Tooltip = 'Double-click to reset your character completely',
    })

    -- Character Spin Logic
    Toggles.CharSpinEnabled:OnChanged(function()
        if Toggles.CharSpinEnabled.Value then
            CharSpinAngle = 0

            Connections.CharSpinRender = RunService.RenderStepped:Connect(function(deltaTime)
                if not Toggles.CharSpinEnabled.Value then
                    return
                end

                pcall(function()
                    local hrp = getHumanoidRootPart()
                    if not hrp then
                        return
                    end

                    local speed = Options.CharSpinSpeed.Value
                    CharSpinAngle = CharSpinAngle + (speed * deltaTime * 10)
                    if CharSpinAngle > 360 then
                        CharSpinAngle = CharSpinAngle - 360
                    end

                    local currentPos = hrp.Position
                    hrp.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(CharSpinAngle), 0)
                end)
            end)
        else
            cleanupConnection('CharSpinRender')
            CharSpinAngle = 0
        end
    end)

    -- Headless Logic
    local HeadOriginalTransparency = nil
    local FaceOriginalTransparency = nil

    Toggles.CharHeadless:OnChanged(function()
        pcall(function()
            local character = getCharacter()
            if not character then
                return
            end

            local head = character:FindFirstChild('Head')
            if not head then
                return
            end

            if Toggles.CharHeadless.Value then
                HeadOriginalTransparency = head.Transparency
                head.Transparency = 1

                local face = head:FindFirstChildOfClass('Decal')
                if face then
                    FaceOriginalTransparency = face.Transparency
                    face.Transparency = 1
                end

                -- Hide head mesh if present
                for _, descendant in ipairs(head:GetDescendants()) do
                    if descendant:IsA('SpecialMesh') then
                        descendant.Scale = Vector3.new(0, 0, 0)
                    end
                end
            else
                head.Transparency = HeadOriginalTransparency or 0
                HeadOriginalTransparency = nil

                local face = head:FindFirstChildOfClass('Decal')
                if face then
                    face.Transparency = FaceOriginalTransparency or 0
                    FaceOriginalTransparency = nil
                end

                -- Restore head mesh
                for _, descendant in ipairs(head:GetDescendants()) do
                    if descendant:IsA('SpecialMesh') then
                        descendant.Scale = Vector3.new(1, 1, 1)
                    end
                end
            end
        end)
    end)

    -- Sit Loop Logic
    Toggles.CharSitLoop:OnChanged(function()
        if Toggles.CharSitLoop.Value then
            if SitLoopRunning then
                return
            end
            SitLoopRunning = true

            task.spawn(function()
                while SitLoopRunning and Toggles.CharSitLoop.Value do
                    pcall(function()
                        local humanoid = getHumanoid()
                        if humanoid then
                            humanoid.Sit = true
                            task.wait(Options.CharSitInterval.Value)
                            if humanoid and humanoid.Parent then
                                humanoid.Sit = false
                            end
                        end
                    end)
                    task.wait(0.1)
                end
                SitLoopRunning = false
            end)
        else
            SitLoopRunning = false
            pcall(function()
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid.Sit = false
                end
            end)
        end
    end)

    -- ═══════════════════════════════════════════
    -- GLOBAL CHARACTER RESPAWN HANDLER
    -- ═══════════════════════════════════════════
    Connections.CharacterRespawn = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)

        -- Restore noclip if active
        if Toggles.NoclipEnabled.Value then
            table.clear(OriginalTransparencies)
        end

        -- Restore headless if active
        if Toggles.CharHeadless.Value then
            HeadOriginalTransparency = nil
            FaceOriginalTransparency = nil
            pcall(function()
                local head = character:FindFirstChild('Head')
                if head then
                    HeadOriginalTransparency = head.Transparency
                    head.Transparency = 1
                    local face = head:FindFirstChildOfClass('Decal')
                    if face then
                        FaceOriginalTransparency = face.Transparency
                        face.Transparency = 1
                    end
                    for _, descendant in ipairs(head:GetDescendants()) do
                        if descendant:IsA('SpecialMesh') then
                            descendant.Scale = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end)
        end

        -- Recreate orbit trail if active
        if Toggles.OrbitEnabled.Value and Toggles.OrbitTrail.Value then
            task.wait(0.3)
            createOrbitTrail()
        end

        -- Reconnect fling touch if active
        if Toggles.FlingEnabled.Value and Toggles.FlingOnTouch.Value then
            task.wait(0.3)
            setupFlingOnTouch()
        end

        -- Reset animation track reference on respawn
        CurrentAnimationTrack = nil
    end)

    -- ═══════════════════════════════════════════
    -- UNLOAD / CLEANUP
    -- ═══════════════════════════════════════════
    Library:OnUnload(function()
        -- Stop all active features
        FlingRunning = false
        FlyActive = false
        SitLoopRunning = false
        TpLoopRunning = false

        -- Stop fly body movers
        destroyBodyMover(FlyBodyVelocity)
        destroyBodyMover(FlyBodyGyro)
        FlyBodyVelocity = nil
        FlyBodyGyro = nil

        -- Restore humanoid state
        pcall(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.PlatformStand = false
                humanoid.Sit = false
            end
        end)

        -- Restore noclip transparency
        restoreNoclipTransparency()

        -- Restore headless
        pcall(function()
            local character = getCharacter()
            if character then
                local head = character:FindFirstChild('Head')
                if head then
                    head.Transparency = HeadOriginalTransparency or 0
                    local face = head:FindFirstChildOfClass('Decal')
                    if face then
                        face.Transparency = FaceOriginalTransparency or 0
                    end
                    for _, descendant in ipairs(head:GetDescendants()) do
                        if descendant:IsA('SpecialMesh') then
                            descendant.Scale = Vector3.new(1, 1, 1)
                        end
                    end
                end
            end
        end)

        -- Destroy orbit trail
        destroyOrbitTrail()

        -- Stop animation
        if CurrentAnimationTrack then
            pcall(function()
                CurrentAnimationTrack:Stop()
            end)
            CurrentAnimationTrack = nil
        end

        -- Disconnect all connections
        cleanupAllConnections()
    end)
end
