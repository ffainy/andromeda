local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local r, g, b = C.r, C.g, C.b

    local frame = _G.GroupLootHistoryFrame
    if not frame then
        return
    end

    F.StripTextures(frame)
    F.SetBD(frame)
    F.ReskinClose(frame.ClosePanelButton)
    F.ReskinTrimScroll(frame.ScrollBar)
    F.ReskinDropdown(frame.EncounterDropdown)

    local bar = frame.Timer
    if bar then
        F.StripTextures(bar)
        F.CreateBDFrame(bar, 0.25)
        bar.Fill:SetTexture(C.Assets.Textures.StatusbarNormal)
        bar.Fill:SetVertexColor(r, g, b)
    end

    -- [[ Resize button ]]

    F.StripTextures(frame.ResizeButton)
    frame.ResizeButton:SetHeight(8)

    local line1 = frame.ResizeButton:CreateTexture()
    line1:SetTexture(C.Assets.Textures.Backdrop)
    line1:SetVertexColor(0.7, 0.7, 0.7)
    line1:SetSize(30, C.MULT)
    line1:SetPoint('TOP', 0, -2)
    local line2 = frame.ResizeButton:CreateTexture()
    line2:SetTexture(C.Assets.Textures.Backdrop)
    line2:SetVertexColor(0.7, 0.7, 0.7)
    line2:SetSize(30, C.MULT)
    line2:SetPoint('TOP', 0, -5)

    frame.ResizeButton:HookScript('OnEnter', function()
        line1:SetVertexColor(r, g, b)
        line2:SetVertexColor(r, g, b)
    end)
    frame.ResizeButton:HookScript('OnLeave', function()
        line1:SetVertexColor(0.7, 0.7, 0.7)
    end)

    -- [[ Item frame ]]

    local function ReskinLootButton(button)
        if not button.styled then
            if button.BackgroundArtFrame then
                button.BackgroundArtFrame.NameFrame:SetAlpha(0)
                button.BackgroundArtFrame.BorderFrame:SetAlpha(0)
                F.CreateBDFrame(button.BackgroundArtFrame.BorderFrame, 0.25)
            end

            local item = button.Item
            if item then
                F.StripTextures(item, 1)
                item.bg = F.ReskinIcon(item.icon)
                item.bg:SetFrameLevel(item.bg:GetFrameLevel() + 1)
                F.ReskinIconBorder(item.IconBorder, true)
            end

            button.styled = true
        end
    end

    hooksecurefunc(frame.ScrollBox, 'Update', function(self)
        self:ForEachFrame(ReskinLootButton)
    end)
end)
