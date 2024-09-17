local F, C, L = unpack(select(2, ...))
local CHAT = F:GetModule('Chat')

local ABBREVIATIONS = {
    OFFICER = 'O',
    GUILD = 'G',
    PARTY = 'P',
    RAID = 'R',
    INSTANCE_CHAT = 'I',
}

local CLIENT_COLORS = {
    [BNET_CLIENT_APP] = '22aaff',
    [BNET_CLIENT_WOW] = '5cc400',
}

local function getClientColorAndTag(accountID)
    local account = C_BattleNet.GetAccountInfoByID(accountID)
    if account then -- fails when bnet is offline
        local accountClient = account.gameAccountInfo.clientProgram
        local color = CLIENT_COLORS[accountClient] or CLIENT_COLORS[BNET_CLIENT_APP]
        return color, account.battleTag:match('(%w+)#%d+')
    end
end

local FORMAT_PLAYER = '|Hplayer:%s|h%s|h'
local function formatPlayer(info, name)
    return FORMAT_PLAYER:format(info, name:gsub('%-[^|]+', ''))
end

local FORMAT_BN_PLAYER = '|HBNplayer:%s|h|cff%s%s|r|h'
local function formatBNPlayer(info)
    -- replace the colors with a client color
    local color, tag = getClientColorAndTag(info:match('(%d+):'))
    return FORMAT_BN_PLAYER:format(info, color or 'ffffff', tag or UNKNOWN)
end

local FORMAT_CHANNEL = '|Hchannel:%s|h%s|h %s'
local function formatChannel(info, name)
    if name:match(LEADER) then
        return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '|cffffff00!|r')
    else
        return FORMAT_CHANNEL:format(info, ABBREVIATIONS[info] or info:gsub('channel:', ''), '')
    end
end

local FORMAT_WAYPOINT_FAR = '|Hworldmap:%d:%d:%d|h[%s: %.2f, %.2f]|h'
local FORMAT_WAYPOINT_NEAR = '|Hworldmap:%d:%d:%d|h[%.2f, %.2f]|h'
local function formatWaypoint(mapID, x, y)
    local playerMapID = C_Map.GetBestMapForUnit('player')
    if tonumber(mapID) ~= playerMapID then
        local mapInfo = C_Map.GetMapInfo(mapID)
        return FORMAT_WAYPOINT_FAR:format(mapID, x, y, mapInfo.name, x / 100, y / 100)
    else
        return FORMAT_WAYPOINT_NEAR:format(mapID, x, y, x / 100, y / 100)
    end
end





function CHAT:GetColor(className, isLocal)
    -- For modules that need to class color things
    if isLocal then
        local found
        for k, v in next, LOCALIZED_CLASS_NAMES_FEMALE do
            if v == className then
                className = k
                found = true
                break
            end
        end
        if not found then
            for k, v in next, LOCALIZED_CLASS_NAMES_MALE do
                if v == className then
                    className = k
                    break
                end
            end
        end
    end
    local tbl = C.ClassColors and C.ClassColors[className] or RAID_CLASS_COLORS[className]
    if not tbl then
        -- Seems to be a bug since 5.3 where the friends list is randomly empty and fires friendlist updates with an "Unknown" class.
        return ('%02x%02x%02x'):format(GRAY_FONT_COLOR.r * 255, GRAY_FONT_COLOR.g * 255, GRAY_FONT_COLOR.b * 255)
    end
    local color = ('%02x%02x%02x'):format(tbl.r * 255, tbl.g * 255, tbl.b * 255)
    return color
end

local changeBNetName = function(icon, misc, id, moreMisc, fakeName, tag, colon)
    local accountInfoTbl = C_BattleNet.GetAccountInfoByID(id)
    local battleTag, englishClass = accountInfoTbl.battleTag, accountInfoTbl.gameAccountInfo.className

    if not battleTag then
        local msg = 'battleTag was nil!'
        F.Debug(msg)
        geterrorhandler()(msg)
    elseif battleTag == '' then
        local msg = 'battleTag was blank!'
        F.Debug(msg)
        geterrorhandler()(msg)
    else
        fakeName = battleTag:gsub('^(.+)#%d+$', '%1') -- Replace real name with battle tag
    end

    if englishClass and englishClass ~= '' then                              -- Not playing wow, logging off, etc.
        -- fakeName = noBNetColor and fakeName or "|cFF"..CHAT:GetColor(englishClass, true)..fakeName.."|r"
        fakeName = '|cFF' .. CHAT:GetColor(englishClass, true) .. fakeName .. '|r' -- Colour name if enabled
    end

    -- if noBNetIcon then --Remove "person" icon if enabled
    -- 	icon = icon:gsub("|[Tt][^|]+|[Tt]", "")
    -- end

    return icon .. misc .. id .. moreMisc .. fakeName .. tag .. colon
