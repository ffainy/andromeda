-- Credit: rgd87
-- https://github.com/rgd87/NugKeyFeedback

local F, C, L = unpack(select(2, ...))
local AB = F:GetModule('ActionBar')

AB.KeyFeedback = CreateFrame('Frame', 'KeyFeedback', UIParent)
local kfb = AB.KeyFeedback
kfb:SetScript('OnEvent', function(self, event, ...)
    return self[event](self, event, ...)
end)

kfb:RegisterEvent('PLAYER_LOGIN')
kfb:RegisterEvent('PLAYER_LOGOUT')

local configs = {
    point = 'CENTER',
    x = 0,
    y = 0,
    enableCastLine = true,
    enableCooldown = true,
    enablePushEffect = false,
    enableCast = true,
    enableCastFlash = true,
    lineIconSize = 30,
    mirrorSize = 32,
    lineDirection = 'LEFT',
    forceUseActionHook = true,
}

local getSpellInfo = function(spellId)
    local info = C_Spell.GetSpellInfo(spellId)
    if info then
        return info.name, nil, info.iconID
    end
end


function kfb:PLAYER_LOGIN(event)
    if not C.DB.Actionbar.KeyFeedback then return end

    if configs.forceUseActionHook then
        self.mirror = self:CreateFeedbackButton(true)
        self:HookUseAction()
    else
        self.mirror = self:CreateFeedbackButton()
        self:HookDefaultBindings()
    end

    local getActionSpellID = function(action)
        local actionType, id = GetActionInfo(action)
        if actionType == 'spell' then
            return id
        elseif actionType == 'macro' then
            return GetMacroSpell(id)
        end
    end

    self.mirror.UpdateAction = function(self, fullUpdate)
        local action = self.action
        if not action then return end

        local tex = GetActionTexture(action)
        if not tex then return end
        self.icon:SetTexture(tex)

        if fullUpdate then
            self:UpdateCooldownOrCast()
        end
    end

    self.mirror.UpdateCooldownOrCast = function(self)
        local action = self.action
        if not action then return end

        local isCastingLastSpell = self.castSpellID == getActionSpellID(action)
        local cooldownStartTime, cooldownDuration, enable, modRate = GetActionCooldown(action)

        local cooldownFrame = self.cooldown
        local castDuration = self.castDuration or 0

        if configs.enableCast and self.castSpellID and self.castSpellID == getActionSpellID(action) and castDuration > cooldownDuration then
            cooldownFrame:SetDrawEdge(true)
            cooldownFrame:SetReverse(self.castInverted)
            CooldownFrame_Set(cooldownFrame, self.castStartTime, castDuration, true, true, 1)
        elseif configs.enableCooldown then
            cooldownFrame:SetDrawEdge(false)
            cooldownFrame:SetReverse(false)
            local charges, maxCharges, chargeStart, chargeDuration, chargeModRate = GetActionCharges(action)
            CooldownFrame_Set(cooldownFrame, cooldownStartTime, cooldownDuration, enable, false, modRate)
        else
            cooldownFrame:Hide()
        end
    end

    self:SetSize(32, 32)

    local mover = F.Mover(self, L['KeyFeedback'], 'KeyFeedback', { 'CENTER', UIParent, 0, -300 }, configs.mirrorSize,
        configs.mirrorSize)
    self:ClearAllPoints()
    self:SetPoint('CENTER', mover)

    self:RefreshSettings()
end

function kfb.UNIT_SPELLCAST_START(self, event, unit, _castID, spellID)
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
    if not startTime then return end -- With heavy lags it's nil sometimes
    local mirror = self.mirror
    mirror.castInverted = false
    mirror.castID = castID
    mirror.castSpellID = spellID
    mirror.castStartTime = startTime / 1000
    mirror.castDuration = (endTime - startTime) / 1000
    mirror:BumpFadeOut(mirror.castDuration)
    mirror:UpdateCooldownOrCast()
    -- self:UpdateCastingInfo(name,texture,startTime,endTime)
