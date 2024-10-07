local F, C = unpack(select(2, ...))
local uf = F:GetModule('UnitFrame')
local oUF = F.Libs.oUF

-- Debuffs on party/raid frames

do
    function uf:AuraButton_OnEnter()
        if not self.index then
            return
        end

        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
        GameTooltip:ClearLines()
        GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
        GameTooltip:Show()
    end

    uf.RaidDebuffsBlackList = {}
    function uf:UpdateRaidDebuffsBlackList()
        wipe(uf.RaidDebuffsBlackList)

        for spellID in pairs(C.RaidDebuffsBlackList) do
            local name = C_Spell.GetSpellName(spellID)
            if name then
                if _G.ANDROMEDA_ADB['RaidDebuffsBlackList'][spellID] == nil then
                    uf.RaidDebuffsBlackList[spellID] = true
                end
            end
        end

        for spellID, value in pairs(_G.ANDROMEDA_ADB['RaidDebuffsBlackList']) do
            if value then
                uf.RaidDebuffsBlackList[spellID] = true
            end
        end
    end

    function uf:CreateDebuffsIndicator(self)
        local debuffFrame = CreateFrame('Frame', nil, self)
        debuffFrame:SetSize(1, 1)
        debuffFrame:SetPoint('BOTTOMRIGHT', -2, 2)

        debuffFrame.buttons = {}
        local prevDebuff
        for i = 1, 3 do
            local button = CreateFrame('Frame', nil, debuffFrame)
            F.PixelIcon(button)
            button:SetScript('OnEnter', uf.AuraButton_OnEnter)
            button:SetScript('OnLeave', F.HideTooltip)
            button:Hide()

            local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
            cd:SetAllPoints()
            cd:SetReverse(true)
            button.cd = cd

            local parentFrame = CreateFrame('Frame', nil, button)
            parentFrame:SetAllPoints()
            parentFrame:SetFrameLevel(button:GetFrameLevel() + 6)

            local outline = _G.ANDROMEDA_ADB.FontOutline
            button.count = F.CreateFS(parentFrame, C.Assets.Fonts.Small, 11, outline or nil, nil, nil,
                outline and 'NONE' or 'THICK')
            button.count:ClearAllPoints()
            button.count:SetPoint('RIGHT', parentFrame, 'TOPRIGHT')

            button.cd = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
            button.cd:SetAllPoints()
            button.cd:SetReverse(true)
            button.cd:SetHideCountdownNumbers(true)

            if not prevDebuff then
                button:SetPoint('BOTTOMLEFT', self.Health)
            else
                button:SetPoint('LEFT', prevDebuff, 'RIGHT')
            end
            prevDebuff = button
            debuffFrame.buttons[i] = button
        end

        self.DebuffsIndicator = debuffFrame

        uf.DebuffsIndicator_UpdateOptions(self)
    end

    function uf:DebuffsIndicator_UpdateButton(debuffIndex, aura)
        local button = self.DebuffsIndicator.buttons[debuffIndex]
        if not button then
            return
        end

        button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
        if button.cd then
            if aura.duration and aura.duration > 0 then
                button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
                button.cd:Show()
            else
                button.cd:Hide()
            end
        end

        if button.bg then
            if aura.isDebuff then
                local color = oUF.colors.debuff[aura.debuffType] or oUF.colors.debuff.none
                button.bg:SetBackdropBorderColor(color[1], color[2], color[3])
            else
                button.bg:SetBackdropBorderColor(0, 0, 0)
            end
        end

        if button.Icon then
            button.Icon:SetTexture(aura.texture)
        end
        if button.count then
            button.count:SetText(aura.count > 1 and aura.count or '')
        end

        button:Show()
    end

    function uf:DebuffsIndicator_HideButtons(from, to)
        if not self.DebuffsIndicator then return end
        for i = from, to do
            local button = self.DebuffsIndicator.buttons[i]
            if button then
                button:Hide()
            end
        end
    end

    function uf.DebuffsIndicator_Filter(raidAuras, aura)
        local spellID = aura.spellID
        if uf.RaidDebuffsBlackList[spellID] then
            return false
        elseif aura.isBossAura or SpellIsPriorityAura(spellID) then
            return true
        else
            local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID,
                raidAuras.isInCombat and 'RAID_INCOMBAT' or 'RAID_OUTOFCOMBAT')
            if hasCustom then
                return showForMySpec or (alwaysShowMine and aura.isPlayerAura)
            else
                return true
            end
        end
    end

    function uf:DebuffsIndicator_UpdateOptions()
        local debuffs = self.DebuffsIndicator
        if not debuffs then
            return
        end

        debuffs.enable = C.DB.Unitframe.ShowRaidDebuff
        local size = C.DB.Unitframe.RaidDebuffSize
        local scale = C.DB.Unitframe.RaidDebuffScale
        local disableMouse = C.DB.Unitframe.RaidDebuffClickThru

        for i = 1, 3 do
            local button = debuffs.buttons[i]
            if button then
                button:SetSize(size, size)
                button:SetScale(scale)
                button:EnableMouse(not disableMouse)
            end
        end
    end
