local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function updateButtonBorder(self)
    if not self.bg then
        return
    end

    if self.objectType == 'item' then
        local quality = select(4, GetQuestItemInfo(self.type, self:GetID()))
        local color = C.QualityColors[quality or 1]
        self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    elseif self.objectType == 'currency' then
        local quality = self.currencyInfo and self.currencyInfo.quality
        local color = C.QualityColors[quality or 1]
        self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    else
        self.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function handleIcon(self)
    if not self.textBg then
        self.Border:Hide()
        self.Mask:Hide()
        self.NameFrame:Hide()

        self.bg = F.ReskinIcon(self.Icon)

        self.textBg = F.CreateBDFrame(self, .25)
        self.textBg:ClearAllPoints()
        self.textBg:SetPoint('TOPLEFT', self.bg, 'TOPRIGHT', 2, 0)
        self.textBg:SetPoint('RIGHT', -5, 0)
        self.textBg:SetPoint('BOTTOM', self.bg, 'BOTTOM')
    end
end

local function handleButtons(buttons)
    for i = 1, #buttons do
        local button = buttons[i]
        handleIcon(button)
        updateButtonBorder(button)
    end
end

local function handleTitleButton(self, index)
    local button = self.Buttons[index]
    if button and not button.styled then
        F.StripTextures(button)
        F.StripTextures(button.Hilite)
        local HL = F.CreateBDFrame(button.Hilite, 0)
        HL:SetAllPoints(button)
        HL:SetBackdropColor(C.r, C.g, C.b, .25)
        HL:SetBackdropBorderColor(C.r, C.g, C.b, 1)
        local bg = F.SetBD(button)
        bg:SetAllPoints()
        button.Overlay:Hide()

        if index > 1 then
            button:ClearAllPoints()
            button:SetPoint('TOP', self.Buttons[index - 1], 'BOTTOM', 0, -3)
        end

        button.styled = true
    end
end

local function handleQuestInfo(self)
    local rewardsFrame = self.TalkBox.Elements.Content.RewardsFrame

    -- Item Rewards
    handleButtons(rewardsFrame.Buttons)

    -- Honor Rewards
    local honorFrame = rewardsFrame.HonorFrame
    if honorFrame then
        handleIcon(honorFrame)
    end

    -- Title Rewards
    local titleFrame = rewardsFrame.TitleFrame
    if titleFrame and not titleFrame.textBg then
        local icon = titleFrame.Icon
        F.StripTextures(titleFrame, 0)
        icon:SetAlpha(1)
        F.ReskinIcon(icon)
        titleFrame.textBg = F.CreateBDFrame(titleFrame, .25)
        titleFrame.textBg:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 2, C.MULT)
        titleFrame.textBg:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 216, -C.MULT)
    end

    -- ArtifactXP Rewards
    local artifactXPFrame = rewardsFrame.ArtifactXPFrame
    if artifactXPFrame then
        handleIcon(artifactXPFrame)
        artifactXPFrame.Overlay:SetAlpha(0)
    end

    -- Skill Point Rewards
    local skillPointFrame = rewardsFrame.SkillPointFrame
    if skillPointFrame then
        handleIcon(skillPointFrame)
    end

    local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(GetQuestID()) or {}
    if #spellRewards > 0 then
        -- Follower Rewards
        for reward in rewardsFrame.followerRewardPool:EnumerateActive() do
            local portrait = reward.PortraitFrame
            if not reward.styled then
                F.ReskinGarrisonPortrait(portrait)
                reward.BG:Hide()
                portrait:SetPoint('TOPLEFT', 2, -5)
                reward.textBg = F.CreateBDFrame(reward, .25)
                reward.textBg:SetPoint('TOPLEFT', 0, -3)
                reward.textBg:SetPoint('BOTTOMRIGHT', 2, 7)
                reward.Class:SetPoint('TOPRIGHT', reward.textBg, 'TOPRIGHT', -C.MULT, -C.MULT)
                reward.Class:SetPoint('BOTTOMRIGHT', reward.textBg, 'BOTTOMRIGHT', -C.MULT, C.MULT)

                reward.styled = true
            end

            local color = C.QualityColors[portrait.quality or 1]
            portrait.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
            reward.Class:SetTexCoord(unpack(C.TEX_COORD))
        end

        -- Spell Rewards
        for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
            if not spellReward.textBg then
                local icon = spellReward.Icon
                local nameFrame = spellReward.NameFrame
                F.ReskinIcon(icon)
                nameFrame:Hide()
                spellReward.textBg = F.CreateBDFrame(nameFrame, .25)
                spellReward.textBg:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 2, C.MULT)
                spellReward.textBg:SetPoint('BOTTOMRIGHT', nameFrame, 'BOTTOMRIGHT', -24, 15)
            end
        end
    end
