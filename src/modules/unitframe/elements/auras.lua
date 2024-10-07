local F, C, L = unpack(select(2, ...))
local uf = F:GetModule('UnitFrame')
local np = F:GetModule('Nameplate')
local oUF = F.Libs.oUF

local x1, x2, y1, y2 = unpack(C.TEX_COORD)
function uf:UpdateIconTexCoord(width, height)
    local ratio = height / width
    local mult = (1 - ratio) / 2

    self.Icon:SetTexCoord(x1, x2, y1 + mult, y2 - mult)
end

function uf.PostCreateButton(element, button)
    button.bg = F.CreateBDFrame(button, 0.25)
    button.glow = F.CreateSD(button.bg)

    button:SetFrameLevel(element:GetFrameLevel() + 4)

    button.Overlay:SetTexture(nil)
    button.Stealable:SetTexture(nil)
    button.Cooldown:SetReverse(true)
    button.Icon:SetDrawLayer('ARTWORK')

    local style = element.__owner.unitStyle
    local isGroup = style == 'party' or style == 'raid'
    local isNP = style == 'nameplate'

    if isGroup then
        button.Icon:SetTexCoord(unpack(C.TEX_COORD))
    elseif isNP then
        button.Icon:SetTexCoord(0.1, 0.9, 0.26, 0.74)     -- precise texcoord for rectangular icons
    else
        button.Icon:SetTexCoord(0.1, 0.9, 0.22, 0.78)     -- precise texcoord for rectangular icons
    end

    -- hooksecurefunc(button, "SetSize", uf.UpdateIconTexCoord)

    button.HL = button:CreateTexture(nil, 'HIGHLIGHT')
    button.HL:SetColorTexture(1, 1, 1, 0.25)
    button.HL:SetAllPoints()

    local outline = _G.ANDROMEDA_ADB.FontOutline
    local font = C.Assets.Fonts.HalfHeight
    local fontSize = max((element.width or element.size) * 0.4, 12)
    button.Count = F.CreateFS(button, font, fontSize, outline or nil, nil, nil, outline and 'NONE' or 'THICK')
    button.Count:ClearAllPoints()
    button.Count:SetPoint('RIGHT', button, 'TOPRIGHT')
    button.timer = F.CreateFS(button, font, fontSize, outline or nil, nil, nil, outline and 'NONE' or 'THICK')
    button.timer:ClearAllPoints()
    button.timer:SetPoint('LEFT', button, 'BOTTOMLEFT')
end

local filteredUnits = {
    ['target'] = true,
    ['nameplate'] = true,
    ['boss'] = true,
    ['arena'] = true,
}

uf.ReplacedSpellIcons = {
    [368078] = 348567,     -- 移速
    [368079] = 348567,     -- 移速
    [368103] = 648208,     -- 急速
    [368243] = 237538,     -- CD
    [373785] = 236293,     -- S4，大魔王伪装
}

local dispellType = {
    ['Magic'] = true,
    [''] = true,
}

function uf.PostUpdateButton(element, button, unit, data)
    local duration = data.duration
    local expiration = data.expirationTime
    local debuffType = data.dispelName
    local isStealable = data.isStealable

    if duration then
        button.bg:Show()

        if button.glow then
            button.glow:Show()
        end
    end

    local style = element.__owner.unitStyle
    local isGroup = style == 'party' or style == 'raid'
    local isNP = style == 'nameplate'
    button:SetSize(element.size, (isGroup and element.size) or (isNP and element.size * 0.6) or element.size * 0.7)

    --[[ local squareness = .6
        element.icon_height = element.size * squareness
        element.icon_ratio = (1 - (element.icon_height / element.size)) / 2.5
        element.tex_coord = {.1,.9,.1+element.icon_ratio,.9-element.icon_ratio}
        print('element.icon_height', element.icon_height)
        print('element.icon_ratio', element.icon_ratio) ]]

    if element.desaturateDebuff and button.isHarmful and filteredUnits[style] and not data.isPlayerAura then
        button.Icon:SetDesaturated(true)
    else
        button.Icon:SetDesaturated(false)
    end

    if element.alwaysShowStealable and dispellType[debuffType] and not UnitIsPlayer(unit) and not button.isHarmful then
        button.Stealable:Show()
    end

    if isStealable then
        button.bg:SetBackdropBorderColor(1, 1, 1)

        if button.glow then
            button.glow:SetBackdropBorderColor(1, 1, 1, 0.25)
        end
    elseif element.showDebuffType and button.isHarmful then
        local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
        button.bg:SetBackdropBorderColor(color[1], color[2], color[3])

        if button.glow then
            button.glow:SetBackdropBorderColor(color[1], color[2], color[3], 0.25)
        end
    else
        button.bg:SetBackdropBorderColor(0, 0, 0)

        if button.glow then
            button.glow:SetBackdropBorderColor(0, 0, 0, 0.25)
        end
    end

    if element.disableCooldown then
        if duration and duration > 0 then
            button.expiration = expiration
            button:SetScript('OnUpdate', F.CooldownOnUpdate)
            button.timer:Show()
        else
            button:SetScript('OnUpdate', nil)
            button.timer:Hide()
        end
    end

    local newTexture = uf.ReplacedSpellIcons[button.spellID]
    if newTexture then
        button.Icon:SetTexture(newTexture)
    end

    if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
        button.Count:SetText(element.bolsterStacks)
    end
