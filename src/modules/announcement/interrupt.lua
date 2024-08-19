local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

-- 打断 → 火球 (老王)
local arrow = GetLocale() == 'zhCN' and ' → ' or ' -> '
local interrupStr = L['Interrupted'] .. arrow .. '%target_spell% ' .. '(%target%)'

local function formatString(msg, srcName, destName, spellId, extraSpellId)
    srcName = gsub(srcName, '%-[^|]+', '')
    msg = gsub(msg, '%%player%%', srcName)
    msg = gsub(msg, '%%target%%', destName)
    msg = gsub(msg, '%%player_spell%%', C_Spell.GetSpellLink(spellId))
    msg = gsub(msg, '%%target_spell%%', C_Spell.GetSpellLink(extraSpellId))

    return msg
end

function A:Interrupt(srcGUID, srcName, destName, spellId, extraSpellId)
    if not C.DB.Announcement.Interrupt then
        return
    end

    if not (spellId and extraSpellId) then
        return
    end

    if srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet') then
        A:SendMessage(
            formatString(interrupStr, srcName, destName, spellId, extraSpellId),
            A:GetChannel()
        )
    end
end
