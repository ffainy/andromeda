local F, C = unpack(select(2, ...))

local function resetToggleTexture(button, texture)
    button:GetNormalTexture():SetTexCoord(unpack(C.TEX_COORD))
    button:GetNormalTexture():SetInside()
    button:SetNormalTexture(texture)
    button:GetPushedTexture():SetTexCoord(unpack(C.TEX_COORD))
    button:GetPushedTexture():SetInside()
    button:SetPushedTexture(texture)
end

tinsert(C.BlizzThemes, function()
    -- Dressup Frame

    local DressUpFrame = _G.DressUpFrame

    F.ReskinPortraitFrame(DressUpFrame)
    F.ReskinButton(_G.DressUpFrameCancelButton)
    F.ReskinButton(_G.DressUpFrameResetButton)
    F.ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)
    F.ReskinButton(DressUpFrame.LinkButton)
    F.ReskinButton(DressUpFrame.ToggleOutfitDetailsButton)
    resetToggleTexture(DressUpFrame.ToggleOutfitDetailsButton, 1392954) -- 70_professions_scroll_01

    F.StripTextures(DressUpFrame.OutfitDetailsPanel)
    local bg = F.SetBD(DressUpFrame.OutfitDetailsPanel)
    bg:SetInside(nil, 11, 11)

    hooksecurefunc(DressUpFrame.OutfitDetailsPanel, 'Refresh', function(self)
        if self.slotPool then
            for slot in self.slotPool:EnumerateActive() do
                if not slot.bg then
                    slot.bg = F.ReskinIcon(slot.Icon)
                    F.ReskinIconBorder(slot.IconBorder, true, true)
                end
            end
        end
    end)

    _G.DressUpFrameResetButton:SetPoint('RIGHT', _G.DressUpFrameCancelButton, 'LEFT', -1, 0)

    DressUpFrame.ModelBackground:Hide()
    F.CreateBDFrame(DressUpFrame.ModelScene)

    F.ReskinCheckbox(_G.TransmogAndMountDressupFrame.ShowMountCheckButton)
    F.ReskinModelControl(DressUpFrame.ModelScene)

    local selectionPanel = DressUpFrame.SetSelectionPanel
    if selectionPanel then
        F.StripTextures(selectionPanel)
        F.SetBD(selectionPanel):SetInside(nil, 9, 9)

        local function SetupSetButton(button)
            if button.styled then
                return
            end
            button.bg = F.ReskinIcon(button.Icon)
            F.ReskinIconBorder(button.IconBorder, true, true)
            button.BackgroundTexture:SetAlpha(0)
            button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.25)
            button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
            button.styled = true
        end

        hooksecurefunc(selectionPanel.ScrollBox, 'Update', function(self)
            self:ForEachFrame(SetupSetButton)
        end)
    end

    F.ReskinDropdown(_G.DressUpFrameOutfitDropdown)
    F.ReskinButton(_G.DressUpFrameOutfitDropdown.SaveButton)

    -- SideDressUp

    F.StripTextures(_G.SideDressUpFrame, 0)
    F.SetBD(_G.SideDressUpFrame)
    F.ReskinButton(_G.SideDressUpFrame.ResetButton)
    F.ReskinClose(_G.SideDressUpFrameCloseButton)

    _G.SideDressUpFrame:HookScript('OnShow', function(self)
        _G.SideDressUpFrame:ClearAllPoints()
        _G.SideDressUpFrame:SetPoint('LEFT', self:GetParent(), 'RIGHT', 3, 0)
    end)

    -- Outfit frame

    F.StripTextures(_G.WardrobeOutfitEditFrame)
    _G.WardrobeOutfitEditFrame.EditBox:DisableDrawLayer('BACKGROUND')
    F.SetBD(_G.WardrobeOutfitEditFrame)
    local ebbg = F.CreateBDFrame(_G.WardrobeOutfitEditFrame.EditBox, 0.25, true)
    ebbg:SetPoint('TOPLEFT', -5, -3)
    ebbg:SetPoint('BOTTOMRIGHT', 5, 3)
    F.ReskinButton(_G.WardrobeOutfitEditFrame.AcceptButton)
    F.ReskinButton(_G.WardrobeOutfitEditFrame.CancelButton)
    F.ReskinButton(_G.WardrobeOutfitEditFrame.DeleteButton)
end)
