local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local r, g, b = C.r, C.g, C.b

    PVEFrameLeftInset:SetAlpha(0)
    PVEFrameBlueBg:SetAlpha(0)
    PVEFrame.shadows:SetAlpha(0)

    PVEFrameTab1:ClearAllPoints()
    PVEFrameTab1:SetPoint('TOPLEFT', PVEFrame, 'BOTTOMLEFT', 10, 0)

    local iconSize = 60 - 2 * C.MULT
    for i = 1, 4 do
        local bu = GroupFinderFrame['groupButton' .. i]

        if bu then
            bu.ring:Hide()
            F.ReskinButton(bu, true)
            bu.bg:SetColorTexture(r, g, b, 0.25)
            bu.bg:SetInside(bu.__bg)

            bu.icon:SetPoint('LEFT', bu, 'LEFT')
            bu.icon:SetSize(iconSize, iconSize)
            F.ReskinIcon(bu.icon)
        end
    end

    hooksecurefunc('GroupFinderFrame_SelectGroupButton', function(index)
        for i = 1, 3 do
            local button = GroupFinderFrame['groupButton' .. i]
            if i == index then
                button.bg:Show()
            else
                button.bg:Hide()
            end
        end
    end)

    F.ReskinPortraitFrame(PVEFrame)

    for i = 1, 4 do
        local tab = _G['PVEFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)

            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['PVEFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end

    if ScenarioQueueFrame then
        F.StripTextures(ScenarioFinderFrame)
        ScenarioQueueFrameBackground:SetAlpha(0)

        F.ReskinDropdown(ScenarioQueueFrameTypeDropdown)
        F.ReskinButton(ScenarioQueueFrameFindGroupButton)
        F.ReskinTrimScroll(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
    end
end)
