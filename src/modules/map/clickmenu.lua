local F, C, L = unpack(select(2, ...))
local MAP = F:GetModule('Map')

local list = {
    {
        text = MAINMENU_BUTTON,
        isTitle = true,
        notCheckable = true,
    },
    {
        text = CHARACTER_BUTTON,
        icon = 'Interface\\PVPFrame\\PVP-Banner-Emblem-3',
        func = function()
            if not CharacterFrame:IsShown() then
                ShowUIPanel(CharacterFrame)
                CharacterFrameTab2:Click()
                CharacterFrameTab1:Click()
            else
                HideUIPanel(CharacterFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = PROFESSIONS_BUTTON,
        icon = 'Interface\\MINIMAP\\TRACKING\\Class',
        func = function()
            if InCombatLockdown() then
                UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_IN_COMBAT)
                return
            end
            ToggleProfessionsBook()
        end,
        notCheckable = true,
    },
    {
        text = PLAYERSPELLS_BUTTON,
        icon = 'Interface\\HELPFRAME\\HelpIcon-CharacterStuck',
        func = function()
            if not PlayerSpellsFrame:IsShown() then
                ShowUIPanel(PlayerSpellsFrame)
            else
                HideUIPanel(PlayerSpellsFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = ACHIEVEMENT_BUTTON,
        icon = 'Interface\\MINIMAP\\TRACKING\\QuestBlob',
        func = function()
            if not AchievementFrame then
                C_AddOns.LoadAddOn('Blizzard_AchievementUI')
            end
            if not AchievementFrame:IsShown() then
                ShowUIPanel(AchievementFrame)
            else
                HideUIPanel(AchievementFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = MAP_AND_QUEST_LOG,
        icon = 'Interface\\GossipFrame\\ActiveQuestIcon',
        func = function()
            if not WorldMapFrame:IsShown() then
                ShowUIPanel(WorldMapFrame)
            else
                HideUIPanel(WorldMapFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = COMMUNITIES_FRAME_TITLE,
        icon = 'Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon',
        arg1 = IsInGuild('player'),
        func = function()
            if not CommunitiesFrame then
                C_AddOns.LoadAddOn('Blizzard_Communities')
            end
            if not CommunitiesFrame:IsShown() then
                ShowUIPanel(CommunitiesFrame)
            else
                HideUIPanel(CommunitiesFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = SOCIAL_BUTTON,
        icon = 'Interface\\CHATFRAME\\UI-ChatWhisperIcon',
        func = function()
            if not FriendsFrame:IsShown() then
                ShowUIPanel(FriendsFrame)
            else
                HideUIPanel(FriendsFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = GROUP_FINDER,
        icon = 'Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor',
        func = function()
            if not PVEFrame:IsShown() then
                ShowUIPanel(PVEFrame)
                PVEFrameTab1:Click()
            else
                HideUIPanel(PVEFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = COLLECTIONS,
        icon = 'Interface\\CURSOR\\Crosshair\\WildPetCapturable',
        func = function()
            if not CollectionsJournal then
                C_AddOns.LoadAddOn('Blizzard_Collections')
            end
            if not CollectionsJournal:IsShown() then
                ShowUIPanel(CollectionsJournal)
            else
                HideUIPanel(CollectionsJournal)
            end
        end,
        notCheckable = true,
    },
    {
        text = ADVENTURE_JOURNAL,
        icon = 'Interface\\ENCOUNTERJOURNAL\\UI-EJ-HeroicTextIcon',
        func = function()
            if not EncounterJournal then
                C_AddOns.LoadAddOn('Blizzard_EncounterJournal')
            end
            if not EncounterJournal:IsShown() then
                ShowUIPanel(EncounterJournal)
            else
                HideUIPanel(EncounterJournal)
            end
        end,
        notCheckable = true,
    },
    {
        text = BLIZZARD_STORE,
        icon = 'Interface\\MINIMAP\\TRACKING\\Auctioneer',
        func = function()
            if not StoreFrame then
                C_AddOns.LoadAddOn('Blizzard_StoreUI')
            end
            securecall(ToggleStoreUI)
        end,
        notCheckable = true,
    },
    {
        text = '',
        isTitle = true,
        notCheckable = true,
    },
    {
        text = OTHER,
        isTitle = true,
        notCheckable = true,
    },
    {
        text = GM_EMAIL_NAME,
        icon = 'Interface\\CHATFRAME\\UI-ChatIcon-Blizz',
        func = function()
            if not HelpFrame:IsShown() then
                ShowUIPanel(HelpFrame)
            else
                HideUIPanel(HelpFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = CHANNEL,
        icon = 'Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile',
        func = function()
            if not ChannelFrame:IsShown() then
                ShowUIPanel(ChannelFrame)
            else
                HideUIPanel(ChannelFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = L['Calendar'],
        func = function()
            if not CalendarFrame then
                C_AddOns.LoadAddOn('Blizzard_Calendar')
            end
            if not CalendarFrame:IsShown() then
                ShowUIPanel(CalendarFrame)
            else
                HideUIPanel(CalendarFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = BATTLEFIELD_MINIMAP,
        func = function()
            if not BattlefieldMapFrame then
                C_AddOns.LoadAddOn('Blizzard_BattlefieldMap')
            end
            if not BattlefieldMapFrame:IsShown() then
                ShowUIPanel(BattlefieldMapFrame)
            else
                HideUIPanel(BattlefieldMapFrame)
            end
        end,
        notCheckable = true,
    },
    {
        text = '',
        isTitle = true,
        notCheckable = true,
    },
    {
        text = ADDONS,
        isTitle = true,
        notCheckable = true,
    },
    {
        text = C.COLORFUL_ADDON_TITLE,
        func = function()
            F.ToggleGUI()
        end,
        notCheckable = true,
    },
    {
        text = L['Reload User Interface'],
        colorCode = '|cffff0000',
        func = function()
            ReloadUI()
        end,
        notCheckable = true,
    },
}

local function onMouseUp(self, btn)
    if not C.DB.Map.ClickMenu then
        return
    end

    if btn == 'MiddleButton' then
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_IN_COMBAT)
            return
        end
        EasyMenu(list, F.EasyMenu, 'cursor', 0, 0, 'MENU', 3)
    elseif btn == 'RightButton' then
        local button = MinimapCluster.Tracking.Button
        if button then
            button:OpenMenu()
            if button.menu then
                button.menu:ClearAllPoints()
                button.menu:SetPoint('CENTER', self, -100, 100)
            end
        end
    else
        Minimap:OnClick()
    end
end

function MAP:ClickMenu()
    Minimap:SetScript('OnMouseUp', onMouseUp)
end
