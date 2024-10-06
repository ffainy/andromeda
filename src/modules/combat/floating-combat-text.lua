--[[
    Floating combat text
    Credits: RgsCT by Rubgrsch
    https://github.com/Rubgrsch/RgsCT
--]]

local F, C, L = unpack(select(2, ...))
local fct = F:RegisterModule('FloatingCombatText')

local vehicleGUID
local playerGUID = UnitGUID('player')
local MASK_MINE_FRIENDLY_PLAYER = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MASK,
    COMBATLOG_OBJECT_REACTION_MASK,
    COMBATLOG_OBJECT_CONTROL_MASK
)
local FLAG_MINE_FRIENDLY_PLAYER = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MINE,
    COMBATLOG_OBJECT_REACTION_FRIENDLY,
    COMBATLOG_OBJECT_CONTROL_PLAYER
)

local blacklist = {
    [201633] = true, -- Earthen Wall
    [143924] = true, -- Leech
}

local dmgcolor = {
    [1] = 'ffff00',
    [2] = 'ffe57f',
    [4] = 'ff7f00',
    [8] = '4cff4c',
    [16] = '7fffff',
    [32] = '7f7fff',
    [64] = 'ff7fff',
    [9] = 'a5ff26',
    [18] = 'bff2bf',
    [36] = 'bf7f7f',
    [5] = 'ffbf00',
    [10] = 'bff2bf',
    [20] = 'bfbf7f',
    [40] = '66bfa5',
    [80] = 'bfbfff',
    [127] = 'c1c48c',
    [126] = 'b7baa3',
    [3] = 'fff23f',
    [6] = 'ffb23f',
    [12] = 'a5bf26',
    [24] = '66ffa5',
    [48] = '7fbfff',
    [65] = 'ffbf7f',
    [124] = 'a8b2a8',
    [66] = 'ffb2bf',
    [96] = 'bf7fff',
    [72] = 'a5bfa5',
    [68] = 'ff7f7f',
    [28] = '99d670',
    [34] = 'bfb2bf',
    [33] = 'bfbf7f',
    [17] = 'bfff7f',
}

setmetatable(dmgcolor, {
    __index = function()
        return 'ffffff'
    end,
})

local environmentalTypeText = {
    Drowning = ACTION_ENVIRONMENTAL_DAMAGE_DROWNING,
    Falling = ACTION_ENVIRONMENTAL_DAMAGE_FALLING,
    Fatigue = ACTION_ENVIRONMENTAL_DAMAGE_FATIGUE,
    Fire = ACTION_ENVIRONMENTAL_DAMAGE_FIRE,
    Lava = ACTION_ENVIRONMENTAL_DAMAGE_LAVA,
    Slime = ACTION_ENVIRONMENTAL_DAMAGE_SLIME,
}

local dmgFunc
local mergeData = {
    [true] = { [true] = {}, [false] = {} },
    [false] = { [true] = {}, [false] = {} },
}

local function createFctFrame(frameName, spacing, maxLines, fadeDuration, timeVisible, justify, width, height)
    local frame = CreateFrame('ScrollingMessageFrame', frameName, UIParent)
    frame:SetSpacing(spacing)
    frame:SetMaxLines(maxLines)
    frame:SetFadeDuration(fadeDuration)
    frame:SetTimeVisible(timeVisible)
    frame:SetJustifyH(justify)
    frame:SetSize(width, height)
    frame:SetFont(
        C.Assets.Fonts.Heavy,
        C.DB.floatingCombatText.fontSize,
        ANDROMEDA_ADB.FontOutline and 'OUTLINE' or '')
    if ANDROMEDA_ADB.FontOutline then
        frame:SetShadowColor(0, 0, 0, 1)
        frame:SetShadowOffset(1, -1)
    else
        frame:SetShadowColor(0, 0, 0, 1)
        frame:SetShadowOffset(2, -2)
    end

    return frame
end

