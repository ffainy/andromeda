local F, C = unpack(select(2, ...))

local function reskinCommunityTab(tab)
    tab:GetRegions():Hide()
    F.ReskinIcon(tab.Icon)
    tab:SetCheckedTexture(C.Assets.Textures.ButtonChecked)
    local hl = tab:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetAllPoints(tab.Icon)
end

local cardGroup = { 'First', 'Second', 'Third' }
local function reskinGuildCards(cards)
    for _, name in pairs(cardGroup) do
        local guildCard = cards[name .. 'Card']
        F.StripTextures(guildCard)
        F.CreateBDFrame(guildCard, 0.25)
        F.ReskinButton(guildCard.RequestJoin)
    end
    F.ReskinArrow(cards.PreviousPage, 'left')
    F.ReskinArrow(cards.NextPage, 'right')
end

local function reskinCommunityCard(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if not child.styled then
            child.CircleMask:Hide()
            child.LogoBorder:Hide()
            child.Background:Hide()
            F.ReskinIcon(child.CommunityLogo)
            F.ReskinButton(child)

            child.styled = true
        end
    end
end

local function reskinRequestCheckbox(self)
    for button in self.SpecsPool:EnumerateActive() do
        if button.Checkbox then
            F.ReskinCheckbox(button.Checkbox)
            button.Checkbox:SetSize(26, 26)
        end
    end
end

local function updateCommunitiesSelection(texture, show)
    local button = texture:GetParent()
    if show then
        if texture:GetTexCoord() == 0 then
            button.bg:SetBackdropColor(0, 1, 0, 0.25)
        else
            button.bg:SetBackdropColor(0.51, 0.773, 1, 0.25)
        end
    else
        button.bg:SetBackdropColor(0, 0, 0, 0)
    end
end

local function updateNameFrame(self)
    if not self.expanded then
        return
    end
    if not self.bg then
        self.bg = F.CreateBDFrame(self.Class)
    end
    local memberInfo = self:GetMemberInfo()
    if memberInfo and memberInfo.classID then
        local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
        if classInfo then
            F.ClassIconTexCoord(self.Class, classInfo.classFile)
        end
    end
end

local function replacedRoleTex(icon, x1, x2, y1, y2)
    if x1 == 0 and x2 == 19 / 64 and y1 == 22 / 64 and y2 == 41 / 64 then
        F.ReskinSmallRole(icon, 'TANK')
    elseif x1 == 20 / 64 and x2 == 39 / 64 and y1 == 1 / 64 and y2 == 20 / 64 then
        F.ReskinSmallRole(icon, 'HEALER')
    elseif x1 == 20 / 64 and x2 == 39 / 64 and y1 == 22 / 64 and y2 == 41 / 64 then
        F.ReskinSmallRole(icon, 'DAMAGER')
    end
end

local function updateRoleTexture(icon)
    if not icon then
        return
    end
    replacedRoleTex(icon, icon:GetTexCoord())
    hooksecurefunc(icon, 'SetTexCoord', replacedRoleTex)
end

local function updateMemberName(self, info)
    if not info then
        return
    end

    local class = self.Class
    if not class.bg then
        class.bg = F.CreateBDFrame(class)
    end

    local classTag = select(2, GetClassInfo(info.classID))
    if classTag then
        local tcoords = _G.CLASS_ICON_TCOORDS[classTag]
        class:SetTexCoord(tcoords[1] + 0.022, tcoords[2] - 0.025, tcoords[3] + 0.022, tcoords[4] - 0.025)
    end
end

C.Themes['Blizzard_Communities'] = function()
    local r, g, b = C.r, C.g, C.b
    local CommunitiesFrame = _G.CommunitiesFrame

    F.ReskinPortraitFrame(CommunitiesFrame)
    CommunitiesFrame.NineSlice:Hide()
    CommunitiesFrame.PortraitOverlay:SetAlpha(0)
    F.ReskinDropdown(CommunitiesFrame.StreamDropdown)
    F.ReskinDropdown(CommunitiesFrame.CommunitiesListDropdown)
    F.ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
    F.StripTextures(CommunitiesFrame.AddToChatButton)
    F.ReskinArrow(CommunitiesFrame.AddToChatButton, 'down')

    local calendarButton = CommunitiesFrame.CommunitiesCalendarButton
    calendarButton:SetSize(24, 24)
    calendarButton:SetNormalTexture(1103070)
    calendarButton:SetPushedTexture(1103070)
    calendarButton:GetPushedTexture():SetTexCoord(unpack(C.TEX_COORD))
    calendarButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    F.ReskinIcon(calendarButton:GetNormalTexture())

    for _, name in
        next,
        { 'GuildFinderFrame', 'InvitationFrame', 'TicketFrame', 'CommunityFinderFrame', 'ClubFinderInvitationFrame' }
    do
        local frame = CommunitiesFrame[name]
        if frame then
            F.StripTextures(frame)
            frame.InsetFrame:Hide()
            if frame.CircleMask then
                frame.CircleMask:Hide()
                frame.IconRing:Hide()
                F.ReskinIcon(frame.Icon)
            end
            if frame.FindAGuildButton then
                F.ReskinButton(frame.FindAGuildButton)
            end
            if frame.AcceptButton then
                F.ReskinButton(frame.AcceptButton)
            end
            if frame.DeclineButton then
                F.ReskinButton(frame.DeclineButton)
            end
            if frame.ApplyButton then
                F.ReskinButton(frame.ApplyButton)
            end

            local optionsList = frame.OptionsList
            if optionsList then
                F.ReskinDropdown(optionsList.ClubFilterDropdown)
                F.ReskinDropdown(optionsList.ClubSizeDropdown)
                F.ReskinDropdown(optionsList.SortByDropdown)
                F.ReskinRole(optionsList.TankRoleFrame, 'TANK')
                F.ReskinRole(optionsList.HealerRoleFrame, 'HEALER')
                F.ReskinRole(optionsList.DpsRoleFrame, 'DPS')
                F.ReskinEditbox(optionsList.SearchBox)
                optionsList.SearchBox:SetSize(118, 22)
                F.ReskinButton(optionsList.Search)
                optionsList.Search:ClearAllPoints()
                optionsList.Search:SetPoint('TOPRIGHT', optionsList.SearchBox, 'BOTTOMRIGHT', 0, -2)
            end

            local requestFrame = frame.RequestToJoinFrame
            if requestFrame then
                F.StripTextures(requestFrame)
                F.SetBD(requestFrame)
                F.StripTextures(requestFrame.MessageFrame)
                F.StripTextures(requestFrame.MessageFrame.MessageScroll)
                F.CreateBDFrame(requestFrame.MessageFrame.MessageScroll, 0.25)
                F.ReskinButton(requestFrame.Apply)
                F.ReskinButton(requestFrame.Cancel)
                hooksecurefunc(requestFrame, 'Initialize', reskinRequestCheckbox)
            end

            if frame.ClubFinderSearchTab then
                reskinCommunityTab(frame.ClubFinderSearchTab)
            end
            if frame.ClubFinderPendingTab then
                reskinCommunityTab(frame.ClubFinderPendingTab)
            end
            if frame.GuildCards then
                reskinGuildCards(frame.GuildCards)
            end
            if frame.PendingGuildCards then
                reskinGuildCards(frame.PendingGuildCards)
            end

            if frame.CommunityCards then
                F.ReskinTrimScroll(frame.CommunityCards.ScrollBar)
                hooksecurefunc(frame.CommunityCards.ScrollBox, 'Update', reskinCommunityCard)
            end

            if frame.PendingCommunityCards then
                F.ReskinTrimScroll(frame.PendingCommunityCards.ScrollBar)
                hooksecurefunc(frame.PendingCommunityCards.ScrollBox, 'Update', reskinCommunityCard)
            end
        end
    end

    F.StripTextures(_G.CommunitiesFrameCommunitiesList)
    _G.CommunitiesFrameCommunitiesList.InsetFrame:Hide()
    _G.CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()

    _G.CommunitiesFrameCommunitiesList.ScrollBar:GetChildren():Hide()
    F.ReskinTrimScroll(_G.CommunitiesFrameCommunitiesList.ScrollBar)

    hooksecurefunc(_G.CommunitiesFrameCommunitiesList.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.bg then
                child.bg = F.CreateBDFrame(child, 0, true)
                child.bg:SetPoint('TOPLEFT', 5, -5)
                child.bg:SetPoint('BOTTOMRIGHT', -10, 5)

                child:SetHighlightTexture(0)
                child.IconRing:SetAlpha(0)
                child.__iconBorder = F.ReskinIcon(child.Icon)
                child.Background:Hide()
                child.Selection:SetAlpha(0)

                hooksecurefunc(child.Selection, 'SetShown', updateCommunitiesSelection)
                child.CircleMask:Hide()
            end
            child.__iconBorder:SetShown(child.IconRing:IsShown())
        end
    end)

    for _, name in next, { 'ChatTab', 'RosterTab', 'GuildBenefitsTab', 'GuildInfoTab' } do
        local tab = CommunitiesFrame[name]
        if tab then
            reskinCommunityTab(tab)
        end
    end

    -- ChatTab
    F.ReskinButton(CommunitiesFrame.InviteButton)
    F.StripTextures(CommunitiesFrame.Chat)
    F.ReskinTrimScroll(CommunitiesFrame.Chat.ScrollBar)
    CommunitiesFrame.ChatEditBox:DisableDrawLayer('BACKGROUND')
    local bg1 = F.CreateBDFrame(CommunitiesFrame.Chat.InsetFrame, 0.25)
    bg1:SetPoint('TOPLEFT', 1, -3)
    bg1:SetPoint('BOTTOMRIGHT', -3, 22)
    local bg2 = F.CreateBDFrame(CommunitiesFrame.ChatEditBox, 0, true)
    bg2:SetPoint('TOPLEFT', -5, -5)
    bg2:SetPoint('BOTTOMRIGHT', 4, 5)

    do
        local dialog = CommunitiesFrame.NotificationSettingsDialog
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinDropdown(dialog.CommunitiesListDropdown)
        if dialog.Selector then
            F.StripTextures(dialog.Selector)
            F.ReskinButton(dialog.Selector.OkayButton)
            F.ReskinButton(dialog.Selector.CancelButton)
        end
        F.ReskinCheckbox(dialog.ScrollFrame.Child.QuickJoinButton)
        dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
        F.ReskinButton(dialog.ScrollFrame.Child.AllButton)
        F.ReskinButton(dialog.ScrollFrame.Child.NoneButton)
        F.ReskinTrimScroll(dialog.ScrollFrame.ScrollBar)

        hooksecurefunc(dialog, 'Refresh', function(self)
            local frame = self.ScrollFrame.Child
            for i = 1, frame:GetNumChildren() do
                local child = select(i, frame:GetChildren())
                if child.StreamName and not child.styled then
                    F.ReskinRadio(child.ShowNotificationsButton)
                    F.ReskinRadio(child.HideNotificationsButton)

                    child.styled = true
                end
            end
        end)
    end

    do
        local dialog = CommunitiesFrame.EditStreamDialog
        F.StripTextures(dialog)
        F.SetBD(dialog)
        dialog.NameEdit:DisableDrawLayer('BACKGROUND')
        local bg = F.CreateBDFrame(dialog.NameEdit, 0.25)
        bg:SetPoint('TOPLEFT', -3, -3)
        bg:SetPoint('BOTTOMRIGHT', -4, 3)
        F.StripTextures(dialog.Description)
        F.CreateBDFrame(dialog.Description, 0.25)
        F.ReskinCheckbox(dialog.TypeCheckbox)
        F.ReskinButton(dialog.Accept)
        F.ReskinButton(dialog.Delete)
        F.ReskinButton(dialog.Cancel)
    end

    do
        local dialog = _G.CommunitiesTicketManagerDialog
        F.StripTextures(dialog)
        F.SetBD(dialog)
        dialog.Background:Hide()
        F.ReskinButton(dialog.LinkToChat)
        F.ReskinButton(dialog.Copy)
        F.ReskinButton(dialog.Close)
        F.ReskinArrow(dialog.MaximizeButton, 'down')
        F.ReskinDropdown(dialog.ExpiresDropdown)
        F.ReskinDropdown(dialog.UsesDropdown)
        F.ReskinButton(dialog.GenerateLinkButton)

        dialog.InviteManager.ArtOverlay:Hide()
        F.StripTextures(dialog.InviteManager.ColumnDisplay)
        dialog.InviteManager.ScrollBar:GetChildren():Hide()
        F.ReskinTrimScroll(dialog.InviteManager.ScrollBar)

        hooksecurefunc(dialog, 'Update', function(self)
            local column = self.InviteManager.ColumnDisplay
            for i = 1, column:GetNumChildren() do
                local child = select(i, column:GetChildren())
                if not child.styled then
                    F.StripTextures(child)
                    local bg = F.CreateBDFrame(child, 0.25)
                    bg:SetPoint('TOPLEFT', 4, -2)
                    bg:SetPoint('BOTTOMRIGHT', 0, 2)

                    child.styled = true
                end
            end
        end)

        hooksecurefunc(dialog.InviteManager.ScrollBox, 'Update', function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local button = select(i, self.ScrollTarget:GetChildren())
                if not button.styled then
                    F.ReskinButton(button.CopyLinkButton)
                    button.CopyLinkButton.Background:Hide()
                    F.ReskinButton(button.RevokeButton)
                    button.RevokeButton:SetSize(18, 18)

                    button.styled = true
                end
            end
        end)
    end

    -- Roster
    CommunitiesFrame.MemberList.InsetFrame:Hide()
    F.StripTextures(CommunitiesFrame.MemberList.ColumnDisplay)
    F.ReskinDropdown(CommunitiesFrame.GuildMemberListDropdown)
    CommunitiesFrame.MemberList.ScrollBar:GetChildren():Hide()
    F.ReskinTrimScroll(CommunitiesFrame.MemberList.ScrollBar)

    hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                hooksecurefunc(child, 'RefreshExpandedColumns', updateNameFrame)
                child.styled = true
            end

            local header = child.ProfessionHeader
            if header and not header.styled then
                for i = 1, 3 do
                    select(i, header:GetRegions()):Hide()
                end
                header.bg = F.CreateBDFrame(header, 0.25)
                header.bg:SetInside()
                header:SetHighlightTexture(C.Assets.Textures.Backdrop)
                header:GetHighlightTexture():SetVertexColor(r, g, b, 0.25)
                header:GetHighlightTexture():SetInside(header.bg)
                F.CreateBDFrame(header.Icon)
                header.styled = true
            end

            if child and child.bg then
                child.bg:SetShown(child.Class:IsShown())
            end
        end
    end)

    F.ReskinCheckbox(CommunitiesFrame.MemberList.ShowOfflineButton)
    CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
    F.ReskinButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
    F.ReskinButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
    F.ReskinButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
    F.ReskinDropdown(CommunitiesFrame.CommunityMemberListDropdown)

    local detailFrame = CommunitiesFrame.GuildMemberDetailFrame
    F.StripTextures(detailFrame)
    F.SetBD(detailFrame)
    F.ReskinClose(detailFrame.CloseButton)
    F.ReskinButton(detailFrame.RemoveButton)
    F.ReskinButton(detailFrame.GroupInviteButton)
    F.ReskinDropdown(detailFrame.RankDropdown)
    F.StripTextures(detailFrame.NoteBackground)
    F.CreateBDFrame(detailFrame.NoteBackground, 0.25)
    F.StripTextures(detailFrame.OfficerNoteBackground)
    F.CreateBDFrame(detailFrame.OfficerNoteBackground, 0.25)
    detailFrame:ClearAllPoints()
    detailFrame:SetPoint('TOPLEFT', CommunitiesFrame, 'TOPRIGHT', 34, 0)

    do
        local dialog = _G.CommunitiesSettingsDialog
        dialog.BG:Hide()
        F.SetBD(dialog)
        F.ReskinButton(dialog.ChangeAvatarButton)
        F.ReskinButton(dialog.Accept)
        F.ReskinButton(dialog.Delete)
        F.ReskinButton(dialog.Cancel)
        F.ReskinEditbox(dialog.NameEdit)
        F.ReskinEditbox(dialog.ShortNameEdit)
        F.StripTextures(dialog.Description)
        F.CreateBDFrame(dialog.Description, 0.25)
        F.StripTextures(dialog.MessageOfTheDay)
        F.CreateBDFrame(dialog.MessageOfTheDay, 0.25)
        F.ReskinCheckbox(dialog.ShouldListClub.Button)
        F.ReskinCheckbox(dialog.AutoAcceptApplications.Button)
        F.ReskinCheckbox(dialog.MaxLevelOnly.Button)
        F.ReskinCheckbox(dialog.MinIlvlOnly.Button)
        F.ReskinEditbox(dialog.MinIlvlOnly.EditBox)
        F.ReskinDropdown(dialog.ClubFocusDropdown)
        F.ReskinDropdown(dialog.LookingForDropdown)
        F.ReskinDropdown(dialog.LanguageDropdown)
    end

    do
        local dialog = _G.CommunitiesAvatarPickerDialog
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinTrimScroll(_G.CommunitiesAvatarPickerDialog.ScrollBar)
        if dialog.Selector then
            F.StripTextures(dialog.Selector)
            F.ReskinButton(dialog.Selector.OkayButton)
            F.ReskinButton(dialog.Selector.CancelButton)
        end
    end

    hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', function(self)
        for i = 1, self.ColumnDisplay:GetNumChildren() do
            local child = select(i, self.ColumnDisplay:GetChildren())
            if not child.styled then
                F.StripTextures(child)
                F.CreateBDFrame(child, 0.25)

                child.styled = true
            end
        end
    end)

    -- Benefits
    CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetAlpha(0)
    CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0)
    F.StripTextures(CommunitiesFrame.GuildBenefitsFrame)

    local function handleRewardButton(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.styled then
                local iconbg = F.ReskinIcon(child.Icon)
                F.StripTextures(child)
                child.bg = F.CreateBDFrame(child, 0.25)
                child.bg:ClearAllPoints()
                child.bg:SetPoint('TOPLEFT', iconbg)
                child.bg:SetPoint('BOTTOMLEFT', iconbg)
                child.bg:SetWidth(child:GetWidth() - 5)

                child.styled = true
            end
        end
    end
    hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBox, 'Update', handleRewardButton)
    hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox, 'Update', handleRewardButton)

    local factionFrameBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
    F.StripTextures(factionFrameBar)
    local bg = F.CreateBDFrame(factionFrameBar, 0.25)
    factionFrameBar.Progress:SetTexture(C.Assets.Textures.Backdrop)
    bg:SetOutside(factionFrameBar.Progress)

    -- Guild Info
    F.ReskinButton(CommunitiesFrame.GuildLogButton)
    F.StripTextures(_G.CommunitiesFrameGuildDetailsFrameInfo)
    F.StripTextures(_G.CommunitiesFrameGuildDetailsFrameNews)
    F.ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame.ScrollBar)

    local bg3 = F.CreateBDFrame(_G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame, 0.25)
    bg3:SetPoint('TOPLEFT', 0, 3)
    bg3:SetPoint('BOTTOMRIGHT', -5, -4)

    F.StripTextures(_G.CommunitiesGuildTextEditFrame)
    F.SetBD(_G.CommunitiesGuildTextEditFrame)
    _G.CommunitiesGuildTextEditFrameBg:Hide()
    F.StripTextures(_G.CommunitiesGuildTextEditFrame.Container)
    F.CreateBDFrame(_G.CommunitiesGuildTextEditFrame.Container, 0.25)
    F.ReskinTrimScroll(_G.CommunitiesGuildTextEditFrame.Container.ScrollFrame.ScrollBar)
    F.ReskinClose(_G.CommunitiesGuildTextEditFrameCloseButton)
    F.ReskinButton(_G.CommunitiesGuildTextEditFrameAcceptButton)

    local closeButton = select(4, _G.CommunitiesGuildTextEditFrame:GetChildren())
    F.ReskinButton(closeButton)

    F.ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame.ScrollBar)
    F.CreateBDFrame(_G.CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, 0.25)

    _G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar:GetChildren():Hide()
    F.ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar)
    F.StripTextures(_G.CommunitiesFrameGuildDetailsFrame)

    hooksecurefunc('GuildNewsButton_SetNews', function(button)
        if button.header:IsShown() then
            button.header:SetAlpha(0)
        end
    end)

    F.StripTextures(_G.CommunitiesGuildNewsFiltersFrame)
    _G.CommunitiesGuildNewsFiltersFrameBg:Hide()
    F.SetBD(_G.CommunitiesGuildNewsFiltersFrame)
    F.ReskinClose(_G.CommunitiesGuildNewsFiltersFrame.CloseButton)
    for _, name in
        next,
        {
            'GuildAchievement',
            'Achievement',
            'DungeonEncounter',
            'EpicItemLooted',
            'EpicItemPurchased',
            'EpicItemCrafted',
            'LegendaryItemLooted',
        }
    do
        local filter = _G.CommunitiesGuildNewsFiltersFrame[name]
        F.ReskinCheckbox(filter)
    end

    F.StripTextures(_G.CommunitiesGuildLogFrame)
    _G.CommunitiesGuildLogFrameBg:Hide()
    F.SetBD(_G.CommunitiesGuildLogFrame)
    F.ReskinClose(_G.CommunitiesGuildLogFrameCloseButton)
    F.ReskinTrimScroll(_G.CommunitiesGuildLogFrame.Container.ScrollFrame.ScrollBar)
    F.StripTextures(_G.CommunitiesGuildLogFrame.Container)
    F.CreateBDFrame(_G.CommunitiesGuildLogFrame.Container, 0.25)
    do
        local closeButton = select(3, _G.CommunitiesGuildLogFrame:GetChildren())
        F.ReskinButton(closeButton)
    end

    local bossModel = _G.CommunitiesFrameGuildDetailsFrameNews.BossModel
    F.StripTextures(bossModel)
    bossModel:ClearAllPoints()
    bossModel:SetPoint('LEFT', CommunitiesFrame, 'RIGHT', 40, 0)
    local textFrame = bossModel.TextFrame
    F.StripTextures(textFrame)
    do
        local bg = F.SetBD(bossModel)
        bg:SetOutside(bossModel, nil, nil, textFrame)
    end

    -- Recruitment dialog
    do
        local dialog = CommunitiesFrame.RecruitmentDialog
        F.StripTextures(dialog)
        F.SetBD(dialog)
        F.ReskinCheckbox(dialog.ShouldListClub.Button)
        F.ReskinCheckbox(dialog.MaxLevelOnly.Button)
        F.ReskinCheckbox(dialog.MinIlvlOnly.Button)
        F.ReskinDropdown(dialog.ClubFocusDropdown)
        F.ReskinDropdown(dialog.LookingForDropdown)
        F.ReskinDropdown(dialog.LanguageDropdown)
        F.StripTextures(dialog.RecruitmentMessageFrame)
        F.StripTextures(dialog.RecruitmentMessageFrame.RecruitmentMessageInput)
        F.ReskinTrimScroll(dialog.RecruitmentMessageFrame.RecruitmentMessageInput.ScrollBar)
        F.ReskinEditbox(dialog.RecruitmentMessageFrame)
        F.ReskinEditbox(dialog.MinIlvlOnly.EditBox)
        F.ReskinButton(dialog.Accept)
        F.ReskinButton(dialog.Cancel)
    end

    -- ApplicantList
    local applicantList = CommunitiesFrame.ApplicantList
    F.StripTextures(applicantList)
    F.StripTextures(applicantList.ColumnDisplay)

    local listBG = F.CreateBDFrame(applicantList, 0.25)
    listBG:SetPoint('TOPLEFT', 0, 0)
    listBG:SetPoint('BOTTOMRIGHT', -15, 0)

    local function reskinApplicant(button)
        if button.styled then
            return
        end

        button:SetPoint('LEFT', listBG, C.MULT, 0)
        button:SetPoint('RIGHT', listBG, -C.MULT, 0)
        button:SetHighlightTexture(C.Assets.Textures.Backdrop)
        button:GetHighlightTexture():SetVertexColor(r, g, b, 0.25)
        button.InviteButton:SetSize(66, 18)
        button.CancelInvitationButton:SetSize(20, 18)

        F.ReskinButton(button.InviteButton)
        F.ReskinButton(button.CancelInvitationButton)
        hooksecurefunc(button, 'UpdateMemberInfo', updateMemberName)

        updateRoleTexture(button.RoleIcon1)
        updateRoleTexture(button.RoleIcon2)
        updateRoleTexture(button.RoleIcon3)
        button.styled = true
    end

    hooksecurefunc(applicantList, 'BuildList', function(self)
        local columnDisplay = self.ColumnDisplay
        for i = 1, columnDisplay:GetNumChildren() do
            local child = select(i, columnDisplay:GetChildren())
            if not child.styled then
                F.StripTextures(child)

                local bg = F.CreateBDFrame(child, 0.25)
                bg:SetPoint('TOPLEFT', 4, -2)
                bg:SetPoint('BOTTOMRIGHT', 0, 2)

                child:SetHighlightTexture(C.Assets.Textures.Backdrop)
                local hl = child:GetHighlightTexture()
                hl:SetVertexColor(r, g, b, 0.25)
                hl:SetInside(bg)

                child.styled = true
            end
        end
    end)

    applicantList.ScrollBar:GetChildren():Hide()
    F.ReskinTrimScroll(applicantList.ScrollBar)

    hooksecurefunc(applicantList.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            reskinApplicant(button)
        end
    end)
end
