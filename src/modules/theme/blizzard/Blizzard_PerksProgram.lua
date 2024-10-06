local F, C = unpack(select(2, ...))

local function reskinCustomizeButton(button)
    F.ReskinButton(button)
    button.__bg:SetInside(nil, 5, 5)
end

local function reskinRewardButton(button)
    if button.styled then
        return
    end

    local container = button.ContentsContainer
    if container then
        F.ReskinIcon(container.Icon)
        F.ReplaceIconString(container.Price)
        hooksecurefunc(container.Price, 'SetText', F.ReplaceIconString)
    end

    button.styled = true
end

local function setupSetButton(button)
    if button.bg then
        return
    end
    button.bg = F.ReskinIcon(button.Icon)
    F.ReskinIconBorder(button.IconBorder, true, true)
    button.BackgroundTexture:SetAlpha(0)
    button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.25)
    button.SelectedTexture:SetInside()
    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
    button.HighlightTexture:SetInside()
end

C.Themes['Blizzard_PerksProgram'] = function()
    local frame = PerksProgramFrame

    if not frame then
        return
    end

    local footerFrame = frame.FooterFrame
    if footerFrame then
        reskinCustomizeButton(footerFrame.LeaveButton)
        reskinCustomizeButton(footerFrame.PurchaseButton)
        reskinCustomizeButton(footerFrame.RefundButton)

        F.ReskinCheckbox(footerFrame.TogglePlayerPreview)
        F.ReskinCheckbox(footerFrame.ToggleHideArmor)
        F.ReskinCheckbox(footerFrame.ToggleAttackAnimation)
        F.ReskinCheckbox(footerFrame.ToggleMountSpecial)

        reskinCustomizeButton(footerFrame.RotateButtonContainer.RotateLeftButton)
        reskinCustomizeButton(footerFrame.RotateButtonContainer.RotateRightButton)
    end

    local productsFrame = frame.ProductsFrame
    if productsFrame then
        F.ReskinButton(productsFrame.PerksProgramFilter)
        F.ReskinIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
        F.StripTextures(productsFrame.PerksProgramProductDetailsContainerFrame)
        F.SetBD(productsFrame.PerksProgramProductDetailsContainerFrame)
        F.ReskinTrimScroll(
            productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBar
        )

        hooksecurefunc(
            productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBox,
            'Update',
            function(self)
                self:ForEachFrame(setupSetButton)
            end
        )

        local productsContainer = productsFrame.ProductsScrollBoxContainer
        F.StripTextures(productsContainer)
        F.SetBD(productsContainer)
        F.ReskinTrimScroll(productsContainer.ScrollBar)
        F.StripTextures(productsContainer.PerksProgramHoldFrame)
        F.CreateBDFrame(productsContainer.PerksProgramHoldFrame, 0.25):SetInside(nil, 3, 3)

        hooksecurefunc(productsContainer.ScrollBox, 'Update', function(self)
            self:ForEachFrame(reskinRewardButton)
        end)
    end
end