local function dmgString(isIn, isHealing, spellID, amount, school, isCritical, Hits)
    local frame = isIn and fct.InFrame or fct.OutFrame
    local symbol = isHealing and '+' or (isIn and '-' or '')

    if isIn then
        if Hits and Hits > 1 then
            frame:AddMessage(
                format(
                    isCritical and '|T%s:0:0:0:-5|t |cff%s%s*%s* x%d|r' or '|T%s:0:0:0:-5|t |cff%s%s%s x%d|r',
                    C_Spell.GetSpellTexture(spellID) or '',
                    dmgcolor[school],
                    symbol,
                    F:Numb(amount / Hits),
                    Hits
                )
            )
        else
            frame:AddMessage(
                format(
                    isCritical and '|T%s:0:0:0:-5|t |cff%s%s*%s*|r' or '|T%s:0:0:0:-5|t |cff%s%s%s|r',
                    C_Spell.GetSpellTexture(spellID) or '',
                    dmgcolor[school],
                    symbol,
                    F:Numb(amount)
                )
            )
        end
    else
        if Hits and Hits > 1 then
            frame:AddMessage(
                format(
                    isCritical and '|cff%s%s*%s* x%d|r |T%s:0:0:0:-5|t' or '|cff%s%s%s x%d|r |T%s:0:0:0:-5|t',
                    dmgcolor[school],
                    symbol,
                    F:Numb(amount / Hits),
                    Hits,
                    C_Spell.GetSpellTexture(spellID) or ''
                )
            )
        else
            frame:AddMessage(
                format(
                    isCritical and '|cff%s%s*%s*|r |T%s:0:0:0:-5|t' or '|cff%s%s%s|r |T%s:0:0:0:-5|t',
                    dmgcolor[school],
                    symbol,
                    F:Numb(amount),
                    C_Spell.GetSpellTexture(spellID) or ''
                )
            )
        end
    end
end

local function missString(isIn, spellID, missType, amountMissed)
    local frame = isIn and fct.InFrame or fct.OutFrame

    if isIn then
        if missType == 'ABSORB' then
            frame:AddMessage(
                format(
                    '|T%s:0:0:0:-5|t %s(%s)',
                    C_Spell.GetSpellTexture(spellID) or '',
                    _G[missType],
                    F:Numb(amountMissed)
                )
            )
        else
            frame:AddMessage(format('|T%s:0:0:0:-5|t %s', C_Spell.GetSpellTexture(spellID) or '', _G[missType]))
        end
    else
        if missType == 'ABSORB' then
            frame:AddMessage(
                format(
                    '%s(%s) |T%s:0:0:0:-5|t',
                    _G[missType],
                    F:Numb(amountMissed),
                    C_Spell.GetSpellTexture(spellID) or ''
                )
            )
        else
            frame:AddMessage(format('%s |T%s:0:0:0:-5|t', _G[missType], C_Spell.GetSpellTexture(spellID) or ''))
        end
    end
end

local function dmgMerge(isIn, isHealing, spellID, amount, school, critical)
    local tbl = mergeData[isIn][isHealing]

    if not tbl[spellID] then
        tbl[spellID] = { 0, school, 0, 0 }
        tbl[spellID].func = function()
            local tbl = tbl
            dmgString(isIn, isHealing, spellID, tbl[1], tbl[2], tbl[3] == tbl[4], tbl[4])
            tbl[1], tbl[3], tbl[4] = 0, 0, 0
        end
    end

    tbl = tbl[spellID]
    tbl[1], tbl[3], tbl[4] = tbl[1] + amount, tbl[3] + (critical and 1 or 0), tbl[4] + 1

    if tbl[4] == 1 then
        F:Delay(0.05, tbl.func)
    end
end

local function setMerge()
    dmgFunc = C.DB.floatingCombatText.merge and dmgMerge or dmgString
end

local function vehicleChanged(_, _, unit, _, _, _, guid)
    if unit == 'player' then
        vehicleGUID = guid
    end
end

