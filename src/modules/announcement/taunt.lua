local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

local tauntSpells = {
    [355] = true,    -- 嘲諷（戰士）
    [1161] = true,   -- 挑戰怒吼（戰士）
    [56222] = true,  -- 黑暗赦令（死亡騎士）
    [6795] = true,   -- 低吼（德魯伊 熊形態）
    [62124] = true,  -- 清算之手（聖騎士）
    [204079] = true, -- 屹立不搖（聖騎士）
    [116189] = true, -- 嘲心嘯（武僧）
    [118635] = true, -- 嘲心嘯（武僧圖騰 玄牛雕像 算作玩家群嘲）
    [196727] = true, -- 嘲心嘯（武僧守護者 玄牛怒兆）
    [281854] = true, -- 折磨（惡魔獵人 災虐）
    [185245] = true, -- 折磨（惡魔獵人 復仇）
    [2649] = true,   -- 低吼（獵人寵物）
    [17735] = true,  -- 受難（術士寵物虛無行者）
}

local tauntAllSpells = {
    [1161] = true,   -- 挑戰怒吼（戰士）
    [118635] = true, -- 嘲心嘯（武僧圖騰 玄牛雕像 算作玩家群嘲）
    [204079] = true, -- 屹立不搖（聖騎士）
}

-- 反射 火球 → (老王)
local arrow = GetLocale() == 'zhCN' and ' → ' or ' -> '
local refStr = L['Reflected'] .. ' %target_spell%' .. arrow .. '(%player%)'

local function formatString(msg, srcName, destName, spellId)
    srcName = gsub(srcName, '%-[^|]+', '')
    msg = gsub(msg, '%%player%%', srcName)
    msg = gsub(msg, '%%target%%', destName)
    msg = gsub(msg, '%%target_spell%%', C_Spell.GetSpellLink(spellId))

    return msg
end

function A:Reflect(srcGUID, srcName, destName)
    if not C.DB.Announcement.Reflect then
        return
    end

    if not srcGUID or srcName == destName then
        return
    end

    local spellId, _, _, missType = select(12, CombatLogGetCurrentEventInfo())
    if missType == 'REFLECT' and destName == C.MY_NAME then
        A:SendMessage(
            formatString(refStr, srcName, destName, spellId),
            A:GetChannel()
        )
    end
end

local tauntStr = L['Taunted'] .. arrow .. '%target%'
local tauntAllStr = L['I taunted all enemies!']
local tauntFailedStr = L['Taunt failed'] .. arrow .. '%target%'

local tauntAllCache = {}

local function formatStr(msg, srcName, destName, spellId)
    destName = destName:gsub('%-[^|]+', '')
    srcName = srcName:gsub('%-[^|]+', '')
    msg = gsub(msg, '%%player%%', srcName)
    msg = gsub(msg, '%%target%%', destName)
    msg = gsub(msg, '%%spell%%', C_Spell.GetSpellLink(spellId))
    return msg
end

function A:Taunt(timestamp, event, srcGUID, srcName, destGUID, destName, spellId)
    if not C.DB.Announcement.Taunt then
        return
    end

    if not spellId or not srcGUID or not destGUID or not tauntSpells[spellId] then
        return
    end

    if not (srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet')) then
        return
    end

    if event == 'SPELL_AURA_APPLIED' then
        if tauntAllSpells[spellId] then
            if not tauntAllCache[srcGUID] or timestamp - tauntAllCache[srcGUID] > 1 then
                tauntAllCache[srcGUID] = timestamp
                A:SendMessage(
                    formatStr(tauntAllStr, srcName, destName, spellId),
                    A:GetChannel()
                )
            end
        else
            A:SendMessage(
                formatStr(tauntStr, srcName, destName, spellId),
                A:GetChannel()
            )
        end
    elseif event == 'SPELL_MISSED' then
        A:SendMessage(
            formatString(tauntFailedStr, srcName, destName, spellId),
            A:GetChannel()
        )
    end
end
