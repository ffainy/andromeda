local F, C = unpack(select(2, ...))

local function reskinTalentFrameDialog(dialog)
    F.StripTextures(dialog)
    F.SetBD(dialog)
    if dialog.AcceptButton then
        F.ReskinButton(dialog.AcceptButton)
    end
    if dialog.CancelButton then
        F.ReskinButton(dialog.CancelButton)
    end
    if dialog.DeleteButton then
        F.ReskinButton(dialog.DeleteButton)
    end

    F.ReskinEditbox(dialog.NameControl.EditBox)
    dialog.NameControl.EditBox.__bg:SetPoint('TOPLEFT', -5, -10)
    dialog.NameControl.EditBox.__bg:SetPoint('BOTTOMRIGHT', 5, 10)
end

C.Themes['Blizzard_PlayerSpells'] = function()
    local frame = PlayerSpellsFrame

    frame.SpellBookFrame.HelpPlateButton:Hide()

    F.ReskinPortraitFrame(frame)
    F.ReskinButton(frame.TalentsFrame.ApplyButton)
    F.ReskinDropdown(frame.TalentsFrame.LoadSystem.Dropdown)
    F.ReskinButton(frame.TalentsFrame.InspectCopyButton)
    F.ReskinMinMax(frame.MaximizeMinimizeButton)

    frame.SpecFrame.BlackBG:SetAlpha(0)
    frame.SpecFrame.Background:SetAlpha(0)

    frame.TalentsFrame.BlackBG:SetAlpha(0)
    frame.TalentsFrame.Background:SetAlpha(0)
    frame.TalentsFrame.BottomBar:SetAlpha(0)

    F.ReskinEditbox(frame.TalentsFrame.SearchBox)
    frame.TalentsFrame.SearchBox.__bg:SetPoint('TOPLEFT', -4, -5)
    frame.TalentsFrame.SearchBox.__bg:SetPoint('BOTTOMRIGHT', 0, 5)

    for i = 1, 3 do
        local tab = select(i, frame.TabSystem:GetChildren())
        F.ReskinTab(tab)
    end

    hooksecurefunc(frame.SpecFrame, 'UpdateSpecFrame', function(self)
        for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
            if not specContentFrame.styled then
                F.ReskinButton(specContentFrame.ActivateButton)

                local role = GetSpecializationRole(specContentFrame.specIndex)
                if role then
                    F.ReskinSmallRole(specContentFrame.RoleIcon, role)
                end

                if specContentFrame.SpellButtonPool then
                    for button in specContentFrame.SpellButtonPool:EnumerateActive() do
                        button.Ring:Hide()
                        F.ReskinIcon(button.Icon)

                        local texture = button.spellID and C_Spell.GetSpellTexture(button.spellID)
                        if texture then
                            button.Icon:SetTexture(texture)
                        end
                    end
                end

                specContentFrame.styled = true
            end
        end
    end)

    local id = ClassTalentLoadoutImportDialog
    if id then
        reskinTalentFrameDialog(id)
        F.StripTextures(id.ImportControl.InputContainer)
        F.CreateBDFrame(id.ImportControl.InputContainer, 0.25)
    end

    local cd = ClassTalentLoadoutCreateDialog
    if cd then
        reskinTalentFrameDialog(cd)
    end

    local ed = ClassTalentLoadoutEditDialog
    if ed then
        reskinTalentFrameDialog(ed)

        local editbox = ed.LoadoutName
        if editbox then
            F.ReskinEditbox(editbox)
            editbox.__bg:SetPoint('TOPLEFT', -5, -5)
            editbox.__bg:SetPoint('BOTTOMRIGHT', 5, 5)
        end

        local check = ed.UsesSharedActionBars
        if check then
            F.ReskinCheckbox(check.CheckButton)
            check.CheckButton.bg:SetInside(nil, 6, 6)
        end
    end

    local dialog = HeroTalentsSelectionDialog
    if dialog then
        F.StripTextures(dialog)
        F.SetBD(dialog, 1)
        F.ReskinClose(dialog.CloseButton)

        hooksecurefunc(dialog, 'ShowDialog', function(self)
            for specFrame in self.SpecContentFramePool:EnumerateActive() do
                if not specFrame.styled then
                    F.ReskinButton(specFrame.ActivateButton)
                    F.ReskinButton(specFrame.ApplyChangesButton)
                    specFrame.styled = true
                end
            end
        end)
    end

    local spellBook = PlayerSpellsFrame.SpellBookFrame
    if spellBook then
        spellBook.TopBar:Hide()
        spellBook.BookBGLeft:SetAlpha(0)
        spellBook.BookBGRight:SetAlpha(0)
        spellBook.BookBGHalved:SetAlpha(0)
        spellBook.Bookmark:SetAlpha(0)
        spellBook.BookCornerFlipbook:Hide()

        for i = 1, 3 do
            local tab = select(i, spellBook.CategoryTabSystem:GetChildren())
            F.ReskinTab(tab)
        end
        F.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.PrevPageButton, 'left')
        F.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.NextPageButton, 'right')
        spellBook.PagedSpellsFrame.PagingControls.PageText:SetTextColor(1, 1, 1)

        F.ReskinCheckbox(spellBook.HidePassivesCheckButton.Button)
        F.ReskinEditbox(spellBook.SearchBox)
        spellBook.SearchBox.__bg:SetPoint('TOPLEFT', -5, -3)
        spellBook.SearchBox.__bg:SetPoint('BOTTOMRIGHT', 2, 3)

        hooksecurefunc(spellBook.PagedSpellsFrame, 'DisplayViewsForCurrentPage', function(self)
            for _, frame in self:EnumerateFrames() do
                if not frame.styled then
                    if frame.Text then
                        frame.Text:SetTextColor(1, 0.8, 0)
                    end
                    if frame.Name then
                        frame.Name:SetTextColor(1, 1, 1)
                    end
                    if frame.SubName then
                        frame.SubName:SetTextColor(0.7, 0.7, 0.7)
                    end

                    frame.styled = true
                end
            end
        end)
    end
end
