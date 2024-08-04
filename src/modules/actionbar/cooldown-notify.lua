local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local function sendMsg(text)
    if IsPartyLFG() then
        SendChatMessage(text, 'INSTANCE_CHAT')
    elseif IsInRaid() then
        SendChatMessage(text, 'RAID')
    elseif IsInGroup() then
        SendChatMessage(text, 'PARTY')
    end
end

local function getRemainTime(second)
    if second > 60 then
        return format('%d:%.2d', second / 60, second % 60)
    else
        return format('%ds', second)
    end
end

local lastCDSend = 0
function ACTIONBAR:SendCurrentSpell(thisTime, spellID)
    local spellLink = GetSpellLink(spellID)
    local chargeInfo = C_Spell.GetSpellCharges(spellID)
    local charges = chargeInfo and chargeInfo.currentCharges
    local maxCharges = chargeInfo and chargeInfo.maxCharges
    local chargeStart = chargeInfo and chargeInfo.cooldownStartTime
    local chargeDuration = chargeInfo and chargeInfo.cooldownDuration
    if charges and maxCharges then
        if charges ~= maxCharges then
            local remain = chargeStart + chargeDuration - thisTime
            sendMsg(
                format(L['%s %s/%s next charge remaining %s.'], spellLink, charges, maxCharges, getRemainTime(remain))
            )
        else
            sendMsg(format(L['%s %s/%s all charges ready.'], spellLink, charges, maxCharges))
        end
    else
        local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
        local start = cooldownInfo and cooldownInfo.startTime
        local duration = cooldownInfo and cooldownInfo.duration
        if start and duration > 0 then
            local remain = start + duration - thisTime
            sendMsg(format(L['%s cooldown remaining %s.'], spellLink, getRemainTime(remain)))
        else
            sendMsg(format(L['%s is now available.'], spellLink))
        end
    end
end

function ACTIONBAR:SendCurrentItem(thisTime, itemID, itemLink, itemCount)
    local start, duration = GetItemCooldown(itemID)
    if start and duration > 0 then
        local remain = start + duration - thisTime
        sendMsg(format(L['%s cooldown remaining %s.'], itemLink .. ' x' .. itemCount, getRemainTime(remain)))
    else
        sendMsg(format(L['%s is now available.'], itemLink .. ' x' .. itemCount))
    end
end

function ACTIONBAR:AnalyzeButtonCooldown()
    if not self._state_action then -- no action for pet actionbar
        return
    end
    if not C.DB.Actionbar.CooldownNotify then
        return
    end
    if not IsInGroup() then
        return
    end

    local thisTime = GetTime()
    if thisTime - lastCDSend < 1.5 then
        return
    end
    lastCDSend = thisTime

    local spellType, id, subType = GetActionInfo(self._state_action)
    local itemCount = GetActionCount(self._state_action)
    if spellType == 'spell' then
        ACTIONBAR:SendCurrentSpell(thisTime, id)
    elseif spellType == 'item' then
        local itemName, itemLink = C_Item.GetItemInfo(id)
        ACTIONBAR:SendCurrentItem(thisTime, id, itemLink or itemName, itemCount)
    elseif spellType == 'macro' then
        local spellID = subType == 'spell' and id or GetMacroSpell(id)
        local _, itemLink = GetMacroItem(id)
        local itemID = itemLink and GetItemInfoFromHyperlink(itemLink)
        if spellID then
            ACTIONBAR:SendCurrentSpell(thisTime, spellID)
        elseif itemID then
            ACTIONBAR:SendCurrentItem(thisTime, itemID, itemLink, itemCount)
        end
    end
end

function ACTIONBAR:CooldownNotify()
    if not C.DB.Actionbar.Enable then
        return
    end

    if not ACTIONBAR then
        return
    end

    for _, button in pairs(ACTIONBAR.buttons) do
        button:HookScript('OnMouseWheel', ACTIONBAR.AnalyzeButtonCooldown)
    end
end
