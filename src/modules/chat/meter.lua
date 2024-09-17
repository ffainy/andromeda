-- Merge damage meter spam
-- SpamageMeters by Wrug and Cybey

local F, C = unpack(select(2, ...))
local CHAT = F:GetModule('Chat')

local firstLines = {
    '^Details!: (.*)$', -- Details!
    '^Recount - (.*)$', -- Recount
    '^Skada: (.*) for (.*):$', -- Skada enUS
    '^Skada: (.*) für (.*):$', -- Skada deDE
    '^Skada: (.*) pour (.*):$', -- Skada frFR
    '^Отчёт Skada: (.*), с (.*):$', -- Skada ruRU
    '^Skada: (.*) por (.*):$', -- Skada esES/ptBR
    '^Skada: (.*) per (.*):$', -- Skada itIT
    '^(.*) 의 Skada 보고 (.*):$', -- Skada koKR
    '^Skada报告(.*)的(.*):$', -- Skada zhCN
    '^Skada:(.*)來自(.*):$', -- Skada zhTW
    '^Numeration: (.*) - (.*)$', -- Numeration
    '^(.*) Done for (.*)$', -- TinyDPS enUS
    '^(.*) für (.*)$', -- TinyDPS deDE
    '데미지량 -(.*)$', -- TinyDPS koKR
    '힐량 -(.*)$', -- TinyDPS koKR
    'Урон:(.*)$', -- TinyDPS ruRU
    'Исцеление:(.*)$', -- TinyDPS ruRU
}

local nextLines = {
    '^(%d+). (.*)$', -- Recount, Details! and Skada
    '^(.*)   (.*)$', -- Additional Skada
    '^[+-]%d+.%d', -- Numeration deathlog details
    '^(%d+). (.*):(.*)(%d+)(.*)(%d+)%%(.*)%((%d+)%)$', -- TinyDPS
}

local meters = {}

local events = {
    'CHAT_MSG_CHANNEL',
    'CHAT_MSG_GUILD',
    'CHAT_MSG_OFFICER',
    'CHAT_MSG_PARTY',
    'CHAT_MSG_PARTY_LEADER',
    'CHAT_MSG_RAID',
    'CHAT_MSG_RAID_LEADER',
    'CHAT_MSG_INSTANCE_CHAT',
    'CHAT_MSG_INSTANCE_CHAT_LEADER',
    'CHAT_MSG_SAY',
    'CHAT_MSG_WHISPER',
    'CHAT_MSG_WHISPER_INFORM',
    'CHAT_MSG_YELL',
}

local function FilterLine(event, source, message)
    for i = 1, #nextLines do
        local v = nextLines[i]
        if message:match(v) then
            local curTime = _G.time()
            for i = 1, #meters do
                local j = meters[i]
                local elapsed = curTime - j.time
                if j.source == source and j.event == event and elapsed < 5 then
                    local toInsert = true

                    for i = 1, #j.data do
                        if j.data[i] == message then
                            toInsert = false
                        end
                    end

                    if toInsert then
                        tinsert(j.data, message)
                    end
                    return true, false, nil
                end
            end
        end
    end

    for i = 1, #firstLines do
        local v = firstLines[i]
        local newID = 0
        if message:match(v) then
            local curTime = _G.time()

            for i = 1, #meters do
                local j = meters[i]
                local elapsed = curTime - j.time
                if j.source == source and j.event == event and elapsed < 1 then
                    newID = i
                    return true, true, format('|Hspam:%1$d|h|cFFFFFF00[%2$s]|r|h', newID or 0, message or 'nil')
                end
            end

            tinsert(meters, { source = source, event = event, time = curTime, data = {}, title = message })

            for i = 1, #meters do
                local j = meters[i]
                if j.source == source and j.event == event and j.time == curTime then
                    newID = i
                end
            end

            return true, true, format('|Hspam:%1$d|h|cFFFFFF00[%2$s]|r|h', newID or 0, message or 'nil')
        end
    end
    return false, false, nil
end

local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
function _G.ItemRefTooltip:SetHyperlink(link, ...)
    if link and (strsub(link, 1, 4) == 'spam') then
        local _, id = strsplit(':', link)
        local meterID = tonumber(id)
        _G.ItemRefTooltip:ClearLines()
        _G.ItemRefTooltip:AddLine(meters[meterID].title)
        _G.ItemRefTooltip:AddLine(format(_G.BY_SOURCE .. ': %s', meters[meterID].source))
        for _, v in ipairs(meters[meterID].data) do
            local left, right = v:match('^(.*)  (.*)$')
            if left and right then
                _G.ItemRefTooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
            else
                _G.ItemRefTooltip:AddLine(v, 1, 1, 1)
            end
        end
        _G.ItemRefTooltip:Show()
        return
    end

    SetHyperlink(self, link, ...)
end

local function ParseChatEvent(_, event, message, sender, ...)
    local isRecount, isFirstLine, newMessage = FilterLine(event, sender, message)
    if isRecount then
        if isFirstLine then
            return false, newMessage, sender, ...
        else
            return true
        end
    end
end

function CHAT:DamageMeterFilter()
    if not C.DB.Chat.DamageMeterFilter then
        return
    end
    for _, event in pairs(events) do
        _G.ChatFrame_AddMessageEventFilter(event, ParseChatEvent)
    end
end
