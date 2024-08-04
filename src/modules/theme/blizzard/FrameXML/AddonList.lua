local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    F.ReskinPortraitFrame(_G.AddonList)
    F.ReskinButton(_G.AddonListEnableAllButton)
    F.ReskinButton(_G.AddonListDisableAllButton)
    F.ReskinButton(_G.AddonListCancelButton)
    F.ReskinButton(_G.AddonListOkayButton)
    F.ReskinCheckbox(_G.AddonListForceLoad)
    F.ReskinDropdown(_G.AddonList.Dropdown)
    F.ReskinTrimScroll(_G.AddonList.ScrollBar)

    _G.AddonListForceLoad:SetSize(18, 18)

    local function forceSaturation(self, _, force)
        if force then
            return
        end
        self:SetVertexColor(C.r, C.g, C.b)
        self:SetDesaturated(true, true)
    end

    hooksecurefunc('AddonList_InitButton', function(entry)
        if not entry.styled then
            entry.Enabled:SetSize(18, 18)
            F.ReskinCheckbox(entry.Enabled, true)
            F.ReskinButton(entry.LoadAddonButton)

            hooksecurefunc(entry.Enabled:GetCheckedTexture(), 'SetDesaturated', forceSaturation)

            F.ReplaceIconString(entry.Title)
            hooksecurefunc(entry.Title, 'SetText', F.ReplaceIconString)

            entry.styled = true
        end
    end)

    hooksecurefunc('AddonList_Update', function()
        for i = 1, _G.MAX_ADDONS_DISPLAYED do
            local entry = _G['AddonListEntry' .. i]
            if entry and entry:IsShown() then
                local checkbox = _G['AddonListEntry' .. i .. 'Enabled']
                if checkbox.forceSaturation then
                    local tex = checkbox:GetCheckedTexture()
                    if checkbox.state == 2 then
                        tex:SetDesaturated(true)
                        tex:SetVertexColor(C.r, C.g, C.b)
                    elseif checkbox.state == 1 then
                        tex:SetVertexColor(1, 0.8, 0, 0.8)
                    end
                end
            end
        end
    end)
end)
