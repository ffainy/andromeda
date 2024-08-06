local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    F.StripTextures(_G.ChatConfigFrame)
    F.SetBD(_G.ChatConfigFrame)
    F.StripTextures(_G.ChatConfigFrame.Header)

    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
        if not _G.FCF_GetCurrentChatFrame() then
            return
        end

        local nameString = frame:GetName() .. 'Checkbox'
        for index in ipairs(frame.checkBoxTable) do
            local checkBoxName = nameString .. index
            local checkbox = _G[checkBoxName]
            if checkbox and not checkbox.styled then
                checkbox:HideBackdrop()
                local bg = F.CreateBDFrame(checkbox, 0.25)
                bg:SetInside()
                F.ReskinCheckbox(_G[checkBoxName .. 'Check'])

                checkbox.styled = true
            end
        end
    end)

    hooksecurefunc('ChatConfig_CreateTieredCheckboxes', function(frame, checkBoxTable)
        if frame.styled then
            return
        end

        local nameString = frame:GetName() .. 'Checkbox'
        for index, value in ipairs(checkBoxTable) do
            local checkBoxName = nameString .. index
            F.ReskinCheckbox(_G[checkBoxName])

            if value.subTypes then
                for i in ipairs(value.subTypes) do
                    F.ReskinCheckbox(_G[checkBoxName .. '_' .. i])
                end
            end
        end

        frame.styled = true
    end)

    hooksecurefunc(_G.ChatConfigFrameChatTabManager, 'UpdateWidth', function(self)
        for tab in self.tabPool:EnumerateActive() do
            if not tab.styled then
                F.StripTextures(tab)

                tab.styled = true
            end
        end
    end)

    for i = 1, 5 do
        local tab = _G['CombatConfigTab' .. i]
        if tab then
            F.StripTextures(tab)

            if tab.Text then
                tab.Text:SetWidth(tab.Text:GetWidth() + 10)
            end
        end
    end

    local line = _G.ChatConfigFrame:CreateTexture()
    line:SetSize(C.MULT, 460)
    line:SetPoint('TOPLEFT', _G.ChatConfigCategoryFrame, 'TOPRIGHT')
    line:SetColorTexture(1, 1, 1, 0.25)

    local backdrops = {
        _G.ChatConfigCategoryFrame,
        _G.ChatConfigBackgroundFrame,
        _G.ChatConfigCombatSettingsFilters,
        _G.CombatConfigColorsHighlighting,
        _G.CombatConfigColorsColorizeUnitName,
        _G.CombatConfigColorsColorizeSpellNames,
        _G.CombatConfigColorsColorizeDamageNumber,
        _G.CombatConfigColorsColorizeDamageSchool,
        _G.CombatConfigColorsColorizeEntireLine,
        _G.ChatConfigChatSettingsLeft,
        _G.ChatConfigOtherSettingsCombat,
        _G.ChatConfigOtherSettingsPVP,
        _G.ChatConfigOtherSettingsSystem,
        _G.ChatConfigOtherSettingsCreature,
        _G.ChatConfigChannelSettingsLeft,
        _G.CombatConfigMessageSourcesDoneBy,
        _G.CombatConfigColorsUnitColors,
        _G.CombatConfigMessageSourcesDoneTo,
    }
    for _, frame in pairs(backdrops) do
        F.StripTextures(frame)
    end

    local combatBoxes = {
        _G.CombatConfigColorsHighlightingLine,
        _G.CombatConfigColorsHighlightingAbility,
        _G.CombatConfigColorsHighlightingDamage,
        _G.CombatConfigColorsHighlightingSchool,
        _G.CombatConfigColorsColorizeUnitNameCheck,
        _G.CombatConfigColorsColorizeSpellNamesCheck,
        _G.CombatConfigColorsColorizeSpellNamesSchoolColoring,
        _G.CombatConfigColorsColorizeDamageNumberCheck,
        _G.CombatConfigColorsColorizeDamageNumberSchoolColoring,
        _G.CombatConfigColorsColorizeDamageSchoolCheck,
        _G.CombatConfigColorsColorizeEntireLineCheck,
        _G.CombatConfigFormattingShowTimeStamp,
        _G.CombatConfigFormattingShowBraces,
        _G.CombatConfigFormattingUnitNames,
        _G.CombatConfigFormattingSpellNames,
        _G.CombatConfigFormattingItemNames,
        _G.CombatConfigFormattingFullText,
        _G.CombatConfigSettingsShowQuickButton,
        _G.CombatConfigSettingsSolo,
        _G.CombatConfigSettingsParty,
        _G.CombatConfigSettingsRaid,
    }
    for _, box in pairs(combatBoxes) do
        F.ReskinCheckbox(box)
    end

    hooksecurefunc('ChatConfig_UpdateSwatches', function(frame)
        if not frame.swatchTable then
            return
        end

        local nameString = frame:GetName() .. 'Swatch'
        local baseName
        for index in ipairs(frame.swatchTable) do
            baseName = nameString .. index
            local bu = _G[baseName]
            if not bu.styled then
                F.StripTextures(bu)
                F.CreateBDFrame(bu, 0.25):SetInside()
                F.ReskinColorSwatch(_G[baseName .. 'ColorSwatch'])
                bu.styled = true
            end
        end
    end)

    local bg = F.CreateBDFrame(_G.ChatConfigCombatSettingsFilters, 0.25)
    bg:SetPoint('TOPLEFT', 3, 0)
    bg:SetPoint('BOTTOMRIGHT', 0, 1)

    F.ReskinButton(_G.CombatLogDefaultButton)
    F.ReskinButton(_G.ChatConfigCombatSettingsFiltersCopyFilterButton)
    F.ReskinButton(_G.ChatConfigCombatSettingsFiltersAddFilterButton)
    F.ReskinButton(_G.ChatConfigCombatSettingsFiltersDeleteButton)
    F.ReskinButton(_G.CombatConfigSettingsSaveButton)
    F.ReskinButton(_G.ChatConfigFrameOkayButton)
    F.ReskinButton(_G.ChatConfigFrameDefaultButton)
    F.ReskinButton(_G.ChatConfigFrameRedockButton)
    F.ReskinArrow(_G.ChatConfigMoveFilterUpButton, 'up')
    F.ReskinArrow(_G.ChatConfigMoveFilterDownButton, 'down')
    F.ReskinEditbox(_G.CombatConfigSettingsNameEditBox)
    F.ReskinRadio(_G.CombatConfigColorsColorizeEntireLineBySource)
    F.ReskinRadio(_G.CombatConfigColorsColorizeEntireLineByTarget)
    F.ReskinColorSwatch(_G.CombatConfigColorsColorizeSpellNamesColorSwatch)
    F.ReskinColorSwatch(_G.CombatConfigColorsColorizeDamageNumberColorSwatch)
    F.ReskinTrimScroll(_G.ChatConfigCombatSettingsFilters.ScrollBar)

    _G.ChatConfigMoveFilterUpButton:SetSize(22, 22)
    _G.ChatConfigMoveFilterDownButton:SetSize(22, 22)

    _G.ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint(
        'RIGHT',
        _G.ChatConfigCombatSettingsFiltersDeleteButton,
        'LEFT',
        -1,
        0
    )
    _G.ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint(
        'RIGHT',
        _G.ChatConfigCombatSettingsFiltersAddFilterButton,
        'LEFT',
        -1,
        0
    )
    _G.ChatConfigMoveFilterUpButton:SetPoint('TOPLEFT', _G.ChatConfigCombatSettingsFilters, 'BOTTOMLEFT', 3, 0)
    _G.ChatConfigMoveFilterDownButton:SetPoint('LEFT', _G.ChatConfigMoveFilterUpButton, 'RIGHT', 1, 0)

    -- TextToSpeech
    F.StripTextures(_G.TextToSpeechButton, 5)

    F.ReskinButton(_G.TextToSpeechFramePlaySampleButton)
    F.ReskinButton(_G.TextToSpeechFramePlaySampleAlternateButton)
    F.ReskinButton(_G.TextToSpeechDefaultButton)
    F.ReskinCheckbox(_G.TextToSpeechCharacterSpecificButton)

    F.ReskinDropdown(_G.TextToSpeechFrameTtsVoiceDropdown)
    F.ReskinDropdown(_G.TextToSpeechFrameTtsVoiceAlternateDropdown)
    F.ReskinSlider(_G.TextToSpeechFrameAdjustRateSlider)
    F.ReskinSlider(_G.TextToSpeechFrameAdjustVolumeSlider)

    local checkboxes = {
        'PlayActivitySoundWhenNotFocusedCheckButton',
        'PlaySoundSeparatingChatLinesCheckButton',
        'AddCharacterNameToSpeechCheckButton',
        'NarrateMyMessagesCheckButton',
        'UseAlternateVoiceForSystemMessagesCheckButton',
    }
    for _, checkbox in pairs(checkboxes) do
        local check = _G.TextToSpeechFramePanelContainer[checkbox]
        F.ReskinCheckbox(check)
        check.bg:SetInside(check, 6, 6)
    end

    hooksecurefunc('TextToSpeechFrame_UpdateMessageCheckboxes', function(frame)
        local checkBoxTable = frame.checkBoxTable
        if checkBoxTable then
            local checkBoxNameString = frame:GetName() .. 'Checkbox'
            local checkBoxName, checkBox
            for index in ipairs(checkBoxTable) do
                checkBoxName = checkBoxNameString .. index
                checkBox = _G[checkBoxName]
                if checkBox and not checkBox.styled then
                    F.ReskinCheckbox(checkBox)
                    checkBox.bg:SetInside(checkBox, 6, 6)
                    checkBox.styled = true
                end
            end
        end
    end)

    -- voice pickers
    F.StripTextures(_G.ChatConfigTextToSpeechChannelSettingsLeft)
end)
