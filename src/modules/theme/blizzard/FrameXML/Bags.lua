local F, C = unpack(select(2, ...))

local backpackTexture = 'Interface\\Buttons\\Button-Backpack-Up'

local function handleMoneyFrame(frame)
    if frame.MoneyFrame then
        F.StripTextures(frame.MoneyFrame)
        F.CreateBDFrame(frame.MoneyFrame, 0.25)
    end
end

local function createBagIcon(frame, index)
    if not frame.bagIcon then
        frame.bagIcon = frame.PortraitButton:CreateTexture()
        F.ReskinIcon(frame.bagIcon)
        frame.bagIcon:SetPoint('TOPLEFT', 5, -3)
        frame.bagIcon:SetSize(32, 32)
    end
    if index == 1 then
        frame.bagIcon:SetTexture(backpackTexture) -- backpack
    end
    handleMoneyFrame(frame)
end

local function replaceSortTexture(texture)
    texture:SetTexture('Interface\\Icons\\INV_Pet_Broom') -- HD version
    texture:SetTexCoord(unpack(C.TEX_COORD))
end

local function reskinSortButton(button)
    replaceSortTexture(button:GetNormalTexture())
    replaceSortTexture(button:GetPushedTexture())
    F.CreateBDFrame(button)

    local highlight = button:GetHighlightTexture()
    highlight:SetColorTexture(1, 1, 1, 0.25)
    highlight:SetAllPoints(button)
end

local function reskinBagSlot(bu)
    bu:SetNormalTexture(0)
    bu:SetPushedTexture(0)
    if bu.Background then
        bu.Background:SetAlpha(0)
    end
    bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    bu.searchOverlay:SetOutside()

    bu.icon:SetTexCoord(unpack(C.TEX_COORD))
    bu.bg = F.CreateBDFrame(bu.icon, 0.25)
    F.ReskinIconBorder(bu.IconBorder)

    local questTexture = bu.IconQuestTexture
    if questTexture then
        questTexture:SetDrawLayer('BACKGROUND')
        questTexture:SetSize(1, 1)
    end

    local hl = bu.SlotHighlightTexture
    if hl then
        hl:SetColorTexture(1, 0.8, 0, 0.5)
    end
end

local function updateContainer(frame)
    local id = frame:GetID()
    local name = frame:GetName()

    if id == 0 then
        BagItemSearchBox:ClearAllPoints()
        BagItemSearchBox:SetPoint('TOPLEFT', frame, 'TOPLEFT', 50, -35)
        BagItemAutoSortButton:ClearAllPoints()
        BagItemAutoSortButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -9, -31)
    end

    for i = 1, frame.size do
        local itemButton = _G[name .. 'Item' .. i]
        local questTexture = _G[name .. 'Item' .. i .. 'IconQuestTexture']
        if itemButton and questTexture:IsShown() then
            itemButton.IconBorder:SetVertexColor(1, 1, 0)
        end
    end

    if frame.bagIcon and id ~= 0 then
        local invID = C_Container.ContainerIDToInventoryID(id)
        if invID then
            local icon = GetInventoryItemTexture('player', invID)
            frame.bagIcon:SetTexture(icon or backpackTexture)
        end
    end
end

local function handleBagSlots(self)
    for button in self.itemButtonPool:EnumerateActive() do
        if not button.bg then
            reskinBagSlot(button)
        end
    end
end

local function handleBankTab(tab)
    if not tab.styled then
        tab.Border:SetAlpha(0)
        tab:SetNormalTexture(0)
        tab:SetPushedTexture(0)
        tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        tab.SelectedTexture:SetTexture(C.Assets.Textures.ButtonPushed)
        F.CreateBDFrame(tab)
        tab.Icon:SetTexCoord(unpack(C.TEX_COORD))

        tab.styled = true
    end
end

