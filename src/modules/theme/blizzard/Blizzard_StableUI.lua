local F, C = unpack(select(2, ...))

C.Themes['Blizzard_StableUI'] = function()
    local StableFrame = _G.StableFrame

    F.ReskinPortraitFrame(StableFrame)
    F.ReskinButton(StableFrame.StableTogglePetButton)
    F.ReskinButton(StableFrame.ReleasePetButton)

    local stabledPetList = StableFrame.StabledPetList
    F.StripTextures(stabledPetList)
    F.StripTextures(stabledPetList.ListCounter)
    F.CreateBDFrame(stabledPetList.ListCounter, 0.25)
    F.ReskinEditbox(stabledPetList.FilterBar.SearchBox)
    F.ReskinFilterButton(stabledPetList.FilterBar.FilterDropdown)
    F.ReskinTrimScroll(stabledPetList.ScrollBar)

    local modelScene = StableFrame.PetModelScene
    if modelScene then
        local petInfo = modelScene.PetInfo
        if petInfo then
            hooksecurefunc(petInfo.Type, 'SetText', F.ReplaceIconString)
        end

        local list = modelScene.AbilitiesList
        if list then
            hooksecurefunc(list, 'Layout', function(self)
                for frame in self.abilityPool:EnumerateActive() do
                    if not frame.styled then
                        F.ReskinIcon(frame.Icon)
                        frame.styled = true
                    end
                end
            end)
        end

        F.ReskinModelControl(modelScene)
    end
end
