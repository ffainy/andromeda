local F, C, L = unpack(select(2, ...))
local MAP = F:GetModule('Map')

local barEntered = false

-- 声望列表

local factionIDs = {

    -- factionID, textureID

    ['1'] = { -- 地心之战
        { 2590, 5891369 }, -- Council of Dornogal
        { 2594, 5891367 }, -- Assembly of the Deeps
        { 2570, 5891368 }, -- Hallowfall Arathi
        { 2600, 5891370 }, -- The Severed Threads
        { 2605, 5862762 }, -- The General
        { 2607, 5862763 }, -- The Vizier
        { 2601, 5862764 }, -- The Weaver
        { 2640, 5453546 }, -- Brann Bronzebeard
    },

    ['2'] = { -- 巨龙时代
        { 2503, 4566591 }, -- Maruuk Centaur
        { 2507, 3012071 }, -- Dragonscale Expedition
        { 2511, 4687629 }, -- Iskaara Tuskarr
        { 2510, 4569780 }, -- Valdrakken Accord
        { 2523, 4574311 }, -- Dark Talons
        { 2524, 4574311 }, -- Obsidian Warders
        { 2564, 1786409 }, -- Loamm Niffen
        { 2574, 341763 },  -- Dream Wardens
    },

    ['3'] = { -- 暗影过度
        { 2413, 3257751 }, -- Court of Harvesters
        { 2407, 3257748 }, -- The Ascended
        { 2410, 3641396 }, -- The Undying Army
        { 2465, 3641394 }, -- The Wild Hunt
        { 2439, 1044087 }, -- The Avowed
        { 2470, 3052062 }, -- Death's Advance
        { 2432, 3528299 }, -- Ve'nari
        { 2472, 2101967 }, -- The Archivists' Codex
        { 2478, 3601566 }, -- The Enlightened
    },
}

--

local colours = {
    repNameColour = { 0.6, 0.8, 1 },
    renownParagonActive = { 86 / 255, 223 / 255, 90 / 255 },
    renownParagonAvailable = { 238 / 255, 74 / 255, 41 / 255 },
    defaultRenown = { 255 / 255, 198 / 255, 45 / 255 },
    nonParagonColour = { 225 / 255, 222 / 255, 215 / 255 },
    paragonColour = { 86 / 255, 223 / 255, 90 / 255 },
    paragonAvailable = { 238 / 255, 74 / 255, 41 / 255 },
}

local configs = {
    showRenownLevel = true,
    showRenownProg = true,
    showCurrentStandingPreExalted = true,
    showCurrentStandingExalted = true,
    hideAtMaxRenown = false,
    showUnmetRenownFaction = true,
    onlyShowMaxRenownIfParagonBox = false,
    showHostile = true,
    showUnmet = true,
    showBeforeExalted = true,
    showAfterExalted = true,
    onlyShowParagonRewards = false,
}

-- 9.0 盟约等级
-- 游戏里只能获取当前所激活盟约的等级，所以需要存储到本地

local covenantList = {
    [1] = 'kyrian',
    [2] = 'venthyr',
    [3] = 'nightfae',
    [4] = 'necrolord',
}

local covenantColor = {
    [1] = COVENANT_COLORS.Kyrian,
    [2] = COVENANT_COLORS.Venthyr,
    [3] = COVENANT_COLORS.NightFae,
    [4] = COVENANT_COLORS.Necrolord,
}

local function getCovenantIcon(covenantID)
    local covenant = covenantList[covenantID]
    if covenant then
        return format('|A:sanctumupgrades-' .. covenantList[covenantID] .. '-32x32:14:14|a ')
    end

    return ''
end

local covenantIDToName = {}
local function getCovenantName(covenantID)
    if not covenantIDToName[covenantID] then
        local covenantData = C_Covenants.GetCovenantData(covenantID)

        covenantIDToName[covenantID] = covenantData and covenantData.name
    end
    local color = covenantColor[covenantID]
    return color:WrapTextInColorCode(covenantIDToName[covenantID])
