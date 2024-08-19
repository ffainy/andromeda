-- Credit: aduth
-- https://github.com/aduth/Doom_CooldownPulse

local F, C, L = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')

local cdp = CreateFrame('Frame', C.ADDON_TITLE .. 'CooldownPulseFrame', UIParent, 'BackdropTemplate')

local cooldowns, animating, watching = {}, {}, {}
local itemSpells, ignoredSpells = {}, {}

local configs = {
    fadeInTime = 0.3,
    fadeOutTime = 0.3,
    maxAlpha = 1,
    animScale = 2,
    iconSize = 32,
    holdTime = 0.3,
    threshold = 3,
    elapsed = 0,
    runtimer = 0,
}


local function tcount(tab)
    local n = 0
    for _ in pairs(tab) do
        n = n + 1
    end

    return n
end

local function memoize(f)
    local cache = nil
    local memoized = {}

    local function get()
        if cache == nil then
            cache = f()
        end

        return cache
    end

    memoized.resetCache = function()
        cache = nil
    end

    setmetatable(memoized, { __call = get })

    return memoized
end

local function getPetActionIndexByName(name)
    for i = 1, NUM_PET_ACTION_SLOTS, 1 do
        if (GetPetActionInfo(i) == name) then
            return i
        end
    end
    return nil
end

local function trackItemSpell(itemID)
    local _, spellID = C_Item.GetItemSpell(itemID)
    if (spellID) then
        itemSpells[spellID] = itemID
        return true
    else
        return false
    end
end

local function isAnimatingCooldownByName(name)
    for i, details in pairs(animating) do
        if details[3] == name then
            return true
        end
    end

    return false
end

function cdp:SetupButton()
    cdp:SetSize(configs.iconSize, configs.iconSize)

    cdp.icon = cdp:CreateTexture(nil, 'ARTWORK')
    cdp.icon:SetAllPoints()
    cdp.bg = F.SetBD(cdp)
    cdp.bg:Hide()

    local mover = F.Mover(
        cdp, L['CooldownPulse'], 'CooldownPulse',
        { 'CENTER', UIParent }, configs.iconSize, configs.iconSize
    )
    cdp:ClearAllPoints()
    cdp:SetPoint('CENTER', mover)
end

function cdp:HookFuncs()
    hooksecurefunc('UseAction', function(slot)
        local actionType, itemID = GetActionInfo(slot)
        if actionType == 'item' and itemID and not trackItemSpell(itemID) then
            local texture = GetActionTexture(slot)
            watching[itemID] = { GetTime(), 'item', texture }
        end
    end)

    hooksecurefunc('UseInventoryItem', function(slot)
        local itemID = GetInventoryItemID('player', slot)
        if itemID and not trackItemSpell(itemID) then
            local texture = GetInventoryItemTexture('player', slot)
            watching[itemID] = { GetTime(), 'item', texture }
        end
    end)

    hooksecurefunc(C_Container, 'UseContainerItem', function(bag, slot)
        local itemID = C_Container.GetContainerItemID(bag, slot)
        if itemID and not trackItemSpell(itemID) then
            local texture = select(10, C_Item.GetItemInfo(itemID))
            watching[itemID] = { GetTime(), 'item', texture }
        end
    end)
end

function COMBAT:HandleCdpEvents()
    if C.DB.Combat.CooldownPulse then
        F:RegisterEvent('ADDON_LOADED', cdp.ADDON_LOADED)
        F:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', cdp.UNIT_SPELLCAST_SUCCEEDED)
        F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', cdp.COMBAT_LOG_EVENT_UNFILTERED)
        F:RegisterEvent('SPELL_UPDATE_COOLDOWN', cdp.SPELL_UPDATE_COOLDOWN)
        F:RegisterEvent('PLAYER_ENTERING_WORLD', cdp.PLAYER_ENTERING_WORLD)
        F:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', cdp.PLAYER_SPECIALIZATION_CHANGED)
    else
        F:UnregisterEvent('ADDON_LOADED', cdp.ADDON_LOADED)
        F:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', cdp.UNIT_SPELLCAST_SUCCEEDED)
        F:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', cdp.COMBAT_LOG_EVENT_UNFILTERED)
        F:UnregisterEvent('SPELL_UPDATE_COOLDOWN', cdp.SPELL_UPDATE_COOLDOWN)
        F:UnregisterEvent('PLAYER_ENTERING_WORLD', cdp.PLAYER_ENTERING_WORLD)
        F:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', cdp.PLAYER_SPECIALIZATION_CHANGED)
    end
end

