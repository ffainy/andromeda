local F, C, L = unpack(select(2, ...))
local MISC = F:GetModule('Misc')

local buttonsList = {}
local menuList = {
    {
        CHARACTER_BUTTON,
        C.Assets.Textures.microMenu.character,
        function()
            if not CharacterFrame:IsShown() then
                ShowUIPanel(CharacterFrame)
                CharacterFrameTab2:Click()
                CharacterFrameTab1:Click()
            else
                HideUIPanel(CharacterFrame)
            end
        end,
    },

    {
        PROFESSIONS_BUTTON,
        C.Assets.Textures.microMenu.spellbook,
        function()
            if InCombatLockdown() then
                UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_IN_COMBAT)
                return
            end
            ToggleProfessionsBook()
        end,
    },
    {
        PLAYERSPELLS_BUTTON,
        C.Assets.Textures.microMenu.talent,
        function()
            if not PlayerSpellsFrame:IsShown() then
                ShowUIPanel(PlayerSpellsFrame)
            else
                HideUIPanel(PlayerSpellsFrame)
            end
        end,
    },
    {
        SOCIAL_BUTTON,
        C.Assets.Textures.microMenu.friend,
        function()
            if not FriendsFrame:IsShown() then
                ShowUIPanel(FriendsFrame)
            else
                HideUIPanel(FriendsFrame)
            end
        end,
    },
    {
        COMMUNITIES_FRAME_TITLE,
        C.Assets.Textures.microMenu.guild,
        function()
            if not CommunitiesFrame then
                C_AddOns.LoadAddOn('Blizzard_Communities')
            end
            if not CommunitiesFrame:IsShown() then
                ShowUIPanel(CommunitiesFrame)
            else
                HideUIPanel(CommunitiesFrame)
            end
        end,
    },
    {
        ACHIEVEMENT_BUTTON,
        C.Assets.Textures.microMenu.achievement,
        function()
            if not AchievementFrame then
                C_AddOns.LoadAddOn('Blizzard_AchievementUI')
            end
            if not AchievementFrame:IsShown() then
                ShowUIPanel(AchievementFrame)
            else
                HideUIPanel(AchievementFrame)
            end
        end,
    },
    {
        COLLECTIONS,
        C.Assets.Textures.microMenu.collection,
        function()
            if not CollectionsJournal then
                C_AddOns.LoadAddOn('Blizzard_Collections')
            end
            if not CollectionsJournal:IsShown() then
                ShowUIPanel(CollectionsJournal)
            else
                HideUIPanel(CollectionsJournal)
            end
        end,
    },
    {
        GROUP_FINDER,
        C.Assets.Textures.microMenu.lfg,
        function()
            if not PVEFrame:IsShown() then
                ShowUIPanel(PVEFrame)
                PVEFrameTab1:Click()
            else
                HideUIPanel(PVEFrame)
            end
        end,
    },
    {
        ADVENTURE_JOURNAL,
        C.Assets.Textures.microMenu.encounter,
        function()
            if not EncounterJournal then
                C_AddOns.LoadAddOn('Blizzard_EncounterJournal')
            end
            if not EncounterJournal:IsShown() then
                ShowUIPanel(EncounterJournal)
            else
                HideUIPanel(EncounterJournal)
            end
        end,
    },
    {
        L['Calendar'],
        C.Assets.Textures.microMenu.calendar,
        function()
            if not CalendarFrame then
                C_AddOns.LoadAddOn('Blizzard_Calendar')
            end
            if not CalendarFrame:IsShown() then
                ShowUIPanel(CalendarFrame)
            else
                HideUIPanel(CalendarFrame)
            end
        end,
    },
    {
        MAP_AND_QUEST_LOG,
        C.Assets.Textures.microMenu.map,
        function()
            if not WorldMapFrame:IsShown() then
                ShowUIPanel(WorldMapFrame)
            else
                HideUIPanel(WorldMapFrame)
            end
        end,
    },
    {
        BAGSLOT,
        C.Assets.Textures.microMenu.bag,
        function()
            ToggleAllBags()
        end,
    },
    {
        BLIZZARD_STORE,
        C.Assets.Textures.microMenu.store,
        function()
            if not StoreFrame then
                C_AddOns.LoadAddOn('Blizzard_StoreUI')
            end
            securecall(ToggleStoreUI)
        end,
    },
    {
        GM_EMAIL_NAME,
        C.Assets.Textures.microMenu.help,
        function()
            if not HelpFrame:IsShown() then
                ShowUIPanel(HelpFrame)
            else
                HideUIPanel(HelpFrame)
            end
        end,
    },
}

