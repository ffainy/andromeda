local F, C = unpack(select(2, ...))
local ep = F:RegisterModule('EnhancedPremade')
local TOOLTIP = F:GetModule('Tooltip')

--[[
    Optimize premade functionality and display
    Double-click on a search result for a quick application
    Hide unimportant windows automatically
    Invite applicants automatically
    Show leader's mythic score
    Abbreviated keystone
--]]

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME or 1
local scoreFormat = C.GREY_COLOR .. '(%s) |r%s'

function ep:HookApplicationClick()
    if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
        LFGListFrame.SearchPanel.SignUpButton:Click()
    end

    if
        (not IsAltKeyDown())
        and LFGListApplicationDialog:IsShown()
        and LFGListApplicationDialog.SignUpButton:IsEnabled()
    then
        LFGListApplicationDialog.SignUpButton:Click()
    end
end

local pendingFrame
function ep:DialogHideInSecond()
    if not pendingFrame then
        return
    end

    if pendingFrame.informational then
        StaticPopupSpecial_Hide(pendingFrame)
    elseif pendingFrame == 'LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS' then
        StaticPopup_Hide(pendingFrame)
    end

    pendingFrame = nil
end

function ep:HookDialogOnShow()
    pendingFrame = self
    F:Delay(1, ep.DialogHideInSecond)
end

local factionStr = {
    [0] = 'Horde',
    [1] = 'Alliance',
}

function ep:ShowLeaderOverallScore()
    local resultID = self.resultID
    local searchResultInfo = resultID and C_LFGList.GetSearchResultInfo(resultID)
    if searchResultInfo then
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode)
        if activityInfo then
            local showScore = activityInfo.isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore
                or activityInfo.isRatedPvpActivity
                and searchResultInfo.leaderPvpRatingInfo
                and searchResultInfo.leaderPvpRatingInfo.rating
            if showScore then
                local oldName = self.ActivityName:GetText()
                oldName = gsub(oldName, '.-' .. HEADER_COLON, '') -- Tazavesh
                self.ActivityName:SetFormattedText(scoreFormat, TOOLTIP.GetDungeonScore(showScore), oldName)

                if not self.crossFactionLogo then
                    local logo = self:CreateTexture(nil, 'OVERLAY')
                    logo:SetPoint('TOPLEFT', -6, 5)
                    logo:SetSize(24, 24)
                    self.crossFactionLogo = logo
                end
            end
        end

        if self.crossFactionLogo then
            if searchResultInfo.crossFactionListing then
                self.crossFactionLogo:Hide()
            else
                self.crossFactionLogo:SetTexture(
                    'Interface\\Timer\\' .. factionStr[searchResultInfo.leaderFactionGroup] .. '-Logo'
                )
                self.crossFactionLogo:Show()
            end
        end
    end
end

function ep:AddAutoAcceptButton()
    local bu = F.CreateCheckbox(LFGListFrame.ApplicationViewer, true)
    bu:SetSize(14, 14)
    bu:SetHitRectInsets(0, -130, 0, 0)
    bu:SetPoint('BOTTOMLEFT', LFGListFrame.ApplicationViewer.InfoBackground, 'LEFT', 12, -30)

    local outline = ANDROMEDA_ADB.FontOutline
    F.CreateFS(
        bu,
        C.Assets.Fonts.Regular, 12, outline or nil,
        LFG_LIST_AUTO_ACCEPT,
        'YELLOW', outline and 'NONE' or 'THICK',
        'LEFT', 24, 0
    )

    local isCN = GetCVar('portal') == 'CN'
    local lastTime = 0
    local function clickInviteButton(button)
        if button.applicantID and button.InviteButton:IsEnabled() then
            if C.DB.Chat.DisableProfanityFilter and isCN then
                ConsoleExec('portal CN')
            end
            C_LFGList.InviteApplicant(button.applicantID)
            if C.DB.Chat.DisableProfanityFilter and isCN then
                ConsoleExec('portal TW')
            end
        end
    end

    F:RegisterEvent('LFG_LIST_APPLICANT_LIST_UPDATED', function()
        if not bu:GetChecked() then
            return
        end
        if not UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME) then
            return
        end

        LFGListFrame.ApplicationViewer.ScrollBox:ForEachFrame(clickInviteButton)

        if LFGListFrame.ApplicationViewer:IsShown() then
            local now = GetTime()
            if now - lastTime > 1 then
                lastTime = now
                LFGListFrame.ApplicationViewer.RefreshButton:Click()
            end
        end
    end)

    hooksecurefunc('LFGListApplicationViewer_UpdateInfo', function(self)
        bu:SetShown(UnitIsGroupLeader('player', LE_PARTY_CATEGORY_HOME) and not self.AutoAcceptButton:IsShown())
    end)
end

