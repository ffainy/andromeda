local F, C, L = unpack(select(2, ...))
local N = F:GetModule('Notification')

local feasts = {
    [104958] = true, -- 熊貓人盛宴
    [126492] = true, -- 燒烤盛宴
    [126494] = true, -- 豪華燒烤盛宴
    [126495] = true, -- 快炒盛宴
    [126496] = true, -- 豪華快炒盛宴
    [126497] = true, -- 燉煮盛宴
    [126498] = true, -- 豪華燉煮盛宴
    [126499] = true, -- 蒸煮盛宴
    [126500] = true, -- 豪華蒸煮盛宴
    [126501] = true, -- 烘烤盛宴
    [126502] = true, -- 豪華烘烤盛宴
    [126503] = true, -- 美酒盛宴
    [126504] = true, -- 豪華美酒盛宴
    [145166] = true, -- 拉麵推車
    [145169] = true, -- 豪華拉麵推車
    [145196] = true, -- 熊貓人國寶級拉麵推車

    [201351] = true, -- 澎湃盛宴
    [201352] = true, -- 蘇拉瑪爾豪宴
    [259409] = true, -- 艦上盛宴
    [259410] = true, -- 豐盛的船長饗宴

    [286050] = true, -- 血潤盛宴
    [297048] = true, -- 超澎湃饗宴


    [308458] = true, -- 意外可口盛宴
    [308462] = true, -- 暴食享樂盛宴
    [359336] = true, -- 石頭湯之壺
    [382423] = true, -- 雨莎的澎湃燉肉
    [382427] = true, -- 卡魯耶克的豪華盛宴
    [383063] = true, -- 龍族佳餚大餐
}

local cauldrons = {
    [188036] = true, -- 靈魂大鍋
    [276972] = true, -- 神秘大鍋
    [298861] = true, -- 強效神秘大鍋
    [307157] = true, -- 永恆大鍋
}

local bots = {
    [22700] = true,  -- 修理機器人74A型
    [44389] = true,  -- 修理機器人110G型
    [54711] = true,  -- 廢料機器人
    [67826] = true,  -- 吉福斯
    [126459] = true, -- 布靈登4000型
    [157066] = true, -- 沃特
    [161414] = true, -- 布靈登5000型
    [199109] = true, -- 自動鐵錘
    [200061] = true, -- 召喚劫福斯
    [200204] = true, -- 自動鐵錘模式
    [200205] = true, -- 自動鐵錘模式
    [200210] = true, -- 滅團偵測水晶塔
    [200211] = true, -- 滅團偵測水晶塔
    [200212] = true, -- 煙火展示模式
    [200214] = true, -- 煙火展示模式
    [200215] = true, -- 點心發送模式
    [200216] = true, -- 點心發送模式
    [200217] = true, -- 閃亮模式
    [200218] = true, -- 閃亮模式
    [200219] = true, -- 機甲戰鬥模式
    [200220] = true, -- 機甲戰鬥模式
    [200221] = true, -- 蟲洞生成模式
    [200222] = true, -- 蟲洞生成模式
    [200223] = true, -- 熱能鐵砧模式
    [200225] = true, -- 熱能鐵砧模式
    [298926] = true, -- 布靈登7000型
}

local codex = {
    [226241] = true, -- 靜心寶典
    [256230] = true, -- 寧神寶典
    [324029] = true, -- 寧心寶典
}

local portals = {
    -- Alliance
    [10059] = true,  -- Stormwind
    [11416] = true,  -- Ironforge
    [11419] = true,  -- Darnassus
    [32266] = true,  -- Exodar
    [49360] = true,  -- Theramore
    [33691] = true,  -- Shattrath
    [88345] = true,  -- Tol Barad
    [132620] = true, -- Vale of Eternal Blossoms
    [176246] = true, -- Stormshield
    [281400] = true, -- Boralus
    -- Horde
    [11417] = true,  -- Orgrimmar
    [11420] = true,  -- Thunder Bluff
    [11418] = true,  -- Undercity
    [32267] = true,  -- Silvermoon
    [49361] = true,  -- Stonard
    [35717] = true,  -- Shattrath
    [88346] = true,  -- Tol Barad
    [132626] = true, -- Vale of Eternal Blossoms
    [176244] = true, -- Warspear
    [281402] = true, -- Dazar'alor
    -- Neutral
    [53142] = true,  -- Dalaran
    [120146] = true, -- Ancient Dalaran
    [224871] = true, -- Dalaran, Broken Isles
    [344597] = true, -- Oribos
}

