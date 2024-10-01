local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

local block
local blockEntered = false

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

local currOld = {
    '2912', -- 苏生觉醒 / Renascent Awakening
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

local function onShiftDown()
    if blockEntered then
        block:onEnter()
    end
end

local yellow = '|cffF5D952%s|r'
local red = '|cffff2020%s|r'
local green = '|cff20ff20%s|r'

local function onEnter(self)
    blockEntered = true

    local anchorTop = C.DB.Infobar.AnchorTop
    GameTooltip:SetOwner(self, (anchorTop and 'ANCHOR_BOTTOM') or 'ANCHOR_TOP', 0, (anchorTop and -6) or 6)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(CURRENCY, 0.9, 0.8, 0.6)

    title = false
    local catalystInfo = C_CurrencyInfo.GetCurrencyInfo(2813) -- 协和绸缎 / Harmonized Silk
    if catalystInfo then
        addTitle(L['Catalyst Charge'])

        if catalystInfo.maxQuantity > 0 then
            GameTooltip:AddDoubleLine(
                addIcon(catalystInfo.iconFileID) .. catalystInfo.name,
                format(
                    yellow .. ' / ' .. red,
                    BreakUpLargeNumbers(catalystInfo.quantity),
                    BreakUpLargeNumbers(catalystInfo.maxQuantity)),
                1, 1, 1, 1, 1, 1
            )
        else
            GameTooltip:AddDoubleLine(
                addIcon(catalystInfo.iconFileID) .. catalystInfo.name,
                format(
                    yellow,
                    BreakUpLargeNumbers(catalystInfo.quantity)),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    title = false
    for _, id in pairs(currPvE) do
        addTitle('PvE')

        local pveInfo = C_CurrencyInfo.GetCurrencyInfo(id)
        if pveInfo.maxQuantity > 0 then
            if pveInfo.totalEarned ~= 0 then
                if pveInfo.maxQuantity == pveInfo.totalEarned then
                    GameTooltip:AddDoubleLine(
                        addIcon(pveInfo.iconFileID) .. pveInfo.name,
                        format(
                            yellow .. ' (' .. red .. ' / ' .. red .. ')',
                            BreakUpLargeNumbers(pveInfo.quantity),
                            BreakUpLargeNumbers(pveInfo.totalEarned),
                            BreakUpLargeNumbers(pveInfo.maxQuantity)),
                        1, 1, 1, 1, 1, 1
                    )
                else
                    GameTooltip:AddDoubleLine(
                        addIcon(pveInfo.iconFileID) .. pveInfo.name,
                        format(
                            yellow .. ' (' .. green .. ' / ' .. red .. ')',
                            BreakUpLargeNumbers(pveInfo.quantity),
                            BreakUpLargeNumbers(pveInfo.totalEarned),
                            BreakUpLargeNumbers(pveInfo.maxQuantity)),
                        1, 1, 1, 1, 1, 1
                    )
                end
            else
                GameTooltip:AddDoubleLine(
                    addIcon(pveInfo.iconFileID) .. pveInfo.name,
                    format(
                        yellow .. ' / ' .. red,
                        BreakUpLargeNumbers(pveInfo.quantity),
                        BreakUpLargeNumbers(pveInfo.maxQuantity)),
                    1, 1, 1, 1, 1, 1
                )
            end
        else
            GameTooltip:AddDoubleLine(
                addIcon(pveInfo.iconFileID) .. pveInfo.name,
                format(yellow, BreakUpLargeNumbers(pveInfo.quantity)),
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
                addIcon(pvpInfo.iconFileID) .. pvpInfo.name,
                format(
                    yellow .. ' / ' .. red,
                    BreakUpLargeNumbers(pvpInfo.quantity),
                    BreakUpLargeNumbers(pvpInfo.maxQuantity)),
                1, 1, 1, 1, 1, 1
            )
        else
            GameTooltip:AddDoubleLine(
                addIcon(pvpInfo.iconFileID) .. pvpInfo.name,
                format(
                    yellow,
                    BreakUpLargeNumbers(pvpInfo.quantity)),
                1, 1, 1, 1, 1, 1
            )
        end
    end

    if IsShiftKeyDown() then
        title = false
        for _, id in pairs(currOld) do
            addTitle(L['Previous Expansion'])

            local oldInfo = C_CurrencyInfo.GetCurrencyInfo(id)
            if oldInfo.maxQuantity > 0 then
                GameTooltip:AddDoubleLine(
                    addIcon(oldInfo.iconFileID) .. oldInfo.name,
                    format(
                        yellow .. ' / ' .. red,
                        BreakUpLargeNumbers(oldInfo.quantity),
                        BreakUpLargeNumbers(oldInfo.maxQuantity)),
                    1, 1, 1, 1, 1, 1
                )
            else
                GameTooltip:AddDoubleLine(
                    addIcon(oldInfo.iconFileID) .. oldInfo.name,
                    format(
                        yellow,
                        BreakUpLargeNumbers(oldInfo.quantity)),
                    1, 1, 1, 1, 1, 1
                )
            end
        end
    else
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            L['Hold SHIFT key for more currencies'],
            0.6, 0.8, 1
        )
    end

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
    GameTooltip:AddDoubleLine(' ', C.MOUSE_LEFT_BUTTON .. L['Toggle Currency Panel'] .. ' ', 1, 1, 1, 0.9, 0.8, 0.6)
    GameTooltip:Show()

    F:RegisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

local function onLeave()
    blockEntered = false
    F.HideTooltip()
    F:UnregisterEvent('MODIFIER_STATE_CHANGED', onShiftDown)
end

function INFOBAR:CreateCurrencyBlock()
    if not C.DB.Infobar.Currency then
        return
    end

    block = INFOBAR:RegisterNewBlock('currency', 'LEFT', 150)
    block.onEvent = onEvent
    block.onEnter = onEnter
    block.onLeave = onLeave
    block.onMouseUp = onMouseUp

    block.eventList = {
        'PLAYER_ENTERING_WORLD',
        'CURRENCY_DISPLAY_UPDATE',
    }
end
