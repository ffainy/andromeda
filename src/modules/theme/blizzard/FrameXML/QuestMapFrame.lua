local F, C = unpack(select(2, ...))

local function reskinQuestHeader(header, isCalling)
    if header.styled then
        return
    end

    if header.Background then
        header.Background:SetAlpha(0.7)
    end
    if header.Divider then
        header.Divider:Hide()
    end
    if header.TopFiligree then
        header.TopFiligree:Hide()
    end

    header.styled = true
end

local function reskinSessionDialog(_, dialog)
    if not dialog.styled then
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinButton(dialog.ButtonContainer.Confirm)
        F.ReskinButton(dialog.ButtonContainer.Decline)
        if dialog.MinimizeButton then
            F.ReskinArrow(dialog.MinimizeButton, 'down')
        end

        dialog.styled = true
    end
end

local function reskinAWQHeader()
    if C_AddOns.IsAddOnLoaded('AngrierWorldQuests') then
        local button = _G['AngrierWorldQuestsHeader']
        if button and not button.styled then
            F.ReskinCollapse(button, true)
            button:GetPushedTexture():SetAlpha(0)
            button:GetHighlightTexture():SetAlpha(0)

            button.styled = true
        end
    end
end

tinsert(C.BlizzThemes, function()
    -- Quest frame

    local QuestMapFrame = _G.QuestMapFrame
    QuestMapFrame.VerticalSeparator:SetAlpha(0)

    local QuestScrollFrame = _G.QuestScrollFrame
    QuestScrollFrame.Contents.Separator:SetAlpha(0)
    reskinQuestHeader(QuestScrollFrame.Contents.StoryHeader)

    QuestScrollFrame.Background:SetAlpha(0)
    F.StripTextures(QuestScrollFrame.BorderFrame)
    F.StripTextures(QuestMapFrame.DetailsFrame.BackFrame)

    local campaignOverview = QuestMapFrame.CampaignOverview
    campaignOverview.BG:SetAlpha(0)
    reskinQuestHeader(campaignOverview.Header)

    QuestScrollFrame.Edge:Hide()
    F.ReskinTrimScroll(QuestScrollFrame.ScrollBar)
    F.ReskinTrimScroll(campaignOverview.ScrollFrame.ScrollBar)

    -- Quest details

    local DetailsFrame = QuestMapFrame.DetailsFrame
    local CompleteQuestFrame = DetailsFrame.CompleteQuestFrame

    F.StripTextures(DetailsFrame)
    F.StripTextures(DetailsFrame.ShareButton)
    DetailsFrame.Bg:SetAlpha(0)
    DetailsFrame.SealMaterialBG:SetAlpha(0)

    F.ReskinButton(DetailsFrame.AbandonButton)
    F.ReskinButton(DetailsFrame.ShareButton)
    F.ReskinButton(DetailsFrame.TrackButton)
    F.ReskinTrimScroll(_G.QuestMapDetailsScrollFrame.ScrollBar)

    F.ReskinButton(DetailsFrame.BackFrame.BackButton)
    F.StripTextures(DetailsFrame.RewardsFrameContainer.RewardsFrame)

    DetailsFrame.AbandonButton:ClearAllPoints()
    DetailsFrame.AbandonButton:SetPoint('BOTTOMLEFT', DetailsFrame, -1, 0)
    DetailsFrame.AbandonButton:SetWidth(95)

    DetailsFrame.ShareButton:ClearAllPoints()
    DetailsFrame.ShareButton:SetPoint('LEFT', DetailsFrame.AbandonButton, 'RIGHT', 1, 0)
    DetailsFrame.ShareButton:SetWidth(94)

    DetailsFrame.TrackButton:ClearAllPoints()
    DetailsFrame.TrackButton:SetPoint('LEFT', DetailsFrame.ShareButton, 'RIGHT', 1, 0)
    DetailsFrame.TrackButton:SetWidth(96)

    -- Scroll frame

    hooksecurefunc('QuestLogQuests_Update', function()
        for button in QuestScrollFrame.headerFramePool:EnumerateActive() do
            if button.ButtonText then
                if not button.styled then
                    F.ReskinCollapse(button, true)
                    button:GetPushedTexture():SetAlpha(0)
                    button:GetHighlightTexture():SetAlpha(0)

                    button.styled = true
                end
            end
        end

        for button in QuestScrollFrame.titleFramePool:EnumerateActive() do
            if not button.styled then
                if button.Checkbox then
                    F.StripTextures(button.Checkbox, 2)
                    F.CreateBDFrame(button.Checkbox, 0, true)
                end
                button.styled = true
            end
        end

        for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
            reskinQuestHeader(header)
        end

        for header in QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
            if header.CollapseButton and not header.styled then
                F.StripTextures(header)
                F.CreateBDFrame(header.Background, 0.25)
                header.Highlight:SetColorTexture(1, 1, 1, 0.25)
                header.styled = true
            end
        end

        for header in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
            reskinQuestHeader(header, true)
        end

        reskinAWQHeader()
    end)

    -- Map legend
    local mapLegend = QuestMapFrame.MapLegend
    if mapLegend then
        F.StripTextures(mapLegend.BorderFrame)
        F.ReskinButton(mapLegend.BackButton)
        F.ReskinTrimScroll(mapLegend.ScrollFrame.ScrollBar)
        F.StripTextures(mapLegend.ScrollFrame)
        F.CreateBDFrame(mapLegend.ScrollFrame, 0.25)
    end

    -- [[ Quest log popup detail frame ]]

    local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame

    F.ReskinPortraitFrame(QuestLogPopupDetailFrame)
    F.ReskinButton(QuestLogPopupDetailFrame.AbandonButton)
    F.ReskinButton(QuestLogPopupDetailFrame.TrackButton)
    F.ReskinButton(QuestLogPopupDetailFrame.ShareButton)
    QuestLogPopupDetailFrame.SealMaterialBG:SetAlpha(0)
    F.ReskinTrimScroll(_G.QuestLogPopupDetailFrameScrollFrame.ScrollBar)

    -- Show map button

    local ShowMapButton = QuestLogPopupDetailFrame.ShowMapButton

    ShowMapButton.Texture:SetAlpha(0)
    ShowMapButton.Highlight:SetTexture('')
    ShowMapButton.Highlight:SetTexture('')

    ShowMapButton:SetSize(ShowMapButton.Text:GetStringWidth() + 14, 22)
    ShowMapButton.Text:ClearAllPoints()
    ShowMapButton.Text:SetPoint('CENTER', 1, 0)

    ShowMapButton:ClearAllPoints()
    ShowMapButton:SetPoint('TOPRIGHT', QuestLogPopupDetailFrame, -30, -25)

    F.ReskinButton(ShowMapButton)

    ShowMapButton:HookScript('OnEnter', function(self)
        self.Text:SetTextColor(1, 1, 1)
    end)

    ShowMapButton:HookScript('OnLeave', function(self)
        self.Text:SetTextColor(1, 0.8, 0)
    end)

    -- Bottom buttons

    QuestLogPopupDetailFrame.ShareButton:ClearAllPoints()
    QuestLogPopupDetailFrame.ShareButton:SetPoint('LEFT', QuestLogPopupDetailFrame.AbandonButton, 'RIGHT', 1, 0)
    QuestLogPopupDetailFrame.ShareButton:SetPoint('RIGHT', QuestLogPopupDetailFrame.TrackButton, 'LEFT', -1, 0)

    -- Party Sync button

    local sessionManagement = QuestMapFrame.QuestSessionManagement
    sessionManagement.BG:Hide()
    F.CreateBDFrame(sessionManagement, 0.25)

    hooksecurefunc(_G.QuestSessionManager, 'NotifyDialogShow', reskinSessionDialog)

    local executeSessionCommand = sessionManagement.ExecuteSessionCommand
    F.ReskinButton(executeSessionCommand)

    local icon = executeSessionCommand:CreateTexture(nil, 'ARTWORK')
    icon:SetInside()
    executeSessionCommand.normalIcon = icon

    local sessionCommandToButtonAtlas = {
        [_G.Enum.QuestSessionCommand.Start] = 'QuestSharing-DialogIcon',
        [_G.Enum.QuestSessionCommand.Stop] = 'QuestSharing-Stop-DialogIcon',
    }

    hooksecurefunc(QuestMapFrame.QuestSessionManagement, 'UpdateExecuteCommandAtlases', function(self, command)
        self.ExecuteSessionCommand:SetNormalTexture(0)
        self.ExecuteSessionCommand:SetPushedTexture(0)
        self.ExecuteSessionCommand:SetDisabledTexture(0)

        local atlas = sessionCommandToButtonAtlas[command]
        if atlas then
            self.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
        end
    end)
end)
