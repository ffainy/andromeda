local F, C = unpack(select(2, ...))

local function updateProgressItemQuality(self)
    local button = self.__owner
    local index = button:GetID()
    local buttonType = button.type
    local objectType = button.objectType

    local quality
    if objectType == 'item' then
        quality = select(4, GetQuestItemInfo(buttonType, index))
    elseif objectType == 'currency' then
        quality = select(4, GetQuestCurrencyInfo(buttonType, index))
    end

    local color = C.QualityColors[quality or 1]
    button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
end

tinsert(C.BlizzThemes, function()
    F.ReskinPortraitFrame(QuestFrame)

    F.StripTextures(QuestFrameDetailPanel, 0)
    F.StripTextures(QuestFrameRewardPanel, 0)
    F.StripTextures(QuestFrameProgressPanel, 0)
    F.StripTextures(QuestFrameGreetingPanel, 0)

    local line = QuestFrameGreetingPanel:CreateTexture()
    line:SetColorTexture(1, 1, 1, 0.25)
    line:SetSize(256, C.MULT)
    line:SetPoint('CENTER', QuestGreetingFrameHorizontalBreak)
    QuestGreetingFrameHorizontalBreak:SetTexture('')
    QuestFrameGreetingPanel:HookScript('OnShow', function()
        line:SetShown(QuestGreetingFrameHorizontalBreak:IsShown())
    end)

    for i = 1, MAX_REQUIRED_ITEMS do
        local button = _G['QuestProgressItem' .. i]
        button.NameFrame:Hide()
        button.bg = F.ReskinIcon(button.Icon)
        button.Icon.__owner = button
        hooksecurefunc(button.Icon, 'SetTexture', updateProgressItemQuality)

        local bg = F.CreateBDFrame(button, 0.25)
        bg:SetPoint('TOPLEFT', button.bg, 'TOPRIGHT', 2, 0)
        bg:SetPoint('BOTTOMRIGHT', button.bg, 100, 0)
    end

    QuestDetailScrollFrame:SetWidth(302) -- else these buttons get cut off

    hooksecurefunc(QuestProgressRequiredMoneyText, 'SetTextColor', function(self, r)
        if r == 0 then
            self:SetTextColor(0.8, 0.8, 0.8)
        elseif r == 0.2 then
            self:SetTextColor(1, 1, 1)
        end
    end)

    F.ReskinButton(QuestFrameAcceptButton)
    F.ReskinButton(QuestFrameDeclineButton)
    F.ReskinButton(QuestFrameCompleteQuestButton)
    F.ReskinButton(QuestFrameCompleteButton)
    F.ReskinButton(QuestFrameGoodbyeButton)
    F.ReskinButton(QuestFrameGreetingGoodbyeButton)

    F.ReskinTrimScroll(QuestProgressScrollFrame.ScrollBar)
    F.ReskinTrimScroll(QuestRewardScrollFrame.ScrollBar)
    F.ReskinTrimScroll(QuestDetailScrollFrame.ScrollBar)
    F.ReskinTrimScroll(QuestGreetingScrollFrame.ScrollBar)

    -- Text colour stuff

    QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0)
    QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
    QuestProgressRequiredItemsText.SetTextColor = nop
    QuestProgressTitleText:SetTextColor(1, 0.8, 0)
    QuestProgressTitleText:SetShadowColor(0, 0, 0)
    QuestProgressTitleText.SetTextColor = nop
    QuestProgressText:SetTextColor(1, 1, 1)
    QuestProgressText.SetTextColor = nop
    GreetingText:SetTextColor(1, 1, 1)
    GreetingText.SetTextColor = nop
    AvailableQuestsText:SetTextColor(1, 0.8, 0)
    AvailableQuestsText.SetTextColor = nop
    AvailableQuestsText:SetShadowColor(0, 0, 0)
    CurrentQuestsText:SetTextColor(1, 1, 1)
    CurrentQuestsText.SetTextColor = nop
    CurrentQuestsText:SetShadowColor(0, 0, 0)

    -- Quest NPC model

    F.StripTextures(QuestModelScene)
    local bg = F.SetBD(QuestModelScene)

    F.StripTextures(QuestModelScene.ModelTextFrame)
    bg:SetOutside(nil, nil, nil, QuestModelScene.ModelTextFrame)

    if QuestNPCModelTextScrollFrame then
        F.ReskinTrimScroll(QuestNPCModelTextScrollFrame.ScrollBar)
    end

    hooksecurefunc('QuestFrame_ShowQuestPortrait', function(parentFrame, _, _, _, _, _, x, y)
        x = x + 6
        QuestModelScene:SetPoint('TOPLEFT', parentFrame, 'TOPRIGHT', x, y)
    end)

    -- Friendship

    for i = 1, 4 do
        local notch = QuestFrame.FriendshipStatusBar['Notch' .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(C.MULT, 16)
        end
    end

    QuestFrame.FriendshipStatusBar.BarBorder:Hide()
end)
