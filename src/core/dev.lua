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
        F.Print(str)
    end
end)

-- Print quest info
F:RegisterSlashCommand('/checkqueststatus', function(msg)
    local questID = tonumber(msg)
    if questID then
        local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
        local status = isCompleted and '|cff20ff20COMPLETE|r' or '|cffff2020NOT complete|r'
        local str = 'Quest |cffe9c55d' .. questID .. '|r is ' .. status

        F.Print(str)
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

    F.Print('Map ID: |cffe9c55d%s|r (%s)', mapID, C_Map.GetMapInfo(mapID).name)
end)

-- Print instance info
F:RegisterSlashCommand('/getinstinfo', function()
    local name, instanceType, difficultyID, difficultyName, _, _, _, instanceMapID = GetInstanceInfo()
    F.Print(C.LINE_STRING)
    F.Print('Name ' .. C.INFO_COLOR .. name)
    F.Print('instanceType ' .. C.INFO_COLOR .. instanceType)
    F.Print('difficultyID ' .. C.INFO_COLOR .. difficultyID)
    F.Print('difficultyName ' .. C.INFO_COLOR .. difficultyName)
    F.Print('instanceMapID ' .. C.INFO_COLOR .. instanceMapID)
    F.Print(C.LINE_STRING)
end)

-- Print item info
F:RegisterSlashCommand('/getiteminfo', function(msg)
    local itemID = tonumber(msg)
    if itemID then
        local name, link, rarity, level, minLevel, type, subType, _, _, _, _, classID, subClassID, bindType =
            C_Item.GetItemInfo(itemID)
        if name then
            F.Print(C.LINE_STRING)
            F.Print('Name ' .. C.INFO_COLOR .. name)
            F.Print('Link ' .. link)
            F.Print('Rarity ' .. C.INFO_COLOR .. rarity)
            F.Print('Level ' .. C.INFO_COLOR .. level)
            F.Print('MinLevel ' .. C.INFO_COLOR .. minLevel)
            F.Print('Type ' .. C.INFO_COLOR .. type)
            F.Print('SubType ' .. C.INFO_COLOR .. subType)
            F.Print('ClassID ' .. C.INFO_COLOR .. classID)
            F.Print('SubClassID ' .. C.INFO_COLOR .. subClassID)
            F.Print('BindType ' .. C.INFO_COLOR .. bindType)
            F.Print(C.LINE_STRING)
        else
            F.Print('Item ' .. itemID .. ' |cffff2020NOT found|r')
        end
    end
end)

-- Print screen scale info
F:RegisterSlashCommand('/getscaleinfo', function()
    F.Print(C.LINE_STRING)
    F.Print('C.SCREEN_WIDTH ' .. C.SCREEN_WIDTH)
    F.Print('C.SCREEN_HEIGHT ' .. C.SCREEN_HEIGHT)
    F.Print('C.MULT ' .. C.MULT)
    F.Print('UIScale ' .. _G.ANDROMEDA_ADB.UIScale)
    F.Print('UIParentScale ' .. UIParent:GetScale())
    F.Print(C.LINE_STRING)
end)

-- DBM test
F:RegisterSlashCommand('/dbmtest', function()
    if C_AddOns.IsAddOnLoaded('DBM-Core') then
        _G['DBM']:DemoMode()
    else
        F.Print(C.RED_COLOR .. 'DBM is not loaded.')
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
        F.Print(k, v)
    end
end ]]

local prefix = '|T' .. C.Assets.Textures.LogoChat .. ':14:14|t'
function F.Print(...)
    print(prefix, format(...))
end

function F.Debug(...)
    local message = strjoin(' ', ...)
    print(format('%s |cff00d1b2[DEBUG]|r %s', prefix, message))
end

function F.SuperPrint(object)
    if not C.IS_DEVELOPER then
        return
    end

    if type(object) == 'table' then
        local cache = {}
        local function printLoop(subject, indent)
            if cache[tostring(subject)] then
                print(indent .. '*' .. tostring(subject))
            else
                cache[tostring(subject)] = true
                if type(subject) == 'table' then
                    for pos, val in pairs(subject) do
                        if type(val) == 'table' then
                            print(indent .. '[' .. pos .. '] => ' .. tostring(subject) .. ' {')
                            printLoop(val, indent .. strrep(' ', strlen(pos) + 8))
                            print(indent .. strrep(' ', strlen(pos) + 6) .. '}')
                        elseif type(val) == 'string' then
                            print(indent .. '[' .. pos .. '] => "' .. val .. '"')
                        else
                            print(indent .. '[' .. pos .. '] => ' .. tostring(val))
                        end
                    end
                else
                    print(indent .. tostring(subject))
                end
            end
        end
        if type(object) == 'table' then
            print(tostring(object) .. ' {')
            printLoop(object, '  ')
            print('}')
        else
            printLoop(object, '  ')
        end
        print()
    elseif type(object) == 'string' then
        print('(string) "' .. object .. '"')
    else
        print('(' .. type(object) .. ') ' .. tostring(object))
    end
end

function F.ThrowError(...)
    local message = strjoin(' ', ...)
    geterrorhandler()(format('%s |cffff3860[ERROR]|r\n%s', '|T' .. C.Assets.Textures.LogoChat .. ':14:14|t', message))
end
