local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local toggleButton = _G.CompactRaidFrameManagerToggleButton
    if not toggleButton then
        return
    end

    toggleButton:SetSize(16, 16)

    local nt = toggleButton:GetNormalTexture()

    local function updateArrow()
        if _G.CompactRaidFrameManager.collapsed then
            F.SetupArrow(nt, 'right')
        else
            F.SetupArrow(nt, 'left')
        end
        nt:SetTexCoord(0, 1, 0, 1)
    end

    updateArrow()
    hooksecurefunc('CompactRaidFrameManager_Collapse', updateArrow)
    hooksecurefunc('CompactRaidFrameManager_Expand', updateArrow)

    F.ReskinDropdown(_G.CompactRaidFrameManagerDisplayFrameModeControlDropdown)
    F.ReskinDropdown(_G.CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
    for _, button in pairs({ _G.CompactRaidFrameManager.displayFrame.BottomButtons:GetChildren() }) do
        if button:IsObjectType('Button') then
            F.ReskinButton(button)
        end
    end

    F.StripTextures(_G.CompactRaidFrameManager, 0)

    select(1, _G.CompactRaidFrameManagerDisplayFrame:GetRegions()):SetAlpha(0)

    local bd = F.SetBD(_G.CompactRaidFrameManager)
    bd:SetPoint('TOPLEFT')
    bd:SetPoint('BOTTOMRIGHT', -9, 9)
    F.ReskinCheckbox(_G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
    F.ReskinCheckbox(_G.CompactRaidFrameManagerDisplayFrameEveryoneIsAssistButton)
end)
