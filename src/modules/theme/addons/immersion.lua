local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function updateItemBorder(self)
    if not self.bg then
        return
    end

    if self.objectType == 'item' then
        local quality = select(4, GetQuestItemInfo(self.type, self:GetID()))
        local color = C.QualityColors[quality or 1]
        self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    elseif self.objectType == 'currency' then
        local name, texture, numItems, quality = GetQuestCurrencyInfo(self.type, self:GetID())
        local currencyID = GetQuestCurrencyID(self.type, self:GetID())
        if name and texture and numItems and quality and currencyID then
            local currencyQuality = select(4,
                CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numItems, name, texture, quality))
            local color = C.QualityColors[currencyQuality or 1]
            self.bg:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    else
        self.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function reskinItemButton(buttons)
    for i = 1, #buttons do
        local button = buttons[i]
        if button and not button.styled then
            button.Border:Hide()
            button.Mask:Hide()
            button.NameFrame:Hide()
            button.bg = F.ReskinIcon(button.Icon)
            button.textBg = F.CreateBDFrame(button, 0.25)
            button.textBg:SetPoint('TOPLEFT', button.bg, 'TOPRIGHT', 2, 0)
            button.textBg:SetPoint('BOTTOMRIGHT', -5, 1)

            button.styled = true
        end
        updateItemBorder(button)
    end
end

local function reskinTitleButton(self, index)
    local button = self.Buttons[index]
    if button and not button.styled then
        F.StripTextures(button)
        F.ReskinButton(button)
        button.Overlay:Hide()
        button.Hilite:Hide()

        if index > 1 then
            button:ClearAllPoints()
            button:SetPoint('TOP', self.Buttons[index - 1], 'BOTTOM', 0, -3)
        end

        button.styled = true
    end
end

local function reskinReward(self)
    local rewardsFrame = self.TalkBox.Elements.Content.RewardsFrame
    reskinItemButton(rewardsFrame.Buttons)

    local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(GetQuestID()) or {}
    if #spellRewards > 0 then
        -- follower
        for reward in rewardsFrame.followerRewardPool:EnumerateActive() do
            local portrait = reward.PortraitFrame
            if not reward.styled then
                F.ReskinGarrisonPortrait(portrait)
                reward.BG:Hide()
                portrait:SetPoint('TOPLEFT', 2, -5)
                reward.textBg = F.CreateBDFrame(reward, 0.25)
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

        -- spell
        for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
            if not spellReward.styled then
                local icon = spellReward.Icon
                F.ReskinIcon(icon)

                local nameFrame = spellReward.NameFrame
                nameFrame:Hide()

                local bg = F.CreateBDFrame(nameFrame, 0.25)
                bg:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 2, 1)
                bg:SetPoint('BOTTOMRIGHT', nameFrame, 'BOTTOMRIGHT', -24, 15)

                spellReward.styled = true
            end
        end
    end
end

local function reskinProgress(self)
    reskinItemButton(self.TalkBox.Elements.Progress.Buttons)
end

local function reskinTooltip(self)
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

local function reskinImmersion()
    if not _G.ANDROMEDA_ADB.ReskinImmersion then
        return
    end

    local cr, cg, cb = C.r, C.g, C.b

    local talkBox = _G['ImmersionFrame'].TalkBox
    F.StripTextures(talkBox.PortraitFrame)
    F.StripTextures(talkBox.BackgroundFrame)
    F.StripTextures(talkBox.Hilite)

    local hilite = F.CreateBDFrame(talkBox.Hilite, 0)
    hilite:SetAllPoints(talkBox)
    hilite:SetBackdropColor(cr, cg, cb, 0.25)
    hilite:SetBackdropBorderColor(cr, cg, cb, 1)

    local mainFrame = talkBox.MainFrame
    F.StripTextures(mainFrame)
    F.SetBD(mainFrame)

    local elements = talkBox.Elements
    F.StripTextures(elements)
    F.SetBD(elements, 0.45, 0, -12, 0, 0)
    elements.Content.RewardsFrame.ItemHighlight.Icon:SetAlpha(0)

    F.ReskinClose(mainFrame.CloseButton)
    F.StripTextures(mainFrame.Model)
    local bg = F.CreateBDFrame(mainFrame.Model, 0)
    bg:SetFrameLevel(mainFrame.Model:GetFrameLevel() + 1)

    local reputationBar = talkBox.ReputationBar
    reputationBar.icon:SetPoint('TOPLEFT', -30, 6)
    F.StripTextures(reputationBar)
    reputationBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    F.CreateBDFrame(reputationBar, 0.25)

    for i = 1, 4 do
        local notch = _G['ImmersionFrameNotch' .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(C.MULT, 16)
        end
    end

    local indicator = mainFrame.Indicator
    indicator:SetScale(1)
    indicator:ClearAllPoints()
    indicator:SetPoint('RIGHT', mainFrame.CloseButton, 'LEFT', -3, 0)

    local titleButtons = _G['ImmersionFrame'].TitleButtons
    hooksecurefunc(titleButtons, 'GetButton', reskinTitleButton)

    hooksecurefunc(_G['ImmersionFrame'], 'AddQuestInfo', reskinReward)
    hooksecurefunc(_G['ImmersionFrame'], 'QUEST_PROGRESS', reskinProgress)
    hooksecurefunc(_G['ImmersionFrame'], 'ShowItems', reskinTooltip)
end

THEME:RegisterSkin('Immersion', reskinImmersion)
