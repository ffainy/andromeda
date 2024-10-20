local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

local prog
local isTimeWalker, walkerTexture

local communityFeast = C_Spell.GetSpellName(388961)
local communityFeastTime = {
    ['CN'] = 1679747400, -- 20:30
    ['TW'] = 1679747400, -- 20:30
    ['KR'] = 1679747400, -- 20:30
    ['EU'] = 1679749200, -- 21:00
    ['US'] = 1679751000, -- 21:30
}

local delveList = {
    { uiMapID = 2248, delveID = 7787 }, -- Earthcrawl Mines
    { uiMapID = 2248, delveID = 7781 }, -- Kriegval's Rest
    { uiMapID = 2248, delveID = 7779 }, -- Fungal Folly
    { uiMapID = 2215, delveID = 7789 }, -- Skittering Breach
    { uiMapID = 2215, delveID = 7785 }, -- Nightfall Sanctum
    { uiMapID = 2215, delveID = 7783 }, -- The Sinkhole
    { uiMapID = 2215, delveID = 7780 }, -- Mycomancer Cavern
    { uiMapID = 2214, delveID = 7782 }, -- The Waterworks
    { uiMapID = 2214, delveID = 7788 }, -- The Dread Pit
    { uiMapID = 2255, delveID = 7790 }, -- The Spiral Weave
    { uiMapID = 2255, delveID = 7784 }, -- Tak-Rethan Abyss
    { uiMapID = 2255, delveID = 7786 }, -- TThe Underkeep
}

