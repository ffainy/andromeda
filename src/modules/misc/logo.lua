local F, C = unpack(select(2, ...))
local logo = F:RegisterModule('Logo')

-- play logo animation on login

local needAnimation
function logo:PlayAnimation()
    if needAnimation then
        logo.logoFrame:Show()
        F:UnregisterEvent(self, logo.PlayAnimation)
        needAnimation = false
    end
end

function logo:CheckStatus(isInitialLogin)
    if
        C.DB.InstallationComplete and isInitialLogin
        and not (IsInInstance() and InCombatLockdown())
    then
        needAnimation = true
        logo:ConstructFrame()
        F:RegisterEvent('PLAYER_STARTED_MOVING', logo.PlayAnimation)
        -- F:RegisterEvent('PLAYER_ENTERING_WORLD', logo.PlayAnimation)
    end
    F:UnregisterEvent(self, logo.CheckStatus)
end

function logo:ConstructFrame()
    local frame = CreateFrame('Frame', nil, UIParent)
    frame:SetSize(512, 256)
    frame:SetPoint('CENTER', UIParent, 'BOTTOM', -500, GetScreenHeight() * 0.618)
    frame:SetFrameStrata('HIGH')
    frame:SetAlpha(0)
    frame:Hide()

    local tex = frame:CreateTexture()
    tex:SetAllPoints()
    tex:SetTexture(C.Assets.Textures.LogoSplash)
    tex:SetBlendMode('ADD')
    tex:SetDesaturated(true)
    local db = ANDROMEDA_ADB.CustomClassColors[C.MY_CLASS]
    local c1 = CreateColor(db.r, db.g, db.b, 1)
    local c2 = CreateColor(1, 1, 1, 1)
    tex:SetGradient('VERTICAL', c2, c1)

    local delayTime = 0
    local timer1 = 0.5
    local timer2 = 2.5
    local timer3 = 0.2

    local anim = frame:CreateAnimationGroup()
    anim.move1 = anim:CreateAnimation('Translation')
    anim.move1:SetOffset(480, 0)
    anim.move1:SetDuration(timer1)
    anim.move1:SetStartDelay(delayTime)

    anim.fadeIn = anim:CreateAnimation('Alpha')
    anim.fadeIn:SetFromAlpha(0)
    anim.fadeIn:SetToAlpha(1)
    anim.fadeIn:SetDuration(timer1)
    anim.fadeIn:SetSmoothing('IN')
    anim.fadeIn:SetStartDelay(delayTime)

    delayTime = delayTime + timer1

    anim.move2 = anim:CreateAnimation('Translation')
    anim.move2:SetOffset(80, 0)
    anim.move2:SetDuration(timer2)
    anim.move2:SetStartDelay(delayTime)

    delayTime = delayTime + timer2

    anim.move3 = anim:CreateAnimation('Translation')
    anim.move3:SetOffset(-40, 0)
    anim.move3:SetDuration(timer3)
    anim.move3:SetStartDelay(delayTime)

    delayTime = delayTime + timer3

    anim.move4 = anim:CreateAnimation('Translation')
    anim.move4:SetOffset(480, 0)
    anim.move4:SetDuration(timer1)
    anim.move4:SetStartDelay(delayTime)

    anim.fadeOut = anim:CreateAnimation('Alpha')
    anim.fadeOut:SetFromAlpha(1)
    anim.fadeOut:SetToAlpha(0)
    anim.fadeOut:SetDuration(timer1)
    anim.fadeOut:SetSmoothing('OUT')
    anim.fadeOut:SetStartDelay(delayTime)

    frame:SetScript('OnShow', function()
        anim:Play()
    end)

    anim:SetScript('OnFinished', function()
        frame:Hide()
    end)

    anim.fadeIn:SetScript('OnFinished', function()
        PlaySoundFile(C.Assets.Sounds.Intro, 'Master')
    end)

    logo.logoFrame = frame
end

-- insert logo icon into AddonList panel

local function replaceIconString(self, text)
    if not text then
        text = self:GetText()
    end
    if not text or text == '' then
        return
    end

    if strfind(text, 'Andromeda') then
        local newText, count = gsub(text, '|T([^:]-):[%d+:]+|t', '|T' .. C.Assets.Textures.LogoChat .. ':12:24|t')
        if count > 0 then
            self:SetFormattedText('%s', newText)
        end
    end
end

function logo:HandleAddOnTitle()
    hooksecurefunc('AddonList_InitButton', function(entry)
        if not entry.logoHooked then
            replaceIconString(entry.Title)
            hooksecurefunc(entry.Title, 'SetText', replaceIconString)

            entry.logoHooked = true
        end
    end)
end

function logo:OnLogin()
    logo:HandleAddOnTitle()

    F:RegisterEvent('PLAYER_ENTERING_WORLD', logo.CheckStatus)
end
