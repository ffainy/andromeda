local F, C = unpack(select(2, ...))
local emg = F:RegisterModule('Emergency')


local lowHealth = false
local lowMana = false

local powerTypes = {
    ['MANA'] = 0,
    ['RAGE'] = 1,
    ['FOCUS'] = 2,
    ['ENERGY'] = 3,
    ['RUNIC_POWER'] = 6,
    ['LUNAR_POWER'] = 8,
    ['MAELSTROM'] = 11,
    ['FURY'] = 17,
    ['PAIN'] = 18,
}

local allowedPowerTypes = {
    ['MANA'] = true,
    ['RAGE'] = false,
    ['FOCUS'] = false,
    ['ENERGY'] = false,
    ['RUNIC_POWER'] = false,
    ['LUNAR_POWER'] = false,
    ['MAELSTROM'] = false,
    ['FURY'] = false,
    ['PAIN'] = false,
}

local function healthAlert(_, unit)
    if unit ~= 'player' then
        return
    end

    local threshold = C.DB.emergency.LowHealthThreshold
    local sound = C.Assets.Sounds.SekiroLowHealth

    if (UnitHealth('player') / UnitHealthMax('player')) <= threshold then
        if not lowHealth then
            PlaySoundFile(sound, 'Master')
            lowHealth = true
        end
    else
        lowHealth = false
    end
end

local function manaAlert(_, unit, powerType)
    if unit ~= 'player' or not allowedPowerTypes[powerType] then
        return
    end

    local threshold = C.DB.emergency.LowManaThreshold
    local sound = C.Assets.Sounds.LowMana
    local cur = UnitPower('player', powerTypes[powerType])
    local max = UnitPowerMax('player', powerTypes[powerType])

    if (cur / max) <= threshold and not UnitIsDeadOrGhost('player') then
        if not lowMana then
            PlaySoundFile(sound, 'Master')
            lowMana = true
        end
    else
        lowMana = false
    end
end

function emg:UpdateConfig()
    if C.DB.emergency.enable and C.DB.emergency.LowHealth then
        F:RegisterEvent('UNIT_HEALTH', healthAlert)
    else
        F:UnregisterEvent('UNIT_HEALTH', healthAlert)
    end

    if C.DB.emergency.enable and C.DB.emergency.LowMana then
        F:RegisterEvent('UNIT_POWER_UPDATE', manaAlert)
    else
        F:UnregisterEvent('UNIT_POWER_UPDATE', manaAlert)
    end
end

function emg:OnLogin()
    if not C.DB.emergency.enable then
        return
    end

    emg:UpdateConfig()
end
