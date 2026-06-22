-- 🌙 LunarHUB | Visual Module
-- ESP, Chams, Tracers, and more (Coming Soon)

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local Tab = Tabs.Visual

    -- ═══════════════════════════════════════════
    -- LEFT SIDE: Status Message
    -- ═══════════════════════════════════════════
    local StatusGroup = Tab:AddLeftGroupbox('🎨 Visual Features')

    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('  🎨 Visual Module')
    StatusGroup:AddLabel('  Status: 🔧 Under Development')
    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel('Last Updated: June 22, 2026', true)
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel(
        'Hey there! 💀💀\n\n' ..
        'The Visual tab is still cooking! 🍳\n' ..
        'I\'m working on bringing you an amazing\n' ..
        'set of visual features.\n\n' ..
        'I\'m so sorry for making you wait this\n' ..
        'long. I know how much you all want ESP,\n' ..
        'Chams, Tracers, and all the good stuff.\n' ..
        'Trust me, it\'s going to be worth the\n' ..
        'wait! 🙏\n\n' ..
        'I\'ve been spending countless nights\n' ..
        'perfecting the rendering pipeline to\n' ..
        'ensure smooth performance even with\n' ..
        'all visual features enabled.\n\n' ..
        'Please bear with me just a little\n' ..
        'longer. Your patience means the world\n' ..
        'to me! ❤️',
        true
    )

    -- ═══════════════════════════════════════════
    -- RIGHT SIDE: Planned Features
    -- ═══════════════════════════════════════════
    local PlannedGroup = Tab:AddRightGroupbox('📋 Planned Features')

    PlannedGroup:AddLabel(
        '🔜 Coming Soon:\n\n' ..
        '👁️ Player ESP\n' ..
        '   • Box ESP (2D / 3D / Corner)\n' ..
        '   • Name Tags\n' ..
        '   • Health Bars\n' ..
        '   • Distance Labels\n' ..
        '   • Skeleton ESP\n\n' ..
        '🎯 Chams\n' ..
        '   • Player Chams\n' ..
        '   • Visible / Hidden Colors\n' ..
        '   • Transparency Control\n\n' ..
        '📍 Tracers\n' ..
        '   • Bottom / Center / Mouse Origin\n' ..
        '   • Color by Team / Distance\n\n' ..
        '💡 World Visuals\n' ..
        '   • Fullbright\n' ..
        '   • No Fog\n' ..
        '   • Custom Skybox\n' ..
        '   • Ambient Lighting',
        true
    )

    local EtaGroup = Tab:AddRightGroupbox('⏰ Estimated Arrival')

    EtaGroup:AddLabel('Visual features are expected in')
    EtaGroup:AddLabel('the next major update (Phase 2).')
    EtaGroup:AddLabel('')
    EtaGroup:AddLabel('Stay tuned and thank you for')
    EtaGroup:AddLabel('your incredible patience! 🌙')
end