end

local function initCovenantLevel()
    if not _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM] then
        _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM] = {}
    end

    if not _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM][C.MY_NAME] then
        _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM][C.MY_NAME] = {}

        for i = 1, 4 do
            _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM][C.MY_NAME][i] = 0
        end
    end
end

local function saveCovenantLevel()
    local level = C_CovenantSanctumUI.GetRenownLevel()
    local CovenantID = C_Covenants.GetActiveCovenantID()

    _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM][C.MY_NAME][CovenantID] = level
end

local function updateCovenantLevel()
    F:RegisterEvent('PLAYER_ENTERING_WORLD', function()
        F:Delay(1, function()
            saveCovenantLevel()
        end)
    end)

    F:RegisterEvent('COVENANT_CHOSEN', function()
        F:Delay(3, function()
            saveCovenantLevel()
        end)
    end)

    F:RegisterEvent('COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED', function()
        F:Delay(3, function()
            saveCovenantLevel()
        end)
    end)
end

-- 声望图标

local function addIcon(texture)
    texture = texture and '|T' .. texture .. ':10:16:0:0:50:50:4:46:4:46|t ' or ''
    return texture
end

-- Takes a color picker colour and returns a hex colour usable by WA
local getColour = function(colour)
    return CreateColor(unpack(colour)):GenerateHexColor()
end

-- Takes in some values and adjusts for paragon API returning aggregate amounts
local getParagonValue = function(val, threshold, hasReward)
    -- We need to adjust the value since we get the total amount of paragon reputation ever
    -- This will be done by checking if there's a reward and then mathing out the proper amount to show
    local adjustedVal = val

    if val > (threshold * 2) or (val > threshold and not hasReward) then
        adjustedVal = val % threshold
    end

    if hasReward then
        adjustedVal = val % threshold + threshold
    end

    return adjustedVal
end

-- Reputation / Renown Name
local getColouredRepName = function(texture, name)
    local repIcon = addIcon(texture)
    local repNameColour = getColour(colours.repNameColour)

    return repIcon .. '|c' .. repNameColour .. name .. ':|r'
end

-- Renown
local getRenownColouredValue = function(currentRenown, renownThreshold, currentRenownLevel, maxRenownLevel, isMaxRenown,
                                        factionID)
    if (isMaxRenown and factionID) then
        local renownColour = getColour(colours.renownParagonActive)
        local renownParagonAvailable = getColour(colours.renownParagonAvailable)


        local curVal, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

        if (not curVal or not threshold) then
            return '0'
        end

        local uiValue = getParagonValue(curVal, threshold, hasRewardPending)

        local colorToShow = hasRewardPending and renownParagonAvailable or renownColour

        return '|c' .. colorToShow .. BreakUpLargeNumbers(uiValue) .. '/' .. BreakUpLargeNumbers(threshold) .. '|r'
    end

    local showRenownLevel = configs.showRenownLevel
    local showRenownProg = configs.showRenownProg

    local renownColour = getColour(colours.defaultRenown)

    local renownLevelInfo = currentRenownLevel .. '/' .. maxRenownLevel
    local renownProgressInfo = BreakUpLargeNumbers(currentRenown) .. '/' .. BreakUpLargeNumbers(renownThreshold)

    if (showRenownLevel and showRenownProg) then
        return '|c' .. renownColour .. renownProgressInfo .. ' (' .. renownLevelInfo .. ')' .. '|r'
    end

    if (showRenownLevel) then
        return '|c' .. renownColour .. renownLevelInfo .. '|r'
    end

    if (showRenownProg) then
        return '|c' .. renownColour .. renownProgressInfo .. '|r'
    end
end

