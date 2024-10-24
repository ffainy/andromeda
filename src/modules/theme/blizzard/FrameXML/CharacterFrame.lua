local F, C = unpack(select(2, ...))

function F:ReskinIconSelector()
    F.StripTextures(self)
    F.SetBD(self):SetInside()
    F.StripTextures(self.BorderBox)
    F.StripTextures(self.BorderBox.IconSelectorEditBox, 2)
    F.ReskinEditbox(self.BorderBox.IconSelectorEditBox)
    F.StripTextures(self.BorderBox.SelectedIconArea.SelectedIconButton)
    F.ReskinIcon(self.BorderBox.SelectedIconArea.SelectedIconButton.Icon)
    F.ReskinButton(self.BorderBox.OkayButton)
    F.ReskinButton(self.BorderBox.CancelButton)
    F.ReskinDropdown(self.BorderBox.IconTypeDropdown)
    F.ReskinTrimScroll(self.IconSelector.ScrollBar)

    hooksecurefunc(self.IconSelector.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.Icon and not child.styled then
                child:DisableDrawLayer('BACKGROUND')
                child.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.5)
                child.SelectedTexture:SetAllPoints(child.Icon)
                local hl = child:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.25)
                hl:SetAllPoints(child.Icon)
                F.ReskinIcon(child.Icon)

                child.styled = true
            end
        end
    end)
end

function F:ReskinModelControl()
    for i = 1, 5 do
        local button = select(i, self.ControlFrame:GetChildren())
        if button.NormalTexture then
            button.NormalTexture:SetAlpha(0)
            button.PushedTexture:SetAlpha(0)
        end
    end
end

local function noTaintArrow(self, direction) -- needs review
    F.StripTextures(self)

    local tex = self:CreateTexture(nil, 'ARTWORK')
    tex:SetAllPoints()
    F.SetupArrow(tex, direction)
    self.__texture = tex

    self:HookScript('OnEnter', F.Texture_OnEnter)
    self:HookScript('OnLeave', F.Texture_OnLeave)
end

