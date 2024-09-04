local F, C = unpack(select(2, ...))
local A = F:GetModule('Announcement')

local cache = {}
local sameMsgInterval = 1

function A:AddCache(text, channel)
    cache[text .. '_@@@_' .. channel] = time()
end

function A:CheckBeforeSend(text, channel)
    local key = text .. '_@@@_' .. channel

    if cache[key] and time() < cache[key] + sameMsgInterval then
        return false
    end

    cache[key] = time()
    return true
end

function A:SendMessage(text, channel, raidWarning, whisperTarget)
    -- Skip if the channel is NONE
    if channel == 'NONE' then
        return
    end

    -- Change channel if it is protected by Blizzard
    if channel == 'YELL' or channel == 'SAY' then
        if not IsInInstance() then
            channel = 'SELF'
        end
    end

    if channel == 'SELF' then
        -- ChatFrame1:AddMessage(text)
        F:Printf(text)
        return
    end

    if channel == 'EMOTE' then
        text = ': ' .. text
    end

    if channel == 'WHISPER' then
        if whisperTarget then
            SendChatMessage(text, channel, nil, whisperTarget)
        end
        return
    end

    if channel == 'RAID' and raidWarning and IsInRaid(LE_PARTY_CATEGORY_HOME) then
        if UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') or IsEveryoneAssistant() then
            channel = 'RAID_WARNING'
        end
    end

    if A:CheckBeforeSend(text, channel) then
        SendChatMessage(text, channel)
    end
end

function A:GetChannel(forceInGroup, warning)
    if forceInGroup then
        C.DB.Announcement.Channel = 1
    end

    if C.DB.Announcement.Channel == 1 then
        if IsPartyLFG() or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
            return 'INSTANCE_CHAT'
        elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
            if warning and (UnitIsGroupLeader('player')
                    or UnitIsGroupAssistant('player')
                    or IsEveryoneAssistant())
            then
                return 'RAID_WARNING'
            else
                return 'RAID'
            end
        elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
            return 'PARTY'
        else
            return 'NONE'
        end
    elseif C.DB.Announcement.Channel == 2 then
        return 'YELL'
    elseif C.DB.Announcement.Channel == 3 then
        return 'EMOTE'
    elseif C.DB.Announcement.Channel == 4 then
        return 'SAY'
    end
end

function A:COMBAT_LOG_EVENT_UNFILTERED()
    if not IsInInstance() or not IsInGroup() then
        return
    end

    local timestamp, event, _, srcGUID, srcName, _, _, destGUID, destName, _, _, spellId, _, _, extraSpellId =
        CombatLogGetCurrentEventInfo()

    if event == 'SPELL_CAST_SUCCESS' then
        A:ImportantSpells(srcGUID, srcName, destName, spellId)
        A:CombatResurrection(srcGUID, srcName, destName, spellId)
    elseif event == 'SPELL_INTERRUPT' then
        A:Interrupt(srcGUID, srcName, destName, spellId, extraSpellId)
    elseif event == "SPELL_DISPEL" then
        A:Dispel(srcGUID, srcName, destName, spellId, extraSpellId)
    elseif event == "SPELL_STOLEN" then
        A:Stolen(srcGUID, srcName, destName, spellId, extraSpellId)
    elseif event == 'SPELL_MISSED' then
        A:Reflect(srcGUID, srcName, destName)
        A:Taunt(timestamp, event, srcGUID, srcName, destGUID, destName, spellId)
    elseif event == 'SPELL_AURA_APPLIED' then
        A:Taunt(timestamp, event, srcGUID, srcName, destGUID, destName, spellId)
    end
end

function A:CHAT_MSG_SYSTEM(text)
    A:ResetInstance(text)
end











function A:UpdateResetInstance()
    if C.DB.Announcement.ResetInstance then
        F:RegisterEvent('CHAT_MSG_SYSTEM', A.CHAT_MSG_SYSTEM)
    else
        F:UnregisterEvent('CHAT_MSG_SYSTEM', A.CHAT_MSG_SYSTEM)
    end
end

function A:OnLogin()
    if not C.DB.Announcement.Enable then
        return
    end

    A:CheckImportantSpells()
    A:RefreshImportantSpells()




    F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', A.COMBAT_LOG_EVENT_UNFILTERED)

    A:UpdateResetInstance()




    A:QuestProgress()
end
