local F, C = unpack(select(2, ...))

C.DevsList = {}

do
    if C.IS_DEVELOPER then
        C.DevsList[C.MY_FULL_NAME] = true
    end
end

F:RegisterSlashCommand('/nt', function()
    local enumf = EnumerateFrames()
    while enumf do
        if (enumf:IsObjectType('GameTooltip') or strfind((enumf:GetName() or ''):lower(), 'tip')) and enumf:IsVisible() and enumf:GetPoint() then
            print(enumf:GetName())
        end
        enumf = EnumerateFrames(enumf)
    end
end)

F:RegisterSlashCommand('/nf', function()
    local frame = EnumerateFrames()
    while frame do
        if (frame:IsVisible() and MouseIsOver(frame)) then
            print(frame:GetName() or format(UNKNOWN .. ': [%s]', tostring(frame)))
        end
        frame = EnumerateFrames(frame)
    end
end)

F:RegisterSlashCommand('/rl', function()
    ReloadUI()
end)

F:RegisterSlashCommand('/fs', function()
    UIParentLoadAddOn('Blizzard_DebugTools')
    FrameStackTooltip_Toggle(false, true, true)
end)

-- Disable all addons except andromeda and debug tool
F:RegisterSlashCommand('/debugmode', function()
    for i = 1, C_AddOns.GetNumAddOns() do
        local name = C_AddOns.GetAddOnInfo(i)
        if name ~= C.ADDON_NAME and name ~= '!BaudErrorFrame' and C_AddOns.GetAddOnEnableState(C.MY_NAME, name) == 2 then
            C_AddOns.DisableAddOn(name, C.MY_NAME)
        end
    end

    ReloadUI()
end)

-- Print NPC ID
local pattern = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
local function getNpcId(unit)
    if unit and UnitExists(unit) then
        local npcGUID = UnitGUID(unit)
        return npcGUID and (tonumber(npcGUID:match(pattern)))
    end
end

F:RegisterSlashCommand('/getnpcid', function()
    local npcID = getNpcId('target')
    if npcID then
        local str = 'NPC ID: ' .. npcID
        F:Print(str)
    end
end)

-- Print quest info
F:RegisterSlashCommand('/checkqueststatus', function(msg)
    local questID = tonumber(msg)
    if questID then
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
        local status = isCompleted and '|cff20ff20COMPLETE|r' or '|cffff2020NOT complete|r'
        local str = 'Quest |cffe9c55d' .. questID .. '|r is ' .. status

        F:Print(str)
    end
end)

-- Print map info
F:RegisterSlashCommand('/getmapid', function()
    local mapID
    if WorldMapFrame:IsShown() then
        mapID = WorldMapFrame:GetMapID()
    else
        mapID = C_Map.GetBestMapForUnit('player')
    end

    F:Printf('Map ID: |cffe9c55d%s|r (%s)', mapID, C_Map.GetMapInfo(mapID).name)
end)

-- Print instance info
F:RegisterSlashCommand('/getinstinfo', function()
    local name, instanceType, difficultyID, difficultyName, _, _, _, instanceMapID = GetInstanceInfo()
    F:Print(C.LINE_STRING)
    F:Print('Name ' .. C.INFO_COLOR .. name)
    F:Print('instanceType ' .. C.INFO_COLOR .. instanceType)
    F:Print('difficultyID ' .. C.INFO_COLOR .. difficultyID)
    F:Print('difficultyName ' .. C.INFO_COLOR .. difficultyName)
    F:Print('instanceMapID ' .. C.INFO_COLOR .. instanceMapID)
    F:Print(C.LINE_STRING)
end)

-- Print item info
F:RegisterSlashCommand('/getiteminfo', function(msg)
    local itemID = tonumber(msg)
    if itemID then
        local name, link, rarity, level, minLevel, type, subType, _, _, _, _, classID, subClassID, bindType =
        C_Item.GetItemInfo(itemID)
        if name then
            F:Print(C.LINE_STRING)
            F:Print('Name ' .. C.INFO_COLOR .. name)
            F:Print('Link ' .. link)
            F:Print('Rarity ' .. C.INFO_COLOR .. rarity)
            F:Print('Level ' .. C.INFO_COLOR .. level)
            F:Print('MinLevel ' .. C.INFO_COLOR .. minLevel)
            F:Print('Type ' .. C.INFO_COLOR .. type)
            F:Print('SubType ' .. C.INFO_COLOR .. subType)
            F:Print('ClassID ' .. C.INFO_COLOR .. classID)
            F:Print('SubClassID ' .. C.INFO_COLOR .. subClassID)
            F:Print('BindType ' .. C.INFO_COLOR .. bindType)
            F:Print(C.LINE_STRING)
        else
            F:Print('Item ' .. itemID .. ' |cffff2020NOT found|r')
        end
    end
end)

-- Print screen scale info
F:RegisterSlashCommand('/getscaleinfo', function()
    F:Print(C.LINE_STRING)
    F:Print('C.SCREEN_WIDTH ' .. C.SCREEN_WIDTH)
    F:Print('C.SCREEN_HEIGHT ' .. C.SCREEN_HEIGHT)
    F:Print('C.MULT ' .. C.MULT)
    F:Print('UIScale ' .. _G.ANDROMEDA_ADB.UIScale)
    F:Print('UIParentScale ' .. UIParent:GetScale())
    F:Print(C.LINE_STRING)
end)

-- DBM test
F:RegisterSlashCommand('/dbmtest', function()
    if C_AddOns.IsAddOnLoaded('DBM-Core') then
        _G['DBM']:DemoMode()
    else
        F:Print(C.RED_COLOR .. 'DBM is not loaded.')
    end
end)

--[[ do
    local sortedKeys = {}
    for k in pairs(tempTable) do
        sortedKeys[#sortedKeys + 1] = k
    end
    sort(sortedKeys)
    for i, k in ipairs(sortedKeys) do
        local v = tempTable[k]
        F:Print(k, v)
    end
end ]]

function F:Debug(...)
    if C.IS_DEVELOPER then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff2020[Debug]: |r " .. format(...))
    end
end

function F:ThrowError(...)
    local message = strjoin(' ', ...)
    geterrorhandler()(format('%s |cffff3860%s|r\n', C.ADDON_TITLE, '[ERROR]') .. message)
end

function F:Dump(object, inspect)
    if C_AddOns.GetAddOnEnableState(C.MY_NAME, 'Blizzard_DebugTools') == 0 then
        F:Print('Blizzard_DebugTools is disabled.')
        return
    end

    local debugTools = C_AddOns.IsAddOnLoaded('Blizzard_DebugTools')
    if not debugTools then
        UIParentLoadAddOn('Blizzard_DebugTools')
    end

    if inspect then
        local tableType = type(object)
        if tableType == 'table' then
            DisplayTableInspectorWindow(object)
        else
            F:Print('Failed: ', tostring(object), ' is type: ', tableType, '. Requires table object.')
        end
    else
        DevTools_Dump(object)
    end
end
