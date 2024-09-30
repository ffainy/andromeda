local F, C, L = unpack(select(2, ...))
local AURA = F:GetModule('Aura')
local oUF = F.Libs.oUF

local function onEvent(_, isLogin, isReload)
    if isLogin or isReload then
        F.HideObject(BuffFrame)
        F.HideObject(DebuffFrame)
        BuffFrame.numHideableBuffs = 0 -- fix error when on editmode
    end
end

function AURA:HideBlizzFrame()
    if not C.DB.Aura.Enable and not C.DB.Auras.HideBlizzFrame then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', onEvent)
end

function AURA:BuildBuffFrame()
    if not C.DB.Aura.Enable then
        return
    end

    -- Config
    AURA.settings = {
        Buffs = {
            offset = 12,
            size = C.DB.Aura.BuffSize,
            wrapAfter = C.DB.Aura.BuffPerRow,
            maxWraps = 3,
            reverseGrow = C.DB.Aura.BuffReverse,
        },
        Debuffs = {
            offset = 12,
            size = C.DB.Aura.DebuffSize,
            wrapAfter = C.DB.Aura.DebuffPerRow,
            maxWraps = 1,
            reverseGrow = C.DB.Aura.DebuffReverse,
        },
    }

    -- Movers
    AURA.BuffFrame = AURA:CreateAuraHeader('HELPFUL')
    AURA.BuffFrame.mover = F.Mover(
        AURA.BuffFrame,
        L['BuffFrame'],
        'BuffAnchor',
        { 'TOPLEFT', UIParent, 'TOPLEFT', C.UI_GAP, -C.UI_GAP }
    )
    AURA.BuffFrame:ClearAllPoints()
    AURA.BuffFrame:SetPoint('TOPRIGHT', AURA.BuffFrame.mover)

    AURA.DebuffFrame = AURA:CreateAuraHeader('HARMFUL')
    AURA.DebuffFrame.mover = F.Mover(
        AURA.DebuffFrame,
        L['DebuffFrame'],
        'DebuffAnchor',
        { 'TOPLEFT', AURA.BuffFrame.mover, 'BOTTOMLEFT', 0, 30 }
    )
    AURA.DebuffFrame:ClearAllPoints()
    AURA.DebuffFrame:SetPoint('TOPRIGHT', AURA.DebuffFrame.mover)

    AURA:CreatePrivateAuras()
end

local day, hour, minute = 86400, 3600, 60
function AURA:FormatAuraTime(s)
    if s >= day then
        return format('|cffbebfb3%d|r' .. C.INFO_COLOR .. 'd', s / day + 0.5), s % day
    elseif s >= hour then
        return format('|cff4fcd35%d|r' .. C.INFO_COLOR .. 'h', s / hour + 0.5), s % hour
    elseif s >= 2 * hour then
        return format('|cff4fcd35%d|r' .. C.INFO_COLOR .. 'h', s / hour + 0.5), s % hour
    elseif s >= 10 * minute then
        return format('|cff21c8de%d|r' .. C.INFO_COLOR .. 'm', s / minute + 0.5), s % minute
    elseif s >= minute then
        return format('|cff21c8de%d:%.2d|r', s / minute, s % minute), s - floor(s)
    elseif s > 10 then
        return format('|cffffe700%d|r' .. C.INFO_COLOR .. 's', s + 0.5), s - floor(s)
    elseif s > 5 then
        return format('|cffffff00%.1f|r', s), s - format('%.1f', s)
    else
        return format('|cffff0000%.1f|r', s), s - format('%.1f', s)
    end
end

function AURA:UpdateTimer(elapsed)
    local onTooltip = GameTooltip:IsOwned(self)

    if not (self.timeLeft or self.expiration or onTooltip) then
        self:SetScript('OnUpdate', nil)
        return
    end

    if self.timeLeft then
        self.timeLeft = self.timeLeft - elapsed
    end

    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    if self.timeLeft and self.timeLeft >= 0 then
        local timer, nextUpdate = AURA:FormatAuraTime(self.timeLeft)
        self.nextUpdate = nextUpdate
        self.timer:SetText(timer)
    end

    if onTooltip then
        AURA:Button_SetTooltip(self)
    end
