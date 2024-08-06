local F, C = unpack(select(2, ...))

local function reskinEventList(frame)
    F.StripTextures(frame)
    F.CreateBDFrame(frame, 0.25)

    if frame.ScrollBar then
        F.ReskinTrimScroll(frame.ScrollBar)
    end
end

local function reskinCalendarPage(frame)
    F.StripTextures(frame)
    F.SetBD(frame)
    F.StripTextures(frame.Header)

    if frame.ScrollBar then
        F.ReskinTrimScroll(frame.ScrollBar)
    end
end

C.Themes['Blizzard_Calendar'] = function()
    local r, g, b = C.r, C.g, C.b

    for i = 1, 42 do
        local dayButtonName = 'CalendarDayButton' .. i
        local bu = _G[dayButtonName]
        bu:DisableDrawLayer('BACKGROUND')
        bu:SetHighlightTexture(C.Assets.Textures.Backdrop)
        local bg = F.CreateBDFrame(bu, 0.25)
        bg:SetInside()
        local hl = bu:GetHighlightTexture()
        hl:SetVertexColor(r, g, b, 0.25)
        hl:SetInside(bg)
        hl.SetAlpha = nop

        _G[dayButtonName .. 'DarkFrame']:SetAlpha(0.5)
        _G[dayButtonName .. 'EventTexture']:SetInside(bg)
        _G[dayButtonName .. 'EventBackgroundTexture']:SetAlpha(0)
        _G[dayButtonName .. 'OverlayFrameTexture']:SetInside(bg)

        local eventButtonIndex = 1
        local eventButton = _G[dayButtonName .. 'EventButton' .. eventButtonIndex]
        while eventButton do
            eventButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            eventButton.black:SetTexture(nil)
            eventButtonIndex = eventButtonIndex + 1
            eventButton = _G[dayButtonName .. 'EventButton' .. eventButtonIndex]
        end
    end

    for i = 1, 7 do
        _G['CalendarWeekday' .. i .. 'Background']:SetAlpha(0)
    end

    _G.CalendarViewEventDivider:Hide()
    _G.CalendarCreateEventDivider:Hide()
    _G.CalendarCreateEventFrameButtonBackground:Hide()
    _G.CalendarCreateEventMassInviteButtonBorder:Hide()
    _G.CalendarCreateEventCreateButtonBorder:Hide()
    F.ReskinIcon(_G.CalendarCreateEventIcon)
    _G.CalendarCreateEventIcon.SetTexCoord = nop
    _G.CalendarEventPickerCloseButtonBorder:Hide()
    _G.CalendarCreateEventRaidInviteButtonBorder:Hide()
    _G.CalendarMonthBackground:SetAlpha(0)
    _G.CalendarYearBackground:SetAlpha(0)
    _G.CalendarFrameModalOverlay:SetAlpha(0.25)
    _G.CalendarViewHolidayFrame.Texture:SetAlpha(0)
    _G.CalendarTexturePickerAcceptButtonBorder:Hide()
    _G.CalendarTexturePickerCancelButtonBorder:Hide()
    F.StripTextures(_G.CalendarClassTotalsButton)

    F.StripTextures(_G.CalendarFrame)
    F.SetBD(_G.CalendarFrame, nil, 9, 0, -7, 1)
    F.CreateBDFrame(_G.CalendarClassTotalsButton)

    reskinEventList(_G.CalendarViewEventInviteList)
    reskinEventList(_G.CalendarViewEventDescriptionContainer)
    reskinEventList(_G.CalendarCreateEventInviteList)
    reskinEventList(_G.CalendarCreateEventDescriptionContainer)

    reskinCalendarPage(_G.CalendarViewHolidayFrame)
    reskinCalendarPage(_G.CalendarCreateEventFrame)
    reskinCalendarPage(_G.CalendarViewEventFrame)
    reskinCalendarPage(_G.CalendarTexturePickerFrame)
    reskinCalendarPage(_G.CalendarEventPickerFrame)
    reskinCalendarPage(_G.CalendarViewRaidFrame)

    local frames = {
        _G.CalendarViewEventTitleFrame,
        _G.CalendarViewHolidayTitleFrame,
        _G.CalendarViewRaidTitleFrame,
        _G.CalendarCreateEventTitleFrame,
        _G.CalendarTexturePickerTitleFrame,
        _G.CalendarMassInviteTitleFrame,
    }
    for _, titleFrame in next, frames do
        F.StripTextures(titleFrame)
        local parent = titleFrame:GetParent()
        F.StripTextures(parent)
        F.SetBD(parent)
    end

    _G.CalendarWeekdaySelectedTexture:SetDesaturated(true)
    _G.CalendarWeekdaySelectedTexture:SetVertexColor(r, g, b)

    hooksecurefunc('CalendarFrame_SetToday', function()
        _G.CalendarTodayFrame:SetAllPoints()
    end)

    _G.CalendarTodayFrame:SetScript('OnUpdate', nil)
    _G.CalendarTodayTextureGlow:Hide()
    _G.CalendarTodayTexture:Hide()

    local bg = F.CreateBDFrame(_G.CalendarTodayFrame, 0)
    bg:SetInside()
    bg:SetBackdropBorderColor(r, g, b)

    for i, class in ipairs(_G.CLASS_SORT_ORDER) do
        local bu = _G['CalendarClassButton' .. i]
        bu:GetRegions():Hide()
        F.CreateBDFrame(bu)
        F.ClassIconTexCoord(bu:GetNormalTexture(), class)
    end

    F.ReskinFilterButton(_G.CalendarFrame.FilterButton)
    _G.CalendarViewEventFrame:SetPoint('TOPLEFT', _G.CalendarFrame, 'TOPRIGHT', -6, -24)
    _G.CalendarViewHolidayFrame:SetPoint('TOPLEFT', _G.CalendarFrame, 'TOPRIGHT', -6, -24)
    _G.CalendarViewRaidFrame:SetPoint('TOPLEFT', _G.CalendarFrame, 'TOPRIGHT', -6, -24)
    _G.CalendarCreateEventFrame:SetPoint('TOPLEFT', _G.CalendarFrame, 'TOPRIGHT', -6, -24)
    _G.CalendarCreateEventInviteButton:SetPoint('TOPLEFT', _G.CalendarCreateEventInviteEdit, 'TOPRIGHT', 1, 1)
    _G.CalendarClassButton1:SetPoint('TOPLEFT', _G.CalendarClassButtonContainer, 'TOPLEFT', 5, 0)

    local line = _G.CalendarMassInviteFrame:CreateTexture(nil, 'BACKGROUND')
    line:SetSize(240, C.MULT)
    line:SetPoint('TOP', _G.CalendarMassInviteFrame, 'TOP', 0, -150)
    line:SetTexture(C.Assets.Textures.Backdrop)
    line:SetVertexColor(0, 0, 0)

    _G.CalendarMassInviteFrame:ClearAllPoints()
    _G.CalendarMassInviteFrame:SetPoint('BOTTOMLEFT', _G.CalendarCreateEventFrame, 'BOTTOMRIGHT', 28, 0)
    _G.CalendarTexturePickerFrame:ClearAllPoints()
    _G.CalendarTexturePickerFrame:SetPoint('TOPLEFT', _G.CalendarCreateEventFrame, 'TOPRIGHT', 28, 0)

    local cbuttons = {
        'CalendarViewEventAcceptButton',
        'CalendarViewEventTentativeButton',
        'CalendarViewEventDeclineButton',
        'CalendarViewEventRemoveButton',
        'CalendarCreateEventMassInviteButton',
        'CalendarCreateEventCreateButton',
        'CalendarCreateEventInviteButton',
        'CalendarEventPickerCloseButton',
        'CalendarCreateEventRaidInviteButton',
        'CalendarTexturePickerAcceptButton',
        'CalendarTexturePickerCancelButton',
        'CalendarMassInviteAcceptButton',
    }
    for i = 1, #cbuttons do
        local cbutton = _G[cbuttons[i]]
        if not cbutton then
            print(cbuttons[i])
        else
            F.ReskinButton(cbutton)
        end
    end

    _G.CalendarViewEventAcceptButton.flashTexture:SetTexture('')
    _G.CalendarViewEventTentativeButton.flashTexture:SetTexture('')
    _G.CalendarViewEventDeclineButton.flashTexture:SetTexture('')

    F.ReskinClose(_G.CalendarCloseButton, _G.CalendarFrame, -14, -4)
    F.ReskinClose(_G.CalendarCreateEventCloseButton)
    F.ReskinClose(_G.CalendarViewEventCloseButton)
    F.ReskinClose(_G.CalendarViewHolidayCloseButton)
    F.ReskinClose(_G.CalendarViewRaidCloseButton)
    F.ReskinClose(_G.CalendarMassInviteCloseButton)

    F.ReskinDropdown(_G.CalendarCreateEventFrame.CommunityDropdown)
    F.ReskinDropdown(_G.CalendarCreateEventFrame.EventTypeDropdown)
    F.ReskinDropdown(_G.CalendarCreateEventFrame.HourDropdown)
    F.ReskinDropdown(_G.CalendarCreateEventFrame.MinuteDropdown)
    F.ReskinDropdown(_G.CalendarCreateEventFrame.AMPMDropdown)
    F.ReskinDropdown(_G.CalendarMassInviteFrame.CommunityDropdown)
    F.ReskinDropdown(_G.CalendarMassInviteFrame.RankDropdown)

    F.ReskinEditbox(_G.CalendarCreateEventTitleEdit)
    F.ReskinEditbox(_G.CalendarCreateEventInviteEdit)
    F.ReskinEditbox(_G.CalendarMassInviteMinLevelEdit)
    F.ReskinEditbox(_G.CalendarMassInviteMaxLevelEdit)
    F.ReskinArrow(_G.CalendarPrevMonthButton, 'left')
    F.ReskinArrow(_G.CalendarNextMonthButton, 'right')
    _G.CalendarPrevMonthButton:SetSize(19, 19)
    _G.CalendarNextMonthButton:SetSize(19, 19)
    F.ReskinCheckbox(_G.CalendarCreateEventLockEventCheck)
end
