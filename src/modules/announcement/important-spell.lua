local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

C.AnnounceableSpellsList = {
    -- Paladin
    [1044] = true,   -- Blessing of Freedom
    [204018] = true, -- Blessing of Spellwarding
    [6940] = true,   -- Blessing of Sacrifice
    [1022] = true,   -- Blessing of Protection
    [498] = true,    -- Divine Protection
    [31850] = true,  -- Ardent Defender
    [86659] = true,  -- Guardian of Ancient Kings
    [212641] = true, -- Guardian of Ancient Kings (Glyph)
    [642] = true,    -- Divine Shield
    [31884] = true,  -- Avenging Wrath
    [633] = true,    -- Lay On Hands
    [31821] = true,  -- Aura Mastery
    -- Warrior
    [97462] = true,  -- Rallying Cry
    [23920] = true,  -- Spell Reflection
    -- Demon Hunter
    [196718] = true, -- Darkness
    -- Death Knight
    [51052] = true,  -- Anti-Magic Zone
    [15286] = true,  -- Vampiric Embrace
    -- Priest
    [246287] = true, -- Evangelism
    [265202] = true, -- Holy Word: Salvation
    [200183] = true, -- Apotheosis
    [62618] = true,  -- Power Word: Barrier
    [64843] = true,  -- Divine Hymn
    [64901] = true,  -- Symbol of Hope
    [47536] = true,  -- Rapture
    [109964] = true, -- Spirit Shell
    [33206] = true,  -- Pain Suppression
    [47788] = true,  -- Guardian Spirit
    -- Shaman
    [207399] = true, -- Ancestral Protection Totem
    [108280] = true, -- Healing Tide Totem
    [98008] = true,  -- Spirit Link Totem
    [114052] = true, -- Ascendance
    [16191] = true,  -- Mana Tide Totem
    [108281] = true, -- Ancestral Guidance
    [198838] = true, -- Earthen Wall Totem
    -- Druid
    [740] = true,    -- Tranquility
    [33891] = true,  -- Incarnation: Tree of Life
    [197721] = true, -- Flourish
    [205636] = true, -- Force of Nature
    -- Monk
    [115310] = true, -- Revival
    [325197] = true, -- Invoke Chi-Ji, the Red Crane
    [116849] = true, -- Life Cocoon
    [322118] = true, -- Invoke Yu'lon, the Jade Serpent
    -- Covenants
    [316958] = true, -- Ashen Hallow
}

function A:CheckImportantSpells()
    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            if _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] then
                _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] = nil
            end
        else
            F.Debug('CheckAnnounceableSpells: Invalid Spell ID ' .. spellID)
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['AnnounceableSpellsList']) do
        if value == false and C.AnnounceableSpellsList[spellID] == nil then
            _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID] = nil
        end
    end
end

A.AnnounceableSpellsList = {}
function A:RefreshImportantSpells()
    wipe(A.AnnounceableSpellsList)

    for spellID in pairs(C.AnnounceableSpellsList) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            local modValue = _G.ANDROMEDA_ADB['AnnounceableSpellsList'][spellID]
            if modValue == nil then
                A.AnnounceableSpellsList[spellID] = true
            end
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['AnnounceableSpellsList']) do
        if value then
            A.AnnounceableSpellsList[spellID] = true
        end
    end
end

-- 施放 火球 → (老王)
local arrow = GetLocale() == 'zhCN' and ' → ' or ' -> '
local noTarStr = L['Casted'] .. ' %player_spell% '
local tarStr = L['Casted'] .. ' %player_spell%' .. arrow .. '(%target%)'

local function formatString(msg, srcName, destName, spellId)
    srcName = gsub(srcName, '%-[^|]+', '')
    msg = gsub(msg, '%%player%%', srcName)
    if destName then
        msg = gsub(msg, '%%target%%', destName)
    end
    msg = gsub(msg, '%%player_spell%%', C_Spell.GetSpellLink(spellId))

    return msg
end

function A:ImportantSpells(srcGUID, srcName, destName, spellId)
    if not C.DB.Announcement.ImportantSpells then
        return
    end

    if not (srcName and spellId) then
        return
    end

    if not (srcGUID == UnitGUID('player') or srcGUID == UnitGUID('pet')) then
        return
    end

    -- /dump ANDROMEDA[2].AnnounceableSpellsList
    -- /dump ANDROMEDA.Modules.Announcement.AnnounceableSpellsList
    -- /dump ANDROMEDA_ADB['AnnounceableSpellsList']

    if A.AnnounceableSpellsList[spellId] then
        if destName == nil then -- cast a spell (without target)
            A:SendMessage(
                formatString(noTarStr, srcName, destName, spellId),
                A:GetChannel()
            )
        else -- cast a spell on someone (with target)
            A:SendMessage(
                formatString(tarStr, srcName, destName, spellId),
                A:GetChannel()
            )
        end
    end
end
