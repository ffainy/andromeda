local F, C, L = unpack(select(2, ...))
local M = F:GetModule('Tooltip')

local LibOR
local DCLoaded

local ZT_Prefix = 'ZenTracker'
local DC_Prefix = 'DCOribos'
local OmniCD_Prefix = 'OmniCD'
local MRT_Prefix = 'EXRTADD'

local memberCovenants = {}

local covenantList = {
    [1] = 'kyrian',
    [2] = 'venthyr',
    [3] = 'nightfae',
    [4] = 'necrolord',
}

local covenantColor = {
    [1] = _G.COVENANT_COLORS.Kyrian,
    [2] = _G.COVENANT_COLORS.Venthyr,
    [3] = _G.COVENANT_COLORS.NightFae,
    [4] = _G.COVENANT_COLORS.Necrolord,
}

local addonPrefixes = {
    [ZT_Prefix] = true,
    [DC_Prefix] = true,
    [OmniCD_Prefix] = true,
    [MRT_Prefix] = true,
}

function M:GetCovenantIcon(covenantID)
    local covenant = covenantList[covenantID]
    if covenant then
        return format('|A:sanctumupgrades-' .. covenantList[covenantID] .. '-32x32:16:16|a ')
    end

    return ''
end

local covenantIDToName = {}
function M:GetCovenantName(covenantID)
    if not covenantIDToName[covenantID] then
        local covenantData = C_Covenants.GetCovenantData(covenantID)

        covenantIDToName[covenantID] = covenantData and covenantData.name
    end
    local color = covenantColor[covenantID]
    return color:WrapTextInColorCode(covenantIDToName[covenantID])
end

function M:GetCovenantID(unit)
    local guid = UnitGUID(unit)
    if not guid then
        return
    end

    local covenantID = memberCovenants[guid]
    if not covenantID and LibOR then
        local playerInfo
        if LibOR.GetUnitInfo then
            playerInfo = LibOR.GetUnitInfo(unit)
        elseif LibOR.playerInfoManager and LibOR.playerInfoManager then
            playerInfo = LibOR.playerInfoManager.GetPlayerInfo(GetUnitName(unit, true))
        end
        return playerInfo and playerInfo.covenantId
    end

    return covenantID
end

local function msgChannel()
    if IsInGroup(_G.LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(_G.LE_PARTY_CATEGORY_INSTANCE) then
        return 'INSTANCE_CHAT'
    elseif IsInRaid(_G.LE_PARTY_CATEGORY_HOME) then
        return 'RAID'
    elseif IsInGroup(_G.LE_PARTY_CATEGORY_HOME) then
        return 'PARTY'
    end
end

local cache = {}
function M:UpdateRosterInfo()
    if not IsInGroup() then
        return
    end

    for i = 1, GetNumGroupMembers() do
        local name = GetRaidRosterInfo(i)
        if name and name ~= C.MY_NAME and not cache[name] then
            if not DCLoaded then
                C_ChatInfo.SendAddonMessage(DC_Prefix, format('ASK:%s', name), msgChannel())
            end
            C_ChatInfo.SendAddonMessage(MRT_Prefix, format('inspect\tREQ\tS\t%s', name), msgChannel())

            cache[name] = true
        end
    end

    if LibOR then
        if LibOR.RequestAllData then
            LibOR.RequestAllData()
        elseif LibOR.RequestAllPlayersInfo then
            LibOR.RequestAllPlayersInfo()
        end
    end
end

function M:HandleAddonMessage(...)
    local prefix, msg, _, sender = ...
    sender = Ambiguate(sender, 'none')
    if sender == C.MY_NAME then
        return
    end

    if prefix == ZT_Prefix then
        local version, type, guid, _, _, _, _, covenantID = strsplit(':', msg)
        version = tonumber(version)
        if (version and version > 3) and (type and type == 'H') and guid then
            covenantID = tonumber(covenantID)
            if covenantID and (not memberCovenants[guid] or memberCovenants[guid] ~= covenantID) then
                memberCovenants[guid] = covenantID
            end
        end
    elseif prefix == OmniCD_Prefix then
        local header, guid, body = strmatch(msg, '(.-),(.-),(.+)')
        if (header and guid and body) and (header == 'INF' or header == 'REQ' or header == 'UPD') then
            local covenantID = select(15, strsplit(',', body))
            covenantID = tonumber(covenantID)
            if covenantID and (not memberCovenants[guid] or memberCovenants[guid] ~= covenantID) then
                memberCovenants[guid] = covenantID
            end
        end
    elseif prefix == DC_Prefix then
        local playerName, covenantID = strsplit(':', msg)
        if playerName == 'ASK' then
            return
        end

        local guid = UnitGUID(sender)
        covenantID = tonumber(covenantID)
        if covenantID and guid and (not memberCovenants[guid] or memberCovenants[guid] ~= covenantID) then
            memberCovenants[guid] = covenantID
        end
    elseif prefix == MRT_Prefix then
        local modPrefix, subPrefix, soulbinds = strsplit('\t', msg)
        if
            (modPrefix and modPrefix == 'inspect')
            and (subPrefix and subPrefix == 'R')
            and (soulbinds and strsub(soulbinds, 1, 1) == 'S')
        then
            local guid = UnitGUID(sender)
            local covenantID = select(2, strsplit(':', soulbinds))
            covenantID = tonumber(covenantID)
            if covenantID and guid and (not memberCovenants[guid] or memberCovenants[guid] ~= covenantID) then
                memberCovenants[guid] = covenantID
            end
        end
    end
end

function M:AddCovenantInfo()
    if not C.DB.Tooltip.Covenant then
        return
    end
    if C.DB.Tooltip.PlayerInfoByAlt and not IsAltKeyDown() then
        return
    end

    local _, unit = GameTooltip:GetUnit()
    if not unit or not UnitIsPlayer(unit) then
        return
    end

    local covenantID
    if UnitIsUnit(unit, 'player') then
        covenantID = C_Covenants.GetActiveCovenantID()
    else
        covenantID = M:GetCovenantID(unit)
    end

    if covenantID and covenantID ~= 0 then
        GameTooltip:AddLine(
            format(
                '%s %s %s',
                C.WHITE_COLOR .. L['Covenant'] .. ':|r',
                M:GetCovenantName(covenantID),
                M:GetCovenantIcon(covenantID)
            )
        )
    end
end

function M:CovenantInfo()
    LibOR = _G.LibStub and _G.LibStub('LibOpenRaid-1.0', true)
    DCLoaded = C_AddOns.IsAddOnLoaded('Details_Covenants')

    for prefix in pairs(addonPrefixes) do
        C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    end

    M:UpdateRosterInfo()
    F:RegisterEvent('GROUP_ROSTER_UPDATE', M.UpdateRosterInfo)
    F:RegisterEvent('CHAT_MSG_ADDON', M.HandleAddonMessage)
end