end

function AURA:GetSpellStat(arg16, arg17, arg18)
    if not arg16 then return end

    return (arg16 > 0 and L['Versa']) or (arg17 > 0 and L['Mastery']) or (arg18 > 0 and L['Haste']) or L['Crit']
end

function AURA:UpdateAuras(button, index)
    local unit, filter = button.header:GetAttribute('unit'), button.filter
    local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
    if not auraData then return end

    if auraData.duration > 0 and auraData.expirationTime then
        local timeLeft = auraData.expirationTime - GetTime()
        if not button.timeLeft then
            button.nextUpdate = -1
            button.timeLeft = timeLeft
            button:SetScript('OnUpdate', AURA.UpdateTimer)
        else
            button.timeLeft = timeLeft
        end
        button.nextUpdate = -1
        AURA.UpdateTimer(button, 0)
    else
        button.timeLeft = nil
        button.timer:SetText('')
    end

    local count = auraData.applications
    if count and count > 1 then
        button.count:SetText(count)
    else
        button.count:SetText('')
    end

    if filter == 'HARMFUL' then
        local color = oUF.colors.debuff[auraData.dispelName or 'none']
        button:SetBackdropBorderColor(color[1], color[2], color[3])

        if button.__shadow then
            button.__shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.25)
        end
    else
        button:SetBackdropBorderColor(0, 0, 0)

        if button.__shadow then
            button.__shadow:SetBackdropBorderColor(0, 0, 0, 0.25)
        end
    end

    -- Show spell stat for 'Soleahs Secret Technique'
    if auraData.spellId == 368512 then
        button.count:SetText(AURA:GetSpellStat(unpack(auraData.points)))
    end

    button.spellID = auraData.spellId
    button.icon:SetTexture(auraData.icon)
    button.expiration = nil
end

function AURA:UpdateTempEnchant(button, index)
    local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
    if expirationTime then
        local quality = GetInventoryItemQuality('player', index)
        local color = C.QualityColors[quality or 1]
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button.icon:SetTexture(GetInventoryItemTexture('player', index))

        button.expiration = expirationTime
        button.oldTime = GetTime()
        button:SetScript('OnUpdate', AURA.UpdateTimer)
        button.nextUpdate = -1
        AURA.UpdateTimer(button, 0)
    else
        button.expiration = nil
        button.timeLeft = nil
        button.timer:SetText('')
    end
end

function AURA:OnAttributeChanged(attribute, value)
    if attribute == 'index' then
        AURA:UpdateAuras(self, value)
    elseif attribute == 'target-slot' then
        AURA:UpdateTempEnchant(self, value)
    end
end

function AURA:UpdateOptions()
    AURA.settings.Buffs.size = C.DB.Aura.BuffSize
    AURA.settings.Buffs.wrapAfter = C.DB.Aura.BuffPerRow
    AURA.settings.Buffs.reverseGrow = C.DB.Aura.BuffReverse
    AURA.settings.Debuffs.size = C.DB.Aura.DebuffSize
    AURA.settings.Debuffs.wrapAfter = C.DB.Aura.DebuffPerRow
    AURA.settings.Debuffs.reverseGrow = C.DB.Aura.DebuffReverse
end

