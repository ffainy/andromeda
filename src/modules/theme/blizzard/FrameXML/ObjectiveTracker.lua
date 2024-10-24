local F, C = unpack(select(2, ...))

local function reskinQuestIcon(button)
    if not button then
        return
    end
    if not button.SetNormalTexture then
        return
    end

    if not button.styled then
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        local icon = button.icon or button.Icon
        if icon then
            button.bg = F.ReskinIcon(icon, true)
        end

        button.styled = true
    end

    if button.bg then
        button.bg:SetFrameLevel(0)
    end
end

local function reskinQuestIcons(_, block)
    reskinQuestIcon(block.ItemButton)
    reskinQuestIcon(block.rightEdgeFrame)
end

local function reskinHeader(header)
    header.Text:SetTextColor(C.r, C.g, C.b)
    header.Background:SetTexture(nil)
    local bg = header:CreateTexture(nil, 'ARTWORK')
    bg:SetTexture('Interface\\LFGFrame\\UI-LFG-SEPARATOR')
    bg:SetTexCoord(0, 0.66, 0, 0.31)
    bg:SetVertexColor(C.r, C.g, C.b, 0.8)
    bg:SetPoint('BOTTOMLEFT', 0, -4)
    bg:SetSize(250, 30)
    header.bg = bg -- accessable for other addons
end

local function reskinBarTemplate(bar)
    if bar.bg then
        return
    end

    F.StripTextures(bar)
    bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    bar:SetStatusBarColor(C.r, C.g, C.b)
    bar.bg = F.SetBD(bar)
end

local function reskinBar(self, key)
    local progressBar = self.usedProgressBars[key]
    local bar = progressBar and progressBar.Bar

    if bar and not bar.bg then
        reskinBarTemplate(bar)
    end

    local icon = bar.Icon
    if icon then
        if not icon.bg then
            icon:SetMask('')
            icon.bg = F.ReskinIcon(icon, true)
            icon:ClearAllPoints()
            icon:SetPoint('TOPLEFT', bar, 'TOPRIGHT', 5, 0)
            icon:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 25, 0)
        end

        if icon.bg then
            icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
        end
    end
end


local function reskinTimer(self, key)
    local timerBar = self.usedTimerBars[key]
    local bar = timerBar and timerBar.Bar

    if bar and not bar.bg then
        reskinBarTemplate(bar)
    end
end

local function updateMinimizeButton(button, collapsed)
    button = button.MinimizeButton
    button.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(button, header)
    F.ReskinCollapse(button)
    button:GetNormalTexture():SetAlpha(0)
    button:GetPushedTexture():SetAlpha(0)
    button.__texture:DoCollapse(false)
    if button.SetCollapsed then
        hooksecurefunc(button, 'SetCollapsed', updateMinimizeButton)
    end
    hooksecurefunc(header, 'SetCollapsed', updateMinimizeButton)
end

local function getMawBuffsAnchor(frame)
    local center = frame:GetCenter()
    if center and center < GetScreenWidth() / 2 then
        return 'LEFT'
    else
        return 'RIGHT'
    end
end

local function container_OnClick(container)
    local direc = getMawBuffsAnchor(container)
    if not container.lastDirec or container.lastDirec ~= direc then
        container.List:ClearAllPoints()
        if direc == 'LEFT' then
            container.List:SetPoint('TOPLEFT', container, 'TOPRIGHT', 15, 1)
        else
            container.List:SetPoint('TOPRIGHT', container, 'TOPLEFT', 15, 1)
        end
        container.lastDirec = direc
    end
end

local function blockList_Show(self)
    self.button:SetWidth(253)
    self.button:SetButtonState('NORMAL')
    self.button:SetPushedTextOffset(1.25, -1)
    self.button:SetButtonState('PUSHED', true)
    self.__bg:SetBackdropBorderColor(1, 0.8, 0, 0.7)
end

local function blockList_Hide(self)
    self.__bg:SetBackdropBorderColor(0, 0, 0, 1)
end

local function reskinMawBuffsContainer(container)
    F.StripTextures(container)
    container:GetPushedTexture():SetAlpha(0)
    container:GetHighlightTexture():SetAlpha(0)
    local bg = F.SetBD(container, 0, 13, -11, -3, 11)
    F.CreateGradient(bg)
    container:HookScript('OnClick', container_OnClick)

    local blockList = container.List
    F.StripTextures(blockList)
    blockList.__bg = bg
    local lbg = F.SetBD(blockList)
    lbg:SetPoint('TOPLEFT', 7, -12)
    lbg:SetPoint('BOTTOMRIGHT', -7, 12)

    blockList:HookScript('OnShow', blockList_Show)
    blockList:HookScript('OnHide', blockList_Hide)
