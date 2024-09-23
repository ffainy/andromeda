local F, C, L = unpack(select(2, ...))
local MAP = F:GetModule('Map')
local TOOLTIP = F:GetModule('Tooltip')

local barEntered = false

local events = {
    'PLAYER_XP_UPDATE',
    'PLAYER_LEVEL_UP',
    'UPDATE_EXHAUSTION',
    'PLAYER_ENTERING_WORLD',
    'UPDATE_FACTION',
    'ARTIFACT_XP_UPDATE',
    'PLAYER_EQUIPMENT_CHANGED',
    'ENABLE_XP_GAIN',
    'DISABLE_XP_GAIN',
    'AZERITE_ITEM_EXPERIENCE_CHANGED',
    'HONOR_XP_UPDATE',
}

local function createExpRepBar()
    local Minimap = Minimap
    local bar = CreateFrame('StatusBar', C.ADDON_TITLE .. 'MinimapProgressBar', Minimap)
    bar:SetPoint('TOPLEFT', 0, -Minimap.halfDiff)
    bar:SetPoint('TOPRIGHT', 0, -Minimap.halfDiff)
    bar:SetHeight(4)
    bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    bar:SetFrameStrata('MEDIUM')
    bar.bg = F.CreateBDFrame(bar)
    bar.bg:SetBackdropBorderColor(0, 0, 0)

    bar:SetFrameLevel(Minimap:GetFrameLevel() + 2)
    bar:SetHitRectInsets(0, 0, 0, -10)

    local rest = CreateFrame('StatusBar', nil, bar)
    rest:SetAllPoints()
    rest:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    rest:SetStatusBarColor(0.34, 0.45, 0.86, 0.8)
    rest:SetFrameLevel(bar:GetFrameLevel() - 1)
    bar.restBar = rest

    MAP.ExpBar = bar
end

local function initCovenantRenownLevel()
    if not _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM] then
        _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM] = {}
    end

    if not _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM][C.MY_NAME] then
        _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM][C.MY_NAME] = {}

        for i = 1, 4 do
            _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM][C.MY_NAME][i] = 0
        end
    end
end

local function checkCovenantRenownLevel()
    local level = C_CovenantSanctumUI.GetRenownLevel()
    local CovenantID = C_Covenants.GetActiveCovenantID()

    _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM][C.MY_NAME][CovenantID] = level
end

local function updateCovenantRenownLevel()
    F:RegisterEvent('PLAYER_ENTERING_WORLD', function()
        F:Delay(1, function()
            checkCovenantRenownLevel()
        end)
    end)

    F:RegisterEvent('COVENANT_CHOSEN', function()
        F:Delay(3, function()
            checkCovenantRenownLevel()
        end)
    end)

    F:RegisterEvent('COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED', function()
        F:Delay(3, function()
            checkCovenantRenownLevel()
        end)
    end)
end

local function onEvent(self)
    local rest = self.restBar
    if rest then
        rest:Hide()
    end

    local factionData = C_Reputation.GetWatchedFactionData()

    if not IsPlayerAtEffectiveMaxLevel() then
        local xp, mxp, rxp = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()
        self:SetStatusBarColor(0.29, 0.59, 0.82)
        self:SetMinMaxValues(0, mxp)
        self:SetValue(xp)
        self:Show()

        if rxp then
            rest:SetMinMaxValues(0, mxp)
            rest:SetValue(min(xp + rxp, mxp))
            rest:Show()
        end

        if IsXPUserDisabled() then
            self:SetStatusBarColor(0.7, 0, 0)
        end
    elseif factionData then
        local standing = factionData.reaction
        local barMin = factionData.currentReactionThreshold
        local barMax = factionData.nextReactionThreshold
        local value = factionData.currentStanding
        local factionID = factionData.factionID
        if factionID and C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
            if majorFactionData then
                value = majorFactionData.renownReputationEarned or 0
                barMin, barMax = 0, majorFactionData.renownLevelThreshold
            end
        else
            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            local friendID, friendRep, friendThreshold, nextFriendThreshold =
                repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
            if C_Reputation.IsFactionParagon(factionID) then
                local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
                currentValue = mod(currentValue, threshold)
                barMin, barMax, value = 0, threshold, currentValue
            elseif friendID and friendID ~= 0 then
                if nextFriendThreshold then
                    barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
                else
                    barMin, barMax, value = 0, 1, 1
                end
                standing = 5
            else
                if standing == MAX_REPUTATION_REACTION then
                    barMin, barMax, value = 0, 1, 1
                end
            end
        end
        local color = FACTION_BAR_COLORS[standing] or FACTION_BAR_COLORS[5]
        self:SetStatusBarColor(color.r, color.g, color.b, 0.85)
        self:SetMinMaxValues(barMin, barMax)
        self:SetValue(value)
        self:Show()
    elseif IsWatchingHonorAsXP() then
        local current, barMax = UnitHonor('player'), UnitHonorMax('player')
        self:SetStatusBarColor(1, 0.24, 0)
        self:SetMinMaxValues(0, barMax)
        self:SetValue(current)
        self:Show()
    else
        self:Hide()
    end