function AURA:UpdateHeader(header)
    local cfg = AURA.settings.Debuffs
    if header.filter == 'HELPFUL' then
        cfg = AURA.settings.Buffs
        header:SetAttribute('consolidateTo', 0)
        header:SetAttribute('weaponTemplate', format(C.ADDON_TITLE .. 'AuraTemplate%d', cfg.size))
    end

    header:SetAttribute('separateOwn', 1)
    header:SetAttribute('sortMethod', 'INDEX')
    header:SetAttribute('sortDirection', '+')
    header:SetAttribute('wrapAfter', cfg.wrapAfter)
    header:SetAttribute('maxWraps', cfg.maxWraps)
    header:SetAttribute('point', cfg.reverseGrow and 'TOPLEFT' or 'TOPRIGHT')
    header:SetAttribute('minWidth', (cfg.size + C.DB.Aura.Margin) * cfg.wrapAfter)
    header:SetAttribute('minHeight', (cfg.size + cfg.offset) * cfg.maxWraps)
    header:SetAttribute('xOffset', (cfg.reverseGrow and 1 or -1) * (cfg.size + C.DB.Aura.Margin))
    header:SetAttribute('yOffset', 0)
    header:SetAttribute('wrapXOffset', 0)
    header:SetAttribute('wrapYOffset', -(cfg.size + cfg.offset))
    header:SetAttribute('template', format(C.ADDON_TITLE .. 'AuraTemplate%d', cfg.size))

    local fontSize = floor(cfg.size / 30 * 10 + 0.5)
    local index = 1
    local child = select(index, header:GetChildren())
    while child do
        if (floor(child:GetWidth() * 100 + 0.5) / 100) ~= cfg.size then
            child:SetSize(cfg.size, cfg.size)
        end

        child.count:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')
        child.timer:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')

        -- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
        if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
            child:Hide()
        end

        index = index + 1
        child = select(index, header:GetChildren())
    end
end

