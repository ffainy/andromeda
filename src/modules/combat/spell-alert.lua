local F, C = unpack(select(2, ...))
local sa = F:RegisterModule('SpellAlert')


local function spellAlert()
    local _, eventType, _, srcGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()

    if not (srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet')) then
        return
    end

    local db = C.DB.spellAlert
    if eventType == 'SPELL_INTERRUPT' and db.interrupt then
        if srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet') then
            PlaySoundFile(C.Assets.Sounds.Interrupt, 'Master')
        end
    elseif eventType == 'SPELL_DISPEL' and db.dispel then
        if srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet') then
            PlaySoundFile(C.Assets.Sounds.Dispel, 'Master')
        end
    elseif eventType == 'SPELL_STOLEN' and db.steal then
        if srcGUID == UnitGUID('player') then
            PlaySoundFile(C.Assets.Sounds.Dispel, 'Master')
        end
    elseif eventType == 'SPELL_MISSED' and db.miss then
        local missType, _, _ = select(15, CombatLogGetCurrentEventInfo())
        if missType == 'REFLECT' and destGUID == UnitGUID('player') then
            PlaySoundFile(C.Assets.Sounds.Missed, 'Master')
        end
    end
end

function sa:UpdateConfig()
    if C.DB.spellAlert.enable then
        F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', spellAlert)
    else
        F:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', spellAlert)
    end
end

function sa:OnLogin()
    sa:UpdateConfig()
end
