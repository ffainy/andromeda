local F, C = unpack(select(2, ...))

local function reskinChatScroll(self)
    F.ReskinTrimScroll(self.ScrollBar)
    F.StripTextures(self.ScrollToBottomButton)

    local flash = self.ScrollToBottomButton.Flash
    F.SetupArrow(flash, 'down')
    flash:SetVertexColor(1, 0.8, 0)
end

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    -- Battlenet toast frame
    _G.BNToastFrame:SetBackdrop(nil)
    F.SetBD(_G.BNToastFrame)
    _G.BNToastFrame.TooltipFrame:HideBackdrop()
    F.SetBD(_G.BNToastFrame.TooltipFrame)
    F.ReskinClose(_G.BNToastFrame.CloseButton)

    _G.TimeAlertFrame:SetBackdrop(nil)
    F.SetBD(_G.TimeAlertFrame)

    -- Battletag invite frame
    local border, send, cancel = _G.BattleTagInviteFrame:GetChildren()
    border:Hide()
    F.ReskinButton(send)
    F.ReskinButton(cancel)
    F.SetBD(_G.BattleTagInviteFrame)

    local friendTex = 'Interface\\HELPFRAME\\ReportLagIcon-Chat'
    local queueTex = 'Interface\\HELPFRAME\\HelpIcon-ItemRestoration'
    local homeTex = 'Interface\\Buttons\\UI-HomeButton'

    _G.QuickJoinToastButton.FriendsButton:SetTexture(friendTex)
    _G.QuickJoinToastButton.QueueButton:SetTexture(queueTex)
    _G.QuickJoinToastButton:SetHighlightTexture(0)
    hooksecurefunc(_G.QuickJoinToastButton, 'ToastToFriendFinished', function(self)
        self.FriendsButton:SetShown(not self.displayedToast)
    end)
    hooksecurefunc(_G.QuickJoinToastButton, 'UpdateQueueIcon', function(self)
        if not self.displayedToast then
            return
        end
        self.QueueButton:SetTexture(queueTex)
        self.FlashingLayer:SetTexture(queueTex)
        self.FriendsButton:SetShown(false)
    end)
    _G.QuickJoinToastButton:HookScript('OnMouseDown', function(self)
        self.FriendsButton:SetTexture(friendTex)
    end)
    _G.QuickJoinToastButton:HookScript('OnMouseUp', function(self)
        self.FriendsButton:SetTexture(friendTex)
    end)
    _G.QuickJoinToastButton.Toast.Background:SetTexture('')
    local bg = F.SetBD(_G.QuickJoinToastButton.Toast)
    bg:SetPoint('TOPLEFT', 10, -1)
    bg:SetPoint('BOTTOMRIGHT', 0, 3)
    bg:Hide()
    hooksecurefunc(_G.QuickJoinToastButton, 'ShowToast', function()
        bg:Show()
    end)
    hooksecurefunc(_G.QuickJoinToastButton, 'HideToast', function()
        bg:Hide()
    end)

    -- ChatFrame
    F.ReskinButton(_G.ChatFrameChannelButton)
    _G.ChatFrameChannelButton:SetSize(20, 20)
    F.ReskinButton(_G.ChatFrameToggleVoiceDeafenButton)
    _G.ChatFrameToggleVoiceDeafenButton:SetSize(20, 20)
    F.ReskinButton(_G.ChatFrameToggleVoiceMuteButton)
    _G.ChatFrameToggleVoiceMuteButton:SetSize(20, 20)
    F.ReskinButton(_G.ChatFrameMenuButton)
    _G.ChatFrameMenuButton:SetSize(20, 20)
    _G.ChatFrameMenuButton:SetNormalTexture(homeTex)
    _G.ChatFrameMenuButton:SetPushedTexture(homeTex)

    for i = 1, _G.NUM_CHAT_WINDOWS do
        reskinChatScroll(_G['ChatFrame' .. i])
    end

    -- ChannelFrame
    F.ReskinPortraitFrame(_G.ChannelFrame)
    F.ReskinButton(_G.ChannelFrame.NewButton)
    F.ReskinButton(_G.ChannelFrame.SettingsButton)
    F.ReskinTrimScroll(_G.ChannelFrame.ChannelList.ScrollBar)
    F.ReskinTrimScroll(_G.ChannelFrame.ChannelRoster.ScrollBar)

    hooksecurefunc(_G.ChannelFrame.ChannelList, 'Update', function(self)
        for i = 1, self.Child:GetNumChildren() do
            local tab = select(i, self.Child:GetChildren())
            if not tab.styled and tab:IsHeader() then
                tab:SetNormalTexture(0)
                tab.bg = F.CreateBDFrame(tab, 0.25)
                tab.bg:SetAllPoints()

                tab.styled = true
            end
        end
    end)

    F.StripTextures(_G.CreateChannelPopup)
    F.SetBD(_G.CreateChannelPopup)
    F.ReskinButton(_G.CreateChannelPopup.OKButton)
    F.ReskinButton(_G.CreateChannelPopup.CancelButton)
    F.ReskinClose(_G.CreateChannelPopup.CloseButton)
    F.ReskinEditbox(_G.CreateChannelPopup.Name)
    F.ReskinEditbox(_G.CreateChannelPopup.Password)

    F.SetBD(_G.VoiceChatPromptActivateChannel)
    F.ReskinButton(_G.VoiceChatPromptActivateChannel.AcceptButton)
    _G.VoiceChatChannelActivatedNotification:SetBackdrop(nil)
    F.SetBD(_G.VoiceChatChannelActivatedNotification)

    -- VoiceActivityManager
    hooksecurefunc(_G.VoiceActivityManager, 'LinkFrameNotificationAndGuid', function(_, _, notification, guid)
        local class = select(2, GetPlayerInfoByGUID(guid))
        if class then
            local color = C.ClassColors[class]
            if notification.Name then
                notification.Name:SetTextColor(color.r, color.g, color.b)
            end
        end
    end)
end)
