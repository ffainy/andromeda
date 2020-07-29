local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
	if not C.Theme.reskin_blizz then return end

	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	F.StripTextures(ScriptErrorsFrame)
	F.SetBD(ScriptErrorsFrame)

	F.ReskinArrow(ScriptErrorsFrame.PreviousError, "left")
	F.ReskinArrow(ScriptErrorsFrame.NextError, "right")
	F.Reskin(ScriptErrorsFrame.Reload)
	F.Reskin(ScriptErrorsFrame.Close)
	F.ReskinScroll(ScriptErrorsFrameScrollBar)
	F.ReskinClose(ScriptErrorsFrameClose)
end)