local function onUpdate(_, update)
    configs.elapsed = configs.elapsed + update
    if (configs.elapsed > 0.05) then
        for id, v in pairs(watching) do
            if (GetTime() >= v[1] + 0.5) then
                local getCooldownDetails
                if (v[2] == 'spell') then
                    getCooldownDetails = memoize(function()
                        local cooldown = C_Spell.GetSpellCooldown(v[3])
                        return {
                            name = C_Spell.GetSpellName(v[3]),
                            texture = C_Spell.GetSpellTexture(v[3]),
                            start = cooldown.startTime,
                            duration = cooldown.duration,
                            enabled = cooldown.isEnabled,
                        }
                    end)
                elseif (v[2] == 'item') then
                    getCooldownDetails = memoize(function()
                        local start, duration, enabled = C_Container.GetItemCooldown(id)
                        return {
                            name = C_Item.GetItemInfo(id),
                            texture = v[3],
                            start = start,
                            duration = duration,
                            enabled = enabled,
                        }
                    end)
                elseif (v[2] == 'pet') then
                    getCooldownDetails = memoize(function()
                        local name, texture = GetPetActionInfo(v[3])
                        local start, duration, enabled = GetPetActionCooldown(v[3])
                        return {
                            name = name,
                            texture = texture,
                            isPet = true,
                            start = start,
                            duration = duration,
                            enabled = enabled,
                        }
                    end)
                end

                local cooldown = getCooldownDetails()
                if (ignoredSpells[cooldown.name] ~= nil or ignoredSpells[tostring(id)] ~= nil) then
                    watching[id] = nil
                else
                    if (cooldown.enabled ~= 0) then
                        if (cooldown.duration and cooldown.duration > configs.threshold and cooldown.texture) then
                            cooldowns[id] = getCooldownDetails
                        end
                    end
                    if (not (cooldown.enabled == 0 and v[2] == 'spell')) then
                        watching[id] = nil
                    end
                end
            end
        end
        for i, getCooldownDetails in pairs(cooldowns) do
            local cooldown = getCooldownDetails()
            if cooldown.start then
                local remaining = cooldown.duration - (GetTime() - cooldown.start)
                if (remaining <= 0) then
                    if not isAnimatingCooldownByName(cooldown.name) then
                        tinsert(animating, { cooldown.texture, cooldown.isPet, cooldown.name })
                    end
                    cooldowns[i] = nil
                end
            else
                cooldowns[i] = nil
            end
        end

        configs.elapsed = 0
        if (#animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0) then
            cdp:SetScript('OnUpdate', nil)
            return
        end
    end

    if (#animating > 0) then
        configs.runtimer = configs.runtimer + update
        if (configs.runtimer > (configs.fadeInTime + configs.holdTime + configs.fadeOutTime)) then
            tremove(animating, 1)
            configs.runtimer = 0
            cdp.icon:SetTexture(nil)
            cdp.bg:Hide()
        else
            if not cdp.icon:GetTexture() then
                cdp.icon:SetTexture(animating[1][1])
                cdp.icon:SetTexCoord(unpack(C.TEX_COORD))
            end
            local alpha = configs.maxAlpha
            if (configs.runtimer < configs.fadeInTime) then
                alpha = configs.maxAlpha * (configs.runtimer / configs.fadeInTime)
            elseif (configs.runtimer >= configs.fadeInTime + configs.holdTime) then
                alpha = configs.maxAlpha -
                (configs.maxAlpha * ((configs.runtimer - configs.holdTime - configs.fadeInTime) / configs.fadeOutTime))
            end
            cdp:SetAlpha(alpha)
            local scale = configs.iconSize +
            (configs.iconSize * ((configs.animScale - 1) * (configs.runtimer / (configs.fadeInTime + configs.holdTime + configs.fadeOutTime))))
            cdp:SetWidth(scale)
            cdp:SetHeight(scale)
            cdp.bg:Show()
        end
    end
end

function cdp:ADDON_LOADED()
    for _, v in pairs(ignoredSpells) do
        ignoredSpells[v] = true
    end

    cdp:UnregisterEvent('ADDON_LOADED')
end

function cdp:SPELL_UPDATE_COOLDOWN()
    for _, getCooldownDetails in pairs(cooldowns) do
        getCooldownDetails.resetCache()
    end
end

function cdp:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
    if (unit == 'player') then
        local itemID = itemSpells[spellID]
        if (itemID) then
            local texture = select(10, C_Item.GetItemInfo(itemID))
            watching[itemID] = { GetTime(), 'item', texture }
            itemSpells[spellID] = nil
        else
            watching[spellID] = { GetTime(), 'spell', spellID }
        end

        if (not cdp:IsMouseEnabled()) then
            cdp:SetScript('OnUpdate', onUpdate)
        end
    end
end

function cdp:COMBAT_LOG_EVENT_UNFILTERED()
    local _, event, _, _, _, sourceFlags, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
    if (event == 'SPELL_CAST_SUCCESS') then
        if
            (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET
                and bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
        then
            local name = C_Spell.GetSpellName(spellID)
            local index = getPetActionIndexByName(name)
            if (index and not select(6, GetPetActionInfo(index))) then
                watching[spellID] = { GetTime(), 'pet', index }
            elseif (not index and spellID) then
                watching[spellID] = { GetTime(), 'spell', spellID }
            else
                return
            end
            if (not cdp:IsMouseEnabled()) then
                cdp:SetScript('OnUpdate', onUpdate)
            end
        end
    end
end

function cdp:PLAYER_ENTERING_WORLD()
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == 'arena' then
        cdp:SetScript('OnUpdate', nil)
        wipe(cooldowns)
        wipe(watching)
    end
end

function cdp:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit == 'player' then
        wipe(cooldowns)
        wipe(watching)
    end
end

function COMBAT:CooldownPulse()
    cdp:SetupButton()
    cdp:HookFuncs()
    COMBAT:HandleCdpEvents()

    F:RegisterSlashCommand('/cdpulse', function()
        tinsert(animating, { C_Spell.GetSpellTexture(87214) })
        cdp:SetScript('OnUpdate', onUpdate)
    end)
end
