local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

local profit, spent, oldMoney = 0, 0, 0
local myName, myRealm, myClass = C.MY_NAME, C.MY_REALM, C.MY_CLASS
myRealm = gsub(myRealm, '%s', '') -- fix for multi words realm name

local function formatMoney(money)
    return format('%s: %s', L['Gold'], GetMoneyString(money))
end

local crossRealms = GetAutoCompleteRealms()
if not crossRealms or #crossRealms == 0 then
    crossRealms = { [1] = myRealm }
end

StaticPopupDialogs.ANDROMEDA_RESET_ALL_GOLD_STATISTICS = {
    text = C.RED_COLOR .. L['Reset All Gold Statistics?'],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        for _, realm in pairs(crossRealms) do
            if ANDROMEDA_ADB['GoldStatistic'][realm] then
                wipe(ANDROMEDA_ADB['GoldStatistic'][realm])
            end
        end

        ANDROMEDA_ADB['GoldStatistic'][myRealm][myName] = { GetMoney(), myClass }
    end,
    timeout = 0,
    whileDead = 1,
}

local menuList = {
    {
        text = F:RgbToHex(1, 0.8, 0) .. REMOVE_WORLD_MARKERS .. '!!!',
        notCheckable = true,
        func = function()
            StaticPopup_Show('ANDROMEDA_RESET_ALL_GOLD_STATISTICS')
        end,
    },
}

local function getClassIcon(class)
    local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
    c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
    local prefix = '|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:13:15:0:-1:50:50:'
    local classStr = prefix .. c1 .. ':' .. c2 .. ':' .. c3 .. ':' .. c4 .. '|t '
    return classStr or ''
end

local rebuildCharList

local function clearCharGold(_, realm, name)
    ANDROMEDA_ADB['GoldStatistic'][realm][name] = nil
    DropDownList1:Hide()
    rebuildCharList()
end

function rebuildCharList()
    for i = 2, #menuList do
        if menuList[i] then
            wipe(menuList[i])
        end
    end

    local index = 1
    for _, realm in pairs(crossRealms) do
        if ANDROMEDA_ADB['GoldStatistic'][myRealm] then
            for name, value in pairs(ANDROMEDA_ADB['GoldStatistic'][myRealm]) do
                if not (realm == myRealm and name == myRealm) then
                    index = index + 1
                    if not menuList[index] then
                        menuList[index] = {}
                    end
                    menuList[index].text = F:RgbToHex(F:ClassColor(value[2])) .. Ambiguate(name .. '-' .. realm, 'none')
                    menuList[index].notCheckable = true
                    menuList[index].arg1 = realm
                    menuList[index].arg2 = name
                    menuList[index].func = clearCharGold
                end
            end
        end
    end
end

local function onEvent(self, event)
    if event == 'PLAYER_ENTERING_WORLD' then
        oldMoney = GetMoney()
        C_WowTokenPublic.UpdateMarketPrice()
        self:UnregisterEvent(event)
    end

    if event == 'TOKEN_MARKET_PRICE_UPDATED' then
        C_WowTokenPublic.UpdateMarketPrice()
        return
    end

    local newMoney = GetMoney()
    local change = newMoney - oldMoney
    if oldMoney > newMoney then
        spent = spent - change
    else
        profit = profit + change
    end

    self.text:SetText(formatMoney(newMoney))

    if not ANDROMEDA_ADB['GoldStatistic'][myRealm] then
        ANDROMEDA_ADB['GoldStatistic'][myRealm] = {}
    end
    if not ANDROMEDA_ADB['GoldStatistic'][myRealm][myName] then
        ANDROMEDA_ADB['GoldStatistic'][myRealm][myName] = {}
    end
    ANDROMEDA_ADB['GoldStatistic'][myRealm][myName][1] = GetMoney()
    ANDROMEDA_ADB['GoldStatistic'][myRealm][myName][2] = myClass

    oldMoney = newMoney
end

local function onMouseUp(self, btn)
    if btn == 'LeftButton' then
        if not StoreFrame then
            C_AddOns.LoadAddOn('Blizzard_StoreUI')
        end
        securecall(ToggleStoreUI)
    elseif btn == 'RightButton' then
        if not menuList[1].created then
            rebuildCharList()
            menuList[1].created = true
        end
        EasyMenu(menuList, F.EasyMenu, self, -80, 100, 'MENU', 1)
    end
