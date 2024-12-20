local F, C = unpack(select(2, ...))

C.Themes['Blizzard_ScrappingMachineUI'] = function()
    F.ReskinPortraitFrame(ScrappingMachineFrame)
    F.ReskinButton(ScrappingMachineFrame.ScrapButton)

    local ItemSlots = ScrappingMachineFrame.ItemSlots
    F.StripTextures(ItemSlots)

    hooksecurefunc(ScrappingMachineFrame, 'UpdateScrapButtonState', function(self)
        for button in self.ItemSlots.scrapButtons:EnumerateActive() do
            if not button.bg then
                F.StripTextures(button)
                button.Icon:SetTexCoord(unpack(C.TEX_COORD))
                button.bg = F.CreateBDFrame(button.Icon, 0.25)
                F.ReskinIconBorder(button.IconBorder)
                local hl = button:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.25)
                hl:SetAllPoints(button.Icon)
            end
        end
    end)
end