end

kfb.UNIT_SPELLCAST_DELAYED = kfb.UNIT_SPELLCAST_START
function kfb.UNIT_SPELLCAST_CHANNEL_START(self, event, unit, _castID, spellID)
    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitChannelInfo(unit)
    local mirror = self.mirror
    mirror.castInverted = true
    mirror.castID = castID
    mirror.castSpellID = spellID
    mirror.castStartTime = startTime / 1000
    mirror.castDuration = (endTime - startTime) / 1000
    mirror:BumpFadeOut(mirror.castDuration)
    mirror:UpdateCooldownOrCast()
    -- self:UpdateCastingInfo(name,texture,startTime,endTime)
end

kfb.UNIT_SPELLCAST_CHANNEL_UPDATE = kfb.UNIT_SPELLCAST_CHANNEL_START
function kfb.UNIT_SPELLCAST_STOP(self, event, unit, castID, spellID)
    local mirror = self.mirror
    mirror.castSpellID = nil
    mirror.castDuration = nil
    mirror:UpdateCooldownOrCast()
end

function kfb.UNIT_SPELLCAST_FAILED(self, event, unit, castID)
    if self.mirror.castID == castID then
        kfb.UNIT_SPELLCAST_STOP(self, event, unit, nil)
    end
end

kfb.UNIT_SPELLCAST_INTERRUPTED = kfb.UNIT_SPELLCAST_STOP
kfb.UNIT_SPELLCAST_CHANNEL_STOP = kfb.UNIT_SPELLCAST_STOP


function kfb:SPELL_UPDATE_COOLDOWN(event)
    self.mirror:UpdateAction(true)
end

local function mirrorActionButtonDown(action)
    if not HasAction(action) then return end
    if C_PetBattles.IsInBattle() then return end

    local mirror = kfb.mirror

    if mirror.action ~= action then
        mirror.action = action
        mirror:UpdateAction(true)
    else
        mirror:UpdateAction()
    end

    mirror:Show()
    mirror._elapsed = 0
    mirror:SetAlpha(1)
    mirror:BumpFadeOut()
    mirror.pushed = true
    if mirror:GetButtonState() == 'NORMAL' then
        if mirror.pushedCircle then
            if mirror.pushedCircle.grow:IsPlaying() then
                mirror.pushedCircle.grow:Stop()
            end
            mirror.pushedCircle:Show()
            mirror.pushedCircle.grow:Play()
        end
        mirror:SetButtonState('PUSHED')
    end
end

local function mirrorActionButtonUp(action)
    local mirror = kfb.mirror

    if mirror:GetButtonState() == 'PUSHED' then
        mirror:SetButtonState('NORMAL')
    end
end

function kfb:HookDefaultBindings()
    hooksecurefunc('ActionButtonDown', function(id)
        local button = GetActionButtonForID(id)
        if button then
            return mirrorActionButtonDown(button.action)
        end
    end)
    hooksecurefunc('ActionButtonUp', mirrorActionButtonUp)
    hooksecurefunc('MultiActionButtonDown', function(bar, id)
        local button = _G[bar .. 'Button' .. id]
        return mirrorActionButtonDown(button.action)
    end)
    hooksecurefunc('MultiActionButtonUp', mirrorActionButtonUp)
end

function kfb:HookUseAction()
    hooksecurefunc('UseAction', function(action)
        return mirrorActionButtonDown(action)
    end)
end

function kfb:UNIT_SPELLCAST_SUCCEEDED(event, unit, lineID, spellID)
    if IsPlayerSpell(spellID) then
        if spellID == 75 then return end -- Autoshot

        if configs.enableCastLine then
            local frame, isNew = self.iconPool:Acquire()
            local texture = select(3, getSpellInfo(spellID))
            frame.icon:SetTexture(texture)
            frame:Show()
            frame.ag:Play()
        end

        if configs.enableCastFlash then
            self.mirror.glow:Show()
            self.mirror.glow.blink:Play()
        end
    end
