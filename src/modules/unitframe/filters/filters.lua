local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')
local NAMEPLATE = F:GetModule('Nameplate')

function UNITFRAME:InitCornerSpellsList()
    if not _G.ANDROMEDA_ADB['CornerSpellsList'][C.MY_CLASS] then
        _G.ANDROMEDA_ADB['CornerSpellsList'][C.MY_CLASS] = {}
    end
    local data = C.CornerSpellsList[C.MY_CLASS]
    if not data then
        return
    end

    for spellID in pairs(data) do
        local name = C_Spell.GetSpellName(spellID)
        if not name then
            F.Debug('CheckCornerSpells: Invalid Spell ID ' .. spellID)
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['CornerSpellsList'][C.MY_CLASS]) do
        if not next(value) and C.CornerSpellsList[C.MY_CLASS][spellID] == nil then
            _G.ANDROMEDA_ADB['CornerSpellsList'][C.MY_CLASS][spellID] = nil
        end
    end
end

function NAMEPLATE:InitMajorSpellsList()
    for spellID in pairs(C.MajorSpellsList) do
        local name = C_Spell.GetSpellName(spellID)
        if name then
            if _G.ANDROMEDA_ADB['MajorSpellsList'][spellID] then
                _G.ANDROMEDA_ADB['MajorSpellsList'][spellID] = nil
            end
        else
            F.Debug('CheckMajorSpells: Invalid Spell ID ' .. spellID)
        end
    end

    for spellID, value in pairs(_G.ANDROMEDA_ADB['MajorSpellsList']) do
        if value == false and C.MajorSpellsList[spellID] == nil then
            _G.ANDROMEDA_ADB['MajorSpellsList'][spellID] = nil
        end
    end
end

function UNITFRAME:InitFilters()
    UNITFRAME:InitCornerSpellsList()
    NAMEPLATE:InitMajorSpellsList()
end
