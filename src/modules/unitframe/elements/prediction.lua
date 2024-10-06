local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')

function UNITFRAME:PostUpdatePrediction(_, health, maxHealth, allIncomingHeal, allAbsorb)
    self.overAbsorb:Hide()

    local overAbsorbAmount = health + allIncomingHeal + allAbsorb - maxHealth
    if overAbsorbAmount > 0 then
        if overAbsorbAmount > maxHealth then
            self.overAbsorb:Show()
            overAbsorbAmount = maxHealth
        end
        self.overAbsorbBar:SetMinMaxValues(0, maxHealth)
        self.overAbsorbBar:SetValue(overAbsorbAmount)
        self.overAbsorbBar:Show()
    else
        self.overAbsorbBar:Hide()
    end
end

function UNITFRAME:CreateHealPrediction(self)
    local frame = CreateFrame('Frame', nil, self)
    frame:SetAllPoints(self.Health)
    local frameLevel = frame:GetFrameLevel() - 1

    -- Position and size
    local myBar = CreateFrame('StatusBar', nil, frame)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetStatusBarTexture(UNITFRAME.StatusBarTex)
    myBar:SetStatusBarColor(0, 1, .5, .5)
    myBar:Hide()

    local otherBar = CreateFrame('StatusBar', nil, frame)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetPoint('LEFT', myBar:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetStatusBarTexture(UNITFRAME.StatusBarTex)
    otherBar:SetStatusBarColor(0, 1, 0, .5)
    otherBar:Hide()

    local absorbBar = CreateFrame('StatusBar', nil, frame)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetPoint('LEFT', otherBar:GetStatusBarTexture(), 'RIGHT')
    absorbBar:SetStatusBarTexture(UNITFRAME.StatusBarTex)
    absorbBar:SetStatusBarColor(.66, 1, 1, .7)
    absorbBar:SetFrameLevel(frameLevel)
    absorbBar:Hide()

    local overAbsorbBar = CreateFrame('StatusBar', nil, frame)
    overAbsorbBar:SetAllPoints()
    overAbsorbBar:SetStatusBarTexture(UNITFRAME.StatusBarTex)
    overAbsorbBar:SetStatusBarColor(.66, 1, 1, .5)
    overAbsorbBar:SetFrameLevel(frameLevel)
    overAbsorbBar:Hide()

    local healAbsorbBar = CreateFrame('StatusBar', nil, frame)
    healAbsorbBar:SetPoint('TOP')
    healAbsorbBar:SetPoint('BOTTOM')
    healAbsorbBar:SetPoint('RIGHT', self.Health:GetStatusBarTexture())
    healAbsorbBar:SetReverseFill(true)
    healAbsorbBar:SetStatusBarTexture(UNITFRAME.StatusBarTex)
    local tex = healAbsorbBar:GetStatusBarTexture()
    tex:SetTexture('Interface\\RaidFrame\\Shield-Overlay', true, true)
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    healAbsorbBar:Hide()

    local overAbsorb = self.Health:CreateTexture(nil, 'OVERLAY')
    overAbsorb:SetWidth(15)
    overAbsorb:SetTexture('Interface\\RaidFrame\\Shield-Overshield')
    overAbsorb:SetBlendMode('ADD')
    overAbsorb:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', -5, 2)
    overAbsorb:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMRIGHT', -5, -2)
    overAbsorb:Hide()

    local overHealAbsorb = frame:CreateTexture(nil, 'OVERLAY')
    overHealAbsorb:SetWidth(15)
    overHealAbsorb:SetTexture('Interface\\RaidFrame\\Absorb-Overabsorb')
    overHealAbsorb:SetBlendMode('ADD')
    overHealAbsorb:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', 5, 2)
    overHealAbsorb:SetPoint('BOTTOMRIGHT', self.Health, 'BOTTOMLEFT', 5, -2)
    overHealAbsorb:Hide()

    -- Register with oUF
    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        healAbsorbBar = healAbsorbBar,
        overAbsorbBar = overAbsorbBar,
        overAbsorb = overAbsorb,
        overHealAbsorb = overHealAbsorb,
        maxOverflow = 1,
        PostUpdate = UNITFRAME.PostUpdatePrediction,
    }
    self.predicFrame = frame
end
