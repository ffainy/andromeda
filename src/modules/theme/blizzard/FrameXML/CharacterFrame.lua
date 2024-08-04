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

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b

    F.ReskinPortraitFrame(_G.CharacterFrame)
    F.StripTextures(_G.CharacterFrameInsetRight)

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

    F.ReskinModelControl(_G.CharacterModelScene)
    _G.CharacterModelScene:DisableDrawLayer('BACKGROUND')
    _G.CharacterModelScene:DisableDrawLayer('BORDER')
    _G.CharacterModelScene:DisableDrawLayer('OVERLAY')

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

    local pane = _G.CharacterStatsPane
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

    if _G.PaperDollSidebarTabs.DecorRight then
        _G.PaperDollSidebarTabs.DecorRight:Hide()
    end

    for i = 1, #_G.PAPERDOLL_SIDEBARS do
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

    F.ReskinButton(_G.PaperDollFrameEquipSet)
    F.ReskinButton(_G.PaperDollFrameSaveSet)
    F.ReskinTrimScroll(_G.PaperDollFrame.EquipmentManagerPane.ScrollBar)

    hooksecurefunc(_G.PaperDollFrame.EquipmentManagerPane.ScrollBox, 'Update', function(self)
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

    F.ReskinIconSelector(_G.GearManagerPopupFrame)

    -- Title Pane
    F.ReskinTrimScroll(_G.PaperDollFrame.TitleManagerPane.ScrollBar)

    hooksecurefunc(_G.PaperDollFrame.TitleManagerPane.ScrollBox, 'Update', function(self)
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
                    repbar:SetStatusBarTexture(C.Assets.Textures.Backdrop)
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
    hooksecurefunc(_G.ReputationFrame.ScrollBox, 'Update', updateReputationBars)

    F.ReskinTrimScroll(_G.ReputationFrame.ScrollBar)
    F.ReskinDropdown(_G.ReputationFrame.filterDropdown)

    local detailFrame = _G.ReputationFrame.ReputationDetailFrame
    F.StripTextures(detailFrame)
    F.SetBD(detailFrame)
    F.ReskinClose(detailFrame.CloseButton)
    F.ReskinCheckbox(detailFrame.AtWarCheckbox)
    F.ReskinCheckbox(detailFrame.MakeInactiveCheckbox)
    F.ReskinCheckbox(detailFrame.WatchFactionCheckbox)
    F.ReskinButton(detailFrame.ViewRenownButton)

    -- Token frame
    if _G.TokenFramePopup.CloseButton then -- blizz typo by parentKey "CloseButton" into "$parent.CloseButton"
        F.ReskinClose(_G.TokenFramePopup.CloseButton)
    else
        F.ReskinClose((select(5, _G.TokenFramePopup:GetChildren())))
    end

    F.ReskinButton(_G.TokenFramePopup.CurrencyTransferToggleButton)
    F.ReskinCheckbox(_G.TokenFramePopup.InactiveCheckbox)
    F.ReskinCheckbox(_G.TokenFramePopup.BackpackCheckbox)

    F.ReskinArrow(_G.TokenFrame.CurrencyTransferLogToggleButton, 'right')
    F.ReskinPortraitFrame(_G.CurrencyTransferLog)
    F.ReskinTrimScroll(_G.CurrencyTransferLog.ScrollBar)

    local function handleCurrencyIcon(button)
        local icon = button.CurrencyIcon
        if icon then
            F.ReskinIcon(icon)
        end
    end
    hooksecurefunc(_G.CurrencyTransferLog.ScrollBox, 'Update', function(self)
        self:ForEachFrame(handleCurrencyIcon)
    end)

    F.ReskinPortraitFrame(_G.CurrencyTransferMenu)
    F.CreateBDFrame(_G.CurrencyTransferMenu.SourceSelector, 0.25)
    _G.CurrencyTransferMenu.SourceSelector.SourceLabel:SetWidth(56)
    F.ReskinDropdown(_G.CurrencyTransferMenu.SourceSelector.Dropdown)
    F.ReskinEditbox(_G.CurrencyTransferMenu.AmountSelector.InputBox)
    F.CreateBDFrame(_G.CurrencyTransferMenu.AmountSelector, 0.25)
    F.ReskinIcon(_G.CurrencyTransferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
    F.ReskinIcon(_G.CurrencyTransferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
    F.ReskinButton(_G.CurrencyTransferMenu.ConfirmButton)
    F.ReskinButton(_G.CurrencyTransferMenu.CancelButton)

    F.ReskinTrimScroll(_G.TokenFrame.ScrollBar)

    hooksecurefunc(_G.TokenFrame.ScrollBox, 'Update', function(self)
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

    F.StripTextures(_G.TokenFramePopup)
    F.SetBD(_G.TokenFramePopup)

    -- Quick Join
    F.ReskinTrimScroll(_G.QuickJoinFrame.ScrollBar)
    F.ReskinButton(_G.QuickJoinFrame.JoinQueueButton)

    F.SetBD(_G.QuickJoinRoleSelectionFrame)
    F.ReskinButton(_G.QuickJoinRoleSelectionFrame.AcceptButton)
    F.ReskinButton(_G.QuickJoinRoleSelectionFrame.CancelButton)
    F.ReskinClose(_G.QuickJoinRoleSelectionFrame.CloseButton)
    F.StripTextures(_G.QuickJoinRoleSelectionFrame)

    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonTank, 'TANK')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonHealer, 'HEALER')
    F.ReskinRole(_G.QuickJoinRoleSelectionFrame.RoleButtonDPS, 'DPS')
end)
