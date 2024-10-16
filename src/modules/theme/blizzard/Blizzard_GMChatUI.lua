local F, C = unpack(select(2, ...))

-- /run C_AddOns.LoadAddOn'Blizzard_GMChatUI' GMChatFrame:Show()
C.Themes['Blizzard_GMChatUI'] = function()
    local frame = _G['GMChatFrame']
    frame:SetClampRectInsets(0, 0, 0, 0)
    F.StripTextures(frame)
    local bg = F.SetBD(frame)
    bg:SetPoint('BOTTOMRIGHT', C.MULT, -5)

    local eb = frame.editBox
    eb:SetAltArrowKeyMode(false)
    for i = 3, 8 do
        select(i, eb:GetRegions()):SetAlpha(0)
    end
    eb:ClearAllPoints()
    eb:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', 0, -7)
    eb:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -28, -32)

    local ebbg = F.SetBD(eb)
    ebbg:Hide()
    hooksecurefunc('ChatEdit_DeactivateChat', function(editBox)
        if editBox.isGM then
            ebbg:Hide()
        end
    end)
    hooksecurefunc('ChatEdit_ActivateChat', function(editBox)
        if editBox.isGM then
            ebbg:Show()
        end
    end)

    local lang = _G['GMChatFrameEditBoxLanguage']
    lang:GetRegions():SetAlpha(0)
    lang:SetPoint('TOPLEFT', eb, 'TOPRIGHT', 3, 0)
    lang:SetPoint('BOTTOMRIGHT', eb, 'BOTTOMRIGHT', 28, 0)
    F.SetBD(lang)

    local tab = _G['GMChatTab']
    F.StripTextures(tab)
    local tabbg = F.SetBD(tab)
    tabbg:SetBackdropColor(0, 0.6, 1, 0.3)
    tab:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', 0, 3)
    tab:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 28)
    _G.GMChatTabIcon:SetTexture('Interface\\ChatFrame\\UI-ChatIcon-Blizz')

    local close = _G.GMChatFrameCloseButton
    F.ReskinClose(close)
    close:ClearAllPoints()
    close:SetPoint('RIGHT', tab, -5, 0)

    F.HideObject(frame.buttonFrame)
end
