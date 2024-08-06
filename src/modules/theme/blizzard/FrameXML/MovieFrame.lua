local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    -- Cinematic

    _G.CinematicFrameCloseDialog:HookScript('OnShow', function(self)
        self:SetScale(UIParent:GetScale())
    end)

    F.StripTextures(_G.CinematicFrameCloseDialog)
    local bg = F.SetBD(_G.CinematicFrameCloseDialog)
    bg:SetFrameLevel(1)
    F.ReskinButton(_G.CinematicFrameCloseDialogConfirmButton)
    F.ReskinButton(_G.CinematicFrameCloseDialogResumeButton)

    -- Movie

    local closeDialog = _G.MovieFrame.CloseDialog

    closeDialog:HookScript('OnShow', function(self)
        self:SetScale(UIParent:GetScale())
    end)

    F.StripTextures(closeDialog)
    local dbg = F.SetBD(closeDialog)
    dbg:SetFrameLevel(1)
    F.ReskinButton(closeDialog.ConfirmButton)
    F.ReskinButton(closeDialog.ResumeButton)
end)
