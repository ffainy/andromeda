-- Credit: fang2hou
-- https://github.com/fang2hou/ElvUI_WindTools/blob/development/Modules/Combat/CombatAlert.lua

local F, C, L = unpack(select(2, ...))
local ca = F:RegisterModule('CombatAlert')

local isPlaying = false
local alertQueue = {}

function ca:CreateAnimationFrame()
    if self.animationFrame then
        return
    end

    local frame, anime
    frame = CreateFrame('Frame', nil, self.combatAlertHolder)
    frame:SetPoint('CENTER')
    self.animationFrame = frame

    -- 盾
    frame = F.CreateAnimationFrame(nil, self.animationFrame, 'HIGH', 3, true, C.Assets.Textures.CombatShield, false,
        { 1, 1, 1 })
    anime = F.CreateAnimationGroup(frame, 'enter') -- 进入战斗
    F.AddTranslation(anime, 'moveToCenter')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    F.CloseAnimationOnHide(frame, anime, ca.LoadNextAlert)
    anime.moveToCenter:SetDuration(0.2)
    anime.moveToCenter:SetStartDelay(0)
    anime.fadeIn:SetDuration(0.2)
    anime.fadeIn:SetStartDelay(0)
    anime.fadeOut:SetDuration(0.3)
    anime.fadeOut:SetStartDelay(0.5)
    anime = F.CreateAnimationGroup(frame, 'leave') -- 离开战斗
    F.AddScale(anime, 'scale', { 1, 1 }, { 0.1, 0.1 })
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    anime.fadeIn:SetDuration(0.3)
    anime.fadeIn:SetStartDelay(0)
    anime.scale:SetDuration(0.6)
    anime.scale:SetStartDelay(0.6)
    anime.fadeOut:SetDuration(0.6)
    anime.fadeOut:SetStartDelay(0.6)
    F.CloseAnimationOnHide(frame, anime, ca.LoadNextAlert)
    self.animationFrame.shield = frame

    -- 剑 ↗
    frame = F.CreateAnimationFrame(nil, self.animationFrame, 'HIGH', 2, true, C.Assets.Textures.CombatSword, false,
        { 1, 1, 1 })
    anime = F.CreateAnimationGroup(frame, 'enter') -- 进入战斗
    F.AddTranslation(anime, 'moveToCenter')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    F.CloseAnimationOnHide(frame, anime)
    anime.moveToCenter:SetDuration(0.4)
    anime.moveToCenter:SetStartDelay(0)
    anime.fadeIn:SetDuration(0.4)
    anime.fadeIn:SetStartDelay(0)
    anime.fadeOut:SetDuration(0.3)
    anime.fadeOut:SetStartDelay(0.9)
    anime.fadeIn:SetScript('OnFinished', function()
        self.animationFrame.shield:Show()
        self.animationFrame.shield.enter:Play()
    end)
    anime = F.CreateAnimationGroup(frame, 'leave') -- 离开战斗
    F.AddTranslation(anime, 'moveToCorner')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    anime.fadeIn:SetDuration(0.3)
    anime.fadeIn:SetStartDelay(0)
    anime.moveToCorner:SetDuration(0.6)
    anime.moveToCorner:SetStartDelay(0.6)
    anime.fadeOut:SetDuration(0.6)
    anime.fadeOut:SetStartDelay(0.6)
    F.CloseAnimationOnHide(frame, anime)
    self.animationFrame.swordLeftToRight = frame

    -- 剑 ↖
    frame = F.CreateAnimationFrame(nil, self.animationFrame, 'HIGH', 2, true, C.Assets.Textures.CombatSword, true,
        { 1, 1, 1 })
    anime = F.CreateAnimationGroup(frame, 'enter') -- 进入战斗
    F.AddTranslation(anime, 'moveToCenter')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    F.CloseAnimationOnHide(frame, anime)
    anime.moveToCenter:SetDuration(0.4)
    anime.moveToCenter:SetStartDelay(0)
    anime.fadeIn:SetDuration(0.4)
    anime.fadeIn:SetStartDelay(0)
    anime.fadeOut:SetDuration(0.3)
    anime.fadeOut:SetStartDelay(0.9)
    anime = F.CreateAnimationGroup(frame, 'leave') -- 离开战斗
    F.AddTranslation(anime, 'moveToCorner')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    anime.fadeIn:SetDuration(0.3)
    anime.fadeIn:SetStartDelay(0)
    anime.moveToCorner:SetDuration(0.6)
    anime.moveToCorner:SetStartDelay(0.6)
    anime.fadeOut:SetDuration(0.6)
    anime.fadeOut:SetStartDelay(0.6)
    F.CloseAnimationOnHide(frame, anime)
    self.animationFrame.swordRightToLeft = frame
end

