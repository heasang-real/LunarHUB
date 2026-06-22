-- 🌙 LunarHUB | World Module
-- World Modifications, Teleports, and more (Coming Soon)

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local Tab = Tabs.World

    -- ═══════════════════════════════════════════
    -- LEFT SIDE: Status Message
    -- ═══════════════════════════════════════════
    local StatusGroup = Tab:AddLeftGroupbox('🌍 World Features')

    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('  🌍 World Module')
    StatusGroup:AddLabel('  Status: 🔧 Under Development')
    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel('Last Updated: June 22, 2026', true)
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel(
        'Hey there! 💀💀\n\n' ..
        'The World tab is being built from\n' ..
        'the ground up! 🏗️\n\n' ..
        'I sincerely apologize for the delay.\n' ..
        'I know you\'ve been eagerly waiting\n' ..
        'for world manipulation features, and\n' ..
        'I feel terrible about making you wait\n' ..
        'this long. 😔\n\n' ..
        'I\'m committed to delivering world-class\n' ..
        '(pun intended 😄) features that will\n' ..
        'transform your gameplay experience.\n\n' ..
        'Every teleport, every modification,\n' ..
        'every tool is being crafted with care.\n' ..
        'Please hang tight — amazing things\n' ..
        'are on the horizon! 🌅\n\n' ..
        'Your loyalty means everything. 💖',
        true
    )

    -- ═══════════════════════════════════════════
    -- RIGHT SIDE: Planned Features
    -- ═══════════════════════════════════════════
    local PlannedGroup = Tab:AddRightGroupbox('📋 Planned Features')

    PlannedGroup:AddLabel(
        '🔜 Coming Soon:\n\n' ..
        '🗺️ Teleportation\n' ..
        '   • Teleport to Waypoints\n' ..
        '   • Custom Waypoint System\n' ..
        '   • Save/Load Locations\n' ..
        '   • Auto-Teleport Loops\n\n' ..
        '🌐 World Modifications\n' ..
        '   • Remove Parts by Type\n' ..
        '   • Unlock All Doors\n' ..
        '   • Remove Invisible Walls\n' ..
        '   • Destroy Obstacles\n\n' ..
        '🔧 Environment\n' ..
        '   • Time of Day Control\n' ..
        '   • Gravity Modifier\n' ..
        '   • Game Speed Control\n\n' ..
        '📦 Workspace Tools\n' ..
        '   • Instance Browser\n' ..
        '   • Property Editor\n' ..
        '   • Delete Tool',
        true
    )

    local EtaGroup = Tab:AddRightGroupbox('⏰ Estimated Arrival')

    EtaGroup:AddLabel('World features are expected in')
    EtaGroup:AddLabel('the next major update (Phase 2).')
    EtaGroup:AddLabel('')
    EtaGroup:AddLabel('We appreciate your patience and')
    EtaGroup:AddLabel('continued support! 🌙')
end
