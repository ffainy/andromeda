local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

local BLIZZARD_LIST = {}

function BLIZZARD:RegisterBlizz(name, func)
    if not BLIZZARD_LIST[name] then
        BLIZZARD_LIST[name] = func
    end
end

function BLIZZARD:OnLogin()
    for name, func in next, BLIZZARD_LIST do
        if name and type(func) == 'function' then
            func()
        end
    end

    BLIZZARD:UpdateBossBanner()
    BLIZZARD:UpdateBossEmote()

    BLIZZARD:TicketStatusMover()
    BLIZZARD:VehicleIndicatorMover()
    BLIZZARD:DurabilityFrameMover()
    BLIZZARD:UIWidgetFrameMover()
    BLIZZARD:EnhancedColorPicker()
    BLIZZARD:EnhancedMerchant()
    -- BLIZZARD:EnhancedFriendsList()
    BLIZZARD:EnhancedPremade()
    BLIZZARD:EnhancedDressup()
    BLIZZARD:ReskinVigorBar()
    BLIZZARD:EnhancedLootRoll()
    BLIZZARD:EnhancedLoot()
    BLIZZARD:FasterLoot()
end

function BLIZZARD:UpdateBossBanner()
    if C.DB.General.HideBossBanner then
        BossBanner:UnregisterEvent('ENCOUNTER_LOOT_RECEIVED')
    else
        BossBanner:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
    end
end

function BLIZZARD:UpdateBossEmote()
    if C.DB.General.HideBossEmote then
        RaidBossEmoteFrame:UnregisterAllEvents()
    else
        RaidBossEmoteFrame:RegisterEvent('RAID_BOSS_EMOTE')
        RaidBossEmoteFrame:RegisterEvent('RAID_BOSS_WHISPER')
        RaidBossEmoteFrame:RegisterEvent('CLEAR_BOSS_EMOTES')
    end
end

-- reposition vehicle indicator
function BLIZZARD:VehicleIndicatorMover()
    local frame = CreateFrame('Frame', C.ADDON_TITLE .. 'VehicleIndicatorMover', UIParent)
    frame:SetSize(100, 100)
    F.Mover(frame, L['VehicleIndicator'], 'VehicleIndicator', { 'BOTTOMRIGHT', Minimap, 'TOPRIGHT', 0, 0 })

    hooksecurefunc(VehicleSeatIndicator, 'SetPoint', function(self, _, parent)
        if parent ~= frame then
            self:ClearAllPoints()
            self:SetPoint('TOPLEFT', frame)
        end
    end)
end

-- reposition durability frame
function BLIZZARD:DurabilityFrameMover()
    local frame = CreateFrame('Frame', C.ADDON_TITLE .. 'DurabilityFrameMover', UIParent)
    frame:SetSize(100, 100)
    F.Mover(
        frame,
        L['DurabilityIndicator'],
        'DurabilityIndicator',
        { 'TOPRIGHT', ObjectiveTrackerFrame, 'TOPLEFT', -10, 0 }
    )

    hooksecurefunc(DurabilityFrame, 'SetPoint', function(self, _, parent)
        if parent == 'MinimapCluster' or parent == MinimapCluster then
            self:ClearAllPoints()
            self:SetPoint('TOPLEFT', frame)
        end
    end)
end

-- reposition ticket status frame
function BLIZZARD:TicketStatusMover()
    hooksecurefunc(TicketStatusFrame, 'SetPoint', function(self, relF)
        if relF == 'TOPRIGHT' then
            self:ClearAllPoints()
            self:SetPoint('TOP', UIParent, 'TOP', 0, -100)
        end
    end)
end

-- reposition UI widget frame
function BLIZZARD:UIWidgetFrameMover()
    local frame1 = CreateFrame('Frame', C.ADDON_TITLE .. 'UIWidgetMover', UIParent)
    frame1:SetSize(200, 50)
    F.Mover(frame1, L['UIWidgetFrame'], 'UIWidgetFrame', { 'TOP', 0, -100 })

    hooksecurefunc(UIWidgetBelowMinimapContainerFrame, 'SetPoint', function(self, _, parent)
        if parent ~= frame1 then
            self:ClearAllPoints()
            self:SetPoint('CENTER', frame1)
        end
    end)

    local frame2 = CreateFrame('Frame', C.ADDON_TITLE .. 'WidgetPowerBarMover', UIParent)
    frame2:SetSize(260, 40)
    F.Mover(frame2, L['UIWidgetPowerBar'], 'UIWidgetPowerBar', { 'BOTTOM', UIParent, 'BOTTOM', 0, 150 })

    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'SetPoint', function(self, _, parent)
        if parent ~= frame2 then
            self:ClearAllPoints()
            self:SetPoint('CENTER', frame2)
        end
    end)
end