-- Reputation (Regular)
local getColouredValue = function(barMin, barMax, barValue, standingId)
    local nonParagonColour = getColour(colours.nonParagonColour)

    -- The UI shows a value/max that is equal to barValue/barMax MINUS barMin
    local currentUIVal = barValue - barMin
    local currentUIMax = barMax - barMin

    if (barValue == barMax and barValue > 0) then
        currentUIVal = barMax
        currentUIMax = barMax
    end

    local showStanding = configs.showCurrentStandingPreExalted and standingId
    local currentStanding = showStanding and
        (type(standingId) == 'number' and ' (' .. _G['FACTION_STANDING_LABEL' .. standingId] .. ')' or ' (' .. standingId .. ')') or
        ''


    return '|c' .. nonParagonColour .. BreakUpLargeNumbers(currentUIVal) .. '/' .. BreakUpLargeNumbers(currentUIMax) .. currentStanding .. '|r'
end


-- Paragon
local getParagonColouredValue = function(val, threshold, hasReward, standingId)
    -- Paragon colours
    local paragonColour = getColour(colours.paragonColour)
    local paragonAvailable = getColour(colours.paragonAvailable)

    if not (val > threshold) then
        return '|c' .. paragonColour .. val .. '/' .. threshold .. '|r'
    end

    local adjustedVal = getParagonValue(val, threshold, hasReward)

    local showStanding = configs.showCurrentStandingExalted and standingId
    local currentStanding = showStanding and
        (type(standingId) == 'number' and ' (' .. _G['FACTION_STANDING_LABEL' .. standingId] .. ')' or ' (' .. standingId .. ')') or
        ''

    if hasReward then
        return '|c' .. paragonAvailable .. BreakUpLargeNumbers(adjustedVal) .. '/' .. BreakUpLargeNumbers(threshold) .. currentStanding .. '|r'
    end

    return '|c' .. paragonColour .. BreakUpLargeNumbers(adjustedVal) .. '/' .. BreakUpLargeNumbers(threshold) .. currentStanding .. '|r'
end