tinsert(C.BlizzThemes, function()
    if not ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local menu = AccountBankPanel and AccountBankPanel.TabSettingsMenu
    if menu then
        F.StripTextures(menu)
        F.ReskinIconSelector(menu)
        menu.DepositSettingsMenu:DisableDrawLayer('OVERLAY')

        for _, child in pairs({ menu.DepositSettingsMenu:GetChildren() }) do
            if child:IsObjectType('CheckButton') then
                F.ReskinCheckbox(child)
                child:SetSize(24, 24)
            elseif child.Arrow then
                F.ReskinDropdown(child)
            end
        end
    end

    if C.DB.Inventory.Enable then
        return
    end

    for i = 1, 13 do
        local frameName = 'ContainerFrame' .. i
        local frame = _G[frameName]
        local name = frame.TitleText or _G[frameName .. 'TitleText']
        name:SetDrawLayer('OVERLAY')
        name:ClearAllPoints()
        name:SetPoint('TOP', 0, -10)
        F.ReskinClose(frame.CloseButton)

        F.StripTextures(frame)
        F.SetBD(frame)
        frame.PortraitContainer:Hide()
        if frame.Bg then
            frame.Bg:Hide()
        end
        createBagIcon(frame, i)
        hooksecurefunc(frame, 'Update', updateContainer)
        hooksecurefunc(frame, 'UpdateItemSlots', handleBagSlots)
    end

    F.StripTextures(BackpackTokenFrame)
    F.CreateBDFrame(BackpackTokenFrame, 0.25)

    hooksecurefunc(BackpackTokenFrame, 'Update', function(self)
        local tokens = self.Tokens
        if next(tokens) then
            for i = 1, #tokens do
                local token = tokens[i]
                if not token.styled then
                    F.ReskinIcon(token.Icon)
                    token.styled = true
                end
            end
        end
    end)

    F.ReskinEditbox(BagItemSearchBox)
    reskinSortButton(BagItemAutoSortButton)

    -- Combined bags
    F.ReskinPortraitFrame(ContainerFrameCombinedBags)
    createBagIcon(ContainerFrameCombinedBags, 1)
    ContainerFrameCombinedBags.PortraitButton.Highlight:SetTexture('')
    hooksecurefunc(ContainerFrameCombinedBags, 'UpdateItemSlots', handleBagSlots)

    -- [[ Bank ]]

    BankSlotsFrame:DisableDrawLayer('BORDER')
    BankFrameMoneyFrameBorder:Hide()
    BankSlotsFrame.NineSlice:SetAlpha(0)
    BankSlotsFrame.EdgeShadows:Hide()

    -- "item slots" and "bag slots" text
    select(9, BankSlotsFrame:GetRegions()):SetDrawLayer('OVERLAY')
    select(10, BankSlotsFrame:GetRegions()):SetDrawLayer('OVERLAY')

    F.ReskinPortraitFrame(BankFrame)
    F.ReskinButton(BankFramePurchaseButton)
    F.ReskinTab(BankFrameTab1)
    F.ReskinTab(BankFrameTab2)
    F.ReskinTab(BankFrameTab3)
    F.ReskinEditbox(BankItemSearchBox)

    for i = 1, 28 do
        reskinBagSlot(_G['BankFrameItem' .. i])
    end

    for i = 1, 7 do
        reskinBagSlot(BankSlotsFrame['Bag' .. i])
    end

    reskinSortButton(BankItemAutoSortButton)

    hooksecurefunc('BankFrameItemButton_Update', function(button)
        if not button.isBag and button.IconQuestTexture:IsShown() then
            button.IconBorder:SetVertexColor(1, 1, 0)
        end
    end)

    -- [[ Reagent bank ]]

    ReagentBankFrame:DisableDrawLayer('BACKGROUND')
    ReagentBankFrame:DisableDrawLayer('BORDER')
    ReagentBankFrame:DisableDrawLayer('ARTWORK')
    ReagentBankFrame.NineSlice:SetAlpha(0)
    ReagentBankFrame.EdgeShadows:Hide()

    F.ReskinButton(ReagentBankFrame.DespositButton)
    F.ReskinButton(ReagentBankFrameUnlockInfoPurchaseButton)

    -- make button more visible
    F.StripTextures(ReagentBankFrameUnlockInfo)
    ReagentBankFrameUnlockInfoBlackBG:SetColorTexture(0.1, 0.1, 0.1)

    local reagentButtonsStyled = false
    ReagentBankFrame:HookScript('OnShow', function()
        if not reagentButtonsStyled then
            for i = 1, 98 do
                local button = _G['ReagentBankFrameItem' .. i]
                reskinBagSlot(button)
                BankFrameItemButton_Update(button)
            end
            reagentButtonsStyled = true
        end
    end)

    -- [[ Account bank ]]
    local AccountBankPanel = AccountBankPanel
    AccountBankPanel.NineSlice:SetAlpha(0)
    AccountBankPanel.EdgeShadows:Hide()
    F.ReskinButton(AccountBankPanel.ItemDepositFrame.DepositButton)
    F.ReskinCheckbox(AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox)
    handleMoneyFrame(AccountBankPanel)
    F.ReskinButton(AccountBankPanel.MoneyFrame.WithdrawButton)
    F.ReskinButton(AccountBankPanel.MoneyFrame.DepositButton)

    hooksecurefunc(AccountBankPanel, 'GenerateItemSlotsForSelectedTab', handleBagSlots)

    hooksecurefunc(AccountBankPanel, 'RefreshBankTabs', function(self)
        for tab in self.bankTabPool:EnumerateActive() do
            handleBankTab(tab)
        end
    end)
    handleBankTab(AccountBankPanel.PurchaseTab)

    F.ReskinButton(AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)
end)