-- dragonfly vigor bar
do
    local vigorBar
    local r, g, b = 0.3, 0.5, 1
    local function setupBar()
        vigorBar = CreateFrame('Frame', C.ADDON_TITLE .. 'VigorBar', UIParent)
        vigorBar:SetSize(200, 12)

        for i = 1, 6 do
            vigorBar[i] = CreateFrame('StatusBar', 'Vigor' .. i, vigorBar)
            vigorBar[i]:SetSize((200 - 15) / 6, 12)
            F.SetBD(vigorBar[i], .65)

            if i == 1 then
                vigorBar[i]:SetPoint('TOPLEFT', vigorBar, 'TOPLEFT', 0, 0)
            else
                vigorBar[i]:SetPoint('TOPLEFT', vigorBar[i - 1], 'TOPRIGHT', 3, 0)
            end
            vigorBar[i]:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            vigorBar[i]:SetMinMaxValues(0, 100)
            vigorBar[i]:SetStatusBarColor(r, g, b)

            vigorBar[i]:SetValue(0)
        end

        F.Mover(vigorBar, L['Dragonfly VigorBar'], 'VigorBar', { 'TOP', 0, -140 })

        vigorBar:Hide()
    end

    local function reskinBar(widget)
        if not widget:IsShown() then
            return
        end

        local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)
        if not widgetInfo then
            return
        end

        vigorBar:Show()

        local total = widgetInfo.numTotalFrames
        for i = 1, total do
            local value = 0
            vigorBar[i]:SetStatusBarColor(r, g, b)
            if widgetInfo.numFullFrames >= i then
                value = widgetInfo.fillMax
            elseif widgetInfo.numFullFrames + 1 == i then
                value = widgetInfo.fillValue
                vigorBar[i]:SetStatusBarColor(r * 0.6, g * 0.6, b * 0.6)
            else
                value = widgetInfo.fillMin
            end
            vigorBar[i]:SetValue(value)
        end

        if total < 6 and IsPlayerSpell(377922) then
            total = 6
        end -- sometimes it returns 5

        if total < 6 then
            for i = total + 1, 6 do
                vigorBar[i]:Hide()
                vigorBar[i]:SetValue(0)
            end

            local spacing = select(4, vigorBar[6]:GetPoint())
            local w = vigorBar:GetWidth()
            local s = 0

            for i = 1, total do
                vigorBar[i]:Show()
                if i ~= total then
                    vigorBar[i]:SetWidth(w / total - spacing)
                    s = s + (w / total)
                else
                    vigorBar[i]:SetWidth(w - s)
                end
            end
        end

        widget:SetAlpha(0)

        if not widget.hook then
            hooksecurefunc(widget, 'Hide', function(self)
                vigorBar:Hide()
            end)
            widget.hook = true
        end
    end

    local function hookWidgets()
        for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
            if widget.widgetType == Enum.UIWidgetVisualizationType.FillUpFrames then
                reskinBar(widget)
            end
        end
    end

    function BLIZZARD:ReskinVigorBar()
        if C_AddOns.IsAddOnLoaded('WeakAuras') then
            return
        end

        setupBar()

        F:RegisterEvent('PLAYER_ENTERING_WORLD', hookWidgets)
        F:RegisterEvent('UPDATE_ALL_UI_WIDGETS', hookWidgets)
        F:RegisterEvent('UPDATE_UI_WIDGET', hookWidgets)
    end
end

-- expand the size of MacroFrame
do
    local tempScrollPer
    local selectorHeight = 100
    local scrollHeight = 150

    local function selectMacro()
        if tempScrollPer then
            MacroFrame.MacroSelector.ScrollBox:SetScrollPercentage(tempScrollPer)
            tempScrollPer = nil
        end
    end

    local function updateMacro()
        if MacroFrame then
            tempScrollPer = MacroFrame.MacroSelector.ScrollBox.scrollPercentage
        end
    end

    local function hook(event, addon)
        if addon == 'Blizzard_MacroUI' then
            hooksecurefunc(MacroFrame, 'SelectMacro', selectMacro)

            MacroFrame.MacroSelector:SetHeight(146 + selectorHeight)
            MacroHorizontalBarLeft:SetPoint('TOPLEFT', 2, -210 - selectorHeight)
            MacroFrameSelectedMacroBackground:SetPoint('TOPLEFT', 2, -218 - selectorHeight)
            MacroFrameTextBackground:SetPoint('TOPLEFT', 6, -289 - selectorHeight)

            local h = MacroFrame:GetHeight()
            MacroFrame:SetHeight(h + scrollHeight + selectorHeight)
            MacroFrameScrollFrame:SetHeight(85 + scrollHeight)
            MacroFrameText:SetHeight(85 + scrollHeight)
            MacroFrameTextButton:SetHeight(85 + scrollHeight)
            MacroFrameTextBackground:SetHeight(95 + scrollHeight)

            F:UnregisterEvent(event, hook)
        end
    end

    F:RegisterEvent('ADDON_LOADED', hook)
    F:RegisterEvent('UPDATE_MACROS', updateMacro)