-- 鼠标事件

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

    -- 升级经验
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

    -- 显示为经验条的声望
    local data = C_Reputation.GetWatchedFactionData()
    if data then
        local name = data.name
        local standing = data.reaction
        local barMin = data.currentReactionThreshold
        local barMax = data.nextReactionThreshold
        local value = data.currentStanding
        local factionID = data.factionID
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

    -- 显示为经验条的荣誉
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

    -- 名望/声望
    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(REPUTATION, 0.9, 0.8, 0.6)

    local nameIndex = 10

    for k, v in pairs(factionIDs) do
        if IsShiftKeyDown() or k == '1' then
            GameTooltip:AddLine(_G['EXPANSION_NAME' .. nameIndex], 0.9, 0.8, 0.6)
            nameIndex = nameIndex - 1

            for _, ids in pairs(v) do
                local factionID = ids[1]
                local textureID = ids[2]

                -- 名望
                local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
                local factionData = C_MajorFactions.GetMajorFactionData(factionID)

                -- 普通声望
                local friendship = C_GossipInfo.GetFriendshipReputation(factionID)

                --------------------- Check if it's a renown faction ---------------------
                if factionData and
                    (configs.showRenownProg or configs.showRenownLevel)
                    and not isMaxRenown or (isMaxRenown and not configs.hideAtMaxRenown)
                then
                    if not factionData then return end

                    local repName = factionData['name']
                    local renownLevel = factionData['renownLevel']
                    local renownReputationEarned = factionData['renownReputationEarned']
                    local renownLevelThreshold = factionData['renownLevelThreshold']

                    -- GetRenownLevels
                    local allRenownLevels = C_MajorFactions.GetRenownLevels(factionID)
                    local maxRenownLevelData = allRenownLevels[#allRenownLevels]
                    local maxRenownLevel = maxRenownLevelData['level']

                    local _, _, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

                    --Should given renown faction be shown
                    local showRenownFaction = (renownLevel > 0 or renownReputationEarned > 0 or configs.showUnmetRenownFaction)
                        and (not configs.onlyShowMaxRenownIfParagonBox or hasRewardPending or not isMaxRenown)

                    GameTooltip:AddDoubleLine(
                        getColouredRepName(textureID, repName),
                        getRenownColouredValue(renownReputationEarned, renownLevelThreshold, renownLevel, maxRenownLevel,
                            isMaxRenown,
                            factionID),
                        0.6, 0.8, 1, 1, 1, 1
                    )

                    --------------------- Check if it's a friendship reputation ---------------------
                    --friendship.nextThreshold is nil when a friendship is exalted
                elseif friendship and friendship.maxRep > 0 and friendship.nextThreshold then
                    local barMin = friendship.reactionThreshold
                    local barMax = friendship.nextThreshold or friendship.standing
                    local barValue = friendship.standing

                    GameTooltip:AddDoubleLine(
                        getColouredRepName(textureID, friendship.name),
                        getColouredValue(barMin, barMax, barValue, friendship.reaction)
                    )

                    --------------------- Assume it's a regular reputation ---------------------
                else
                    local fd = C_Reputation.GetFactionDataByID(factionID)
                    if not fd then return end

                    local repName = fd.name
                    local standingId = fd.reaction
                    local barMin = fd.currentReactionThreshold
                    local barMax = fd.nextReactionThreshold
                    local barValue = fd.currentStanding

                    local isAssumedUnmet = standingId == 4 and barMin == 0

                    --check if faction has paragon levels
                    local paragonValue = C_Reputation.GetFactionParagonInfo(factionID)

                    if barValue and
                        (
                            barValue > 0 or
                            configs.showHostile and barValue < 0 or
                            configs.showUnmet and isAssumedUnmet
                        ) and
                        (
                            barValue < barMax and configs.showBeforeExalted or
                            barValue == barMax and configs.showAfterExalted and not paragonValue
                        )
                    then
                        -- Set reputation information for the faction
                        GameTooltip:AddDoubleLine(
                            getColouredRepName(textureID, repName),
                            getColouredValue(barMin, barMax, barValue, standingId)
                        )

                        --Faction is exalted
                    elseif configs.showAfterExalted then
                        local curVal, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)

                        --Faction has paragon rewards possible
                        if curVal and threshold and (not configs.onlyShowParagonRewards or hasRewardPending) then
                            -- Set PARAGON information for the faction
                            GameTooltip:AddDoubleLine(
                                getColouredRepName(textureID, repName),
                                getParagonColouredValue(curVal, threshold, hasRewardPending, standingId)
                            )
                        end
                    end
                end
            end

            if not IsShiftKeyDown() then
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(
                    L['Hold SHIFT key for more factions'],
                    0.6, 0.8, 1
                )
                break
            end
        end
    end

    -- 暗影国度盟约等级
    if IsShiftKeyDown() then
        local covenantID = C_Covenants.GetActiveCovenantID()
        if covenantID and covenantID > 0 then
            GameTooltip:AddLine(L['Covenant'], 0.9, 0.8, 0.6)
            for i = 1, 4 do
                local level = _G['ANDROMEDA_ADB']['CovenantLevels'][C.MY_REALM][C.MY_NAME][i]
                if level > 0 then
                    GameTooltip:AddDoubleLine(getCovenantIcon(i) .. getCovenantName(i), level)
                end
            end
        end
    end

    GameTooltip:Show()
    F:RegisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

local function onLeave(self)
    barEntered = false
    F.HideTooltip()
    F:UnregisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

--

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
    'MAJOR_FACTION_RENOWN_LEVEL_CHANGED',
    'CHAT_MSG_COMBAT_FACTION_CHANGE',
}

local function constructBar()
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

    constructBar()
    setupScript()
    initCovenantLevel()
    updateCovenantLevel()
end
