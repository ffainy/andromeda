local F, C = unpack(select(2, ...))

local function hideCategoryButton(button)
    button.NormalTexture:Hide()
    button.SelectedTexture:SetColorTexture(0, 0.6, 1, 0.3)
    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
end

local function reskinListIcon(frame)
    if not frame.tableBuilder then
        return
    end

    for i = 1, 22 do
        local row = frame.tableBuilder.rows[i]
        if row then
            local cell = row.cells and row.cells[1]
            if cell and cell.Icon then
                if not cell.styled then
                    cell.Icon.bg = F.ReskinIcon(cell.Icon)
                    if cell.IconBorder then
                        cell.IconBorder:Hide()
                    end
                    cell.styled = true
                end
                cell.Icon.bg:SetShown(cell.Icon:IsShown())
            end
        end
    end
end

local function reskinListHeader(headerContainer)
    local maxHeaders = headerContainer:GetNumChildren()
    for i = 1, maxHeaders do
        local header = select(i, headerContainer:GetChildren())
        if header and not header.styled then
            header:DisableDrawLayer('BACKGROUND')
            header.bg = F.CreateBDFrame(header)
            local hl = header:GetHighlightTexture()
            hl:SetColorTexture(1, 1, 1, 0.1)
            hl:SetAllPoints(header.bg)

            header.styled = true
        end

        if header.bg then
            header.bg:SetPoint('BOTTOMRIGHT', i < maxHeaders and -5 or 0, -2)
        end
    end
end

local function reskinBrowseOrders(frame)
    local headerContainer = frame.RecipeList and frame.RecipeList.HeaderContainer
    if headerContainer then
        reskinListHeader(headerContainer)
    end
end

local function reskinMoneyInput(box)
    F.ReskinEditbox(box)
    box.__bg:SetPoint('TOPLEFT', 0, -3)
    box.__bg:SetPoint('BOTTOMRIGHT', 0, 3)
end

local function reskinContainer(container)
    local button = container.Button
    button.bg = F.ReskinIcon(button.Icon)
    F.ReskinIconBorder(button.IconBorder)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

    local box = container.EditBox
    box:DisableDrawLayer('BACKGROUND')
    F.ReskinEditbox(box)
    F.ReskinArrow(box.DecrementButton, 'left')
    F.ReskinArrow(box.IncrementButton, 'right')
end

local function reskinOrderIcon(child)
    if child.styled then
        return
    end

    local button = child:GetChildren()
    if button and button.IconBorder then
        button.bg = F.ReskinIcon(button.Icon)
        F.ReskinIconBorder(button.IconBorder)
    end

    child.styled = true
end