end

function kfb:RefreshSettings()
    local db = configs
    self.mirror:SetSize(db.mirrorSize, db.mirrorSize)

    self:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
    if db.enableCastLine then
        if not self.iconPool then
            self.iconPool = self:CreateLastSpellIconLine(self.mirror)
        end

        local pool = self.iconPool
        pool:ReleaseAll()
        for i, f in ipairs(pool.inactiveObjects) do
            -- f:SetHeight(db.lineIconSize)
            -- f:SetWidth(db.lineIconSize)
            pool:resetterFunc(f)
        end
    end

    if db.enableCooldown then
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    else
        self:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
    end

    if db.enableCast then
        self:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', 'player')
        self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
    else
        self:UnregisterEvent('UNIT_SPELLCAST_START')
        self:UnregisterEvent('UNIT_SPELLCAST_DELAYED')
        self:UnregisterEvent('UNIT_SPELLCAST_STOP')
        self:UnregisterEvent('UNIT_SPELLCAST_FAILED')
        self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED')
        self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START')
        self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE')
        self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
    end
end

function kfb:CreateFeedbackButton(autoKeyup)
    local mirror = CreateFrame('Button', 'KeyFeedbackMirror', self, 'ActionButtonTemplate')
    mirror:SetHeight(configs.mirrorSize)
    mirror:SetWidth(configs.mirrorSize)

    if mirror.SetNormalTexture then
        mirror:SetNormalTexture(0)
    end
    if mirror.SetPushedTexture then
        mirror:SetPushedTexture(0)
    end

    mirror.cooldown:SetEdgeTexture('Interface\\Cooldown\\edge')
    mirror.cooldown:SetSwipeColor(0, 0, 0, 0)
    mirror.cooldown:SetHideCountdownNumbers(true)

    local bg = F.CreateBDFrame(mirror)
    bg:SetBackdropBorderColor(0, 0, 0)
    F.CreateSD(bg)

    mirror:Show()
    mirror._elapsed = 0

    local glow = CreateFrame('Frame', nil, mirror)
    glow:SetPoint('TOPLEFT', -16, 16)
    glow:SetPoint('BOTTOMRIGHT', 16, -16)
    local gtex = glow:CreateTexture(nil, 'OVERLAY')
    gtex:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    gtex:SetTexCoord(0, 66 / 128, 136 / 256, 202 / 256)
    gtex:SetVertexColor(0, 1, 0)
    gtex:SetAllPoints(glow)
    mirror.glow = glow
    glow:Hide()

    local ag = glow:CreateAnimationGroup()
    glow.blink = ag

    local a2 = ag:CreateAnimation('Alpha')
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetSmoothing('OUT')
    a2:SetDuration(0.3)
    a2:SetOrder(2)

    ag:SetScript('OnFinished', function(self)
        self:GetParent():Hide()
    end)

    if configs.enablePushEffect then
        local pushedCircle = CreateFrame('Frame', nil, mirror)
        local size = configs.mirrorSize
        pushedCircle:SetSize(size, size)
        pushedCircle:SetPoint('CENTER', 0, 0)
        local pctex = pushedCircle:CreateTexture(nil, 'OVERLAY')
        pctex:SetTexture(C.Assets.Textures.ButtonPushed)
        pctex:SetBlendMode('ADD')
        pctex:SetAllPoints(pushedCircle)
        mirror.pushedCircle = pushedCircle
        pushedCircle:Hide()

        local gag = pushedCircle:CreateAnimationGroup()
        pushedCircle.grow = gag

        local ga1 = gag:CreateAnimation('Scale')
        ga1:SetScaleFrom(0.1, 0.1)
        ga1:SetScaleTo(1.3, 1.3)
        ga1:SetDuration(0.3)
        ga1:SetOrder(2)

        local ga2 = gag:CreateAnimation('Alpha')
        ga2:SetFromAlpha(0.5)
        ga2:SetToAlpha(0)
        -- ga2:SetSmoothing("OUT")
        ga2:SetDuration(0.2)
        ga2:SetStartDelay(0.1)
        ga2:SetOrder(2)

        gag:SetScript('OnFinished', function(self)
            self:GetParent():Hide()
        end)
    end

    mirror.BumpFadeOut = function(self, modifier)
        modifier = modifier or 1.5
        if -modifier < self._elapsed then
            self._elapsed = -modifier
        end
    end

    if autoKeyup then
        mirror:SetScript('OnUpdate', function(self, elapsed)
            self._elapsed = self._elapsed + elapsed

            local timePassed = self._elapsed

            if timePassed >= 0.1 and self.pushed then
                mirror:SetButtonState('NORMAL')
                self.pushed = false
            end

            if timePassed >= 1 then
                local alpha = 2 - timePassed
                if alpha <= 0 then
                    alpha = 0
                    self:Hide()
                end
                self:SetAlpha(alpha)
            end
        end)
    else
        mirror:SetScript('OnUpdate', function(self, elapsed)
            self._elapsed = self._elapsed + elapsed

            local timePassed = self._elapsed
            if timePassed >= 1 then
                local alpha = 2 - timePassed
                if alpha <= 0 then
                    alpha = 0
                    self:Hide()
                end
                self:SetAlpha(alpha)
            end
        end)
    end

    mirror:EnableMouse(false)

    mirror:SetPoint('CENTER', self, 'CENTER')

    mirror:Hide()

    return mirror