end

function uf.AurasPostUpdateInfo(element, _, _, debuffsChanged)
    element.bolsterStacks = 0
    element.bolsterInstanceID = nil
    element.hasTheDot = nil

    for auraInstanceID, data in next, element.allBuffs do
        if data.spellId == 209859 then
            if not element.bolsterInstanceID then
                element.bolsterInstanceID = auraInstanceID
                element.activeBuffs[auraInstanceID] = true
            end

            element.bolsterStacks = element.bolsterStacks + 1

            if element.bolsterStacks > 1 then
                element.activeBuffs[auraInstanceID] = nil
            end
        end
    end

    if element.bolsterStacks > 0 then
        for i = 1, element.visibleButtons do
            local button = element[i]
            if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
                button.Count:SetText(element.bolsterStacks)
                break
            end
        end
    end

    if debuffsChanged then
        element.hasTheDot = nil

        if C.DB['Nameplate']['ColorByDot'] then
            for _, data in next, element.allDebuffs do
                if data.isPlayerAura and C.DB['Nameplate']['DotSpellsList'][data.spellId] then
                    element.hasTheDot = true
                    break
                end
            end
        end
    end
end

function uf.FilterAura(element, unit, data)
    local style = element.__owner.unitStyle
    local name = data.name
    local debuffType = data.dispelName
    local isStealable = data.isStealable
    local spellID = data.spellId
    local nameplateShowAll = data.nameplateShowAll
    local isPlayerAura = data.isPlayerAura
    local isHarmful = data.isHarmful
    local isHelpful = data.isHelpful

    if style == 'nameplate' or style == 'boss' or style == 'arena' then
        if name and spellID == 209859 then     -- pass all bolster
            return true
        end
        if element.__owner.plateType == 'NameOnly' then
            return np.NameplateAuraWhiteList[spellID]
        elseif np.NameplateAuraBlackList[spellID] then
            return false
        elseif (element.showStealableBuffs and isStealable or element.alwaysShowStealable and dispellType[debuffType]) and not UnitIsPlayer(unit) and not data.isHarmful then
            return true
        elseif np.NameplateAuraWhiteList[spellID] then
            return true
        else
            local auraFilter = C.DB.Nameplate.AuraFilterMode
            return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isPlayerAura)
        end
    elseif style == 'player' then
        return true
    elseif style == 'pet' then
        return true
    elseif style == 'target' then
        if C.DB.Unitframe.HideTargetBuffs then
            return isStealable or (isHarmful and element.onlyShowPlayer and isPlayerAura) or
                (not element.onlyShowPlayer and isHarmful and name)
        else
            return isStealable or not isHarmful or (element.onlyShowPlayer and isPlayerAura) or
                (not element.onlyShowPlayer and name)
        end
    else
        return (element.onlyShowPlayer and isPlayerAura) or (not element.onlyShowPlayer and name)
    end
end

function uf.PostUpdateGapButton(_, _, button)
    if button and button:IsShown() then
        button:Hide()
    end
end

local function calcIconSize(width, num, size)
    return (width - (num - 1) * size) / num
