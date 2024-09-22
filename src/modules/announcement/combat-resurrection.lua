local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

local spellsList = {
    [20484] = true,  -- 復生
    [20707] = true,  -- 靈魂石
    [61999] = true,  -- 盟友復生
    [265116] = true, -- 不穩定的時間轉移器（工程學）
    [345130] = true, -- 拋棄式光學相位復生器（工程學）
    [391054] = true, -- 代禱
}

-- 施放 战复 → (老王)
local arrow = GetLocale() == 'zhCN' and ' → ' or ' -> '
local crStr = L['Casted'] .. ' %player_spell%' .. arrow .. '(%target%)'

local function formatString(msg, srcName, destName, spellId)
    destName = destName:gsub('%-[^|]+', '')
    srcName = srcName:gsub('%-[^|]+', '')
    msg = gsub(msg, '%%player%%', srcName)
    msg = gsub(msg, '%%target%%', destName)
    msg = gsub(msg, '%%player_spell%%', C_Spell.GetSpellLink(spellId))
    return msg
end

function A:CombatResurrection(srcGUID, srcName, destName, spellId)
    if not C.DB.Announcement.CombatResurrection then
        return
    end

    if not srcName or not destName then
        return
    end

    if not (srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet')) then
        return
    end

    if spellsList[spellId] then
        A:SendMessage(
            formatString(crStr, srcName, destName, spellId),
            A:GetChannel()
        )
    end
end