end

local function onEnter(self)
    local anchorTop = C.DB.Infobar.AnchorTop
    GameTooltip:SetOwner(self, (anchorTop and 'ANCHOR_BOTTOM') or 'ANCHOR_TOP', 0, (anchorTop and -6) or 6)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(WORLD_QUEST_REWARD_FILTERS_GOLD, 0.9, 0.8, 0.6)
    GameTooltip:AddLine(' ')

    GameTooltip:AddLine(L['Session'], 0.6, 0.8, 1)
    GameTooltip:AddDoubleLine(L['Earned'], GetMoneyString(profit, true), 1, 1, 1, 1, 1, 1)
    GameTooltip:AddDoubleLine(L['Spent'], GetMoneyString(spent, true), 1, 1, 1, 1, 1, 1)
    if profit < spent then
        GameTooltip:AddDoubleLine(L['Deficit'], GetMoneyString(spent - profit, true), 1, 0, 0, 1, 1, 1)
    elseif profit > spent then
        GameTooltip:AddDoubleLine(L['Profit'], GetMoneyString(profit - spent, true), 0, 1, 0, 1, 1, 1)
    end
    GameTooltip:AddLine(' ')

    local totalGold = 0
    GameTooltip:AddLine(CHARACTER, 0.6, 0.8, 1)

    for _, realm in pairs(crossRealms) do
        local thisRealmList = ANDROMEDA_ADB['GoldStatistic'][realm]
        if thisRealmList then
            for k, v in pairs(thisRealmList) do
                local name = Ambiguate(k .. '-' .. realm, 'none')
                local gold, class = unpack(v)
                local r, g, b = F:ClassColor(class)
                GameTooltip:AddDoubleLine(
                    getClassIcon(class) .. name,
                    GetMoneyString(gold, true),
                    r, g, b, 1, 1, 1
                )
                totalGold = totalGold + gold
            end
        end
    end

    GameTooltip:AddLine(' ')
    local accountmoney = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
    if accountmoney > 0 then
        GameTooltip:AddDoubleLine(
            ACCOUNT_BANK_PANEL_TITLE,
            GetMoneyString(accountmoney, true),
            0.6, 0.8, 1, 1, 1, 1
        )
    end
    GameTooltip:AddDoubleLine(
        TOTAL,
        GetMoneyString(totalGold + accountmoney, true),
        0.6, 0.8, 1, 1, 1, 1
    )

    GameTooltip:AddLine(' ')
    GameTooltip:AddLine(ITEM_QUALITY8_DESC, 0.6, 0.8, 1)

    local tokenPrice = C_WowTokenPublic.GetCurrentMarketPrice() or 0
    GameTooltip:AddDoubleLine(
        AUCTION_HOUSE_BROWSE_HEADER_PRICE,
        GetMoneyString(tokenPrice, true),
        1, 1, 1, 1, 1, 1
    )

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
    GameTooltip:AddDoubleLine(
        ' ',
        C.MOUSE_LEFT_BUTTON .. L['Toggle Store Panel'] .. ' ',
        1, 1, 1, 0.9, 0.8, 0.6
    )
    GameTooltip:AddDoubleLine(
        ' ',
        C.MOUSE_RIGHT_BUTTON .. L['Reset Gold Statistics'] .. ' ',
        1, 1, 1, 0.9, 0.8, 0.6
    )
    GameTooltip:Show()
end

local function onLeave(self)
    F:HideTooltip()
end

function INFOBAR:CreateGoldBlock()
    if not C.DB.Infobar.Gold then
        return
    end

    local bu = INFOBAR:RegisterNewBlock('gold', 'LEFT', 200)
    bu:HookScript('OnEvent', onEvent)
    bu:HookScript('OnMouseUp', onMouseUp)
    bu:HookScript('OnEnter', onEnter)
    bu:HookScript('OnLeave', onLeave)

    bu:RegisterEvent('PLAYER_ENTERING_WORLD')
    bu:RegisterEvent('PLAYER_MONEY')
    bu:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
    bu:RegisterEvent('SEND_MAIL_COD_CHANGED')
    bu:RegisterEvent('PLAYER_TRADE_MONEY')
    bu:RegisterEvent('TRADE_MONEY_CHANGED')
    bu:RegisterEvent('TOKEN_MARKET_PRICE_UPDATED')
end