function ep:ReplaceFindGroupButton()
    if not C_AddOns.IsAddOnLoaded('PremadeGroupsFilter') then
        return
    end

    LFGListFrame.CategorySelection.FindGroupButton:Hide()

    local bu = CreateFrame('Button', nil, LFGListFrame.CategorySelection, 'LFGListMagicButtonTemplate')
    bu:SetText(LFG_LIST_FIND_A_GROUP)
    bu:SetSize(135, 22)
    bu:SetPoint('BOTTOMRIGHT', -3, 4)

    local lastCategory = 0
    bu:SetScript('OnClick', function()
        local selectedCategory = LFGListFrame.CategorySelection.selectedCategory
        if not selectedCategory then
            return
        end

        if lastCategory ~= selectedCategory then
            LFGListFrame.CategorySelection.FindGroupButton:Click()
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            LFGListSearchPanel_SetCategory(
                LFGListFrame.SearchPanel,
                selectedCategory,
                LFGListFrame.CategorySelection.selectedFilters,
                LFGListFrame.baseFilters
            )
            LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
            LFGListFrame_SetActivePanel(LFGListFrame, LFGListFrame.SearchPanel)
        end
        lastCategory = selectedCategory
    end)

    if ANDROMEDA_ADB.ReskinBlizz then
        F.ReskinButton(bu)
    end
end

local function clickSortButton(self)
    self.__owner.Sorting.Expression:SetText(self.sortStr)
    self.__parent.RefreshButton:Click()
end

local function createSortButton(parent, texture, sortStr, panel)
    local bu = F.CreateButton(parent, 24, 24, true, texture)
    bu.sortStr = sortStr
    bu.__parent = parent
    bu.__owner = panel
    bu:SetScript('OnClick', clickSortButton)
    F.AddTooltip(bu, 'ANCHOR_RIGHT', CLUB_FINDER_SORT_BY)

    tinsert(parent.__sortBu, bu)
end

function ep:AddPGFSortingExpression()
    if not C_AddOns.IsAddOnLoaded('PremadeGroupsFilter') then
        return
    end

    local PGFDialog = _G['PremadeGroupsFilterDialog']
    local ExpressionPanel = _G['PremadeGroupsFilterMiniPanel']
    PGFDialog.__sortBu = {}

    createSortButton(PGFDialog, 525134, 'mprating desc', ExpressionPanel)
    createSortButton(PGFDialog, 1455894, 'pvprating desc', ExpressionPanel)
    createSortButton(PGFDialog, 237538, 'age asc', ExpressionPanel)

    for i = 1, #PGFDialog.__sortBu do
        local bu = PGFDialog.__sortBu[i]
        if i == 1 then
            bu:SetPoint('BOTTOMLEFT', PGFDialog, 'BOTTOMRIGHT', 3, 0)
        else
            bu:SetPoint('BOTTOM', PGFDialog.__sortBu[i - 1], 'TOP', 0, 3)
        end
    end

    if _G['PremadeGroupsFilterSettings'] then
        _G['PremadeGroupsFilterSettings'].classBar = false
        _G['PremadeGroupsFilterSettings'].classCircle = false
        _G['PremadeGroupsFilterSettings'].leaderCrown = false
        _G['PremadeGroupsFilterSettings'].ratingInfo = false
        _G['PremadeGroupsFilterSettings'].oneClickSignUp = false
    end
end

-- Fix LFG taint
-- Credit: PremadeGroupsFilter

function ep:FixListingTaint()
    if C_AddOns.IsAddOnLoaded('PremadeGroupsFilter') then
        return
    end

    local activityIdOfArbitraryMythicPlusDungeon = 1160 -- Algeth'ar Academy
    if not C_LFGList.IsPlayerAuthenticatedForLFG(activityIdOfArbitraryMythicPlusDungeon) then
        return
    end

    C_LFGList.GetPlaystyleString = function(playstyle, activityInfo)
        if
            not (
                activityInfo
                and playstyle
                and playstyle ~= 0
                and C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown
            )
        then
            return nil
        end
        local globalStringPrefix
        if activityInfo.isMythicPlusActivity then
            globalStringPrefix = 'GROUP_FINDER_PVE_PLAYSTYLE'
        elseif activityInfo.isRatedPvpActivity then
            globalStringPrefix = 'GROUP_FINDER_PVP_PLAYSTYLE'
        elseif activityInfo.isCurrentRaidActivity then
            globalStringPrefix = 'GROUP_FINDER_PVE_RAID_PLAYSTYLE'
        elseif activityInfo.isMythicActivity then
            globalStringPrefix = 'GROUP_FINDER_PVE_MYTHICZERO_PLAYSTYLE'
        end
        return globalStringPrefix and _G[globalStringPrefix .. tostring(playstyle)] or nil
    end

    -- Disable automatic group titles to prevent tainting errors
    LFGListEntryCreation_SetTitleFromActivityInfo = function(_) end
end

function ep:OnLogin()
    if not C.DB.General.EnhancedPremade then
        return
    end

    hooksecurefunc(LFGListFrame.SearchPanel.ScrollBox, 'Update', function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.Name and not child.hooked then
                child.Name:SetFontObject(Game13Font)
                child.ActivityName:SetFontObject(Game12Font)
                child:HookScript('OnDoubleClick', ep.HookApplicationClick)

                child.hooked = true
            end
        end
    end)

    hooksecurefunc('LFGListInviteDialog_Accept', function()
        if PVEFrame:IsShown() then HideUIPanel(PVEFrame) end
    end)

    hooksecurefunc('StaticPopup_Show', ep.HookDialogOnShow)
    hooksecurefunc('LFGListInviteDialog_Show', ep.HookDialogOnShow)
    hooksecurefunc('LFGListSearchEntry_Update', ep.ShowLeaderOverallScore)

    ep:AddAutoAcceptButton()
    ep:ReplaceFindGroupButton()
    ep:AddPGFSortingExpression()
    ep:FixListingTaint()
end
