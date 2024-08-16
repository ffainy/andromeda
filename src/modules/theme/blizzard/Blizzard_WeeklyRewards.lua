local F, C = unpack(select(2, ...))

-- /run UIParent_OnEvent({}, "WEEKLY_REWARDS_SHOW")

local function updateSelection(frame)
    if not frame.bg then
        return
    end

    if frame.SelectedTexture:IsShown() then
        frame.bg:SetBackdropBorderColor(1, 0.8, 0)
    else
        frame.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local iconColor = C.QualityColors[Enum.ItemQuality.Epic or 4] -- epic color only
local function reskinRewardIcon(itemFrame)
    if not itemFrame.bg then
        itemFrame:DisableDrawLayer('BORDER')
        itemFrame.Icon:SetPoint('LEFT', 6, 0)
        itemFrame.bg = F.ReskinIcon(itemFrame.Icon)
        itemFrame.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
    end
end

local function fixBg(anim) -- color reset for the first time game launched
    if anim.bg then
        anim.bg:SetBackdropColor(0, 0, 0, 0.25)
    end
end

local function reskinActivityFrame(frame, isObject)
    if frame.Border then
        if isObject then
            hooksecurefunc(frame, 'SetSelectionState', updateSelection)
            hooksecurefunc(frame.ItemFrame, 'SetDisplayedItem', reskinRewardIcon)

            if frame.SheenAnim then
                frame.SheenAnim.bg = F.CreateBDFrame(frame.ItemFrame, 0.25)
                frame.SheenAnim:HookScript('OnFinished', fixBg)
            end
        else
            frame.Border:SetTexCoord(0.926, 1, 0, 1)
            frame.Border:SetSize(25, 137)
            frame.Border:SetPoint('LEFT', frame, 'RIGHT', 3, 0)
        end
    end
end

local function replaceIconString(self, text)
    if not text then
        text = self:GetText()
    end
    if not text or text == '' then
        return
    end

    local newText, count = gsub(text, '24:24:0:%-2', '14:14:0:0:64:64:5:59:5:59')
    if count > 0 then
        self:SetFormattedText('%s', newText)
    end
end

local function reskinConfirmIcon(frame)
    if frame.bg then
        return
    end
    frame.bg = F.ReskinIcon(frame.Icon)
    F.ReskinIconBorder(frame.IconBorder, true)
end

C.Themes['Blizzard_WeeklyRewards'] = function()
    local WeeklyRewardsFrame = WeeklyRewardsFrame

    local bg = F.SetBD(WeeklyRewardsFrame)
    F.ReskinClose(WeeklyRewardsFrame.CloseButton)
    F.StripTextures(WeeklyRewardsFrame.SelectRewardButton)
    F.ReskinButton(WeeklyRewardsFrame.SelectRewardButton)

    WeeklyRewardsFrame.BorderShadow:SetInside(bg)
    WeeklyRewardsFrame.BorderContainer:SetAlpha(0)


    reskinActivityFrame(WeeklyRewardsFrame.RaidFrame)
    reskinActivityFrame(WeeklyRewardsFrame.MythicFrame)
    reskinActivityFrame(WeeklyRewardsFrame.PVPFrame)
    reskinActivityFrame(WeeklyRewardsFrame.WorldFrame)

    for _, frame in pairs(WeeklyRewardsFrame.Activities) do
        reskinActivityFrame(frame, true)
    end

    hooksecurefunc(WeeklyRewardsFrame, 'SelectReward', function(self)
        local confirmFrame = self.confirmSelectionFrame
        if confirmFrame then
            if not confirmFrame.styled then
                reskinConfirmIcon(confirmFrame.ItemFrame)
                WeeklyRewardsFrameNameFrame:Hide()
                confirmFrame.styled = true
            end

            local alsoItemsFrame = confirmFrame.AlsoItemsFrame
            if alsoItemsFrame.pool then
                for frame in alsoItemsFrame.pool:EnumerateActive() do
                    reskinConfirmIcon(frame)
                end
            end
        end
    end)

    local rewardText = WeeklyRewardsFrame.ConcessionFrame.RewardsFrame.Text
    replaceIconString(rewardText)
    hooksecurefunc(rewardText, 'SetText', replaceIconString)

    local dialog = WeeklyRewardExpirationWarningDialog
    if dialog then
        F.StripTextures(dialog)
        F.SetBD(dialog)
    end
end
