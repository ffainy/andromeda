local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local GameMenuFrame = _G['GameMenuFrame']
    F.StripTextures(GameMenuFrame.Header)
    GameMenuFrame.Header:ClearAllPoints()
    GameMenuFrame.Header:SetPoint('TOP', GameMenuFrame, 0, 7)
    F.SetBD(GameMenuFrame)
    GameMenuFrame.Border:Hide()
    GameMenuFrame.Header.Text:SetFontObject(_G.Game16Font)
    local line = GameMenuFrame.Header:CreateTexture(nil, 'ARTWORK')
    line:SetSize(190, C.MULT)
    line:SetPoint('BOTTOM', 0, 5)
    line:SetColorTexture(1, 1, 1, 0.25)

    local buttons = {
        'GameMenuButtonHelp',
        'GameMenuButtonWhatsNew',
        'GameMenuButtonStore',
        'GameMenuButtonMacros',
        'GameMenuButtonAddons',
        'GameMenuButtonLogout',
        'GameMenuButtonQuit',
        'GameMenuButtonContinue',
        'GameMenuButtonSettings',
        'GameMenuButtonEditMode',
    }

    for _, buttonName in next, buttons do
        local button = _G[buttonName]
        if button then
            F.ReskinButton(button)
        end
    end

    hooksecurefunc(GameMenuFrame, 'InitButtons', function(self)
        if not self.buttonPool then
            return
        end

        for button in self.buttonPool:EnumerateActive() do
            if not button.styled then
                local outline = ANDROMEDA_ADB.FontOutline
                local fstring = button:GetFontString()
                fstring:SetFont(C.Assets.Fonts.Bold, 14, outline and 'OUTLINE' or nil)
                fstring:SetShadowColor(0, 0, 0, outline and 0 or 1)
                fstring:SetShadowOffset(2, -2)

                button:SetSize(200, 30)
                F.ReskinButton(button)
                button.styled = true
            end
        end
    end)
end)
