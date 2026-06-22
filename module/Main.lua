-- 🌙 LunarHUB | Main Module
-- Welcome & Development Status

return function(Library, Window, Tabs, ThemeManager, SaveManager)
    local Tab = Tabs.Main

    -- ═══════════════════════════════════════════
    -- LEFT SIDE: Welcome & Info
    -- ═══════════════════════════════════════════
    local WelcomeGroup = Tab:AddLeftGroupbox('🌙 Welcome to LunarHUB')

    WelcomeGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    WelcomeGroup:AddLabel('  🌙 LunarHUB — Premium Universal Script')
    WelcomeGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    WelcomeGroup:AddLabel('')
    WelcomeGroup:AddLabel('  Welcome back, Explorer! 🚀')
    WelcomeGroup:AddLabel('  Thank you for choosing LunarHUB.')
    WelcomeGroup:AddLabel('  We are working hard to bring you')
    WelcomeGroup:AddLabel('  the best experience possible.')
    WelcomeGroup:AddLabel('')
    WelcomeGroup:AddLabel('  Current Status: 🔧 In Development')
    WelcomeGroup:AddLabel('  Version: v0.1.0-alpha')
    WelcomeGroup:AddLabel('')

    local StatusGroup = Tab:AddLeftGroupbox('📋 Development Status')

    StatusGroup:AddLabel('Last Updated: June 22, 2026', true)
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('  💬 A Message from the Developer:', true)
    StatusGroup:AddLabel('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    StatusGroup:AddLabel('')
    StatusGroup:AddLabel(
        'Hey there! 💀💀\n\n' ..
        'Yay, I\'m just developing! This tab is still\n' ..
        'a work in progress. I know many of you have\n' ..
        'been waiting patiently for new features, and\n' ..
        'I truly appreciate your patience.\n\n' ..
        'I\'m deeply sorry for the long wait. 🙏\n' ..
        'Building something great takes time, and I\n' ..
        'want to make sure LunarHUB delivers the\n' ..
        'quality experience you all deserve.\n\n' ..
        'Every day, I\'m pouring hours into coding,\n' ..
        'testing, and refining each feature. Your\n' ..
        'support keeps me going! ❤️\n\n' ..
        'Thank you for sticking with me through\n' ..
        'this journey. The best is yet to come! 🌟',
        true
    )

    -- ═══════════════════════════════════════════
    -- RIGHT SIDE: Changelog & Roadmap
    -- ═══════════════════════════════════════════
    local ChangelogGroup = Tab:AddRightGroupbox('📝 Changelog')

    ChangelogGroup:AddLabel('v0.1.0-alpha — June 22, 2026', true)
    ChangelogGroup:AddLabel('')
    ChangelogGroup:AddLabel(
        '✅ Initial framework setup\n' ..
        '✅ LinoriaLib integration\n' ..
        '✅ Module loading system\n' ..
        '✅ Troll tab — 7 features\n' ..
        '✅ Script Settings — Full suite\n' ..
        '✅ Rainbow UI system\n' ..
        '✅ Encrypted config export/import\n' ..
        '🔄 Visual tab — Coming soon\n' ..
        '🔄 World tab — Coming soon\n' ..
        '🔄 Player tab — Coming soon',
        true
    )

    local RoadmapGroup = Tab:AddRightGroupbox('🗺️ Roadmap')

    RoadmapGroup:AddLabel(
        '📌 Phase 1 (Current):\n' ..
        '   • Universal Troll Features\n' ..
        '   • Core Settings & Configuration\n' ..
        '   • Rainbow UI System\n\n' ..
        '📌 Phase 2 (Coming Soon):\n' ..
        '   • Full ESP System\n' ..
        '   • Player Visuals\n' ..
        '   • World Modifications\n\n' ..
        '📌 Phase 3 (Future):\n' ..
        '   • Game-Specific Modules\n' ..
        '   • Custom Script Hub API\n' ..
        '   • Community Features',
        true
    )

    local CreditsGroup = Tab:AddRightGroupbox('💎 Credits')

    CreditsGroup:AddLabel('Developer: heasang')
    CreditsGroup:AddLabel('UI Library: LinoriaLib')
    CreditsGroup:AddLabel('Framework: LunarHUB')
    CreditsGroup:AddLabel('')
    CreditsGroup:AddLabel('Thank you for your support! 🌙')
end