end

-- Buffs on party/raid frames

do
    uf.RaidBuffsWhiteList = {}
    function uf:UpdateRaidBuffsWhiteList()
        wipe(uf.RaidBuffsWhiteList)

        for spellID in pairs(C.RaidBuffsWhiteList) do
            local name = C_Spell.GetSpellName(spellID)
            if name then
                if _G.ANDROMEDA_ADB['RaidBuffsWhiteList'][spellID] == nil then
                    uf.RaidBuffsWhiteList[spellID] = true
                end
            end
        end

        for spellID, value in pairs(_G.ANDROMEDA_ADB['RaidBuffsWhiteList']) do
            if value then
                uf.RaidBuffsWhiteList[spellID] = true
            end
        end
    end

    function uf:CreateBuffsIndicator(self)
        local buffFrame = CreateFrame('Frame', nil, self)
        buffFrame:SetSize(1, 1)
        buffFrame:SetPoint('LEFT', self, 'RIGHT', 5, 0)
        buffFrame:SetFrameLevel(5)

        buffFrame.buttons = {}
        local prevBuff
        for i = 1, 3 do
            local button = CreateFrame('Frame', nil, buffFrame)
            F.PixelIcon(button, nil, nil, true)
            button:SetScript('OnEnter', uf.AuraButton_OnEnter)
            button:SetScript('OnLeave', F.HideTooltip)
            button:Hide()

            local parentFrame = CreateFrame('Frame', nil, button)
            parentFrame:SetAllPoints()
            parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)

            local outline = _G.ANDROMEDA_ADB.FontOutline
            button.count = F.CreateFS(parentFrame, C.Assets.Fonts.Small, 11, outline or nil, nil, nil,
                outline and 'NONE' or 'THICK')
            button.count:ClearAllPoints()
            button.count:SetPoint('RIGHT', parentFrame, 'TOPRIGHT')

            button.cd = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
            button.cd:SetAllPoints()
            button.cd:SetReverse(true)
            button.cd:SetHideCountdownNumbers(true)

            if not prevBuff then
                button:SetPoint('LEFT', self, 'RIGHT', 5, 0)
            else
                button:SetPoint('LEFT', prevBuff, 'RIGHT', 3, 0)
            end
            prevBuff = button
            buffFrame.buttons[i] = button
        end

        self.BuffsIndicator = buffFrame

        uf.BuffsIndicator_UpdateOptions(self)
    end

    function uf:BuffsIndicator_UpdateButton(buffIndex, aura)
        local button = self.BuffsIndicator.buttons[buffIndex]
        if not button then
            return
        end

        button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
        if button.cd then
            if aura.duration and aura.duration > 0 then
                button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
                button.cd:Show()
            else
                button.cd:Hide()
            end
        end

        if button.Icon then
            button.Icon:SetTexture(aura.texture)
        end
        if button.count then
            button.count:SetText(aura.count > 1 and aura.count or '')
        end

        button:Show()
    end

    function uf:BuffsIndicator_HideButtons(from, to)
        if not self.BuffsIndicator then return end
        for i = from, to do
            local button = self.BuffsIndicator.buttons[i]
            if button then
                button:Hide()
            end
        end
    end

    function uf.BuffsIndicator_Filter(raidAuras, aura)
        local spellID = aura.spellID
        if aura.isBossAura then
            return true
        elseif C.DB.Unitframe.RaidBuffAuto then
            local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID,
                raidAuras.isInCombat and 'RAID_INCOMBAT' or 'RAID_OUTOFCOMBAT')
            if hasCustom then
                return showForMySpec or (alwaysShowMine and aura.isPlayerAura)
            else
                return aura.isPlayerAura and aura.canApply and not SpellIsSelfBuff(spellID)
            end
        else
            return uf.RaidBuffsWhiteList[spellID]
        end
    end

    function uf:BuffsIndicator_UpdateOptions()
        local buffs = self.BuffsIndicator
        if not buffs then
            return
        end

        buffs.enable = C.DB.Unitframe.ShowRaidBuff
        local size = (C.DB.Unitframe.PartyHealthHeight + C.DB.Unitframe.PartyPowerHeight) * 0.75
        local scale = C.DB.Unitframe.RaidBuffScale
        local disableMouse = C.DB.Unitframe.BuffClickThru

        for i = 1, 3 do
            local button = buffs.buttons[i]
            if button then
                button:SetSize(size, size)
                button:SetScale(scale)
                button:EnableMouse(not disableMouse)
            end
        end
    end