local function onEvent()
    local db = C.DB.floatingCombatText
    local _, Event, _, sourceGUID, _, sourceFlags, _, destGUID, _, _, _, arg1, arg2, arg3, arg4, arg5, arg6, arg7, _, _, arg10 =
        CombatLogGetCurrentEventInfo()
    local fromMe = sourceGUID == playerGUID
    local fromPet = bit.band(sourceFlags, MASK_MINE_FRIENDLY_PLAYER) == FLAG_MINE_FRIENDLY_PLAYER
        and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0
    local fromGuardian = bit.band(sourceFlags, MASK_MINE_FRIENDLY_PLAYER) == FLAG_MINE_FRIENDLY_PLAYER
        and bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0
    local fromMine = fromMe or (db.pet and (fromPet or fromGuardian)) or sourceGUID == vehicleGUID

    local toMe = destGUID == playerGUID or destGUID == vehicleGUID

    if Event == 'SWING_DAMAGE' then
        if fromMine then
            dmgFunc(false, false, 5586, arg1, arg3, arg7)
        end
        if toMe then
            dmgFunc(true, false, 5586, arg1, arg3, arg7)
        end
    elseif
        (Event == 'SPELL_DAMAGE' or Event == 'RANGE_DAMAGE')
        or (db.periodic and Event == 'SPELL_PERIODIC_DAMAGE')
    then
        if blacklist[arg1] then
            return
        end
        if toMe then
            dmgFunc(true, false, arg1, arg4, arg6, arg10)
        elseif fromMine then
            dmgFunc(false, false, arg1, arg4, arg6, arg10)
        end
    elseif Event == 'SWING_MISSED' then
        if fromMe then
            missString(false, 5586, arg1, arg3)
        end
        if toMe then
            missString(true, 5586, arg1, arg3)
        end
    elseif Event == 'SPELL_MISSED' or Event == 'RANGE_MISSED' then
        if blacklist[arg1] then
            return
        end
        if toMe then
            missString(true, arg1, arg4, arg6)
        elseif fromMe or (db.pet and fromPet) or sourceGUID == vehicleGUID then
            missString(false, arg1, arg4, arg6)
        end
    elseif Event == 'SPELL_HEAL' or (db.periodic and Event == 'SPELL_PERIODIC_HEAL') then
        -- block full-overhealing
        if blacklist[arg1] or arg4 == arg5 then
            return
        end
        -- Show healing in outFrame for healers, inFrame for tank/dps
        if fromMine and C.MyRole == 'Healer' then
            dmgFunc(false, true, arg1, arg4, arg3, arg7)
        elseif toMe then
            dmgFunc(true, true, arg1, arg4, arg3, arg7)
        elseif fromMine then
            dmgFunc(false, true, arg1, arg4, arg3, arg7)
        end
    elseif Event == 'ENVIRONMENTAL_DAMAGE' then
        if toMe then
            fct.InFrame:AddMessage(
                format('|cff%s%s -%s|r', dmgcolor[arg4], environmentalTypeText[arg1], F:Numb(arg2))
            )
        end
    end
end

function fct.UpdateConfig()
    if C.DB.floatingCombatText.enable then
        F:RegisterEvent('UNIT_ENTERED_VEHICLE', vehicleChanged)
        F:RegisterEvent('UNIT_EXITING_VEHICLE', vehicleChanged)
        F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', onEvent)
    else
        F:UnregisterEvent('UNIT_ENTERED_VEHICLE', vehicleChanged)
        F:UnregisterEvent('UNIT_EXITING_VEHICLE', vehicleChanged)
        F:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', onEvent)
    end
end

function fct:OnLogin()
    if not C.DB.floatingCombatText.enable then
        return
    end

    fct.InFrame = createFctFrame('CombatText_In', 3, 20, 0.2, 3, 'LEFT', 120, 160)
    fct.OutFrame = createFctFrame('CombatText_Out', 3, 20, 0.2, 3, 'RIGHT', 120, 160)

    if C.DB.floatingCombatText.incoming then
        F.Mover(
            fct.InFrame,
            L['FCTInFrame'],
            'FCTInFrame',
            { 'RIGHT', UIParent, 'CENTER', -500, 0 },
            fct.InFrame:GetWidth(),
            fct.InFrame:GetHeight()
        )
    end

    if C.DB.floatingCombatText.outgoing then
        F.Mover(
            fct.OutFrame,
            L['FCTOutFrame'],
            'FCTOutFrame',
            { 'LEFT', UIParent, 'CENTER', 300, 140 },
            fct.OutFrame:GetWidth(),
            fct.OutFrame:GetHeight()
        )
    end

    setMerge()


    fct.UpdateConfig()
end