end


local chatFrameHooks = {}
local function addMessage(chatFrame, msg, ...)
    if strfind(msg, INTERFACE_ACTION_BLOCKED) and not C.IS_DEVELOPER then
        return
    end

    -- Different whisper color
    local r, g, b = ...
    if strfind(msg, L['Tell'] .. ' |H[BN]*player.+%]') then
        r, g, b = r * 0.7, g * 0.7, b * 0.7
    end

    -- Dev logo
    local unitName = strmatch(msg, '|Hplayer:([^|:]+)')
    if unitName and C.DevsList[unitName] then
        msg = msg:gsub('(|Hplayer.+)', '|T' .. C.Assets.Textures.LogoChat .. ':14:14|t%1')
    end

    msg = msg:gsub('|Hplayer:(.-)|h%[(.-)%]|h', formatPlayer)
    --msg = msg:gsub('|HBNplayer:(.-)|h%[(.-)%]|h', formatBNPlayer)
    msg = msg:gsub('^(.*)(|HBNplayer:%S-|k:)(%d-)(:%S-|h)%[(%S-)%](|?h?)(:?)', changeBNetName)
    msg = msg:gsub('|Hchannel:(.-)|h%[(.-)%]|h', formatChannel)
    msg = msg:gsub('^%w- (|H)', '|cffa1a1a1@|r%1')
    msg = msg:gsub('^(.-|h) %w-:', '%1:')
    msg = msg:gsub('^%[' .. RAID_WARNING .. '%]', 'RW')
    msg = msg:gsub('|Hworldmap:(.-):(.-):(.-)|h%[(.-)%]|h', formatWaypoint)
    -- msg = msg:gsub(CHAT_FLAG_AFK, '')
    -- msg = msg:gsub(CHAT_FLAG_DND, '')

    msg = msg:gsub('|h：', '|h: ')

    return chatFrameHooks[chatFrame](chatFrame, msg, r, g, b)
end

function CHAT:ShortenChannelNames()
    for index = 1, NUM_CHAT_WINDOWS do
        if index ~= 2 then -- ignore combat frame
            -- override the message injection
            local chatFrame = _G['ChatFrame' .. index]
            chatFrameHooks[chatFrame] = chatFrame.AddMessage
            chatFrame.AddMessage = addMessage
        end
    end



    -- whisper
    CHAT_WHISPER_INFORM_GET = L['Tell'] .. ' %s: '
    CHAT_WHISPER_GET = L['From'] .. ' %s: '
    CHAT_BN_WHISPER_INFORM_GET = L['Tell'] .. ' %s: '
    CHAT_BN_WHISPER_GET = L['From'] .. ' %s: '

    -- online/offline info
    ERR_FRIEND_ONLINE_SS = gsub(ERR_FRIEND_ONLINE_SS, '%]%|h', ']|h|cff00c957')
    ERR_FRIEND_OFFLINE_S = gsub(ERR_FRIEND_OFFLINE_S, '%%s', '%%s|cffff7f50')

    -- say / yell
    CHAT_SAY_GET = '%s: '
    CHAT_YELL_GET = '%s: '

    if C.DB.Chat.ShortenChannelName then
        --[[ -- guild
        CHAT_GUILD_GET = '|Hchannel:GUILD|h[G]|h %s '
        CHAT_OFFICER_GET = '|Hchannel:OFFICER|h[O]|h %s '

        -- raid
        CHAT_RAID_GET = '|Hchannel:RAID|h[R]|h %s '
        CHAT_RAID_WARNING_GET = '[RW] %s '
        CHAT_RAID_LEADER_GET = '|Hchannel:RAID|h[RL]|h %s '

        -- party
        CHAT_PARTY_GET = '|Hchannel:PARTY|h[P]|h %s '
        CHAT_PARTY_LEADER_GET = '|Hchannel:PARTY|h[PL]|h %s '
        CHAT_PARTY_GUIDE_GET = '|Hchannel:PARTY|h[PG]|h %s '

        -- instance
        CHAT_INSTANCE_CHAT_GET = '|Hchannel:INSTANCE|h[I]|h %s '
        CHAT_INSTANCE_CHAT_LEADER_GET = '|Hchannel:INSTANCE|h[IL]|h %s ' ]]

        -- flags
        CHAT_FLAG_AFK = '[AFK] '
        CHAT_FLAG_DND = '[DND] '
        CHAT_FLAG_GM = '[GM] '
    end
end
