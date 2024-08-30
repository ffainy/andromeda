local F, C = unpack(select(2, ...))

local function skinFactionCategory(button)
    if button.UnlockedState and not button.styled then
        button.UnlockedState.WatchFactionButton:SetSize(28, 28)
        F.ReskinCheckbox(button.UnlockedState.WatchFactionButton)
        button.UnlockedState.WatchFactionButton.Label:SetFontObject(Game18Font)
        button.styled = true
    end
end

C.Themes['Blizzard_ExpansionLandingPage'] = function()
    local frame = ExpansionLandingPage
    local panel

    frame:HookScript('OnShow', function()
        if not panel then
            if frame.Overlay then
                for i = 1, frame.Overlay:GetNumChildren() do
                    local child = select(i, frame.Overlay:GetChildren())
                    if child.DragonridingPanel then
                        panel = child
                        break
                    end
                end
            end
        end

        if panel and not panel.styled then
            panel.NineSlice:SetAlpha(0)
            panel.Background:SetAlpha(0)
            F.SetBD(panel)

            if panel.DragonridingPanel then
                F.ReskinButton(panel.DragonridingPanel.SkillsButton)
            end

            if panel.CloseButton then
                F.ReskinClose(panel.CloseButton)
            end

            if panel.MajorFactionList then
                F.ReskinTrimScroll(panel.MajorFactionList.ScrollBar)
                panel.MajorFactionList.ScrollBox:ForEachFrame(skinFactionCategory)
                hooksecurefunc(panel.MajorFactionList.ScrollBox, 'Update', function(self)
                    self:ForEachFrame(skinFactionCategory)
                end)
            end

            if panel.ScrollFadeOverlay then
                panel.ScrollFadeOverlay:SetAlpha(0)
            end

            panel.styled = true
        end
    end)

    local overlay = ExpansionLandingPage.Overlay
    if overlay then
        for _, child in next, { overlay:GetChildren() } do
            F.SetBD(child)

            if child.ScrollFadeOverlay then
                child.ScrollFadeOverlay:Hide()
            end
        end

        local landingOverlay = overlay.WarWithinLandingOverlay
        local renownFrame = MajorFactionRenownFrame
        if landingOverlay then
            F.ReskinClose(landingOverlay.CloseButton)
            landingOverlay.Background:SetAlpha(0)
            landingOverlay.Border:SetAlpha(0)
        end
        if renownFrame then
            renownFrame.Background:SetAlpha(0)
            renownFrame.Border:SetAlpha(0)
            renownFrame.TopLeftBorderDecoration:SetAlpha(0)
            renownFrame.TopRightBorderDecoration:SetAlpha(0)
            renownFrame.BottomBorderDecoration:SetAlpha(0)
        end
    end
end