end

local function createPoolIcon(pool)
    local hdr = pool.parent
    local id = pool.idCounter
    pool.idCounter = pool.idCounter + 1
    local f = CreateFrame('Button', 'KeyFeedbackPoolIcon' .. id, hdr, 'ActionButtonTemplate')

    if f.SetNormalTexture then
        f:SetNormalTexture(0)
    end

    f:EnableMouse(false)
    f:SetHeight(configs.lineIconSize)
    f:SetWidth(configs.lineIconSize)
    f:SetPoint('BOTTOM', hdr, 'BOTTOM', 0, -0)

    local t = f.icon
    f:SetAlpha(0)

    t:SetTexture('Interface\\Icons\\Spell_Shadow_SacrificialShield')

    local ag = f:CreateAnimationGroup()
    f.ag = ag

    local scaleOrigin = 'RIGHT'
    local translateX = -100
    local translateY = 0


    local s1 = ag:CreateAnimation('Scale')
    s1:SetScale(0.01, 1)
    s1:SetDuration(0)
    s1:SetOrigin(scaleOrigin, 0, 0)
    s1:SetOrder(1)

    local s2 = ag:CreateAnimation('Scale')
    s2:SetScale(100, 1)
    s2:SetDuration(0.5)
    s2:SetOrigin(scaleOrigin, 0, 0)
    s2:SetSmoothing('OUT')
    s2:SetOrder(2)

    local a1 = ag:CreateAnimation('Alpha')
    a1:SetFromAlpha(0)
    a1:SetToAlpha(1)
    a1:SetDuration(0.1)
    a1:SetOrder(2)

    local t1 = ag:CreateAnimation('Translation')
    t1:SetOffset(translateX, translateY)
    t1:SetDuration(1.2)
    t1:SetSmoothing('IN')
    t1:SetOrder(2)

    local a2 = ag:CreateAnimation('Alpha')
    a2:SetFromAlpha(1)
    a2:SetToAlpha(0)
    a2:SetSmoothing('OUT')
    a2:SetDuration(0.5)
    a2:SetStartDelay(0.6)
    a2:SetOrder(2)

    ag.s1 = s1
    ag.s2 = s2
    ag.t1 = t1

    ag:SetScript('OnFinished', function(self)
        local icon = self:GetParent()
        icon:Hide()
        pool:Release(icon)
    end)

    return f
