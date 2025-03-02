local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local function forceSaturation(self, _, force)
        if force then
            return
        end
        self:SetVertexColor(C.r, C.g, C.b)
        self:SetDesaturated(true, true)
    end

    F.ReskinPortraitFrame(AddonList)
    F.ReskinDropdown(AddonList.Dropdown)
    F.ReskinTrimScroll(AddonList.ScrollBar)


    F.ReskinButton(AddonList.EnableAllButton)
    F.ReskinButton(AddonList.DisableAllButton)
    F.ReskinButton(AddonList.CancelButton)
    F.ReskinButton(AddonList.OkayButton)
    F.ReskinCheckbox(AddonList.ForceLoad)
    F.ReskinEditbox(AddonList.SearchBox)

    hooksecurefunc('AddonList_InitAddon', function(entry)
        if not entry.styled then
            F.ReskinCheckbox(entry.Enabled, true)
            F.ReskinButton(entry.LoadAddonButton)
            hooksecurefunc(entry.Enabled:GetCheckedTexture(), 'SetDesaturated', forceSaturation)

            F.ReplaceIconString(entry.Title)
            hooksecurefunc(entry.Title, 'SetText', F.ReplaceIconString)

            entry.styled = true
        end
    end)
end)