local toys = {
    [61031] = true, -- 玩具火車組
    [49844] = true, -- 恐酒遙控器
}

local oddToys = {    -- CLEU can't catch these toy spells, why?
    [290154] = true, -- Transmorpher Beacon 幻变者道标
    [384911] = true, -- Atomic Recalibrator 原子重较器
    [412643] = true, -- Ethereal Transmogrifier 虚灵幻化师
}

function N:IsGroupMember(name)
    if name then
        if UnitInParty(name) then
            return 1
        elseif UnitInRaid(name) then
            return 2
        elseif name == C.MY_NAME then
            return 3
        end
    end

    return false
end

function N:AddNotification(title, srcName, spellId)
    local spellIcon = C_Spell.GetSpellTexture(spellId)
    local spellName = C_Spell.GetSpellLink(spellId)
    F:CreateNotification(
        title,
        format('%s: %s', srcName, spellName),
        nil,
        spellIcon
    )
end

function N:COMBAT_LOG_EVENT_UNFILTERED()
    if not IsInInstance() or not IsInGroup() then
        return
    end

    local _, event, _, _, srcName, _, _, _, _, _, _, spellId = CombatLogGetCurrentEventInfo()

    if not UnitIsPlayer(srcName) then return end

    if event == 'SPELL_CAST_SUCCESS' then
        N:Utility(event, srcName, spellId)
    elseif event == 'SPELL_SUMMON' then
        N:Utility(event, srcName, spellId)
    elseif event == 'SPELL_CREATE' then
        N:Utility(event, srcName, spellId)
    end
end

function N:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellId)
    if InCombatLockdown() or not IsInInstance() or not IsInGroup() or not UnitIsPlayer(unitTarget) then
        return
    end

    N:OddToys(UnitName(unitTarget), spellId)
end

function N:OddToys(srcName, spellId)
    if not (spellId and srcName) then
        return
    end

    local groupStatus = N:IsGroupMember(srcName)
    if not groupStatus then
        return
    end

    srcName = srcName:gsub('%-[^|]+', '')

    if oddToys[spellId] then
        N:AddNotification(L['Toy'], srcName, spellId)
    end
end

function N:Utility(event, srcName, spellId)
    if not (event and spellId and srcName) then
        return
    end

    local groupStatus = N:IsGroupMember(srcName)
    if not groupStatus then
        return
    end

    srcName = srcName:gsub('%-[^|]+', '')

    if event == 'SPELL_CAST_SUCCESS' then
        if feasts[spellId] then
            N:AddNotification(L['Feast'], srcName, spellId)
        elseif cauldrons[spellId] then
            N:AddNotification(L['Cauldron'], srcName, spellId)
        elseif spellId == 190336 then -- Mage Refreshment Table
            N:AddNotification(L['Food'], srcName, spellId)
        end
    elseif event == 'SPELL_SUMMON' then
        if bots[spellId] then
            N:AddNotification(L['Bot'], srcName, spellId)
        elseif codex[spellId] then
            N:AddNotification(L['Codex'], srcName, spellId)
        elseif spellId == 261602 then -- Katy's Stampwhistle
            N:AddNotification(L['Mailbox'], srcName, spellId)
        elseif spellId == 376664 then -- Ohuna Perch
            N:AddNotification(L['Mailbox'], srcName, spellId)
        elseif spellId == 195782 then -- Moonfeather Statue
            N:AddNotification(L['Toy'], srcName, spellId)
        end
    elseif event == 'SPELL_CREATE' then
        if spellId == 29893 then     -- Soulwell
            N:AddNotification(L['Soulwell'], srcName, spellId)
        elseif spellId == 698 then   -- Ritual of Summoning
            N:AddNotification(L['Summoning'], srcName, spellId)
        elseif spellId == 54710 then -- MOLL-E
            N:AddNotification(L['Mailbox'], srcName, spellId)
        elseif portals[spellId] then -- Mage Portals
            N:AddNotification(L['Portal'], srcName, spellId)
        elseif toys[spellId] then
            N:AddNotification(L['Toy'], srcName, spellId)
        end
    end
end

function N:InstanceUtility()
    if C.DB.Notification.InstanceUtility then
        F:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', N.COMBAT_LOG_EVENT_UNFILTERED)
        F:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', N.UNIT_SPELLCAST_SUCCEEDED)
    else
        F:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', N.COMBAT_LOG_EVENT_UNFILTERED)
        F:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', N.UNIT_SPELLCAST_SUCCEEDED)
    end
end
