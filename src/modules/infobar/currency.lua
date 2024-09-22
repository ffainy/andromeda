local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

local currPvP = {
    '1792', -- 荣誉
    '1602', -- 征服
}

local currPvE = {
    '2815', -- 共鸣水晶
    '3008', -- 神勇石
    '2914', -- 风化
    '2915', -- 蚀刻
    '2916', -- 符文
    '2917', -- 鎏金
    '3028', -- 宝匣钥匙
    '2803', -- 晦幽铸币
    '3056', -- 刻基
}

local function addIcon(texture)
    texture = texture and '|T' .. texture .. ':12:16:0:0:50:50:4:46:4:46|t ' or ''
    return texture
end

local title
local function addTitle(text)
    if not title then
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(text, 0.6, 0.8, 1)

        title = true
    end
end

local function onEvent(self)
    local info = C_CurrencyInfo.GetCurrencyInfo(2815) -- 共鸣水晶 / Resonance Crystals
    self.text:SetText(format('%s: |cffdf5ed9%s|r', info.name, BreakUpLargeNumbers(info.quantity)))
end

local function onMouseUp(self, btn)
    if btn == 'LeftButton' then
        securecall(ToggleCharacter, 'TokenFrame')
    end
end

local function onEnter(self)
    local anchorTop = C.DB.Infobar.AnchorTop
    GameTooltip:SetOwner(self, (anchorTop and 'ANCHOR_BOTTOM') or 'ANCHOR_TOP', 0, (anchorTop and -6) or 6)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(CURRENCY, 0.9, 0.8, 0.6)

    title = false
    local chargeInfo = C_CurrencyInfo.GetCurrencyInfo(2813) -- 协和绸缎 / Harmonized Silk
    if chargeInfo then
        addTitle(L['Catalyst Charge'])

        GameTooltip:AddDoubleLine(
            addIcon(chargeInfo.iconFileID) .. chargeInfo.name,
            chargeInfo.quantity .. '/' .. chargeInfo.maxQuantity,
            1, 1, 1, 1, 1, 1
        )
    end

    title = false
    for _, id in pairs(currPvE) do
        addTitle('PvE')

        local pveInfo = C_CurrencyInfo.GetCurrencyInfo(id)
        if pveInfo.maxQuantity > 0 then
            GameTooltip:AddDoubleLine(
                addIcon(pveInfo.iconFileID) .. pveInfo.name,
                BreakUpLargeNumbers(pveInfo.quantity) .. '/' .. BreakUpLargeNumbers(pveInfo.maxQuantity),
                1, 1, 1, 1, 1, 1
            )
        else
            GameTooltip:AddDoubleLine(
                addIcon(pveInfo.iconFileID) .. pveInfo.name,
                BreakUpLargeNumbers(pveInfo.quantity),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    title = false
    for _, id in pairs(currPvP) do
        addTitle('PvP')

        local pvpInfo = C_CurrencyInfo.GetCurrencyInfo(id)
        if pvpInfo.maxQuantity > 0 then
            GameTooltip:AddDoubleLine(
                addIcon(pvpInfo.iconFileID)..pvpInfo.name,
                BreakUpLargeNumbers(pvpInfo.quantity) .. '/' .. BreakUpLargeNumbers(pvpInfo.maxQuantity),
                1, 1, 1, 1, 1, 1
            )
        else
            GameTooltip:AddDoubleLine(
                addIcon(pvpInfo.iconFileID)..pvpInfo.name,
                BreakUpLargeNumbers(pvpInfo.quantity),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
    GameTooltip:AddDoubleLine(' ', C.MOUSE_LEFT_BUTTON .. L['Toggle Currency Panel'] .. ' ', 1, 1, 1, 0.9, 0.8, 0.6)
    GameTooltip:Show()
end

local function onLeave()
    F:HideTooltip()
end

function INFOBAR:CreateCurrencyBlock()
    if not C.DB.Infobar.Currency then
        return
    end

    local cur = INFOBAR:RegisterNewBlock('currency', 'LEFT', 150)

    cur.onEvent = onEvent
    cur.onEnter = onEnter
    cur.onLeave = onLeave
    cur.onMouseUp = onMouseUp

    cur.eventList = {
        'PLAYER_ENTERING_WORLD',
        'CURRENCY_DISPLAY_UPDATE',
    }
end