function ca:UpdateAnimationFrame()
    if not self.animationFrame then
        return
    end

    local animationFrameSize = { 240 * C.DB.combatAlert.animScale, 220 * C.DB.combatAlert.animScale }
    local textureSize = 200 * C.DB.combatAlert.animScale
    local swordAnimationRange = 130 * C.DB.combatAlert.animScale
    local shieldAnimationRange = 65 * C.DB.combatAlert.animScale

    local f = self.animationFrame

    f:SetSize(unpack(animationFrameSize))

    f.shield:Hide()
    f.shield:SetSize(0.8 * textureSize, 0.8 * textureSize)
    f.shield.enter.moveToCenter:SetOffset(0, -shieldAnimationRange)

    f.swordLeftToRight:Hide()
    f.swordLeftToRight:SetSize(textureSize, textureSize)
    f.swordLeftToRight.enter.moveToCenter:SetOffset(swordAnimationRange, swordAnimationRange)
    f.swordLeftToRight.leave.moveToCorner:SetOffset(swordAnimationRange, swordAnimationRange)

    f.swordRightToLeft:Hide()
    f.swordRightToLeft:SetSize(textureSize, textureSize)
    f.swordRightToLeft.enter.moveToCenter:SetOffset(-swordAnimationRange, swordAnimationRange)
    f.swordRightToLeft.leave.moveToCorner:SetOffset(-swordAnimationRange, swordAnimationRange)

    F.SpeedAnimationGroup(f.shield.enter, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.swordLeftToRight.enter, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.swordRightToLeft.enter, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.shield.leave, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.swordLeftToRight.leave, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.swordRightToLeft.leave, C.DB.combatAlert.animSpeed)
end

function ca:CreateTextFrame()
    if self.textFrame then
        return
    end

    local frame = F.CreateAnimationFrame(nil, self.combatAlertHolder, 'HIGH', 4, true)
    frame.text = frame:CreateFontString()
    frame.text:SetPoint('CENTER')
    frame.text:SetJustifyV('MIDDLE')
    frame.text:SetJustifyH('CENTER')

    local anime = F.CreateAnimationGroup(frame, 'enter')
    F.AddTranslation(anime, 'moveUp')
    F.AddTranslation(anime, 'moveDown')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    anime.moveUp:SetDuration(0.4)
    anime.moveUp:SetStartDelay(0)
    anime.moveDown:SetDuration(0.1)
    anime.moveDown:SetStartDelay(0.4)
    anime.fadeIn:SetDuration(0.5)
    anime.fadeIn:SetStartDelay(0)
    anime.fadeOut:SetDuration(0.3)
    anime.fadeOut:SetStartDelay(0.9)
    anime = F.CreateAnimationGroup(frame, 'leave')
    F.AddFadeIn(anime, 'fadeIn')
    F.AddFadeOut(anime, 'fadeOut')
    F.AddTranslation(anime, 'moveUp')
    anime.fadeIn:SetDuration(0.3)
    anime.fadeIn:SetStartDelay(0)
    anime.fadeOut:SetDuration(0.6)
    anime.fadeOut:SetStartDelay(0.6)
    anime.moveUp:SetDuration(0.6)
    anime.moveUp:SetStartDelay(0.6)

    self.textFrame = frame
end

function ca:UpdateTextFrame()
    if not self.textFrame then
        return
    end

    local moveUpOffset = 160 * C.DB.combatAlert.animScale
    local moveDownOffset = -40 * C.DB.combatAlert.animScale

    local f = self.textFrame

    f:Hide()
    f.text:SetFont(C.Assets.Fonts.Combat, 26)
    f.text:SetText(L['Enter Combat'])
    f:SetSize(f.text:GetStringWidth(), f.text:GetStringHeight())

    f.enter.moveUp:SetOffset(0, moveUpOffset)
    f.enter.moveDown:SetOffset(0, moveDownOffset)
    f.leave.moveUp:SetOffset(0, -moveDownOffset)

    F.SpeedAnimationGroup(f.enter, C.DB.combatAlert.animSpeed)
    F.SpeedAnimationGroup(f.leave, C.DB.combatAlert.animSpeed)

    -- 上方动画窗体如果不存在，确认下个提示的工作就交给文字窗体了
    -- if not self.db.animation then
    F.CloseAnimationOnHide(f, 'enter', ca.LoadNextAlert)
    F.CloseAnimationOnHide(f, 'leave', ca.LoadNextAlert)
    -- else
    -- 	F.CloseAnimationOnHide(f, 'enter')
    -- 	F.CloseAnimationOnHide(f, 'leave')
    -- end
end

