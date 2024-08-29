local F, C = unpack(select(2, ...))

local Type_ItemDisplay = Enum.UIWidgetVisualizationType.ItemDisplay

local function reskinOptionText(text, r, g, b)
    if text then
        text:SetTextColor(r, g, b)
    end
end

-- Needs review, still buggy on blizz
local function reskinOptionButton(self)
    if not self or self.__bg then
        return
    end

    F.StripTextures(self, true)
    F.ReskinButton(self, true)
end

local function reskinSpellWidget(spell)
    if not spell.bg then
        spell.Border:SetAlpha(0)
        spell.bg = F.ReskinIcon(spell.Icon)
    end

    spell.IconMask:Hide()
    spell.Text:SetTextColor(1, 1, 1)
end

local ignoredTextureKit = {
    ['jailerstower'] = true,
    ['cypherchoice'] = true,
    ['genericplayerchoice'] = true,
}

local uglyBackground = {
    ['ui-frame-genericplayerchoice-cardparchment'] = true,
}

C.Themes['Blizzard_PlayerChoice'] = function()
    hooksecurefunc(PlayerChoiceFrame, 'TryShow', function(self)
        self.Header:Hide()

        if not self.bg then
            self.BlackBackground:SetAlpha(0)
            self.Background:SetAlpha(0)
            self.NineSlice:SetAlpha(0)
            self.BorderOverlay:SetAlpha(0)
            self.Title:DisableDrawLayer('BACKGROUND')
            self.Title.Text:SetTextColor(1, 0.8, 0)
            self.Title.Text:SetFontObject(SystemFont_Huge2)
            F.CreateBDFrame(self.Title, 0.25)
            F.ReskinClose(self.CloseButton)
            self.bg = F.SetBD(self)

            if GenericPlayerChoiceToggleButton then
                F.ReskinButton(GenericPlayerChoiceToggleButton)
            end
        end

        if self.CloseButton.Border then
            self.CloseButton.Border:SetAlpha(0)
        end -- no border for some templates

        local isIgnored = ignoredTextureKit[self.uiTextureKit]
        self.bg:SetShown(not isIgnored)

        if not self.optionFrameTemplate then
            return
        end

        for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
            local header = optionFrame.Header
            if header then
                reskinOptionText(header.Text, 1, 0.8, 0)
                if header.Contents then
                    reskinOptionText(header.Contents.Text, 1, 1, 1)
                    header.Contents.Text:SetFontObject(SystemFont_Med3)
                end
            end
            reskinOptionText(optionFrame.OptionText, 1, 1, 1)
            F.ReplaceIconString(optionFrame.OptionText.String)

            if optionFrame.Artwork and isIgnored then
                optionFrame.Artwork:SetSize(64, 64)
            end -- fix high resolution icons

            local optionBG = optionFrame.Background
            if optionBG then
                if not optionBG.bg then
                    optionBG.bg = F.SetBD(optionBG)
                    optionBG.bg:SetInside(optionBG, 4, 4)
                end

                local isUgly = uglyBackground[optionBG:GetAtlas()]
                optionBG:SetShown(not isUgly)
                optionBG.bg:SetShown(isUgly)
            end

            local optionButtonsContainer = optionFrame.OptionButtonsContainer
            if optionButtonsContainer and optionButtonsContainer.buttonPool then
                for button in optionButtonsContainer.buttonPool:EnumerateActive() do
                    reskinOptionButton(button)
                end
            end

            local rewards = optionFrame.Rewards
            if rewards then
                for rewardFrame in rewards.rewardsPool:EnumerateActive() do
                    local text = rewardFrame.Name or rewardFrame.Text -- .Text for PlayerChoiceBaseOptionReputationRewardTemplate
                    if text then
                        reskinOptionText(text, 0.9, 0.8, 0.5)
                    end

                    if not rewardFrame.styled then
                        -- PlayerChoiceBaseOptionItemRewardTemplate, PlayerChoiceBaseOptionCurrencyContainerRewardTemplate
                        local itemButton = rewardFrame.itemButton
                        if itemButton then
                            F.StripTextures(itemButton, 1)
                            itemButton.bg = F.ReskinIcon((itemButton:GetRegions()))
                            F.ReskinIconBorder(itemButton.IconBorder, true)
                        end
                        -- PlayerChoiceBaseOptionCurrencyRewardTemplate
                        local count = rewardFrame.Count
                        if count then
                            rewardFrame.bg = F.ReskinIcon(rewardFrame.Icon)
                            F.ReskinIconBorder(rewardFrame.IconBorder, true)
                        end

                        rewardFrame.styled = true
                    end
                end
            end

            local widgetContainer = optionFrame.WidgetContainer
            if widgetContainer and widgetContainer.widgetFrames then
                for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
                    reskinOptionText(widgetFrame.Text, 1, 1, 1)
                    if widgetFrame.Spell then
                        reskinSpellWidget(widgetFrame.Spell)
                    end

                    if widgetFrame.widgetType == Type_ItemDisplay then
                        local item = widgetFrame.Item
                        if item then
                            item.IconMask:Hide()
                            item.NameFrame:SetAlpha(0)
                            if not item.bg then
                                item.bg = F.ReskinIcon(item.Icon)
                                item.bg:SetFrameLevel(item.bg:GetFrameLevel() + 1)
                                F.ReskinIconBorder(item.IconBorder, true)
                            end
                        end
                    end
                end
            end
        end
    end)
end