function AURA:CreateAuraHeader(filter)
    local name = C.ADDON_TITLE .. 'PlayerDebuffs'
    if filter == 'HELPFUL' then
        name = C.ADDON_TITLE .. 'PlayerBuffs'
    end

    local header = CreateFrame('Frame', name, UIParent, 'SecureAuraHeaderTemplate')
    header:SetClampedToScreen(true)
    header:UnregisterEvent('UNIT_AURA') -- we only need to watch player and vehicle
    header:RegisterUnitEvent('UNIT_AURA', 'player', 'vehicle')
    header:SetAttribute('unit', 'player')
    header:SetAttribute('filter', filter)
    header.filter = filter
    RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')

    header.visibility = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
    header.visibility:RegisterEvent('WEAPON_ENCHANT_CHANGED')
    SecureHandlerSetFrameRef(header.visibility, 'AuraHeader', header)
    RegisterStateDriver(header.visibility, 'customVisibility', '[petbattle] 0;1')
    header.visibility:SetAttribute(
        '_onstate-customVisibility',
        [[
        local header = self:GetFrameRef('AuraHeader')
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]]
    ) -- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`

    if filter == 'HELPFUL' then
        header:SetAttribute('consolidateDuration', -1)
        header:SetAttribute('includeWeapons', 1)
    end

    AURA:UpdateHeader(header)
    header:Show()

    return header
end

function AURA:Button_SetTooltip(button)
    if button:GetAttribute('index') then
        GameTooltip:SetUnitAura(button.header:GetAttribute('unit'), button:GetID(), button.filter)
    elseif button:GetAttribute('target-slot') then
        GameTooltip:SetInventoryItem('player', button:GetID())
    end
end

function AURA:Button_OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT', -5, -5)
    -- Update tooltip
    self.nextUpdate = -1
    self:SetScript('OnUpdate', AURA.UpdateTimer)
end

local indexToOffset = { 2, 6, 10 }
function AURA:CreateAuraIcon(button)
    button.header = button:GetParent()
    button.filter = button.header.filter
    button.name = button:GetName()
    local enchantIndex = tonumber(strmatch(button.name, 'TempEnchant(%d)$'))
    button.enchantOffset = indexToOffset[enchantIndex]

    local cfg = AURA.settings.Debuffs
    if button.filter == 'HELPFUL' then
        cfg = AURA.settings.Buffs
    end
    local fontSize = floor(cfg.size / 30 * 10 + 0.5)

    button.icon = button:CreateTexture(nil, 'BORDER')
    button.icon:SetInside()
    button.icon:SetTexCoord(unpack(C.TEX_COORD))

    button.count = button:CreateFontString(nil, 'ARTWORK')
    button.count:SetPoint('CENTER', button, 'TOP')
    button.count:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')

    button.timer = button:CreateFontString(nil, 'ARTWORK')
    button.timer:SetPoint('CENTER', button, 'BOTTOM')
    button.timer:SetFont(C.Assets.Fonts.HalfHeight, fontSize, 'OUTLINE')

    button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
    button.highlight:SetColorTexture(1, 1, 1, 0.25)
    button.highlight:SetInside()

    F.CreateBD(button, 0.25)
    F.CreateSD(button)

    button:RegisterForClicks('RightButtonUp', 'RightButtonDown')
    button:SetScript('OnAttributeChanged', AURA.OnAttributeChanged)
    button:SetScript('OnEnter', AURA.Button_OnEnter)
    button:SetScript('OnLeave', F.HideTooltip)
end

local auraAnchor = {
    unitToken = 'player',
    auraIndex = 1,
    parent = UIParent,
    showCountdownFrame = true,
    showCountdownNumbers = true,

    iconInfo = {
        iconWidth = 30,
        iconHeight = 30,
        iconAnchor = {
            point = 'CENTER',
            relativeTo = UIParent,
            relativePoint = 'CENTER',
            offsetX = 0,
            offsetY = 0,
        },
    },

    durationAnchor = {
        point = 'TOP',
        relativeTo = UIParent,
        relativePoint = 'BOTTOM',
        offsetX = 0,
        offsetY = 0,
    },
}

function AURA:CreatePrivateAuras()
    local maxButtons = 4 -- only 4 in blzz code, needs review
    local buttonSize = C.DB.Aura.PrivateSize
    local reverse = C.DB.Aura.PrivateReverse

    AURA.PrivateFrame = CreateFrame('Frame', 'NDuiPrivateAuras', UIParent)
    AURA.PrivateFrame:SetSize(
        (buttonSize + C.DB.Aura.Margin) * maxButtons - C.DB.Aura.Margin,
        buttonSize + 2 * C.DB.Aura.Margin
    )
    AURA.PrivateFrame.mover = F.Mover(
        AURA.PrivateFrame,
        'PrivateAuras',
        'PrivateAuras',
        { 'TOPRIGHT', AURA.DebuffFrame.mover, 'BOTTOMRIGHT', 0, -12 }
    )
    AURA.PrivateFrame:ClearAllPoints()
    AURA.PrivateFrame:SetPoint('TOPRIGHT', AURA.PrivateFrame.mover)

    AURA.PrivateAuras = {}
    local prevButton

    local rel1 = reverse and 'TOPLEFT' or 'TOPRIGHT'
    local rel2 = reverse and 'LEFT' or 'RIGHT'
    local rel3 = reverse and 'RIGHT' or 'LEFT'
    local margin = reverse and C.DB.Aura.Margin or -C.DB.Aura.Margin

    for i = 1, maxButtons do
        local button = CreateFrame('Frame', '$parentAnchor' .. i, AURA.PrivateFrame)
        button:SetSize(buttonSize, buttonSize)
        if not prevButton then
            button:SetPoint(rel1, AURA.PrivateFrame)
        else
            button:SetPoint(rel2, prevButton, rel3, margin, 0)
        end
        prevButton = button

        auraAnchor.auraIndex = i
        auraAnchor.parent = button
        auraAnchor.durationAnchor.relativeTo = button
        auraAnchor.iconInfo.iconWidth = buttonSize
        auraAnchor.iconInfo.iconHeight = buttonSize
        auraAnchor.iconInfo.iconAnchor.relativeTo = button

        C_UnitAuras.RemovePrivateAuraAnchor(i)
        C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
        AURA.PrivateAuras[i] = button
    end
end

function AURA:OnLogin()
    if not C.DB.Aura.Enable then
        return
    end

    AURA:HideBlizzFrame()
    AURA:BuildBuffFrame()
end