end

tinsert(C.BlizzThemes, function()
    -- Reskin Headers
    local mainHeader = ObjectiveTrackerFrame.Header
    F.StripTextures(mainHeader) -- main header looks simple this way

    -- Minimize Button
    local mainMinimize = mainHeader.MinimizeButton
    reskinMinimizeButton(mainMinimize, mainHeader)
    mainMinimize.bg:SetBackdropBorderColor(1, 0.8, 0, 0.5)

    local trackers = {
        ScenarioObjectiveTracker,
        UIWidgetObjectiveTracker,
        CampaignQuestObjectiveTracker,
        QuestObjectiveTracker,
        AdventureObjectiveTracker,
        AchievementObjectiveTracker,
        MonthlyActivitiesObjectiveTracker,
        ProfessionsRecipeTracker,
        BonusObjectiveTracker,
        WorldQuestObjectiveTracker,
    }
    for _, tracker in pairs(trackers) do
        reskinHeader(tracker.Header)
        hooksecurefunc(tracker, 'AddBlock', reskinQuestIcons)
        hooksecurefunc(tracker, 'GetProgressBar', reskinBar)
        hooksecurefunc(tracker, 'GetTimerBar', reskinTimer)
    end

    -- Handle blocks, untest
    hooksecurefunc(ScenarioObjectiveTracker.StageBlock, 'UpdateStageBlock', function(block)
        block.NormalBG:SetTexture('')
        if not block.bg then
            block.bg = F.SetBD(block.GlowTexture, nil, 4, -2, -4, 2)
        end
    end)

    hooksecurefunc(ScenarioObjectiveTracker.StageBlock, 'UpdateWidgetRegistration', function(self)
        local widgetContainer = self.WidgetContainer
        if widgetContainer.widgetFrames then
            for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
                if widgetFrame.Frame then
                    widgetFrame.Frame:SetAlpha(0)
                end

                local bar = widgetFrame.TimerBar
                if bar and not bar.bg then
                    bar.bg = F.CreateBDFrame(bar, 0.25)
                end

                if widgetFrame.CurrencyContainer then
                    for currencyFrame in widgetFrame.currencyPool:EnumerateActive() do
                        if not currencyFrame.bg then
                            currencyFrame.bg = F.ReskinIcon(currencyFrame.Icon)
                        end
                    end
                end
            end
        end
    end)

    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, 'SetUpAffixes', function(self)
        for frame in self.affixPool:EnumerateActive() do
            frame.Border:SetTexture(nil)
            frame.Portrait:SetTexture(nil)
            if not frame.bg then
                frame.bg = F.ReskinIcon(frame.Portrait)
            end

            if frame.info then
                frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
            elseif frame.affixID then
                local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
                frame.Portrait:SetTexture(filedataid)
            end
        end
    end)

    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, 'Activate', function(block)
        if not block.bg then
            block.TimerBG:Hide()
            block.TimerBGBack:Hide()
            block.timerbg = F.CreateBDFrame(block.TimerBGBack, 0.3)
            block.timerbg:SetPoint('TOPLEFT', block.TimerBGBack, 6, -2)
            block.timerbg:SetPoint('BOTTOMRIGHT', block.TimerBGBack, -6, -5)

            block.StatusBar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
            block.StatusBar:SetStatusBarColor(C.r, C.g, C.b)
            block.StatusBar:SetHeight(10)

            select(3, block:GetRegions()):Hide()
            block.bg = F.SetBD(block, nil, 4, -2, -4, 0)
        end
    end)

    hooksecurefunc(ScenarioObjectiveTracker, 'UpdateSpellCooldowns', function(self)
        for spellFrame in self.spellFramePool:EnumerateActive() do
            local spellButton = spellFrame.SpellButton
            if spellButton and not spellButton.styled then
                local bg = F.ReskinIcon(spellButton.Icon)
                spellButton:SetNormalTexture(0)
                spellButton:SetPushedTexture(0)
                local hl = spellButton:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.25)
                hl:SetInside(bg)

                spellButton.styled = true
            end
        end
    end)

    -- Maw buffs container
    reskinMawBuffsContainer(ScenarioObjectiveTracker.MawBuffsBlock.Container)
end)