local function checkTimeWalker(event)
    local date = C_DateAndTime.GetCurrentCalendarTime()
    C_Calendar.SetAbsMonth(date.month, date.year)
    C_Calendar.OpenCalendar()

    local today = date.monthDay
    local numEvents = C_Calendar.GetNumDayEvents(0, today)
    if numEvents <= 0 then
        return
    end

    for i = 1, numEvents do
        local info = C_Calendar.GetDayEvent(0, today, i)
        if info and strfind(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= 'END' then
            isTimeWalker = true
            walkerTexture = info.iconTexture
            break
        end
    end

    F:UnregisterEvent(event, checkTimeWalker)
end

local function checkTexture(texture)
    if not walkerTexture then
        return
    end

    if walkerTexture == texture or walkerTexture == texture - 1 then
        return true
    end
end

local questlist = {
    { name = L['Winter Veil Daily'],       id = 6983 },
    { name = L['Blingtron Daily Pack'],    id = 34774 },
    { name = L['Timewarped Badge Reward'], id = 40168, texture = 1129674 }, -- TBC
    { name = L['Timewarped Badge Reward'], id = 40173, texture = 1129686 }, -- WotLK
    { name = L['Timewarped Badge Reward'], id = 40786, texture = 1304688 }, -- Cata
    { name = L['Timewarped Badge Reward'], id = 45799, texture = 1530590 }, -- MoP
    { name = L['Timewarped Badge Reward'], id = 55499, texture = 1129683 }, -- WoD
    { name = L['Timewarped Badge Reward'], id = 64710, texture = 1467047 }, -- Legion
    { name = C_Spell.GetSpellName(388945), id = 70866 },                    -- SoDK
    { name = '',                           id = 70906, itemID = 200468 },   -- Grand hunt
    { name = '',                           id = 70893, questName = true },  -- Community feast
    { name = '',                           id = 79226, questName = true },  -- The big dig
    { name = '',                           id = 78319, questName = true },  -- The superbloom
    { name = '',                           id = 76586, questName = true },  -- Spreading the Light / 散布圣光
    { name = '',                           id = 82946, questName = true },  -- Rollin' Down in the Deeps / 滚滚深邃都是蜡
    { name = '',                           id = 83240, questName = true },  -- The Theater Troupe / 剧场巡演
    { name = C_Map.GetAreaInfo(15141),     id = 83333 },                    -- Gearing Up for Trouble / 谨防麻烦(主机觉醒)
}

local region = GetCVar('portal')
local legionZoneTime = {
    ['EU'] = 1565168400, -- CN-16
    ['US'] = 1565197200, -- CN-8
    ['CN'] = 1565226000, -- CN time 8/8/2019 09:00 [1]
}
local bfaZoneTime = {
    ['CN'] = 1546743600, -- CN time 1/6/2019 11:00 [1]
    ['EU'] = 1546768800, -- CN+7
    ['US'] = 1546769340, -- CN+16
}

local invIndex = {
    [1] = {
        title = L['Legion Invasion'],
        duration = 66600,
        maps = { 630, 641, 650, 634 },
        timeTable = {},
        baseTime = legionZoneTime[region] or legionZoneTime['CN'],
    },
    [2] = {
        title = L['BfA Invasion'],
        duration = 68400,
        maps = { 862, 863, 864, 896, 942, 895 },
        timeTable = { 4, 1, 6, 2, 5, 3 },
        baseTime = bfaZoneTime[region] or bfaZoneTime['CN'],
    },
}

local mapAreaPoiIDs = {
    [630] = 5175,
    [641] = 5210,
    [650] = 5177,
    [634] = 5178,
    [862] = 5973,
    [863] = 5969,
    [864] = 5970,
    [896] = 5964,
    [942] = 5966,
    [895] = 5896,
}

local function getInvasionInfo(mapID)
    local areaPoiID = mapAreaPoiIDs[mapID]
    local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
    local mapInfo = C_Map.GetMapInfo(mapID)

    return seconds, mapInfo.name
end

local function checkInvasion(index)
    for _, mapID in pairs(invIndex[index].maps) do
        local timeLeft, name = getInvasionInfo(mapID)
        if timeLeft and timeLeft > 0 then
            return timeLeft, name
        end
    end
end

local function getNextTime(baseTime, index)
    local currentTime = time()
    local duration = invIndex[index].duration
    local elapsed = mod(currentTime - baseTime, duration)

    return duration - elapsed + currentTime
end

local function getNextLocation(nextTime, index)
    local inv = invIndex[index]
    local count = #inv.timeTable
    if count == 0 then
        return QUEUE_TIME_UNAVAILABLE
    end

    local elapsed = nextTime - inv.baseTime
    local round = mod(floor(elapsed / inv.duration) + 1, count)
    if round == 0 then
        round = count
    end

    return C_Map.GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

local huntAreaToMapID = { -- 狩猎区域ID转换为地图ID
    [7342] = 2023,        -- 欧恩哈拉平原
    [7343] = 2022,        -- 觉醒海岸
    [7344] = 2025,        -- 索德拉苏斯
    [7345] = 2024,        -- 碧蓝林海
}

local stormPoiIDs = {
    [2022] = {
        { 7249, 7250, 7251, 7252 },
        { 7253, 7254, 7255, 7256 },
        { 7257, 7258, 7259, 7260 },
    },

    [2023] = {
        { 7221, 7222, 7223, 7224 },
        { 7225, 7226, 7227, 7228 },
    },

    [2024] = {
        { 7229, 7230, 7231, 7232 },
        { 7233, 7234, 7235, 7236 },
        { 7237, 7238, 7239, 7240 },
    },

    [2025] = {
        { 7245, 7246, 7247, 7248 },
        { 7298, 7299, 7300, 7301 },
    },

    --[[ [2085] = {
        { 7241, 7242, 7243, 7244 },
    }, ]]
}

local atlasCache = {}
local function getElementalType(element) -- 获取入侵类型图标
    local str = atlasCache[element]
    if not str then
        local info = C_Texture.GetAtlasInfo('ElementalStorm-Lesser-' .. element)
        if info then
            str = F:GetTextureStrByAtlas(info, 16, 16)
            atlasCache[element] = str
        end
    end

    return str
end

local function getFormattedTimeLeft(timeLeft)
    return format('%.2d:%.2d', timeLeft / 60, timeLeft % 60)
end

local itemCache = {}
local function getItemLink(itemID)
    local link = itemCache[itemID]
    if not link then
        link = select(2, C_Item.GetItemInfo(itemID))
        itemCache[itemID] = link
    end

    return link
end

local title
local function addTitle(text)
    if not title then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(text, 0.6, 0.8, 1)
        title = true
    end
end

local function onShiftDown()
    if prog.entered then
        prog:onEnter()
    end
end


local function onEnter(self)
    self.entered = true

    RequestRaidInfo()

    local r, g, b
    local anchorTop = C.DB.Infobar.AnchorTop
    local GameTooltip = GameTooltip

    GameTooltip:SetOwner(
        self,
        (anchorTop and 'ANCHOR_BOTTOM') or 'ANCHOR_TOP',
        0, (anchorTop and -6) or 6
    )
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L['Daily/Weekly'], 0.9, 0.8, 0.6)

    -- World bosses
    title = false
    for i = 1, GetNumSavedWorldBosses() do
        local name, id, reset = GetSavedWorldBossInfo(i)
        if not (id == 11 or id == 12 or id == 13) then
            addTitle(RAID_INFO_WORLD_BOSS)
            GameTooltip:AddDoubleLine(
                name,
                SecondsToTime(reset, true, nil, 3),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    -- Mythic Dungeons
    title = false
    for i = 1, GetNumSavedInstances() do
        local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
        if diff == 23 and (locked or extended) then
            addTitle(DUNGEON_DIFFICULTY3 .. DUNGEONS)
            if extended then
                r, g, b = 0.3, 1, 0.3
            else
                r, g, b = 1, 1, 1
            end
            GameTooltip:AddDoubleLine(
                name, SecondsToTime(reset, true, nil, 3),
                1, 1, 1, r, g, b
            )
        end
    end

    -- Raids
    title = false
    for i = 1, GetNumSavedInstances() do
        local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numBosses, progress = GetSavedInstanceInfo(i)
        if isRaid and (locked or extended) then
            addTitle(RAID_INFO)

            if extended then
                r, g, b = 0.3, 1, 0.3
            else
                r, g, b = 1, 1, 1
            end

            local progressColor = (numBosses == progress) and 'ff0000' or '00ff00'
            local progressStr = format(' |cff%s(%s/%s)|r', progressColor, progress, numBosses)
            GameTooltip:AddDoubleLine(
                name .. ' - ' .. diffName .. progressStr,
                SecondsToTime(reset, true, nil, 3),
                1, 1, 1, r, g, b
            )
        end
    end

    -- Quests
    title = false
    for _, v in pairs(questlist) do
        if v.name and C_QuestLog.IsQuestFlaggedCompleted(v.id) then
            if v.name == L['Timewarped'] and isTimeWalker and checkTexture(v.texture) or v.name ~= L['Timewarped'] then
                addTitle(QUESTS_LABEL)
                GameTooltip:AddDoubleLine(
                    (v.itemID and getItemLink(v.itemID)) or (v.questName and QuestUtils_GetQuestName(v.id)) or v.name,
                    QUEST_COMPLETE,
                    1, 1, 1, 1, 0, 0
                )
            end
        end
    end

    -- Delves
    title = false
    for _, v in pairs(delveList) do
        local delveInfo = C_AreaPoiInfo.GetAreaPOIInfo(v.uiMapID, v.delveID)
        if delveInfo then
            addTitle(delveInfo.description)
            local mapInfo = C_Map.GetMapInfo(v.uiMapID)
            GameTooltip:AddDoubleLine(
                mapInfo.name .. ' - ' .. delveInfo.name,
                SecondsToTime(GetQuestResetTime(), true, nil, 3),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    if IsShiftKeyDown() then
        -- Elemental threats
        title = false
        for mapID, stormGroup in next, stormPoiIDs do
            for _, areaPoiIDs in next, stormGroup do
                for _, areaPoiID in next, areaPoiIDs do
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
                    local elementType = poiInfo
                        and poiInfo.atlasName
                        and strmatch(poiInfo.atlasName, 'ElementalStorm%-Lesser%-(.+)')

                    if elementType then
                        addTitle(poiInfo.name)

                        local mapInfo = C_Map.GetMapInfo(mapID)
                        local timeLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) or 0

                        timeLeft = timeLeft / 60

                        if timeLeft < 60 then
                            r, g, b = 1, 0, 0
                        else
                            r, g, b = 0, 1, 0
                        end

                        GameTooltip:AddDoubleLine(
                            mapInfo.name .. getElementalType(elementType),
                            getFormattedTimeLeft(timeLeft),
                            1, 1, 1, r, g, b
                        )

                        break
                    end
                end
            end
        end

        -- Grand hunts
        title = false
        for areaPoiID, mapID in pairs(huntAreaToMapID) do
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(1978, areaPoiID) -- Dragon isles
            if poiInfo then
                addTitle(poiInfo.name)

                local mapInfo = C_Map.GetMapInfo(mapID)
                local timeLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) or 0

                timeLeft = timeLeft / 60

                if timeLeft < 60 then
                    r, g, b = 1, 0, 0
                else
                    r, g, b = 0, 1, 0
                end

                GameTooltip:AddDoubleLine(
                    mapInfo.name,
                    getFormattedTimeLeft(timeLeft),
                    1, 1, 1, r, g, b
                )

                break
            end
        end

        -- Community feast
        title = false
        local feastTime = communityFeastTime[region]
        if feastTime then
            local currentTime = time()
            local duration = 5400 -- 1.5hrs
            local elapsed = mod(currentTime - feastTime, duration)
            local nextTime = duration - elapsed + currentTime

            addTitle(communityFeast)

            if currentTime - (nextTime - duration) < 900 then
                r, g, b = 0, 1, 0
            else
                r, g, b = 0.6, 0.6, 0.6
            end -- green text if progressing

            GameTooltip:AddDoubleLine(
                date('%m/%d %H:%M', nextTime - duration * 2),
                date('%m/%d %H:%M', nextTime - duration),
                0.6, 0.6, 0.6, r, g, b
            )
            GameTooltip:AddDoubleLine(
                date('%m/%d %H:%M', nextTime),
                date('%m/%d %H:%M', nextTime + duration),
                1, 1, 1, 1, 1, 1
            )
        end

        -- Invasions
        for index, value in ipairs(invIndex) do
            title = false
            addTitle(value.title)
            local timeLeft, zoneName = checkInvasion(index)
            local nextTime = getNextTime(value.baseTime, index)

            if timeLeft then
                timeLeft = timeLeft / 60
                if timeLeft < 60 then
                    r, g, b = 1, 0, 0
                else
                    r, g, b = 0, 1, 0
                end

                GameTooltip:AddDoubleLine(
                    L['Current Invasion: '] .. zoneName,
                    format('%.2d:%.2d', timeLeft / 60, timeLeft % 60),
                    1, 1, 1, r, g, b
                )
                GameTooltip:AddDoubleLine(
                    L['Current Invasion: '] .. zoneName,
                    getFormattedTimeLeft(timeLeft),
                    1, 1, 1, r, g, b
                )
            end

            local nextLocation = getNextLocation(nextTime, index)
            GameTooltip:AddDoubleLine(
                L['Next Invasion: '] .. nextLocation,
                date('%m/%d %H:%M', nextTime),
                1, 1, 1, 1, 1, 1
            )
        end
    else
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            L['Hold SHIFT key for more events'],
            0.6, 0.8, 1
        )
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
    GameTooltip:AddDoubleLine(
        ' ',
        C.MOUSE_LEFT_BUTTON .. L['Toggle Calendar Panel'],
        1, 1, 1, 0.9, 0.8, 0.6
    )
    GameTooltip:AddDoubleLine(
        ' ',
        C.MOUSE_RIGHT_BUTTON .. L['Toggle Great Vault Panel'],
        1, 1, 1, 0.9, 0.8, 0.6
    )
    GameTooltip:Show()

    F:RegisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

local function onMouseUp(self, btn)
    if btn == 'RightButton' then
        if not WeeklyRewardsFrame then
            C_AddOns.LoadAddOn('Blizzard_WeeklyRewards')
        end
        if InCombatLockdown() then
            F:TogglePanel(WeeklyRewardsFrame)
        else
            ToggleFrame(WeeklyRewardsFrame)
        end

        local dialog = WeeklyRewardExpirationWarningDialog
        if dialog and dialog:IsShown() then
            dialog:Hide()
        end
    elseif btn == 'MiddleButton' then
        ToggleTimeManager()
    else
        ToggleCalendar()
    end
end

local function onLeave(self)
    self.entered = false
    F.HideTooltip()
    F:UnregisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

function INFOBAR:CreateChoreBlock()
    if not C.DB.Infobar.Chore then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', checkTimeWalker)

    prog = INFOBAR:RegisterNewBlock('progress', 'RIGHT', 150)
    prog.text:SetText(L['Daily/Weekly'])
    prog.onEnter = onEnter
    prog.onLeave = onLeave
    prog.onMouseUp = onMouseUp
end
