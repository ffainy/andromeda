local F, C = unpack(select(2, ...))

local function reskinHeader(header)
    for i = 4, 18 do
        select(i, header.button:GetRegions()):SetTexture('')
    end
    F.ReskinButton(header.button)
    header.descriptionBG:SetAlpha(0)
    header.descriptionBGBottom:SetAlpha(0)
    header.description:SetTextColor(1, 1, 1)
    header.button.title:SetTextColor(1, 1, 1)
    header.button.expandedIcon:SetWidth(20) -- don't wrap the text
end

local function reskinSectionHeader()
    local index = 1
    while true do
        local header = _G['EncounterJournalInfoHeader' .. index]
        if not header then
            return
        end
        if not header.styled then
            reskinHeader(header)
            header.button.bg = F.ReskinIcon(header.button.abilityIcon)
            header.styled = true
        end

        if header.button.abilityIcon:IsShown() then
            header.button.bg:Show()
        else
            header.button.bg:Hide()
        end

        index = index + 1
    end
end

C.Themes['Blizzard_EncounterJournal'] = function()
    local r, g, b = C.r, C.g, C.b
    local EncounterJournal = _G.EncounterJournal

    -- Tabs
    for i = 1, 5 do
        local tab = EncounterJournal.Tabs[i]
        if tab then
            F.ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', EncounterJournal.Tabs[i - 1], 'TOPRIGHT', -10, 0)
            end
        end
    end

    -- Side tabs
    local tabs = { 'overviewTab', 'modelTab', 'bossTab', 'lootTab' }
    for _, name in pairs(tabs) do
        local tab = EncounterJournal.encounter.info[name]
        local bg = F.SetBD(tab)
        bg:SetInside(tab, 2, 2)

        tab:SetNormalTexture(0)
        tab:SetPushedTexture(0)
        tab:SetDisabledTexture(0)
        local hl = tab:GetHighlightTexture()
        hl:SetColorTexture(r, g, b, 0.2)
        hl:SetInside(bg)

        if name == 'overviewTab' then
            tab:SetPoint('TOPLEFT', _G.EncounterJournalEncounterFrameInfo, 'TOPRIGHT', 9, -35)
        end
    end

    -- Instance select
    _G.EncounterJournalInstanceSelectBG:SetAlpha(0)
    F.ReskinDropdown(EncounterJournal.instanceSelect.ExpansionDropdown)
    F.ReskinTrimScroll(EncounterJournal.instanceSelect.ScrollBar)

    hooksecurefunc(EncounterJournal.instanceSelect.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                child:SetNormalTexture(0)
                child:SetHighlightTexture(0)
                child:SetPushedTexture(0)

                local bg = F.CreateBDFrame(child.bgImage)
                bg:SetPoint('TOPLEFT', 3, -3)
                bg:SetPoint('BOTTOMRIGHT', -4, 2)

                child.styled = true
            end
        end
    end)

    -- Encounter frame
    _G.EncounterJournalEncounterFrameInfo:DisableDrawLayer('BACKGROUND')
    _G.EncounterJournalInstanceSelectBG:Hide()
    _G.EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
    _G.EncounterJournalEncounterFrameInfoModelFrame.dungeonBG:Hide()

    _G.EncounterJournalEncounterFrameInfoEncounterTitle:SetTextColor(1, 0.8, 0)
    _G.EncounterJournal.encounter.instance.LoreScrollingFont:SetTextColor(CreateColor(1, 1, 1))
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor(
        'P',
        1,
        1,
        1
    )
    _G.EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject('GameFontNormalLarge')
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 0.8, 0)

    F.CreateBDFrame(_G.EncounterJournalEncounterFrameInfoModelFrame, 0.25)
    _G.EncounterJournalEncounterFrameInfoCreatureButton1:SetPoint(
        'TOPLEFT',
        _G.EncounterJournalEncounterFrameInfoModelFrame,
        0,
        -35
    )

    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                F.ReskinButton(child, true)
                local hl = child:GetHighlightTexture()
                hl:SetColorTexture(r, g, b, 0.25)
                hl:SetInside(child.__bg)

                child.text:SetTextColor(1, 1, 1)
                child.creature:SetPoint('TOPLEFT', 0, -4)

                child.styled = true
            end
        end
    end)
    hooksecurefunc('EncounterJournal_ToggleHeaders', reskinSectionHeader)

    hooksecurefunc('EncounterJournal_SetUpOverview', function(self, _, index)
        local header = self.overviews[index]
        if not header.styled then
            reskinHeader(header)
            header.styled = true
        end
    end)

    hooksecurefunc('EncounterJournal_SetBullets', function(object)
        local parent = object:GetParent()
        if parent.Bullets then
            for _, bullet in pairs(parent.Bullets) do
                if not bullet.styled then
                    bullet.Text:SetTextColor('P', 1, 1, 1)
                    bullet.styled = true
                end
            end
        end
    end)

    hooksecurefunc(EncounterJournal.encounter.info.LootContainer.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.boss and not child.styled then
                child.boss:SetTextColor(1, 1, 1)
                child.slot:SetTextColor(1, 1, 1)
                child.armorType:SetTextColor(1, 1, 1)
                child.bossTexture:SetAlpha(0)
                child.bosslessTexture:SetAlpha(0)
                child.IconBorder:SetAlpha(0)
                child.icon:SetPoint('TOPLEFT', 1, -1)
                F.ReskinIcon(child.icon)

                local bg = F.CreateBDFrame(child, 0.25)
                bg:SetPoint('TOPLEFT')
                bg:SetPoint('BOTTOMRIGHT', 0, 1)

                child.styled = true
            end
        end
    end)

    -- Search results
    _G.EncounterJournalSearchBox:SetFrameLevel(15)
    local showAllResults = _G.EncounterJournalSearchBox.showAllResults
    local previewContainer = _G.EncounterJournalSearchBox.searchPreviewContainer
    F.StripTextures(previewContainer)

    local bg = F.SetBD(previewContainer)
    bg:SetPoint('TOPLEFT', -3, 3)
    bg:SetPoint('BOTTOMRIGHT', showAllResults, 3, -3)

    for i = 1, _G.EncounterJournalSearchBox:GetNumChildren() do
        local child = select(i, _G.EncounterJournalSearchBox:GetChildren())
        if child.iconFrame then
            F.StyleSearchButton(child)
        end
    end
    F.StyleSearchButton(showAllResults)

    do
        local result = _G.EncounterJournalSearchResults
        result:SetPoint('BOTTOMLEFT', EncounterJournal, 'BOTTOMRIGHT', 15, -1)
        F.StripTextures(result)
        local bg = F.SetBD(result)
        bg:SetPoint('TOPLEFT', -10, 0)
        bg:SetPoint('BOTTOMRIGHT')

        F.ReskinClose(_G.EncounterJournalSearchResultsCloseButton)
        F.ReskinTrimScroll(result.ScrollBar)

        hooksecurefunc(result.ScrollBox, 'Update', function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local child = select(i, self.ScrollTarget:GetChildren())
                if not child.styled then
                    F.StripTextures(child, 2)
                    F.ReskinIcon(child.icon)
                    local bg = F.CreateBDFrame(child, 0.25)
                    bg:SetInside()

                    child:SetHighlightTexture(C.Assets.Textures.Backdrop)
                    local hl = child:GetHighlightTexture()
                    hl:SetVertexColor(r, g, b, 0.25)
                    hl:SetInside(bg)

                    child.styled = true
                end
            end
        end)
    end

    -- Various controls
    F.ReskinPortraitFrame(EncounterJournal)
    F.ReskinButton(_G.EncounterJournalEncounterFrameInfoResetButton)
    if not C.IS_NEW_PATCH then
        F.ReskinButton(_G.EncounterJournalEncounterFrameInfoResetButton)
    end
    F.ReskinEditbox(_G.EncounterJournalSearchBox)
    F.ReskinTrimScroll(EncounterJournal.encounter.instance.LoreScrollBar)
    F.ReskinTrimScroll(EncounterJournal.encounter.info.BossesScrollBar)
    F.ReskinTrimScroll(EncounterJournal.encounter.info.LootContainer.ScrollBar)
    F.ReskinTrimScroll(EncounterJournal.encounter.info.overviewScroll.ScrollBar)
    F.ReskinTrimScroll(EncounterJournal.encounter.info.detailsScroll.ScrollBar)

    F.ReskinDropdown(EncounterJournal.encounter.info.LootContainer.filter)
    F.ReskinDropdown(EncounterJournal.encounter.info.LootContainer.slotFilter)
    F.ReskinDropdown(_G.EncounterJournalEncounterFrameInfoDifficulty)

    -- Suggest frame
    local suggestFrame = EncounterJournal.suggestFrame

    -- Suggestion 1
    local suggestion = suggestFrame.Suggestion1
    suggestion.bg:Hide()
    F.CreateBDFrame(suggestion, 0.25)
    suggestion.icon:SetPoint('TOPLEFT', 135, -15)
    F.CreateBDFrame(suggestion.icon)

    local centerDisplay = suggestion.centerDisplay
    centerDisplay.title.text:SetTextColor(1, 1, 1)
    centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)
    F.ReskinButton(suggestion.button)

    local reward = suggestion.reward
    reward.text:SetTextColor(0.9, 0.9, 0.9)
    reward.iconRing:Hide()
    reward.iconRingHighlight:SetTexture('')
    F.CreateBDFrame(reward.icon):SetFrameLevel(3)
    F.ReskinArrow(suggestion.prevButton, 'left')
    F.ReskinArrow(suggestion.nextButton, 'right')

    -- Suggestion 2 and 3
    for i = 2, 3 do
        local suggestion = suggestFrame['Suggestion' .. i]

        suggestion.bg:Hide()
        F.CreateBDFrame(suggestion, 0.25)
        suggestion.icon:SetPoint('TOPLEFT', 10, -10)
        F.CreateBDFrame(suggestion.icon)

        local centerDisplay = suggestion.centerDisplay

        centerDisplay:ClearAllPoints()
        centerDisplay:SetPoint('TOPLEFT', 85, -10)
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)
        F.ReskinButton(centerDisplay.button)

        local reward = suggestion.reward
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture('')
        F.CreateBDFrame(reward.icon):SetFrameLevel(3)
    end

    -- Hook functions
    hooksecurefunc('EJSuggestFrame_RefreshDisplay', function()
        local self = suggestFrame

        if #self.suggestions > 0 then
            local suggestion = self.Suggestion1
            local data = self.suggestions[1]
            suggestion.iconRing:Hide()

            if data.iconPath then
                suggestion.icon:SetMask('')
                suggestion.icon:SetTexCoord(unpack(C.TEX_COORD))
            end
        end

        if #self.suggestions > 1 then
            for i = 2, #self.suggestions do
                local suggestion = self['Suggestion' .. i]
                if not suggestion then
                    break
                end

                local data = self.suggestions[i]
                suggestion.iconRing:Hide()

                if data.iconPath then
                    suggestion.icon:SetMask('')
                    suggestion.icon:SetTexCoord(unpack(C.TEX_COORD))
                end
            end
        end
    end)

    hooksecurefunc('EJSuggestFrame_UpdateRewards', function(suggestion)
        local rewardData = suggestion.reward.data
        if rewardData then
            suggestion.reward.icon:SetMask('')
            suggestion.reward.icon:SetTexCoord(unpack(C.TEX_COORD))
        end
    end)

    -- LootJournal

    local lootJournal = EncounterJournal.LootJournal
    F.StripTextures(lootJournal)

    local iconColor = C.QualityColors[Enum.ItemQuality.Legendary or 5] -- legendary color
    F.ReskinTrimScroll(lootJournal.ScrollBar)

    hooksecurefunc(lootJournal.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                child.Background:SetAlpha(0)
                child.BackgroundOverlay:SetAlpha(0)
                child.UnavailableOverlay:SetAlpha(0)
                child.UnavailableBackground:SetAlpha(0)
                child.CircleMask:Hide()
                child.bg = F.ReskinIcon(child.Icon)
                child.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)

                local bg = F.CreateBDFrame(child, 0.25)
                bg:SetPoint('TOPLEFT', 3, 0)
                bg:SetPoint('BOTTOMRIGHT', -2, 1)

                child.styled = true
            end
        end
    end)

    -- ItemSetsFrame
    if EncounterJournal.LootJournalItems then
        F.StripTextures(EncounterJournal.LootJournalItems)
        F.ReskinDropdown(EncounterJournal.LootJournalViewDropdown)

        local function reskinBar(bar)
            if not bar.styled then
                bar.ItemLevel:SetTextColor(1, 1, 1)
                bar.Background:Hide()
                F.CreateBDFrame(bar, 0.25)

                bar.styled = true
            end

            local itemButtons = bar.ItemButtons
            for i = 1, #itemButtons do
                local button = itemButtons[i]
                if not button.bg then
                    button.bg = F.ReskinIcon(button.Icon)
                    F.ReskinIconBorder(button.Border, true, true)
                end
            end
        end

        local itemSetsFrame = EncounterJournal.LootJournalItems.ItemSetsFrame
        F.ReskinTrimScroll(itemSetsFrame.ScrollBar)

        hooksecurefunc(itemSetsFrame.ScrollBox, 'Update', function(self)
            self:ForEachFrame(reskinBar)
        end)
        F.ReskinDropdown(itemSetsFrame.ClassDropdown)
    end

    -- Monthly activities
    local frame = _G.EncounterJournalMonthlyActivitiesFrame
    if frame then
        F.StripTextures(frame)
        F.ReskinTrimScroll(frame.ScrollBar)
        if frame.ThemeContainer then
            frame.ThemeContainer:SetAlpha(0)
        end

        local function replaceBlackColor(text, r, g, b)
            if r == 0 and g == 0 and b == 0 then
                text:SetTextColor(0.7, 0.7, 0.7)
            end
        end

        local function handleText(button)
            local container = button.TextContainer
            if container and not container.styled then
                hooksecurefunc(container.NameText, 'SetTextColor', replaceBlackColor)
                hooksecurefunc(container.ConditionsText, 'SetTextColor', replaceBlackColor)
                container.styled = true
            end
        end

        hooksecurefunc(frame.ScrollBox, 'Update', function(self)
            self:ForEachFrame(handleText)
        end)
    end
end
