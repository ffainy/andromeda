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


local playerClass = {}
function CHAT:FRIENDLIST_UPDATE()
    for index = 1, C_FriendList.GetNumFriends() do
        local friend = C_FriendList.GetFriendInfoByIndex(index)
        if friend and friend.connected then
            playerClass[friend.name] = friend.className -- TODO: is this className localized or not?
        end
    end
end

function CHAT:GUILD_ROSTER_UPDATE()
    for index = 1, (GetNumGuildMembers()) do
        local characterName, _, _, _, _, _, _, _, isOnline, _, characterClass = GetGuildRosterInfo(index)
        if isOnline then
            -- guildies are always on the same server (for now)
            characterName = string.split('-', characterName)
            playerClass[characterName] = characterClass
        end
    end
end

function CHAT:GROUP_ROSTER_UPDATE()
    if IsInGroup() then
        local prefix = IsInRaid() and 'raid' or 'party'
        local groupSize = IsInRaid() and 40 or 5

        for index = 1, groupSize do
            if UnitExists(prefix .. index) and not UnitIsUnit('player', prefix .. index) then
                local name, realm = UnitName(prefix .. index)
                if realm then
                    name = name .. '-' .. realm
                end

                playerClass[name] = UnitClassBase(prefix .. index)
            end
        end
    end
end

function CHAT:PLAYER_TARGET_CHANGED()
    if UnitExists('target') then
        playerClass[GetUnitName('target')] = UnitClassBase('target')
    end
end

function CHAT:CHAT_MSG_WHISPER(_, playerName, _, _, _, _, _, _, _, _, _, playerGUID)
    if not playerClass[playerName] then
        local _, className = GetPlayerInfoByGUID(playerGUID)
        playerClass[playerName] = className
    end
end

function CHAT:PLAYER_LOGIN()
    -- these two don't seem to trigger on login
    self:FRIENDLIST_UPDATE()
    self:GROUP_ROSTER_UPDATE()
    return true
end

-- adjust abbreviations in the edit box
local editBoxHooks = {}
function editBoxHooks.WHISPER(editBox)
    if not editBox.header then
        return
    end

    local characterName = editBox:GetAttribute('tellTarget')
    local characterClass = playerClass[characterName]
    if characterClass then
        local classColor = C_ClassColor.GetClassColor(characterClass)
        editBox.header:SetFormattedText('|cffa1a1a1@|r%s: ', classColor:WrapTextInColorCode(characterName))
    else
        editBox.header:SetFormattedText('|cffa1a1a1@|r%s: ', characterName)
    end
end

function editBoxHooks.BN_WHISPER(editBox)
    local color, tag = getClientColorAndTag(GetAutoCompletePresenceID(editBox:GetAttribute('tellTarget')))
    if color and tag then
        editBox.header:SetFormattedText('|cffa1a1a1@|r|cff%s%s|r: ', color, tag)
    end
end

function editBoxHooks.CHANNEL(editBox)
    local _, channelName, instanceID = GetChannelName(editBox:GetAttribute('channelTarget'))
    if channelName then
        -- channelName = channelName:match('%w+')
        if instanceID > 0 then
            channelName = channelName .. instanceID
        end

        editBox.header:SetFormattedText('%s: ', channelName)
    end
end

hooksecurefunc('ChatEdit_UpdateHeader', function(editBox)
    local chatType = editBox:GetAttribute('chatType')
    if not chatType or not editBox.header then
        return
    end

    if editBoxHooks[chatType] then
        editBoxHooks[chatType](editBox)
    end

    -- since we're re-formatting the editbox header we'll need to adjust its insets
    editBox:SetTextInsets(editBox.header:GetWidth() + 13, 13, 0, 0)
end)










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
    msg = msg:gsub('|HBNplayer:(.-)|h%[(.-)%]|h', formatBNPlayer)
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