local function createButtonTexture(icon, texture)
    icon:SetAllPoints()
    icon:SetTexture(texture)
    if C.DB.General.GameMenuClassColor then
        icon:SetVertexColor(C.r, C.g, C.b)
    else
        icon:SetVertexColor(1, 1, 1)
    end
end

local function OnEnter(self)
    F:UIFrameFadeIn(self, C.DB.General.GameMenuSmooth, self:GetAlpha(), C.DB.General.GameMenuButtonInAlpha)
end

local function OnLeave(self)
    F:UIFrameFadeOut(self, C.DB.General.GameMenuSmooth, self:GetAlpha(), C.DB.General.GameMenuButtonOutAlpha)
end

local function OnClick(self)
    self.func()
end

local function setupButton(bar, data)
    local tip, texture, func = unpack(data)

    local bu = CreateFrame('Button', nil, bar)
    tinsert(buttonsList, bu)
    bu:SetSize(C.DB.General.GameMenuButtonSize, C.DB.General.GameMenuButtonSize)
    bu:SetAlpha(C.DB.General.GameMenuButtonOutAlpha)
    bu.icon = bu:CreateTexture(nil, 'ARTWORK')

    bu.tip = tip
    bu.texture = texture
    bu.func = func

    createButtonTexture(bu.icon, texture)

    F.AddTooltip(bu, 'ANCHOR_RIGHT', tip)

    bu:HookScript('OnEnter', OnEnter)
    bu:HookScript('OnLeave', OnLeave)
    bu:HookScript('OnClick', OnClick)
end

function MISC:MicroMenu()
    if not C.DB.General.GameMenu then
        return
    end

    local buSize = C.DB.General.GameMenuButtonSize
    local buGap = C.DB.General.GameMenuButtonGap
    local buNum = #menuList

    local barWidth = (buSize * buNum) + (buGap * (buNum - 1))
    local bar = CreateFrame('Frame', C.ADDON_TITLE .. 'GameMenu', UIParent)
    bar:SetSize(barWidth, C.DB.General.GameMenuBarHeight)

    local glow = bar:CreateTexture(nil, 'BACKGROUND')
    glow:SetPoint('BOTTOMLEFT', bar, 'BOTTOMLEFT', -30, 0)
    glow:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 30, 0)
    glow:SetHeight(C.DB.General.GameMenuButtonSize * 2)
    glow:SetTexture(C.Assets.Textures.Glow)
    if C.DB.General.GameMenuClassColor then
        glow:SetVertexColor(C.r, C.g, C.b, C.DB.General.GameMenuBackdropAlpha)
    else
        glow:SetVertexColor(1, 1, 1, C.DB.General.GameMenuBackdropAlpha)
    end

    for _, info in pairs(menuList) do
        setupButton(bar, info)
    end

    for i = 1, #buttonsList do
        if i == 1 then
            buttonsList[i]:SetPoint('LEFT')
        else
            buttonsList[i]:SetPoint('LEFT', buttonsList[i - 1], 'RIGHT', C.DB.General.GameMenuButtonGap, 0)
        end
    end

    F.Mover(bar, L['GameMenu'], 'GameMenu', { 'BOTTOM' })
end
