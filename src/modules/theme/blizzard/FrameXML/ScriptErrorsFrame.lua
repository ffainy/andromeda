local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    local ScriptErrorsFrame = _G.ScriptErrorsFrame

    ScriptErrorsFrame:SetScale(UIParent:GetScale())
    F.StripTextures(ScriptErrorsFrame)
    F.SetBD(ScriptErrorsFrame)

    F.ReskinArrow(ScriptErrorsFrame.PreviousError, 'left')
    F.ReskinArrow(ScriptErrorsFrame.NextError, 'right')
    F.ReskinButton(ScriptErrorsFrame.Reload)
    F.ReskinButton(ScriptErrorsFrame.Close)
    F.ReskinTrimScroll(ScriptErrorsFrame.ScrollFrame.ScrollBar)
    F.ReskinClose(_G.ScriptErrorsFrameClose)
end)