tinsert(C.BlizzThemes, function()
    if not ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b

    F.ReskinPortraitFrame(CharacterFrame)
    F.StripTextures(CharacterFrameInsetRight)

    for i = 1, 3 do
        local tab = _G['CharacterFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['CharacterFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end

    F.ReskinModelControl(CharacterModelScene)
    CharacterModelScene:DisableDrawLayer('BACKGROUND')
    CharacterModelScene:DisableDrawLayer('BORDER')
    CharacterModelScene:DisableDrawLayer('OVERLAY')

    -- [[ Item buttons ]]

    local function colourPopout(self)
        local aR, aG, aB
        local glow = self:GetParent().IconBorder

        if glow:IsShown() then
            aR, aG, aB = glow:GetVertexColor()
        else
            aR, aG, aB = r, g, b
        end

        self.arrow:SetVertexColor(aR, aG, aB)
    end

    local function clearPopout(self)
        self.arrow:SetVertexColor(1, 1, 1)
    end

    local function updateAzeriteItem(self)
        if not self.styled then
            self.AzeriteTexture:SetAlpha(0)
            self.RankFrame.Texture:SetTexture('')
            self.RankFrame.Label:ClearAllPoints()
            self.RankFrame.Label:SetPoint('TOPLEFT', self, 2, -1)
            self.RankFrame.Label:SetTextColor(1, 0.5, 0)

            self.styled = true
        end
    end

    local function updateAzeriteEmpoweredItem(self)
        self.AzeriteTexture:SetAtlas('AzeriteIconFrame')
        self.AzeriteTexture:SetInside()
        self.AzeriteTexture:SetDrawLayer('BORDER', 1)
    end

    local function updateHighlight(self)
        local highlight = self:GetHighlightTexture()
        highlight:SetColorTexture(1, 1, 1, 0.25)
        highlight:SetInside(self.bg)
    end

    local function updateCosmetic(self)
        local itemLink = GetInventoryItemLink('player', self:GetID())
        self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
    end

    local slots = {
        'Head',
        'Neck',
        'Shoulder',
        'Shirt',
        'Chest',
        'Waist',
        'Legs',
        'Feet',
        'Wrist',
        'Hands',
        'Finger0',
        'Finger1',
        'Trinket0',
        'Trinket1',
        'Back',
        'MainHand',
        'SecondaryHand',
        'Tabard',
    }

    for i = 1, #slots do
        local slot = _G['Character' .. slots[i] .. 'Slot']
        local cooldown = _G['Character' .. slots[i] .. 'SlotCooldown']

        F.StripTextures(slot)
        slot.icon:SetTexCoord(unpack(C.TEX_COORD))
        slot.icon:SetInside()
        slot.bg = F.CreateBDFrame(slot.icon, 0.25)
        slot.bg:SetFrameLevel(3)
        cooldown:SetInside()

        slot.ignoreTexture:SetTexture('Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent')
        slot.IconOverlay:SetInside()
        F.ReskinIconBorder(slot.IconBorder)

        local popout = slot.popoutButton
        popout:SetNormalTexture(0)
        popout:SetHighlightTexture(0)

        local arrow = popout:CreateTexture(nil, 'OVERLAY')
        arrow:SetSize(14, 14)
        if slot.verticalFlyout then
            F.SetupArrow(arrow, 'down')
            arrow:SetPoint('TOP', slot, 'BOTTOM', 0, 1)
        else
            F.SetupArrow(arrow, 'right')
            arrow:SetPoint('LEFT', slot, 'RIGHT', -1, 0)
        end
        popout.arrow = arrow

        popout:HookScript('OnEnter', clearPopout)
        popout:HookScript('OnLeave', colourPopout)

        hooksecurefunc(slot, 'DisplayAsAzeriteItem', updateAzeriteItem)
        hooksecurefunc(slot, 'DisplayAsAzeriteEmpoweredItem', updateAzeriteEmpoweredItem)
    end

    hooksecurefunc('PaperDollItemSlotButton_Update', function(button)
        -- also fires for bag slots, we don't want that
        if button.popoutButton then
            button.icon:SetShown(GetInventoryItemTexture('player', button:GetID()) ~= nil)
            colourPopout(button.popoutButton)
        end
        updateCosmetic(button)
        updateHighlight(button)
    end)

    -- [[ Stats pane ]]

    local pane = CharacterStatsPane
    pane.ClassBackground:Hide()
    pane.ItemLevelFrame.Corruption:SetPoint('RIGHT', 22, -8)

    local categories = { pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory }
    for _, category in pairs(categories) do
        category.Background:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
        category.Background:SetTexCoord(0, 0.66, 0, 0.31)
        category.Background:SetVertexColor(r, g, b, 0.8)
        category.Background:SetPoint('BOTTOMLEFT', -30, -4)

        category.Title:SetTextColor(r, g, b)
    end

    -- [[ Sidebar tabs ]]

    if PaperDollSidebarTabs.DecorRight then
        PaperDollSidebarTabs.DecorRight:Hide()
    end

    for i = 1, #PAPERDOLL_SIDEBARS do
        local tab = _G['PaperDollSidebarTab' .. i]

        if i == 1 then
            for i = 1, 4 do
                local region = select(i, tab:GetRegions())
                region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
                region.SetTexCoord = nop
            end
        end

        tab.bg = F.CreateBDFrame(tab)
        tab.bg:SetPoint('TOPLEFT', 2, -3)
        tab.bg:SetPoint('BOTTOMRIGHT', 0, -2)

        tab.Icon:SetInside(tab.bg)
        tab.Hider:SetInside(tab.bg)
        tab.Highlight:SetInside(tab.bg)
        tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
        tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
        tab.TabBg:SetAlpha(0)
    end

    -- [[ Equipment manager ]]

    F.ReskinButton(PaperDollFrameEquipSet)
    F.ReskinButton(PaperDollFrameSaveSet)
    F.ReskinTrimScroll(PaperDollFrame.EquipmentManagerPane.ScrollBar)

    hooksecurefunc(PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.icon and not child.styled then
                F.HideObject(child.Stripe)
                child.BgTop:SetTexture('')
                child.BgMiddle:SetTexture('')
                child.BgBottom:SetTexture('')
                F.ReskinIcon(child.icon)

                child.HighlightBar:SetColorTexture(1, 1, 1, 0.25)
                child.HighlightBar:SetDrawLayer('BACKGROUND')
                child.SelectedBar:SetColorTexture(r, g, b, 0.25)
                child.SelectedBar:SetDrawLayer('BACKGROUND')
                child.Check:SetAtlas('checkmark-minimal')

                child.styled = true
            end
        end
    end)

    F.ReskinIconSelector(GearManagerPopupFrame)

    -- Title Pane
    F.ReskinTrimScroll(PaperDollFrame.TitleManagerPane.ScrollBar)

    hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                child:DisableDrawLayer('BACKGROUND')
                child.Check:SetAtlas('checkmark-minimal')

                child.styled = true
            end
        end
    end)

    -- Reputation Frame
    local oldAtlas = {
        ['Options_ListExpand_Right'] = 1,
        ['Options_ListExpand_Right_Expanded'] = 1,
    }
    local function updateCollapse(texture, atlas)
        if (not atlas) or oldAtlas[atlas] then
            if not texture.__owner then
                texture.__owner = texture:GetParent()
            end
            if texture.__owner:IsCollapsed() then
                texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Expand')
            else
                texture:SetAtlas('Soulbinds_Collection_CategoryHeader_Collapse')
            end
        end
    end

    local function updateToggleCollapse(button)
        button:SetNormalTexture(0)
        button.__texture:DoCollapse(button:GetHeader():IsCollapsed())
    end

    local function updateReputationBars(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and not child.styled then
                if child.Right then
                    F.StripTextures(child)
                    hooksecurefunc(child.Right, 'SetAtlas', updateCollapse)
                    hooksecurefunc(child.HighlightRight, 'SetAtlas', updateCollapse)
                    updateCollapse(child.Right)
                    updateCollapse(child.HighlightRight)
                    F.CreateBDFrame(child, 0.25):SetInside(nil, 2, 2)
                end
                local repbar = child.Content and child.Content.ReputationBar
                if repbar then
                    F.StripTextures(repbar)
                    repbar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
                    F.CreateBDFrame(repbar, 0.25)
                end
                if child.ToggleCollapseButton then
                    child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
                    F.ReskinCollapse(child.ToggleCollapseButton, true)
                    updateToggleCollapse(child.ToggleCollapseButton)
                    hooksecurefunc(child.ToggleCollapseButton, 'RefreshIcon', updateToggleCollapse)
                end

                child.styled = true
            end
        end
    end
    hooksecurefunc(ReputationFrame.ScrollBox, 'Update', updateReputationBars)

    F.ReskinTrimScroll(ReputationFrame.ScrollBar)
    F.ReskinDropdown(ReputationFrame.filterDropdown)

    local detailFrame = ReputationFrame.ReputationDetailFrame
    F.StripTextures(detailFrame)
    F.SetBD(detailFrame)
    F.ReskinClose(detailFrame.CloseButton)
    F.ReskinCheckbox(detailFrame.AtWarCheckbox)
    F.ReskinCheckbox(detailFrame.MakeInactiveCheckbox)
    F.ReskinCheckbox(detailFrame.WatchFactionCheckbox)
    F.ReskinButton(detailFrame.ViewRenownButton)

    -- Token frame
    F.ReskinTrimScroll(TokenFrame.ScrollBar, true) -- taint if touching thumb, needs review
    if C.IS_NEW_PATCH then
        F.ReskinDropdown(TokenFrame.filterDropdown)
    end
    if TokenFramePopup.CloseButton then -- blizz typo by parentKey "CloseButton" into "$parent.CloseButton"
        F.ReskinClose(TokenFramePopup.CloseButton)
    else
        F.ReskinClose((select(5, TokenFramePopup:GetChildren())))
    end

    F.ReskinButton(TokenFramePopup.CurrencyTransferToggleButton)
    F.ReskinCheckbox(TokenFramePopup.InactiveCheckbox)
    F.ReskinCheckbox(TokenFramePopup.BackpackCheckbox)

    noTaintArrow(TokenFrame.CurrencyTransferLogToggleButton, 'right') -- taint control, needs review
    F.ReskinPortraitFrame(CurrencyTransferLog)
    F.ReskinTrimScroll(CurrencyTransferLog.ScrollBar)

    local function handleCurrencyIcon(button)
        local icon = button.CurrencyIcon
        if icon then
            F.ReskinIcon(icon)
        end
    end
    hooksecurefunc(CurrencyTransferLog.ScrollBox, 'Update', function(self)
        self:ForEachFrame(handleCurrencyIcon)
    end)

    F.ReskinPortraitFrame(CurrencyTransferMenu)
    F.CreateBDFrame(CurrencyTransferMenu.SourceSelector, 0.25)
    CurrencyTransferMenu.SourceSelector.SourceLabel:SetWidth(56)
    F.ReskinDropdown(CurrencyTransferMenu.SourceSelector.Dropdown)
    F.ReskinIcon(CurrencyTransferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
    F.ReskinIcon(CurrencyTransferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
    F.ReskinButton(CurrencyTransferMenu.ConfirmButton)
    F.ReskinButton(CurrencyTransferMenu.CancelButton)

    local amountSelector = CurrencyTransferMenu.AmountSelector
    if amountSelector then
        F.CreateBDFrame(amountSelector, .25)
        F.ReskinEditbox(amountSelector.InputBox)
        amountSelector.InputBox.__bg:SetInside(nil, 3, 3)
    end

    hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and not child.styled then
                if child.Right then
                    F.StripTextures(child)
                    hooksecurefunc(child.Right, 'SetAtlas', updateCollapse)
                    hooksecurefunc(child.HighlightRight, 'SetAtlas', updateCollapse)
                    updateCollapse(child.Right)
                    updateCollapse(child.HighlightRight)
                    F.CreateBDFrame(child, 0.25):SetInside(nil, 2, 2)
                end
                local icon = child.Content and child.Content.CurrencyIcon
                if icon then
                    F.ReskinIcon(icon)
                end
                if child.ToggleCollapseButton then
                    F.ReskinCollapse(child.ToggleCollapseButton, true)
                    updateToggleCollapse(child.ToggleCollapseButton)
                    hooksecurefunc(child.ToggleCollapseButton, 'RefreshIcon', updateToggleCollapse)
                end

                child.styled = true
            end
        end
    end)

    F.StripTextures(TokenFramePopup)
    F.SetBD(TokenFramePopup)

    -- Quick Join
    F.ReskinTrimScroll(QuickJoinFrame.ScrollBar)
    F.ReskinButton(QuickJoinFrame.JoinQueueButton)

    F.SetBD(QuickJoinRoleSelectionFrame)
    F.ReskinButton(QuickJoinRoleSelectionFrame.AcceptButton)
    F.ReskinButton(QuickJoinRoleSelectionFrame.CancelButton)
    F.ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
    F.StripTextures(QuickJoinRoleSelectionFrame)

    F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, 'TANK')
    F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, 'HEALER')
    F.ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, 'DPS')
end)
