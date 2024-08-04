local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    local r, g, b = C.r, C.g, C.b

    _G.PVEFrameLeftInset:SetAlpha(0)
    _G.PVEFrameBlueBg:SetAlpha(0)
    _G.PVEFrame.shadows:SetAlpha(0)

    _G.PVEFrameTab1:ClearAllPoints()
    _G.PVEFrameTab1:SetPoint('TOPLEFT', _G.PVEFrame, 'BOTTOMLEFT', 10, 0)

    local iconSize = 60 - 2 * C.MULT
    for i = 1, 4 do
        local bu = _G.GroupFinderFrame['groupButton' .. i]

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
            local button = _G.GroupFinderFrame['groupButton' .. i]
            if i == index then
                button.bg:Show()
            else
                button.bg:Hide()
            end
        end
    end)

    F.ReskinPortraitFrame(_G.PVEFrame)

    for i = 1, 3 do
        local tab = _G['PVEFrameTab' .. i]
        if tab then
            F.ReskinTab(tab)

            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint('TOPLEFT', _G['PVEFrameTab' .. (i - 1)], 'TOPRIGHT', -10, 0)
            end
        end
    end

    if _G.ScenarioQueueFrame then
        F.StripTextures(_G.ScenarioFinderFrame)
        _G.ScenarioQueueFrameBackground:SetAlpha(0)

        F.ReskinDropdown(_G.ScenarioQueueFrameTypeDropdown)
        F.ReskinButton(_G.ScenarioQueueFrameFindGroupButton)
        F.ReskinTrimScroll(_G.ScenarioQueueFrameRandomScrollFrame.ScrollBar)
        if _G.ScenarioQueueFrameRandomScrollFrameScrollBar then
            _G.ScenarioQueueFrameRandomScrollFrameScrollBar:SetAlpha(0)
        end
    end
end)