end

local function resetPoolIcon(pool, f)
    f:SetHeight(configs.lineIconSize)
    f:SetWidth(configs.lineIconSize)

    f.ag:Stop()

    local scaleOrigin, revOrigin, translateX, translateY
    -- local sx1, sx2, sy1, sy2
    if configs.lineDirection == 'RIGHT' then
        scaleOrigin = 'LEFT'
        revOrigin = 'RIGHT'
        -- sx1, sx2, sy1, sy2 = 0.01, 100, 1, 1
        translateX = 100
        translateY = 0
    elseif configs.lineDirection == 'TOP' then
        scaleOrigin = 'BOTTOM'
        revOrigin = 'TOP'
        -- sx1, sx2, sy1, sy2 = 1,1, 0.01, 100
        translateX = 0
        translateY = 100
    elseif configs.lineDirection == 'BOTTOM' then
        scaleOrigin = 'TOP'
        revOrigin = 'BOTTOM'
        -- sx1, sx2, sy1, sy2 = 1,1, 0.01, 100
        translateX = 0
        translateY = -100
    else
        scaleOrigin = 'RIGHT'
        revOrigin = 'LEFT'
        -- sx1, sx2, sy1, sy2 = 0.01, 100, 1, 1
        translateX = -100
        translateY = 0
    end
    local ag = f.ag
    -- ag.s1:SetScale(sx1, sy1)
    ag.s1:SetOrigin(scaleOrigin, 0, 0)

    -- ag.s1:SetScale(sx2, sy2)
    ag.s2:SetOrigin(scaleOrigin, 0, 0)
    ag.t1:SetOffset(translateX, translateY)

    f:ClearAllPoints()
    local parent = pool.parent
    f:SetPoint(scaleOrigin, parent, revOrigin, 0, 0)
end


local framePool = {
    -- creationFunc = function(self)
    --     return self.parent:CreateMaskTexture()
    -- end,
    -- resetterFunc = function(self, mask)
    --     mask:Hide()
    --     mask:ClearAllPoints()
    -- end,
    AddObject = function(self, object)
        local dummy = true
        self.activeObjects[object] = dummy
        self.activeObjectCount = self.activeObjectCount + 1
    end,
    ReclaimObject = function(self, object)
        tinsert(self.inactiveObjects, object)
        self.activeObjects[object] = nil
        self.activeObjectCount = self.activeObjectCount - 1
    end,
    Release = function(self, object)
        local active = self.activeObjects[object] ~= nil
        if active then
            self:resetterFunc(object)
            self:ReclaimObject(object)
        end
        return active
    end,
    Acquire = function(self)
        local object = tremove(self.inactiveObjects)
        local new = object == nil
        if new then
            object = self:creationFunc()
            self:resetterFunc(object, new)
        end
        self:AddObject(object)
        return object, new
    end,
    ReleaseAll = function(self)
        for obj in pairs(self.activeObjects) do
            self:Release(obj)
        end
    end,
    Init = function(self, parent)
        self.activeObjects = {}
        self.inactiveObjects = {}
        self.activeObjectCount = 0
        self.parent = parent
    end,
}
local function createFramePool(frameType, parent, frameTemplate, resetterFunc, frameInitFunc)
    local self = setmetatable({}, { __index = framePool })
    self:Init(parent)
    self.frameType = frameType
    -- self.parent = parent
    self.frameTemplate = frameTemplate
    return self
end

function kfb:CreateLastSpellIconLine(parent)
    local template        = nil
    local resetterFunc    = resetPoolIcon
    local iconPool        = createFramePool('Frame', parent, template, resetterFunc)
    iconPool.creationFunc = createPoolIcon
    iconPool.resetterFunc = resetPoolIcon
    iconPool.idCounter    = 1

    return iconPool
end
