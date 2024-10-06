local F, C = unpack(select(2, ...))
local kb = F:RegisterModule('KillingBlow')

local playerName, playerGUID = UnitName('player'), UnitGUID('player')
local lastKill, killCount, streakCount = nil, 0, 0
local deathsTable, killsTable = {}, {}
local playedIndex = 0
local debugMode = true

local FILTER_MY_PETS = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MINE,
    COMBATLOG_OBJECT_REACTION_FRIENDLY,
    COMBATLOG_OBJECT_CONTROL_PLAYER,
    COMBATLOG_OBJECT_TYPE_OBJECT,
    COMBATLOG_OBJECT_TYPE_GUARDIAN,
    COMBATLOG_OBJECT_TYPE_PET
)

local FILTER_ENEMY_PLAYERS = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MASK,
    COMBATLOG_OBJECT_REACTION_MASK,
    COMBATLOG_OBJECT_CONTROL_PLAYER,
    COMBATLOG_OBJECT_TYPE_PLAYER
)

local FILTER_ENEMY_NPC = bit.bor(
    COMBATLOG_OBJECT_AFFILIATION_MASK,
    COMBATLOG_OBJECT_REACTION_MASK,
    COMBATLOG_OBJECT_CONTROL_PLAYER,
    COMBATLOG_OBJECT_TYPE_PLAYER,
    COMBATLOG_OBJECT_CONTROL_NPC,
    COMBATLOG_OBJECT_TYPE_NPC
)

function kb.PlaySound(file)
    PlaySoundFile(file, 'Master')
end

function kb.PrintMsg(str)
    if C.DB.killingBlow.emote then
        SendChatMessage(str, 'EMOTE')
    end

    if not debugMode then
        return
    end

    F.Debug(str)
end

function kb.ResetAllCounts()
    lastKill = nil
    killCount = 0
    streakCount = 0
end

local function onEvent()
    local timestamp, type, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, _, swingOverkill, _, _, spellOverkill = CombatLogGetCurrentEventInfo()
    local toEnemy, fromEnemy, fromMyPets
    local db = C.Assets.killingBlow

    if destName and not CombatLog_Object_IsA(destFlags, COMBATLOG_OBJECT_NONE) then
        toEnemy = CombatLog_Object_IsA(destFlags,
            not C.DB.killingBlow.pvpOnly and FILTER_ENEMY_NPC or FILTER_ENEMY_PLAYERS)
    end

    if sourceName and not CombatLog_Object_IsA(sourceFlags, COMBATLOG_OBJECT_NONE) then
        fromMyPets = CombatLog_Object_IsA(sourceFlags, FILTER_MY_PETS)
        fromEnemy = CombatLog_Object_IsA(sourceFlags, FILTER_ENEMY_PLAYERS)
    end

    if
        (type == 'PARTY_KILL' and sourceGUID == playerGUID and toEnemy)
        or (type == 'SWING_DAMAGE' and destGUID ~= playerGUID and fromMyPets and toEnemy and swingOverkill >= 0)
        or ((type == 'RANGE_DAMAGE' or type == 'SPELL_DAMAGE' or type == 'SPELL_PERIODIC_DAMAGE')
            and destGUID ~= playerGUID and fromMyPets and toEnemy and spellOverkill >= 0)
    then
        if killsTable[destName] and (timestamp - killsTable[destName]) < 5 then
            return
        else
            killsTable[destName] = timestamp
        end

        if lastKill and (timestamp - lastKill < 17) then
            streakCount = streakCount + 1
        else
            streakCount = 1
            killCount = killCount + 1
        end

        if streakCount == 2 then
            kb.PlaySound(db.doublekill)
            kb.PrintMsg('Double Kill')
        elseif streakCount == 3 then
            kb.PlaySound(db.multikill)
            kb.PrintMsg('Multi Kill')
        elseif streakCount == 4 then
            kb.PlaySound(db.megakill)
            kb.PrintMsg('Mega Kill')
        elseif streakCount == 5 then
            kb.PlaySound(db.ultrakill)
            kb.PrintMsg('Ultra Kill')
        elseif streakCount == 6 then
            kb.PlaySound(db.monsterkill)
            kb.PrintMsg('Monster Kill')
        elseif streakCount == 7 then
            kb.PlaySound(db.ludicrouskill)
            kb.PrintMsg('Ludicrous Kill')
        elseif streakCount >= 8 then
            kb.PlaySound(db.holyshit)
            kb.PrintMsg('Holy Shit')
        elseif streakCount <= 1 then
            if deathsTable[destName] and (timestamp - deathsTable[destName]) < 90 then
                deathsTable[destName] = nil
                kb.PlaySound(db.retribution)
                kb.PrintMsg('Retribution')
            elseif killCount == 1 then
                kb.PlaySound(db.firstblood)
                kb.PrintMsg('First Blood')
            elseif killCount == 2 then
                kb.PlaySound(db.killingspree)
                kb.PrintMsg('Killing Spree')
            elseif killCount == 3 then
                kb.PlaySound(db.rampage)
                kb.PrintMsg('Rampage')
            elseif killCount == 4 then
                kb.PlaySound(db.dominating)
                kb.PrintMsg('Dominating')
            elseif killCount == 5 then
                kb.PlaySound(db.unstoppable)
                kb.PrintMsg('Unstoppable')
            elseif killCount == 6 then
                kb.PlaySound(db.godlike)
                kb.PrintMsg('GodLike')
            elseif killCount >= 7 then
                kb.PlaySound(db.wickedsick)
                kb.PrintMsg('Wicked Sick')
            end
        end

        lastKill = timestamp
    elseif
        (type == 'SWING_DAMAGE' and fromEnemy and destGUID == playerGUID and swingOverkill >= 0)
        or ((type == 'RANGE_DAMAGE' or type == 'SPELL_DAMAGE' or type == 'SPELL_PERIODIC_DAMAGE')
            and fromEnemy
            and destGUID == playerGUID
            and spellOverkill >= 0)
    then
        if sourceName ~= nil and sourceName ~= playerName then
            if deathsTable[sourceName] and (timestamp - deathsTable[sourceName]) < 5 then
                return
            else
                deathsTable[sourceName] = timestamp
            end

            if killsTable[sourceName] and (timestamp - killsTable[sourceName]) < 90 then
                killsTable[sourceName] = nil
                kb.PlaySound(db.denied)
                kb.PrintMsg('Denied')
            end
        end
    end
end

function kb.ToggleKillingBlow()
    if C.DB.killingBlow.enable then
        F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', onEvent)
        F:RegisterEvent('ZONE_CHANGED_NEW_AREA', kb.ResetAllCounts)
        F:RegisterEvent('PLAYER_DEAD', kb.ResetAllCounts)
    else
        F:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', onEvent)
        F:UnregisterEvent('ZONE_CHANGED_NEW_AREA', kb.ResetAllCounts)
        F:UnregisterEvent('PLAYER_DEAD', kb.ResetAllCounts)
    end
end

local function hook(_, index)
    local status = GetBattlefieldStatus(index)
    if playedIndex == 0 and status == 'confirm' then
        playedIndex = index
        kb.PlaySound(C.Assets.killingblow.play)
    elseif playedIndex == index and (status == 'queued' or status == 'active' or status == 'none') then
        playedIndex = 0
    end
end

function kb:OnLogin()
    kb.ToggleKillingBlow()

    -- 排战场准备就绪时播放音效
    hooksecurefunc('PVPReadyDialog_Update', hook)
end