C.Themes['Blizzard_ProfessionsCustomerOrders'] = function()
    local frame = _G.ProfessionsCustomerOrdersFrame

    F.ReskinPortraitFrame(frame)
    for i = 1, 2 do
        F.ReskinTab(frame.Tabs[i])
    end
    F.StripTextures(frame.MoneyFrameBorder)
    F.CreateBDFrame(frame.MoneyFrameBorder, 0.25)
    F.StripTextures(frame.MoneyFrameInset)

    local searchBar = frame.BrowseOrders.SearchBar
    F.ReskinButton(searchBar.FavoritesSearchButton)
    searchBar.FavoritesSearchButton:SetSize(22, 22)
    F.ReskinEditbox(searchBar.SearchBox)
    F.ReskinButton(searchBar.SearchButton)
    F.ReskinFilterButton(searchBar.FilterDropdown)

    F.StripTextures(frame.BrowseOrders.CategoryList)
    F.ReskinTrimScroll(frame.BrowseOrders.CategoryList.ScrollBar)

    hooksecurefunc(frame.BrowseOrders.CategoryList.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.Text and not child.styled then
                hideCategoryButton(child)
                hooksecurefunc(child, 'Init', hideCategoryButton)

                child.styled = true
            end
        end
    end)

    local recipeList = frame.BrowseOrders.RecipeList
    F.StripTextures(recipeList)
    F.CreateBDFrame(recipeList.ScrollBox, 0.25):SetInside()
    F.ReskinTrimScroll(recipeList.ScrollBar)

    hooksecurefunc(frame.BrowseOrders, 'SetupTable', reskinBrowseOrders)
    hooksecurefunc(frame.BrowseOrders, 'StartSearch', reskinListIcon)

    -- Form
    F.ReskinButton(frame.Form.BackButton)
    F.ReskinCheckbox(frame.Form.AllocateBestQualityCheckbox)
    F.ReskinCheckbox(frame.Form.TrackRecipeCheckbox.Checkbox)
    frame.Form.RecipeHeader:Hide() -- needs review
    F.CreateBDFrame(frame.Form.RecipeHeader, 0.25)
    F.StripTextures(frame.Form.LeftPanelBackground)
    F.StripTextures(frame.Form.RightPanelBackground)

    local itemButton = frame.Form.OutputIcon
    itemButton.CircleMask:Hide()
    itemButton.bg = F.ReskinIcon(itemButton.Icon)
    F.ReskinIconBorder(itemButton.IconBorder, true, true)

    local hl = itemButton:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside(itemButton.bg)

    F.ReskinEditbox(frame.Form.OrderRecipientTarget)
    frame.Form.OrderRecipientTarget.__bg:SetPoint('TOPLEFT', -8, -2)
    frame.Form.OrderRecipientTarget.__bg:SetPoint('BOTTOMRIGHT', 0, 2)
    F.ReskinDropdown(frame.Form.OrderRecipientDropdown)
    F.ReskinDropdown(frame.Form.MinimumQuality.Dropdown)

    local paymentContainer = frame.Form.PaymentContainer
    F.StripTextures(paymentContainer.NoteEditBox)
    local bg = F.CreateBDFrame(paymentContainer.NoteEditBox, 0.25)
    bg:SetPoint('TOPLEFT', 15, 5)
    bg:SetPoint('BOTTOMRIGHT', -18, 0)

    reskinMoneyInput(paymentContainer.TipMoneyInputFrame.GoldBox)
    reskinMoneyInput(paymentContainer.TipMoneyInputFrame.SilverBox)
    F.ReskinDropdown(paymentContainer.DurationDropdown)
    F.ReskinButton(paymentContainer.ListOrderButton)
    F.ReskinButton(paymentContainer.CancelOrderButton)

    local viewButton = paymentContainer.ViewListingsButton
    viewButton:SetAlpha(0)
    local buttonFrame = CreateFrame('Frame', nil, paymentContainer)
    buttonFrame:SetInside(viewButton)
    local tex = buttonFrame:CreateTexture(nil, 'ARTWORK')
    tex:SetAllPoints()
    tex:SetTexture('Interface\\CURSOR\\Crosshair\\Repair')

    local current = frame.Form.CurrentListings
    F.StripTextures(current)
    F.SetBD(current)
    F.ReskinButton(current.CloseButton)
    F.ReskinTrimScroll(current.OrderList.ScrollBar)
    reskinListHeader(current.OrderList.HeaderContainer)
    F.StripTextures(current.OrderList)
    current:ClearAllPoints()
    current:SetPoint('LEFT', frame, 'RIGHT', 10, 0)

    local function resetButton(button)
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        local hl = button:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside(button.bg)
    end

    hooksecurefunc(frame.Form, 'UpdateReagentSlots', function(self)
        for slot in self.reagentSlotPool:EnumerateActive() do
            local button = slot.Button
            if button and not button.styled then
                button.bg = F.ReskinIcon(button.Icon)
                F.ReskinIconBorder(button.IconBorder, true)
                if button.SlotBackground then
                    button.SlotBackground:Hide()
                end
                F.ReskinCheckbox(slot.Checkbox)
                button.HighlightTexture:SetColorTexture(1, 0.8, 0, 0.5)
                button.HighlightTexture:SetInside(button.bg)
                resetButton(button)
                hooksecurefunc(button, 'Update', resetButton)

                button.styled = true
            end
        end
    end)

    local qualityDialog = frame.Form.QualityDialog
    F.StripTextures(qualityDialog)
    F.SetBD(qualityDialog)
    F.ReskinClose(qualityDialog.ClosePanelButton)
    F.ReskinButton(qualityDialog.AcceptButton)
    F.ReskinButton(qualityDialog.CancelButton)

    for i = 1, 3 do
        reskinContainer(qualityDialog['Container' .. i])
    end

    F.ReskinButton(frame.Form.OrderRecipientDisplay.SocialDropdown)

    -- Orders
    F.ReskinButton(frame.MyOrdersPage.RefreshButton)
    frame.MyOrdersPage.RefreshButton.__bg:SetInside(nil, 3, 3)
    F.StripTextures(frame.MyOrdersPage.OrderList)
    F.CreateBDFrame(frame.MyOrdersPage.OrderList, 0.25)
    reskinListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
    F.ReskinTrimScroll(frame.MyOrdersPage.OrderList.ScrollBar)

    hooksecurefunc(frame.MyOrdersPage.OrderList.ScrollBox, 'Update', function(self)
        self:ForEachFrame(reskinOrderIcon)
    end)

    -- Item flyout
    if _G.OpenProfessionsItemFlyout then
        hooksecurefunc('OpenProfessionsItemFlyout', F.ReskinProfessionsFlyout)
    end
end
