local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

local msgList = {
    INSTANCE_RESET_SUCCESS = L['%s has been reset'],
    INSTANCE_RESET_FAILED = L['Cannot reset %s (There are players still inside the instance.)'],
    INSTANCE_RESET_FAILED_ZONING = L['Cannot reset %s (There are players in your party attempting to zone into an instance.)'],
    INSTANCE_RESET_FAILED_OFFLINE = L['Cannot reset %s (There are players offline in your party.)'],
}

function A:ResetInstance(text)
    for systemMessage, friendlyMessage in pairs(msgList) do
        systemMessage = _G[systemMessage]
        if (strmatch(text, gsub(systemMessage, '%%s', '.+'))) then
            local instance = strmatch(text, gsub(systemMessage, '%%s', '(.+)'))
            A:SendMessage(format(friendlyMessage, instance), A:GetChannel(true, true))

            return
        end
    end
end