end

local function onShiftDown()
    if barEntered then
        MAP.ExpBar:onEnter()
    end
end

local function onEnter(self)
    barEntered = true

    GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine(C.MY_NAME, LEVEL .. ': ' .. UnitLevel('player'), C.r, C.g, C.b, 1, 1, 1)

    if not IsPlayerAtEffectiveMaxLevel() then
        GameTooltip:AddLine(' ')
        local xp, mxp, rxp = UnitXP('player'), UnitXPMax('player'), GetXPExhaustion()
        GameTooltip:AddDoubleLine(
            XP,
            BreakUpLargeNumbers(xp) .. ' / ' .. BreakUpLargeNumbers(mxp) .. ' (' .. format('%.1f%%)', xp / mxp * 100),
            0.6, 0.8, 1, 1, 1, 1
        )
        if rxp then
            GameTooltip:AddDoubleLine(
                TUTORIAL_TITLE26,
                '+' .. BreakUpLargeNumbers(rxp) .. ' (' .. format('%.1f%%)', rxp / mxp * 100),
                0.6, 0.8, 1, 1, 1, 1
            )
        end
        if IsXPUserDisabled() then
            GameTooltip:AddLine('|cffff0000' .. XP .. LOCKED)
        end
    end

    local factionData = C_Reputation.GetWatchedFactionData()
    if factionData then
        local name = factionData.name
        local standing = factionData.reaction
        local barMin = factionData.currentReactionThreshold
        local barMax = factionData.nextReactionThreshold
        local value = factionData.currentStanding
        local factionID = factionData.factionID
        local standingtext
        if factionID and C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
            if majorFactionData then
                name = majorFactionData.name
                value = majorFactionData.renownReputationEarned or 0
                barMin, barMax = 0, majorFactionData.renownLevelThreshold
                standingtext = RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel
            end
        else
            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            local friendID, friendRep, friendThreshold, nextFriendThreshold =
                repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
            local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
            local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
            if friendID and friendID ~= 0 then
                if maxRank > 0 then
                    name = name .. ' (' .. currentRank .. ' / ' .. maxRank .. ')'
                end
                if nextFriendThreshold then
                    barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
                else
                    barMax = barMin + 1e3
                    value = barMax - 1
                end
                standingtext = repInfo.reaction
            else
                if standing == MAX_REPUTATION_REACTION then
                    barMax = barMin + 1e3
                    value = barMax - 1
                end
                standingtext = _G['FACTION_STANDING_LABEL' .. standing] or UNKNOWN
            end
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(name, 0, 0.6, 1)
        GameTooltip:AddDoubleLine(
            standingtext,
            value - barMin
            .. ' / '
            .. barMax - barMin
            .. ' ('
            .. floor((value - barMin) / (barMax - barMin) * 100)
            .. '%)',
            0.6, 0.8, 1, 1, 1, 1
        )

        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
            local paraCount = floor(currentValue / threshold)
            currentValue = mod(currentValue, threshold)
            GameTooltip:AddDoubleLine(
                L['Paragon'] .. paraCount,
                currentValue .. ' / ' .. threshold .. ' (' .. floor(currentValue / threshold * 100) .. '%)',
                0.6, 0.8, 1, 1, 1, 1
            )
        end

        if factionID == 2465 then                                      -- 荒猎团
            local repInfo = C_GossipInfo.GetFriendshipReputation(2463) -- 玛拉斯缪斯
            local rep, name, reaction, threshold, nextThreshold =
                repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
            if nextThreshold and rep > 0 then
                local current = rep - threshold
                local currentMax = nextThreshold - threshold
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(name, 0, 0.6, 1)
                GameTooltip:AddDoubleLine(
                    reaction,
                    current .. ' / ' .. currentMax .. ' (' .. floor(current / currentMax * 100) .. '%)',
                    0.6, 0.8, 1, 1, 1, 1
                )
            end
        end
    end

    if IsWatchingHonorAsXP() then
        local current, barMax, level = UnitHonor('player'), UnitHonorMax('player'), UnitHonorLevel('player')
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(HONOR, 0.9, 0.8, 0.6)
        GameTooltip:AddDoubleLine(
            LEVEL .. ' ' .. level,
            BreakUpLargeNumbers(current) .. ' / ' .. BreakUpLargeNumbers(barMax),
            0.6, 0.8, 1, 1, 1, 1
        )
    end

    -- factions of the WarWithin
    local wwFactionIds = C_MajorFactions.GetMajorFactionIDs(LE_EXPANSION_WAR_WITHIN)
    -- if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_WAR_WITHIN) then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(EXPANSION_NAME10, 0.9, 0.8, 0.6)
        for _, id in pairs(wwFactionIds) do
            local data = C_MajorFactions.GetMajorFactionData(id)
            if not data then
                return
            end
            if not data.isUnlocked then
                return
            end

            GameTooltip:AddDoubleLine(
                data.name .. ' ' .. data.renownLevel,
                BreakUpLargeNumbers(data.renownReputationEarned) ..
                ' / ' .. BreakUpLargeNumbers(data.renownLevelThreshold),
                0.6, 0.8, 1, 1, 1, 1
            )
        end
    -- end

    if IsShiftKeyDown() then
        -- factions of DragonFlight
        local dfFactionIds = C_MajorFactions.GetMajorFactionIDs(LE_EXPANSION_DRAGONFLIGHT)
        -- if C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_DRAGONFLIGHT) then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(EXPANSION_NAME9, 0.9, 0.8, 0.6)
            for _, id in pairs(dfFactionIds) do
                local data = C_MajorFactions.GetMajorFactionData(id)
                if not data then
                    return
                end
                if not data.isUnlocked then
                    return
                end

                GameTooltip:AddDoubleLine(
                    data.name .. ' ' .. data.renownLevel,
                    BreakUpLargeNumbers(data.renownReputationEarned) ..
                    ' / ' .. BreakUpLargeNumbers(data.renownLevelThreshold),
                    0.6, 0.8, 1, 1, 1, 1
                )
            end
        -- end

        -- factions of ShadowLands
        local covenantID = C_Covenants.GetActiveCovenantID()
        if covenantID and covenantID > 0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(EXPANSION_NAME8, 0.9, 0.8, 0.6)

            for i = 1, 4 do
                local level = _G['ANDROMEDA_ADB']['RenownLevels'][C.MY_REALM][C.MY_NAME][i]
                if level > 0 then
                    GameTooltip:AddDoubleLine(TOOLTIP:GetCovenantIcon(i) .. TOOLTIP:GetCovenantName(i), level)
                end
            end
        end
    else
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            L['Hold SHIFT key for more factions'],
            0.6, 0.8, 1
        )
    end

    GameTooltip:Show()
    F:RegisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

local function onLeave(self)
    barEntered = false
    F.HideTooltip()
    F:UnregisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

local function setupScript()
    for _, event in pairs(events) do
        MAP.ExpBar:RegisterEvent(event)
    end

    MAP.ExpBar.onEnter = onEnter
    MAP.ExpBar:SetScript('OnEvent', onEvent)
    MAP.ExpBar:SetScript('OnEnter', onEnter)
    MAP.ExpBar:SetScript('OnLeave', onLeave)

    hooksecurefunc(StatusTrackingBarManager, 'UpdateBarsShown', function()
        onEvent(MAP.ExpBar)
    end)
end

function MAP:CreateExpBar()
    if not C.DB.Map.ProgressBar then
        return
    end

    createExpRepBar()
    setupScript()
    initCovenantRenownLevel()
    updateCovenantRenownLevel()
end