end

local function handleQuestProgress(self)
    handleButtons(self.TalkBox.Elements.Progress.Buttons)
end

local function handleItems(self)
    for tooltip in self.Inspector.tooltipFramePool:EnumerateActive() do
        if not tooltip.styled then
            tooltip:HideBackdrop()
            local bg = F.SetBD(tooltip)
            bg:SetPoint('TOPLEFT', 0, 0)
            bg:SetPoint('BOTTOMRIGHT', 6, 0)
            tooltip.Icon.Border:SetAlpha(0)
            F.ReskinIcon(tooltip.Icon.Texture)
            tooltip.Hilite:SetOutside(bg, 2, 2)

            tooltip.styled = true
        end
    end
end

local function handleText()
    local text = _G['ImmersionFrame'].TalkBox.TextFrame.SpeechProgress
    text:SetFont(C.Assets.Fonts.Bold, 16)
end

local function reskinImmersion()
    local ImmersionFrame = _G['ImmersionFrame']
    if not ImmersionFrame then
        return
    end

    if not ANDROMEDA_ADB.ReskinImmersion then
        return
    end

    local TalkBox = ImmersionFrame.TalkBox
    F.StripTextures(TalkBox.PortraitFrame)
    F.StripTextures(TalkBox.BackgroundFrame)
    F.StripTextures(TalkBox.Hilite)
    hooksecurefunc(TalkBox.TextFrame.Text, 'OnDisplayLineCallback', handleText)

    local hilite = F.CreateBDFrame(TalkBox.Hilite, 0)
    hilite:SetAllPoints(TalkBox)
    hilite:SetBackdropColor(C.r, C.g, C.b, .25)
    hilite:SetBackdropBorderColor(C.r, C.g, C.b, 1)

    local Elements = TalkBox.Elements
    F.StripTextures(Elements)
    F.SetBD(Elements, nil, 0, -10, 0, 0)
    Elements.Content.RewardsFrame.ItemHighlight.Icon:SetAlpha(0)

    local MainFrame = TalkBox.MainFrame
    F.StripTextures(MainFrame)
    F.SetBD(MainFrame)
    F.ReskinClose(MainFrame.CloseButton)
    F.StripTextures(MainFrame.Model)

    local ModelBG = F.CreateBDFrame(MainFrame.Model, 0)
    ModelBG:SetFrameLevel(MainFrame.Model:GetFrameLevel() + 1)

    local ReputationBar = TalkBox.ReputationBar
    ReputationBar.icon:SetPoint('TOPLEFT', -30, 6)
    F.StripTextures(ReputationBar)
    ReputationBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    F.CreateBDFrame(ReputationBar, .25)

    for i = 1, 4 do
        local notch = _G['ImmersionFrameNotch' .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(C.MULT, 16)
        end
    end

    local Indicator = MainFrame.Indicator
    Indicator:SetScale(1.25)
    Indicator:ClearAllPoints()
    Indicator:SetPoint('RIGHT', MainFrame.CloseButton, 'LEFT', -3, 0)

    hooksecurefunc(ImmersionFrame.TitleButtons, 'GetButton', handleTitleButton)
    hooksecurefunc(ImmersionFrame, 'AddQuestInfo', handleQuestInfo)
    hooksecurefunc(ImmersionFrame, 'QUEST_PROGRESS', handleQuestProgress)
    hooksecurefunc(ImmersionFrame, 'ShowItems', handleItems)
end

THEME:RegisterSkin('Immersion', reskinImmersion)