end

function uf:UpdateAuraContainer(parent, element, maxAuras)
    local width = parent:GetWidth()
    local iconsPerRow = element.iconsPerRow
    local maxLines = iconsPerRow and F:Round(maxAuras / iconsPerRow) or 2

    element.size = iconsPerRow and calcIconSize(width, iconsPerRow, element.spacing) or element.size
    element:SetWidth(width)
    element:SetHeight((element.size + element.spacing) * maxLines)

    local fontSize = max((element.width or element.size) * 0.4, 12)
    for i = 1, #element do
        local button = element[i]
        if button then
            if button.timer then
                F.SetFontSize(button.timer, fontSize)
            end
            if button.Count then
                F.SetFontSize(button.Count, fontSize)
            end
        end
    end
end

function uf:ConfigureAuras(element)
    local value = element.__value

    --element.numBuffs = C.DB['Unitframe'][value .. 'BuffType'] ~= 1 and C.DB['Unitframe'][value .. 'NumBuff'] or 0
    --element.numDebuffs = C.DB['Unitframe'][value .. 'DebuffType'] ~= 1 and C.DB['Unitframe'][value .. 'NumDebuff'] or 0

    element.iconsPerRow = C.DB['Unitframe'][value .. 'AuraPerRow']

    element.showDebuffType = C.DB.Unitframe.DebuffTypeColor
    element.desaturateDebuff = C.DB.Unitframe.DesaturateIcon
    element.onlyShowPlayer = C.DB.Unitframe.OnlyShowPlayer
    element.showStealableBuffs = C.DB.Unitframe.StealableBuffs
end

local function refreshAuras(frame)
    if not (frame and frame.Auras) then
        return
    end

    local element = frame.Auras
    if not element then
        return
    end

    uf:ConfigureAuras(element)
    uf:UpdateAuraContainer(frame, element, element.numBuffs + element.numDebuffs)
    uf:UpdateAuraDirection(frame, element)

    element:ForceUpdate()
end

function uf:RefreshAuras()
    refreshAuras(_G['oUF_Player'])
    refreshAuras(_G['oUF_Pet'])
    refreshAuras(_G['oUF_Target'])
    refreshAuras(_G['oUF_TargetTarget'])
    refreshAuras(_G['oUF_Focus'])
    refreshAuras(_G['oUF_FocusTarget'])

    for i = 1, 5 do
        refreshAuras(_G['oUF_Boss' .. i])
        refreshAuras(_G['oUF_Arena' .. i])
    end
end

function uf:UpdateAuras()
    for _, frame in pairs(oUF.objects) do
        if C.DB.Unitframe.ShowAuras then
            if not frame:IsElementEnabled('Auras') then
                frame:EnableElement('Auras')
                refreshAuras(frame)
            end
        else
            if frame:IsElementEnabled('Auras') then
                frame:DisableElement('Auras')
            end
        end
    end
end

function uf:ToggleAllAuras()
    local enable = C.DB.Unitframe.ShowAuras
    uf:ToggleAuras(_G['oUF_Player'])
    uf:ToggleAuras(_G['oUF_Pet'])
    uf:ToggleAuras(_G['oUF_Target'])
    uf:ToggleAuras(_G['oUF_TargetTarget'])
    uf:ToggleAuras(_G['oUF_Focus'])
    uf:ToggleAuras(_G['oUF_FocusTarget'])
end

local function UpdatePlayerAuraPosition(self)
    local specIndex = GetSpecialization()

    if
        (C.MY_CLASS == 'ROGUE' or C.MY_CLASS == 'PALADIN'
            or C.MY_CLASS == 'WARLOCK' or C.MY_CLASS == 'DEATHKNIGHT'
            or (C.MY_CLASS == 'DRUID' and specIndex == 2)
            or (C.MY_CLASS == 'MONK' and specIndex == 3)
            or (C.MY_CLASS == 'MAGE' and specIndex == 1))
        and C.DB.Unitframe.ClassPower
    then
        self.Auras:ClearAllPoints()
        self.Auras:SetPoint('TOP', self.ClassPowerBar, 'BOTTOM', 0, -5)
    else
        self.Auras:ClearAllPoints()
        self.Auras:SetPoint('TOP', self.Power, 'BOTTOM', 0, -5)
    end

    self:UnregisterEvent('PLAYER_ENTERING_WORLD', UpdatePlayerAuraPosition, true)