function ca:ShowAlert(alertType)
    if isPlaying then
        self:QueueAlert(alertType)
        return
    end

    isPlaying = true

    local a = self.animationFrame
    local t = self.textFrame
    local swordOffsetEnter = 150 * C.DB.combatAlert.animScale
    local swordOffsetLeave = 20 * C.DB.combatAlert.animScale
    local shieldOffsetEnter = 50 * C.DB.combatAlert.animScale
    local shieldOffsetLeave = -15 * C.DB.combatAlert.animScale
    local textOffsetEnter = -120 * C.DB.combatAlert.animScale
    local textOffsetLeave = -20 * C.DB.combatAlert.animScale

    a.shield.enter:Stop()
    a.swordLeftToRight.enter:Stop()
    a.swordRightToLeft.enter:Stop()
    a.shield.leave:Stop()
    a.swordLeftToRight.leave:Stop()
    a.swordRightToLeft.leave:Stop()

    t.enter:Stop()
    t.leave:Stop()

    if alertType == 'ENTER' then
        -- 盾牌动画会由左到右的剑自动触发
        a.shield:SetPoint('CENTER', 0, shieldOffsetEnter)
        a.swordLeftToRight:SetPoint('CENTER', -swordOffsetEnter, -swordOffsetEnter)
        a.swordRightToLeft:SetPoint('CENTER', swordOffsetEnter, -swordOffsetEnter)
        a.swordLeftToRight:Show()
        a.swordRightToLeft:Show()
        a.swordLeftToRight.enter:Restart()
        a.swordRightToLeft.enter:Restart()

        F.SetFS(t.text, C.Assets.Fonts.Combat, 26, ANDROMEDA_ADB.FontOutline, L['Enter Combat'], 'RED')
        t:SetSize(t.text:GetStringWidth(), t.text:GetStringHeight())
        t:SetPoint('TOP', self.animationFrame or self.combatAlertHolder, 'BOTTOM', 0, textOffsetEnter)
        t:Show()
        t.enter:Restart()
    else
        a.shield:SetPoint('CENTER', 0, shieldOffsetLeave)
        a.swordLeftToRight:SetPoint('CENTER', -swordOffsetLeave, -swordOffsetLeave)
        a.swordRightToLeft:SetPoint('CENTER', swordOffsetLeave, -swordOffsetLeave)
        a.shield:Show()
        a.swordLeftToRight:Show()
        a.swordRightToLeft:Show()
        a.shield.leave:Restart()
        a.swordLeftToRight.leave:Restart()
        a.swordRightToLeft.leave:Restart()

        F.SetFS(t.text, C.Assets.Fonts.Combat, 26, ANDROMEDA_ADB.FontOutline, L['Leave Combat'], 'GREEN')
        t:SetSize(t.text:GetStringWidth(), t.text:GetStringHeight())
        t:SetPoint('TOP', self.animationFrame or self.combatAlertHolder, 'BOTTOM', 0, textOffsetLeave)
        t:Show()
        t.leave:Restart()
    end
end

function ca:QueueAlert(alertType)
    tinsert(alertQueue, alertType)
end

function ca.LoadNextAlert()
    isPlaying = false

    if alertQueue and alertQueue[1] then
        ca:ShowAlert(alertQueue[1])
        tremove(alertQueue, 1)
    end
end

function ca:PLAYER_REGEN_DISABLED()
    ca:ShowAlert('ENTER')
end

function ca:PLAYER_REGEN_ENABLED()
    ca:ShowAlert('LEAVE')
end

function ca:UpdateHolderSize()
    if not self.combatAlertHolder then
        return
    end

    if self.animationFrame then
        self.combatAlertWidth = self.combatAlertWidth + (self.animationFrame:GetWidth() or 0)
        self.combatAlertHeight = self.combatAlertHeight + (self.animationFrame:GetHeight() or 0)
    end

    if self.textFrame then
        self.combatAlertWidth = max(self.combatAlertWidth, self.animationFrame:GetWidth())
        self.combatAlertHeight = self.combatAlertHeight + self.textFrame:GetHeight()
    end

    if self.combatAlertWidth ~= 0 and self.combatAlertHeight ~= 0 then
        self.combatAlertHolder:SetSize(self.combatAlertWidth, self.combatAlertHeight)
    end
end

function ca:UpdateConfig()
    if C.DB.combatAlert.enable then
        F:RegisterEvent('PLAYER_REGEN_DISABLED', ca.PLAYER_REGEN_DISABLED)
        F:RegisterEvent('PLAYER_REGEN_ENABLED', ca.PLAYER_REGEN_ENABLED)
    else
        F:UnregisterEvent('PLAYER_REGEN_DISABLED', ca.PLAYER_REGEN_DISABLED)
        F:UnregisterEvent('PLAYER_REGEN_ENABLED', ca.PLAYER_REGEN_ENABLED)
    end
end

function ca:OnLogin()
    if not C.DB.combatAlert.enable then
        return
    end

    ca.combatAlertHolder = CreateFrame('Frame', nil, UIParent)
    ca.combatAlertHolder:SetPoint('CENTER')

    ca.combatAlertWidth = 0
    ca.combatAlertHeight = 0

    ca:CreateAnimationFrame()
    ca:CreateTextFrame()
    ca:UpdateAnimationFrame()
    ca:UpdateTextFrame()
    ca:UpdateHolderSize()
    ca:UpdateConfig()

    F.Mover(
        ca.combatAlertHolder,
        L['CombatAlert'],
        'CombatAlert',
        { 'CENTER', UIParent, 0, 200 },
        ca.combatAlertWidth,
        ca.combatAlertHeight
    )
end
