local F, C = unpack(select(2, ...))
local ANNOUNCEMENT = F:GetModule('Announcement')

local arrowStr = GetLocale() == 'zhCN' and '→' or '->'

local function GetChannel(warning)
    if C.DB.Announcement.Channel == 1 then
        if IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) then
            return 'INSTANCE_CHAT'
        elseif IsInRaid(_G.LE_PARTY_CATEGORY_HOME) then
            if warning and (UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') or IsEveryoneAssistant()) then
                return 'RAID_WARNING'
            else
                return 'RAID'
            end
        elseif IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
            return 'PARTY'
        end
    elseif C.DB.Announcement.Channel == 2 then
        return 'YELL'
    elseif C.DB.Announcement.Channel == 3 then
        return 'EMOTE'
    elseif C.DB.Announcement.Channel == 4 then
        return 'SAY'
    end
end

ANNOUNCEMENT.AnnounceableSpellsList = {}
function ANNOUNCEMENT:RefreshSpells()
    wipe(ANNOUNCEMENT.AnnounceableSpellsList)

    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            local modValue = _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID]
            if modValue == nil then
                ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['AnnounceableSpellsList']) do
        if value then
            ANNOUNCEMENT.AnnounceableSpellsList[spellID] = true
        end
    end
end

function ANNOUNCEMENT:OnEvent()
    if not (IsInInstance() and IsInGroup() and GetNumGroupMembers() > 1) then
        return true
    end

    local _, eventType, _, srcGUID, srcName, srcFlags, _, _, destName, _, _, spellID, _, _, extraSpellID =
        CombatLogGetCurrentEventInfo()

    if not srcGUID or srcName == destName then
        return
    end

    if destName then
        destName = destName:gsub('%-[^|]+', '')
    end

    if eventType == 'SPELL_MISSED' and C.DB.Announcement.Reflect then
        local id, _, _, missType = select(12, CombatLogGetCurrentEventInfo())
        if missType == 'REFLECT' and destName == C.MY_NAME then
            SendChatMessage(
                format(_G.COMBAT_TEXT_REFLECT .. ' %s %s', arrowStr, GetSpellLink(id)),
                GetChannel()
            )
        end
    end

    if srcName ~= C.MY_NAME and not C:IsMyPet(srcFlags) then
        return
    end

    if eventType == 'SPELL_CAST_SUCCESS' then
        if ANNOUNCEMENT.AnnounceableSpellsList[spellID] and C.DB.Announcement.Spells then
            if destName == nil then
                SendChatMessage(
                    format(_G.ACTION_SPELL_CAST_SUCCESS .. ' %s', GetSpellLink(spellID)),
                    GetChannel()
                )
            else
                SendChatMessage(
                    format(
                        _G.ACTION_SPELL_CAST_SUCCESS .. ' %s %s %s',
                        GetSpellLink(spellID),
                        arrowStr,
                        destName
                    ),
                    GetChannel()
                )
            end
        end
    elseif eventType == 'SPELL_INTERRUPT' and C.DB.Announcement.Interrupt then
        SendChatMessage(
            format(_G.ACTION_SPELL_INTERRUPT .. ' %s %s', arrowStr, GetSpellLink(extraSpellID)),
            GetChannel()
        )
    elseif eventType == 'SPELL_DISPEL' and C.DB.Announcement.Dispel then
        SendChatMessage(
            format(_G.ACTION_SPELL_DISPEL .. ' %s %s', arrowStr, GetSpellLink(extraSpellID)),
            GetChannel()
        )
    elseif eventType == 'SPELL_STOLEN' and C.DB.Announcement.Stolen then
        SendChatMessage(
            format(_G.ACTION_SPELL_STOLEN .. ' %s %s', arrowStr, GetSpellLink(extraSpellID)),
            GetChannel()
        )
    end
end

function ANNOUNCEMENT:AnnounceSpells()
    F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', ANNOUNCEMENT.OnEvent)
end

function ANNOUNCEMENT:CheckAnnounceableSpells()
    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            if _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] then
                _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] = nil
            end
        else
            F:Debug('CheckAnnounceableSpells: Invalid Spell ID ' .. spellID)
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['AnnounceableSpellsList']) do
        if value == false and C.AnnounceableSpellsList[spellID] == nil then
            _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] = nil
        end
    end
end

function ANNOUNCEMENT:OnLogin()
    if not C.DB.Announcement.Enable then
        return
    end

    ANNOUNCEMENT:CheckAnnounceableSpells()
    ANNOUNCEMENT:RefreshSpells()

    ANNOUNCEMENT:AnnounceSpells()
    ANNOUNCEMENT:AnnounceReset()
    ANNOUNCEMENT:QuestProgress()
end
