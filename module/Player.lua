-- 🌙 LunarHUB | Player Module
-- Player Utilities, Speed, Jump, and more (Coming Soon)

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local Tab = Tabs.Player

    -- ═══════════════════════════════════════════
    -- LEFT SIDE: Status Message
    -- ═══════════════════════════════════════════
    local StatusGroup = Tab:AddLeftGroupbox('🧑 Player Features')

    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('  🧑 Player Module')
    StatusGroup:AddLabel('  Status: 🔧 Under Development')
    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel('Last Updated: June 22, 2026', true)
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel(
        'Hey there! 💀💀\n\n' ..
        'The Player tab is coming together\n' ..
        'piece by piece! 🧩\n\n' ..
        'I owe you all a huge apology for the\n' ..
        'wait. I know player utilities are one\n' ..
        'of the most requested features, and\n' ..
        'not having them ready must be\n' ..
        'frustrating. I\'m truly sorry. 😞\n\n' ..
        'But I promise — when these features\n' ..
        'drop, they\'re going to blow your mind!\n' ..
        'WalkSpeed, JumpPower, custom physics,\n' ..
        'anti-void, god mode attempts... the\n' ..
        'whole package! 🎁\n\n' ..
        'I\'m testing every single feature to\n' ..
        'make sure they work flawlessly across\n' ..
        'as many games as possible.\n\n' ..
        'Thank you for believing in LunarHUB.\n' ..
        'You are what makes this project\n' ..
        'worth building! 💜\n\n' ..
        'The wait will be over soon. I promise.',
        true
    )

    -- ═══════════════════════════════════════════
    -- RIGHT SIDE: Planned Features
    -- ═══════════════════════════════════════════
    local PlannedGroup = Tab:AddRightGroupbox('📋 Planned Features')

    PlannedGroup:AddLabel(
        '🔜 Coming Soon:\n\n' ..
        '🏃 Movement\n' ..
        '   • WalkSpeed Modifier\n' ..
        '   • JumpPower Modifier\n' ..
        '   • Infinite Jump\n' ..
        '   • Anti-Slowdown\n\n' ..
        '🛡️ Character\n' ..
        '   • God Mode (Client)\n' ..
        '   • Anti-Void\n' ..
        '   • No Fall Damage\n' ..
        '   • Auto Respawn\n\n' ..
        '🔧 Utilities\n' ..
        '   • Click Teleport\n' ..
        '   • Freecam\n' ..
        '   • Third Person Mod\n' ..
        '   • FOV Changer\n\n' ..
        '📊 Info Display\n' ..
        '   • Player Stats Overlay\n' ..
        '   • Coordinates Display\n' ..
        '   • FPS Counter',
        true
    )

    local EtaGroup = Tab:AddRightGroupbox('⏰ Estimated Arrival')

    EtaGroup:AddLabel('Player features are expected in')
    EtaGroup:AddLabel('the next major update (Phase 2).')
    EtaGroup:AddLabel('')
    EtaGroup:AddLabel('Thank you for your incredible')
    EtaGroup:AddLabel('patience and support! 🌙')
end
