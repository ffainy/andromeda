local F, C = unpack(select(2, ...))

C.Themes['Blizzard_BarbershopUI'] = function()
    local frame = BarberShopFrame

    F.ReskinButton(frame.AcceptButton)
    F.ReskinButton(frame.CancelButton)
    F.ReskinButton(frame.ResetButton)
end

local function reskinCustomizeButton(button)
    F.ReskinButton(button)
    button.__bg:SetInside(nil, 5, 5)
end

C.Themes['Blizzard_CharacterCustomize'] = function()
    local frame = CharCustomizeFrame

    reskinCustomizeButton(frame.SmallButtons.ResetCameraButton)
    reskinCustomizeButton(frame.SmallButtons.ZoomOutButton)
    reskinCustomizeButton(frame.SmallButtons.ZoomInButton)
    reskinCustomizeButton(frame.SmallButtons.RotateLeftButton)
    reskinCustomizeButton(frame.SmallButtons.RotateRightButton)
    reskinCustomizeButton(frame.RandomizeAppearanceButton)

    hooksecurefunc(frame, 'UpdateOptionButtons', function(self)
        if self.dropdownPool then
            for option in self.dropdownPool:EnumerateActive() do
                if not option.styled then
                    F.ReskinButton(option.Dropdown)
                    F.ReskinButton(option.DecrementButton)
                    F.ReskinButton(option.IncrementButton)
                    option.styled = true
                end
            end
        end

        if self.sliderPool then
            for slider in self.sliderPool:EnumerateActive() do
                if not slider.styled then
                    F.ReskinSlider(slider)
                    slider.styled = true
                end
            end
        end

        local optionPool = self.pools:GetPool('CustomizationOptionCheckButtonTemplate')
        if optionPool then
            for button in optionPool:EnumerateActive() do
                if not button.styled then
                    F.ReskinButton(button.Button)
                    button.styled = true
                end
            end
        end
    end)
end
