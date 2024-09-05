local F, C = unpack(select(2, ...))

C.Themes['Blizzard_MacroUI'] = function()
    MacroHorizontalBarLeft:Hide()
    F.StripTextures(MacroFrameTab1)
    F.StripTextures(MacroFrameTab2)

    F.StripTextures(MacroPopupFrame)
    F.StripTextures(MacroPopupFrame.BorderBox)
    MacroFrameTextBackground:HideBackdrop()

    MacroPopupFrame:SetHeight(525)

    F.ReskinTrimScroll(MacroFrame.MacroSelector.ScrollBar)

    local function handleMacroButton(button)
        local bg = F.ReskinIcon(button.Icon)
        button:DisableDrawLayer('BACKGROUND')
        button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.5)
        button.SelectedTexture:SetInside(bg)
        local hl = button:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside(bg)
    end
    handleMacroButton(MacroFrameSelectedMacroButton)

    hooksecurefunc(MacroFrame.MacroSelector.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                handleMacroButton(child)

                child.styled = true
            end
        end
    end)

    F.ReskinIconSelector(MacroPopupFrame)
    F.ReskinPortraitFrame(MacroFrame)
    F.CreateBDFrame(MacroFrameScrollFrame, 0.25)
    F.ReskinTrimScroll(MacroFrameScrollFrame.ScrollBar)
    F.ReskinButton(MacroEditButton)
    F.ReskinButton(MacroSaveButton)
    F.ReskinButton(MacroCancelButton)

    MacroDeleteButton:SetWidth(70)
    F.ReskinButton(MacroDeleteButton)
    MacroNewButton:SetWidth(70)
    MacroNewButton:ClearAllPoints()
    MacroNewButton:SetPoint('RIGHT', MacroExitButton, 'LEFT', -5, 0)
    F.ReskinButton(MacroNewButton)
    MacroExitButton:SetWidth(70)
    F.ReskinButton(MacroExitButton)

    -- compat MacroToolkit
    if _G['MacroToolkitOpen'] then
        _G['MacroToolkitOpen']:ClearAllPoints()
        _G['MacroToolkitOpen']:SetPoint('LEFT', MacroDeleteButton, 'RIGHT', 5, 0)
        F.ReskinButton(_G['MacroToolkitOpen'])
    end
end