end


-- Kill blizz tutorial, real man dont need these crap
-- Credit: ketho
-- https://github.com/ketho-wow/HideTutorial

do
    local pendingChanges

    local function addonLoaded(_, _, addon)
        if addon ~= C.ADDON_NAME then
            return
        end

        local tocVersion = select(4, GetBuildInfo())
        if not C.DB.HideTutorial or C.DB.HideTutorial < tocVersion then
            C.DB.HideTutorial = tocVersion
            pendingChanges = true
        end

        F:UnregisterEvent('ADDON_LOADED', addonLoaded)
    end

    local function variablesLoaded()
        C_CVar.SetCVar('showTutorials', 0)
        C_CVar.SetCVar('showNPETutorials', 0)
        C_CVar.SetCVar('hideAdventureJournalAlerts', 1)
        -- C_CVar.RegisterCVar('hideHelptips', 1) -- this can actually block interaction with mission tables

        local lastInfoFrame = C_CVar.GetCVarBitfield('closedInfoFrames', NUM_LE_FRAME_TUTORIALS)
        if pendingChanges or not lastInfoFrame then
            for i = 1, NUM_LE_FRAME_TUTORIALS do
                C_CVar.SetCVarBitfield('closedInfoFrames', i, true)
            end
            for i = 1, NUM_LE_FRAME_TUTORIAL_ACCCOUNTS do
                C_CVar.SetCVarBitfield('closedInfoFramesAccountWide', i, true)
            end
        end

        -- disable alert of new talent
        if not InCombatLockdown() then
            function MainMenuMicroButton_AreAlertsEnabled()
                return false
            end
        end

        F:UnregisterEvent('VARIABLES_LOADED', variablesLoaded)
    end

    F:RegisterEvent('ADDON_LOADED', addonLoaded)
    F:RegisterEvent('VARIABLES_LOADED', variablesLoaded)

    hooksecurefunc('NPE_CheckTutorials', function()
        if C_PlayerInfo.IsPlayerNPERestricted() and UnitLevel('player') == 1 then
            F.Print('Disabling NPE tutorial.')
            SetCVar('showTutorials', 0)
        end
    end)
end

-- Select target when click on raid units
do
    local function FixRaidGroupButton()
        for i = 1, 40 do
            local bu = _G['RaidGroupButton' .. i]
            if bu and bu.unit and not bu.clickFixed then
                bu:SetAttribute('type', 'target')
                bu:SetAttribute('unit', bu.unit)

                bu.clickFixed = true
            end
        end
    end

    local function OnEvent(event, addon)
        if event == 'ADDON_LOADED' and addon == 'Blizzard_RaidUI' then
            if not InCombatLockdown() then
                FixRaidGroupButton()
            else
                F:RegisterEvent('PLAYER_REGEN_ENABLED', OnEvent)
            end
            F:UnregisterEvent(event, OnEvent)
        elseif event == 'PLAYER_REGEN_ENABLED' then
            if RaidGroupButton1 and RaidGroupButton1:GetAttribute('type') ~= 'target' then
                FixRaidGroupButton()
                F:UnregisterEvent(event, OnEvent)
            end
        end
    end

    F:RegisterEvent('ADDON_LOADED', OnEvent)
end

-- Fix blizz guild news hyperlink error
do
    local function FixGuildNews(event, addon)
        if addon ~= 'Blizzard_GuildUI' then
            return
        end

        local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
        function GuildNewsButton_OnEnter(self)
            if not (self.newsInfo and self.newsInfo.whatText) then
                return
            end
            _GuildNewsButton_OnEnter(self)
        end

        F:UnregisterEvent(event, FixGuildNews)
    end

    F:RegisterEvent('ADDON_LOADED', FixGuildNews)
end

-- Fix blizz bug in addon list
do
    local _AddonTooltip_Update = AddonTooltip_Update
    function AddonTooltip_Update(owner)
        if not owner then
            return
        end
        if owner:GetID() < 1 then
            return
        end
        _AddonTooltip_Update(owner)
    end
end

-- Fix achievement date missing in zhTW
do
    if GetLocale() == 'zhTW' then
        local function fixAchievementData(event, addon)
            if addon ~= 'Blizzard_AchievementUI' then
                return
            end

            hooksecurefunc('AchievementButton_Localize', function(button)
                button.DateCompleted:SetPoint('TOP', button.Shield, 'BOTTOM', -2, 6)
            end)

            F:UnregisterEvent(event, fixAchievementData)
        end
        F:RegisterEvent('ADDON_LOADED', fixAchievementData)
    end
end

-- Fix missing localization file
if not GuildControlUIRankSettingsFrameRosterLabel then
    GuildControlUIRankSettingsFrameRosterLabel = CreateFrame('Frame')
end
