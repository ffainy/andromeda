local F, C = unpack(select(2, ...))

local function reskinEventTraceButton(button)
    F.ReskinButton(button)
    button.NormalTexture:SetAlpha(0)
    button.MouseoverOverlay:SetAlpha(0)
end

local function reskinScrollChild(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        local hideButton = child and child.HideButton
        if hideButton and not hideButton.styled then
            F.ReskinClose(hideButton, nil, nil, nil, true)
            hideButton:ClearAllPoints()
            hideButton:SetPoint('LEFT', 3, 0)

            local checkButton = child.CheckButton
            if checkButton then
                F.ReskinCheckbox(checkButton)
                checkButton:SetSize(22, 22)
            end

            hideButton.styled = true
        end
    end
end

local function reskinEventTraceScrollBox(frame)
    frame:DisableDrawLayer('BACKGROUND')
    F.CreateBDFrame(frame, 0.25)
    hooksecurefunc(frame, 'Update', reskinScrollChild)
end

local function reskinEventTraceFrame(frame)
    reskinEventTraceScrollBox(frame.ScrollBox)
    F.ReskinTrimScroll(frame.ScrollBar)
end

C.Themes['Blizzard_EventTrace'] = function()
    F.ReskinPortraitFrame(_G.EventTrace)

    local subtitleBar = _G.EventTrace.SubtitleBar
    F.ReskinFilterButton(subtitleBar.OptionsDropdown)

    local logBar = _G.EventTrace.Log.Bar
    local filterBar = _G.EventTrace.Filter.Bar
    F.ReskinEditbox(logBar.SearchBox)

    reskinEventTraceFrame(_G.EventTrace.Log.Events)
    reskinEventTraceFrame(_G.EventTrace.Log.Search)
    reskinEventTraceFrame(_G.EventTrace.Filter)

    local buttons = {
        subtitleBar.ViewLog,
        subtitleBar.ViewFilter,
        logBar.DiscardAllButton,
        logBar.PlaybackButton,
        logBar.MarkButton,
        filterBar.DiscardAllButton,
        filterBar.UncheckAllButton,
        filterBar.CheckAllButton,
    }
    for _, button in pairs(buttons) do
        reskinEventTraceButton(button)
    end
end
