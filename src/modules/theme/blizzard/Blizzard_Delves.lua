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
    F.ReskinPortraitFrame(DelvesCompanionConfigurationFrame)
    F.ReskinButton(DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

    reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot, true)
    reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot)
    reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot)

    F.ReskinPortraitFrame(DelvesCompanionAbilityListFrame)
    F.ReskinDropdown(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
    F.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, 'left')
    F.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, 'right')

    hooksecurefunc(DelvesCompanionAbilityListFrame, 'UpdatePaginatedButtonDisplay', function(self)
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
    DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
    F.ReskinButton(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

local function handleRewards(self)
    for rewardFrame in self.rewardPool:EnumerateActive() do
        if not rewardFrame.bg then
            F.CreateBDFrame(rewardFrame, .25)
            rewardFrame.NameFrame:SetAlpha(0)
            rewardFrame.bg = F.ReskinIcon(rewardFrame.Icon)
            F.ReskinIconBorder(rewardFrame.IconBorder, true)
        end
    end
end

C.Themes['Blizzard_DelvesDifficultyPicker'] = function()
    F.ReskinPortraitFrame(DelvesDifficultyPickerFrame)
    F.ReskinDropdown(DelvesDifficultyPickerFrame.Dropdown)
    F.ReskinButton(DelvesDifficultyPickerFrame.EnterDelveButton)

    DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:HookScript('OnShow', handleRewards)
    hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, 'SetRewards', handleRewards)
end
