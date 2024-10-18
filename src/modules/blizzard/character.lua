local F, C, L = unpack(select(2, ...))
local M = F:RegisterModule('EnhancedCharacterFrame')

function M:MissingStats()
    if not C.DB.General.MissingStats then
        return
    end

    if C_AddOns.IsAddOnLoaded('DejaCharacterStats') then
        return
    end

    local statPanel = CreateFrame('Frame', nil, CharacterFrameInsetRight)
    statPanel:SetSize(200, 350)
    statPanel:SetPoint('TOP', 0, -5)

    local scrollFrame = CreateFrame('ScrollFrame', nil, statPanel, 'UIPanelScrollFrameTemplate')
    scrollFrame:SetAllPoints()
    scrollFrame.ScrollBar:Hide()
    scrollFrame.ScrollBar.Show = nop

    local stat = CreateFrame('Frame', nil, scrollFrame)
    stat:SetSize(200, 1)
    scrollFrame:SetScrollChild(stat)
    CharacterStatsPane:ClearAllPoints()
    CharacterStatsPane:SetParent(stat)
    CharacterStatsPane:SetAllPoints(stat)

    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()
        statPanel:SetShown(CharacterStatsPane:IsShown())
    end)

    -- Change default data
    PAPERDOLL_STATCATEGORIES = {
        [1] = {
            categoryFrame = 'AttributesCategory',
            stats = {
                [1] = { stat = 'STRENGTH', primary = LE_UNIT_STAT_STRENGTH },
                [2] = { stat = 'AGILITY', primary = LE_UNIT_STAT_AGILITY },
                [3] = { stat = 'INTELLECT', primary = LE_UNIT_STAT_INTELLECT },
                [4] = { stat = 'STAMINA' },
                [5] = { stat = 'ARMOR' },
                [6] = { stat = 'STAGGER', hideAt = 0, roles = { Enum.LFGRole.Tank } },
                [7] = { stat = 'ATTACK_DAMAGE', primary = LE_UNIT_STAT_STRENGTH, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [8] = { stat = 'ATTACK_AP', hideAt = 0, primary = LE_UNIT_STAT_STRENGTH, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [9] = { stat = 'ATTACK_ATTACKSPEED', primary = LE_UNIT_STAT_STRENGTH, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [10] = { stat = 'ATTACK_DAMAGE', primary = LE_UNIT_STAT_AGILITY, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [11] = { stat = 'ATTACK_AP', hideAt = 0, primary = LE_UNIT_STAT_AGILITY, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [12] = { stat = 'ATTACK_ATTACKSPEED', primary = LE_UNIT_STAT_AGILITY, roles = { Enum.LFGRole.Tank, Enum.LFGRole.Damage } },
                [13] = { stat = 'SPELLPOWER', hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
                [14] = { stat = 'MANAREGEN', hideAt = 0, primary = LE_UNIT_STAT_INTELLECT },
                [15] = { stat = 'ENERGY_REGEN', hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
                [16] = { stat = 'RUNE_REGEN', hideAt = 0, primary = LE_UNIT_STAT_STRENGTH },
                [17] = { stat = 'FOCUS_REGEN', hideAt = 0, primary = LE_UNIT_STAT_AGILITY },
                [18] = { stat = 'MOVESPEED' },
            },
        },
        [2] = {
            categoryFrame = 'EnhancementsCategory',
            stats = {
                { stat = 'CRITCHANCE',  hideAt = 0 },
                { stat = 'HASTE',       hideAt = 0 },
                { stat = 'MASTERY',     hideAt = 0 },
                { stat = 'VERSATILITY', hideAt = 0 },
                { stat = 'LIFESTEAL',   hideAt = 0 },
                { stat = 'AVOIDANCE',   hideAt = 0 },
                { stat = 'SPEED',       hideAt = 0 },
                { stat = 'DODGE',       roles = { 'TANK' } },
                { stat = 'PARRY',       hideAt = 0,        roles = { 'TANK' } },
                { stat = 'BLOCK',       hideAt = 0,        showFunc = C_PaperDollInfo.OffhandHasShield },
            },
        },
    }

    PAPERDOLL_STATINFO['ENERGY_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetEnergyRegen(statFrame, unit)
    end

    PAPERDOLL_STATINFO['RUNE_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetRuneRegen(statFrame, unit)
    end

    PAPERDOLL_STATINFO['FOCUS_REGEN'].updateFunc = function(statFrame, unit)
        statFrame.numericValue = 0
        PaperDollFrame_SetFocusRegen(statFrame, unit)
    end

    function PaperDollFrame_SetAttackSpeed(statFrame, unit)
        local meleeHaste = GetMeleeHaste()
        local speed, offhandSpeed = UnitAttackSpeed(unit)
        local displaySpeed = format('%.2f', speed)

        if offhandSpeed then
            offhandSpeed = format('%.2f', offhandSpeed)
        end

        if offhandSpeed then
            displaySpeed = BreakUpLargeNumbers(displaySpeed) .. ' / ' .. offhandSpeed
        else
            displaySpeed = BreakUpLargeNumbers(displaySpeed)
        end

        PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, displaySpeed, false, speed)
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE ..
        format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED) .. ' ' .. displaySpeed .. FONT_COLOR_CODE_CLOSE
        statFrame.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
        statFrame:Show()
    end

    MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = 1
    hooksecurefunc('PaperDollFrame_SetItemLevel', function(statFrame, unit)
        if unit ~= 'player' then
            return
        end

        local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
        local minItemLevel = C_PaperDollInfo.GetMinItemLevel()
        local displayItemLevel = max(minItemLevel or 0, avgItemLevelEquipped)
        displayItemLevel = format('%.1f', displayItemLevel)
        avgItemLevel = format('%.1f', avgItemLevel)

        if displayItemLevel ~= avgItemLevel then
            displayItemLevel = displayItemLevel .. ' / ' .. avgItemLevel
        end

        PaperDollFrame_SetLabelAndText(statFrame, STAT_AVERAGE_ITEM_LEVEL, displayItemLevel, false, displayItemLevel)

        CharacterStatsPane.ItemLevelFrame.Value:SetFont(C.Assets.Fonts.Heavy, 18)
        CharacterStatsPane.ItemLevelFrame.Value:SetShadowColor(0, 0, 0, 1)
        CharacterStatsPane.ItemLevelFrame.Value:SetShadowOffset(1, -1)
    end)

    hooksecurefunc('PaperDollFrame_SetLabelAndText', function(statFrame, label, _, isPercentage)
        if isPercentage or label == STAT_HASTE then
            statFrame.Value:SetFormattedText('%.2f%%', statFrame.numericValue)
        end
    end)

    hooksecurefunc('PaperDollFrame_UpdateStats', function()
        for statFrame in CharacterStatsPane.statsFramePool:EnumerateActive() do
            if not statFrame.styled then
                statFrame.Label:SetFontObject(Game12Font)
                statFrame.Value:SetFontObject(Game12Font)

                statFrame.styled = true
            end
        end
    end)
end

function M:NakedButton()
    if not C.DB.General.NakedButton then
        return
    end

    local bu = CreateFrame('Button', nil, CharacterFrameInsetRight)
    bu:SetSize(31, 33)
    bu:SetPoint('RIGHT', PaperDollSidebarTab1, 'LEFT', -4, -3)
    F.PixelIcon(bu, 'Interface\\ICONS\\UI_Calendar_FreeTShirtDay', true)
    F.AddTooltip(bu, 'ANCHOR_RIGHT', L['Double click to unequip all gears'])

    local function UnequipItemInSlot(i)
        local action = EquipmentManager_UnequipItemInSlot(i)
        EquipmentManager_RunAction(action)
    end

    bu:SetScript('OnDoubleClick', function()
        for i = 1, 17 do
            local texture = GetInventoryItemTexture('player', i)

            if texture then
                UnequipItemInSlot(i)
            end
        end
    end)
end

function M:OnLogin()
    M:MissingStats()
    M:NakedButton()
end
