local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')
local oUF = F.Libs.oUF

local repairCostString = gsub(REPAIR_COST, HEADER_COLON, ' ')
local lowDurabilityCap = 0.25

local localSlots = {
    [1] = { 1, INVTYPE_HEAD, 1000 },
    [2] = { 3, INVTYPE_SHOULDER, 1000 },
    [3] = { 5, INVTYPE_CHEST, 1000 },
    [4] = { 6, INVTYPE_WAIST, 1000 },
    [5] = { 9, INVTYPE_WRIST, 1000 },
    [6] = { 10, INVTYPE_HAND, 1000 },
    [7] = { 7, INVTYPE_LEGS, 1000 },
    [8] = { 8, INVTYPE_FEET, 1000 },
    [9] = { 16, INVTYPE_WEAPONMAINHAND, 1000 },
    [10] = { 17, INVTYPE_WEAPONOFFHAND, 1000 },
}

local function sortSlots(a, b)
    if a and b then
        return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
    end
end

local function updateAllSlots()
    local numSlots = 0
    for i = 1, 10 do
        localSlots[i][3] = 1000
        local index = localSlots[i][1]
        if GetInventoryItemLink('player', index) then
            local current, max = GetInventoryItemDurability(index)
            if current then
                localSlots[i][3] = current / max
                numSlots = numSlots + 1
            end
            local iconTexture = GetInventoryItemTexture('player', index) or 134400
            localSlots[i][4] = '|T' .. iconTexture .. ':13:15:0:0:50:50:4:46:4:46|t ' or ''
        end
    end
    sort(localSlots, sortSlots)
    return numSlots
end

local function isLowDurability()
    for i = 1, 10 do
        if localSlots[i][3] < lowDurabilityCap then
            return true
        end
    end
end

local function getDurabilityColor(cur, max)
    local r, g, b = oUF:RGBColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
    return r, g, b
end

local function onEvent(self, event)
    if updateAllSlots() > 0 then
        local r, g, b = getDurabilityColor(floor(localSlots[1][3] * 100), 100)
        self.text:SetText(
            format(
                '%s: %s%s',
                L['Durability'], F:RgbToHex(r, g, b) .. floor(localSlots[1][3] * 100), '%')
        )
    else
        self.text:SetText(format('%s: %s', L['Durability'], C.INFO_COLOR .. NONE))
    end

    if
        event == 'PLAYER_ENTERING_WORLD'
        or event == 'PLAYER_REGEN_ENABLED'
        and C.DB.Notification.Enable
        and C.DB.Notification.LowDurability
        and not InCombatLockdown()
    then
        if isLowDurability() then
            F:CreateNotification(
                MINIMAP_TRACKING_REPAIR,
                L['You have slots in low durability!'],
                nil,
                'Interface\\ICONS\\Ability_Repair'
            )
        end
    end
end

local function onMouseUp(self)
    ToggleCharacter('PaperDollFrame')
end

local function onEnter(self)
    local anchorTop = C.DB.Infobar.AnchorTop
    GameTooltip:SetOwner(self, (anchorTop and 'ANCHOR_BOTTOM') or 'ANCHOR_TOP', 0, (anchorTop and -6) or 6)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(DURABILITY, 0.9, 0.8, 0.6)
    GameTooltip:AddLine(' ')

    local totalCost = 0
    for i = 1, 10 do
        if localSlots[i][3] ~= 1000 then
            local slot = localSlots[i][1]
            local cur = floor(localSlots[i][3] * 100)
            local slotIcon = localSlots[i][4]
            GameTooltip:AddDoubleLine(
                slotIcon .. localSlots[i][2],
                cur .. '%',
                1, 1, 1, getDurabilityColor(cur, 100)
            )

            local data = C_TooltipInfo.GetInventoryItem('player', slot)
            if data then
                if data and data.repairCost then
                    totalCost = totalCost + data.repairCost
                end
            end
        end
    end

    if totalCost > 0 then
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            repairCostString,
            GetMoneyString(totalCost),
            0.6, 0.8, 1, 1, 1, 1
        )
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
    GameTooltip:AddDoubleLine(
        ' ',
        C.MOUSE_LEFT_BUTTON .. L['Toggle Character Panel'] .. ' ',
        1, 1, 1, 0.9, 0.8, 0.6
    )
    GameTooltip:Show()
end

local function onLeave()
    F:HideTooltip()
end

function INFOBAR:CreateDurabilityBlock()
    if not C.DB.Infobar.Durability then
        return
    end

    local du = INFOBAR:RegisterNewBlock('durability', 'LEFT', 150)
    du.onEvent = onEvent
    du.onEnter = onEnter
    du.onLeave = onLeave
    du.onMouseUp = onMouseUp
    du.eventList = {
        'PLAYER_ENTERING_WORLD',
        'UPDATE_INVENTORY_DURABILITY',
        'PLAYER_REGEN_ENABLED',
    }

    INFOBAR.Durabiliy = du
end