end

function uf:UpdatePlayerAuraPosition(self)
    self:RegisterEvent('PLAYER_ENTERING_WORLD', UpdatePlayerAuraPosition, true)
    self:RegisterEvent('PLAYER_TALENT_UPDATE', UpdatePlayerAuraPosition, true)
end

function uf:CreateAuras(self)
    local style = self.unitStyle
    local bu = CreateFrame('Frame', nil, self)
    bu:SetFrameLevel(self:GetFrameLevel() + 2)
    bu.gap = true
    bu.spacing = 5
    bu.numBuffs = 32
    bu.numDebuffs = 40
    bu.disableCooldown = true
    bu.tooltipAnchor = 'ANCHOR_TOPRIGHT'

    if style == 'player' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -5)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'Player'
        uf:ConfigureAuras(bu)
    elseif style == 'pet' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'Pet'
        uf:ConfigureAuras(bu)
    elseif style == 'target' then
        bu.initialAnchor = 'BOTTOMLEFT'
        bu:SetPoint('BOTTOM', self, 'TOP', 0, 24)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'UP'
        bu.__value = 'Target'
        uf:ConfigureAuras(bu)
    elseif style == 'targettarget' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'TargetTarget'
        uf:ConfigureAuras(bu)
    elseif style == 'focus' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'Focus'
        uf:ConfigureAuras(bu)
    elseif style == 'focustarget' then
        bu.initialAnchor = 'TOPRIGHT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'LEFT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'FocusTarget'
        uf:ConfigureAuras(bu)
    elseif style == 'boss' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'Boss'
        uf:ConfigureAuras(bu)
    elseif style == 'arena' then
        bu.initialAnchor = 'TOPLEFT'
        bu:SetPoint('TOP', self.Power, 'BOTTOM', 0, -4)
        bu['growth-x'] = 'RIGHT'
        bu['growth-y'] = 'DOWN'
        bu.__value = 'Arena'
        uf:ConfigureAuras(bu)
    end

    uf:UpdateAuraContainer(self, bu, bu.numTotal or bu.numBuffs + bu.numDebuffs)

    bu.FilterAura = uf.FilterAura
    bu.PostCreateButton = uf.PostCreateButton
    bu.PostUpdateButton = uf.PostUpdateButton
    bu.PostUpdateGapButton = uf.PostUpdateGapButton

    self.Auras = bu

    F:RegisterEvent('PLAYER_ENTERING_WORLD', uf.UpdateAuraFilter)
end

function uf:CreatePartyAuras()

end

function np:CreateAuras(self)
    local bu = CreateFrame('Frame', nil, self)
    bu.gap = true
    bu.spacing = 5
    bu.numTotal = 32
    bu.initialAnchor = 'BOTTOMLEFT'
    bu:SetPoint('BOTTOM', self, 'TOP', 0, 16)
    bu['growth-x'] = 'RIGHT'
    bu['growth-y'] = 'UP'
    bu.iconsPerRow = C.DB.Nameplate.AuraPerRow
    bu.disableCooldown = true
    bu.tooltipAnchor = 'ANCHOR_BOTTOMLEFT'

    uf:UpdateAuraContainer(self, bu, bu.numTotal)

    bu.onlyShowPlayer = C.DB.Nameplate.OnlyShowPlayer
    bu.desaturateDebuff = C.DB.Nameplate.DesaturateIcon
    bu.showDebuffType = C.DB.Nameplate.DebuffTypeColor
    bu.showStealableBuffs = C.DB.Nameplate.DispellMode == 1
    bu.alwaysShowStealable = C.DB.Nameplate.DispellMode == 2
    bu.disableMouse = true
    bu.disableCooldown = true

    bu.FilterAura = uf.FilterAura
    bu.PostCreateButton = uf.PostCreateButton
    bu.PostUpdateButton = uf.PostUpdateButton
    bu.PostUpdateGapButton = uf.PostUpdateGapButton
    bu.PostUpdateInfo = uf.AurasPostUpdateInfo

    self.Auras = bu
end