end

local invalidPrio = -1

function uf:CreateRaidAuras(self)
    -- Indicators
    uf:CreateAurasIndicator(self)
    uf:CreateSpellsIndicator(self)

    local style = self.unitStyle
    if style == ('party' or 'raid') then
        uf:CreateBuffsIndicator(self)
        uf:CreateDebuffsIndicator(self)
    end

    -- RaidAuras Util
    local frame = CreateFrame('Frame', nil, self)
    frame:SetSize(1, 1)
    frame:SetPoint('CENTER')

    self.RaidAuras = frame
    self.RaidAuras.PostUpdate = uf.RaidAurasPostUpdate
end

function uf.RaidAurasPostUpdate(element, unit)
    local self = element.__owner
    local auras = self.AurasIndicator
    local spells = self.SpellsIndicator
    local debuffs = self.DebuffsIndicator
    local buffs = self.BuffsIndicator

    local enableSpells = C.DB.Unitframe.CornerSpell
    local auraIndex, debuffIndex, buffIndex = 0, 0, 0
    local numBuffs = element.buffList.num
    local numDebuffs = element.debuffList.num

    element.isInCombat = UnitAffectingCombat('player')

    if C.DB.Unitframe.DebuffWatcherDispellType ~= 3 or C.DB.Unitframe.InstanceDebuff then
        uf.AurasIndicator_UpdatePriority(self, numDebuffs, unit)
        uf.AurasIndicator_HideButtons(self)

        for i = 1, numDebuffs do
            local button = auras.buttons[i]
            if not button then
                break
            end

            local aura = element.debuffList[i]
            if aura.priority > invalidPrio then
                auraIndex = auraIndex + 1
                uf:AurasIndicator_UpdateButton(button, aura)
            end
            if aura.visibleNum == 1 then
                auras:SetSize(auras.ButtonSize, auras.ButtonSize)
                auras:ClearAllPoints()
                auras:SetPoint('CENTER')
            elseif aura.visibleNum == 2 then
                auras:SetSize(auras.ButtonSize * 2 + 5, auras.ButtonSize)
                auras:ClearAllPoints()
                auras:SetPoint('CENTER')
            else
                auras:SetSize(1, 1)
                auras:ClearAllPoints()
                auras:SetPoint('CENTER')
            end
            print(aura.visibleNum)
        end
    end

    uf.SpellsIndicator_HideButtons(self)

    for i = auraIndex + 1, numDebuffs do
        local aura = element.debuffList[i]
        local value = enableSpells and uf.CornerSpellsList[aura.spellID]
        if value and (value[3] or aura.isPlayerAura) then
            local button = spells[value[1]]
            if button then
                uf:SpellsIndicator_UpdateButton(button, aura, value[2][1], value[2][2], value[2][3])
            end
        elseif debuffs and debuffs.enable and debuffIndex < 4 and uf.DebuffsIndicator_Filter(element, aura) then
            debuffIndex = debuffIndex + 1
            uf.DebuffsIndicator_UpdateButton(self, debuffIndex, aura)
        end
    end

    uf.DebuffsIndicator_HideButtons(self, debuffIndex + 1, 3)

    for i = 1, numBuffs do
        local aura = element.buffList[i]
        local value = enableSpells and uf.CornerSpellsList[aura.spellID]
        if value and (value[3] or aura.isPlayerAura) then
            local button = spells[value[1]]
            if button then
                uf:SpellsIndicator_UpdateButton(button, aura, value[2][1], value[2][2], value[2][3])
            end
        elseif buffs and buffs.enable and buffIndex < 4 and uf.BuffsIndicator_Filter(element, aura) then
            buffIndex = buffIndex + 1
            uf.BuffsIndicator_UpdateButton(self, buffIndex, aura)
        end
    end

    uf.BuffsIndicator_HideButtons(self, buffIndex + 1, 3)
end

function uf:RaidAuras_UpdateOptions()
    for _, frame in pairs(oUF.objects) do
        if frame.unitStyle == 'party' or frame.unitStyle == 'raid' then
            uf.AurasIndicator_UpdateOptions(frame)
            uf.SpellsIndicator_UpdateOptions(frame)
            uf.DebuffsIndicator_UpdateOptions(frame)
            uf.BuffsIndicator_UpdateOptions(frame)
        end
    end
end
