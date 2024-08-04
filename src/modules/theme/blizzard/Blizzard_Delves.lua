local F, C = unpack(select(2, ...))

local function reskinButton(button)
    if button.styled then
        return
    end
    if button.Border then
        button.Border:SetAlpha(0)
    end
    if button.Icon then
        F.ReskinIcon(button.Icon)
    end
    button.styled = true
end

local function updateButton(self)
    self:ForEachFrame(reskinButton)
end

local function reskinOptionSlot(frame, skip)
    local option = frame.OptionsList
    F.StripTextures(option)
    F.SetBD(option, nil, -5, 5, 5, -5)
    if not skip then
        hooksecurefunc(option.ScrollBox, 'Update', updateButton)
    end
end

C.Themes['Blizzard_DelvesCompanionConfiguration'] = function()
    F.ReskinPortraitFrame(_G.DelvesCompanionConfigurationFrame)
    F.ReskinButton(_G.DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot, true)
    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot)
    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot)

    F.ReskinPortraitFrame(_G.DelvesCompanionAbilityListFrame)
    F.ReskinDropdown(_G.DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
    F.ReskinArrow(_G.DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, 'left')
    F.ReskinArrow(_G.DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, 'right')

    hooksecurefunc(_G.DelvesCompanionAbilityListFrame, 'UpdatePaginatedButtonDisplay', function(self)
        for _, button in pairs(self.buttons) do
            if not button.styled then
                if button.Icon then
                    F.ReskinIcon(button.Icon)
                end

                button.styled = true
            end
        end
    end)
end

C.Themes['Blizzard_DelvesDashboardUI'] = function()
    _G.DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
    F.ReskinButton(_G.DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

C.Themes['Blizzard_DelvesDifficultyPicker'] = function()
    F.ReskinPortraitFrame(_G.DelvesDifficultyPickerFrame)
    F.ReskinDropdown(_G.DelvesDifficultyPickerFrame.Dropdown)
    F.ReskinButton(_G.DelvesDifficultyPickerFrame.EnterDelveButton)

    hooksecurefunc(_G.DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, 'SetRewards', function(self)
        for rewardFrame in self.rewardPool:EnumerateActive() do
            if not rewardFrame.styled then
                F.CreateBDFrame(rewardFrame, 0.25)
                rewardFrame.NameFrame:SetAlpha(0)
                rewardFrame.IconBorder:SetAlpha(0)
                F.ReskinIcon(rewardFrame.Icon)
                rewardFrame.styled = true
            end
        end
    end)
end
