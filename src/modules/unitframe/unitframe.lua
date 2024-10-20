local F, C = unpack(select(2, ...))
local UNITFRAME = F:GetModule('UnitFrame')
local oUF = F.Libs.oUF
local colors = oUF.colors

UNITFRAME.Positions = {
    player = { 'CENTER', UIParent, 'CENTER', 0, -180 },
    pet = { 'RIGHT', 'oUF_Player', 'LEFT', -6, 0 },
    target = { 'LEFT', 'oUF_Player', 'RIGHT', 40, 40 },
    tot = { 'LEFT', 'oUF_Target', 'RIGHT', 6, 0 },
    focus = { 'RIGHT', 'oUF_Player', 'LEFT', -100, -40 },
    tof = { 'TOPLEFT', 'oUF_Focus', 'TOPRIGHT', 6, 0 },
    boss = { 'CENTER', UIParent, 'CENTER', 500, 0 },
    arena = { 'CENTER', UIParent, 'CENTER', 500, 0 },
    party = { 'CENTER', UIParent, 'CENTER', -330, 0 },
    raid = { 'TOPRIGHT', 'Minimap', 'TOPLEFT', -6, -42 },
    simple = { 'TOPLEFT', C.UI_GAP, -100 },
}

-- Utility

function UNITFRAME:GetHeightVal(bar, val1, val2, val3, val4, val5, val6, val7, val8, val9, val10)
    local style = bar.unitStyle
    if style == 'player' then
        return val1
    elseif style == 'pet' then
        return val2
    elseif style == 'target' then
        return val3
    elseif style == 'targettarget' then
        return val4
    elseif style == 'focus' then
        return val5
    elseif style == 'focustarget' then
        return val6
    elseif style == 'party' then
        return val7
    elseif style == 'raid' then
        return val8
    elseif style == 'boss' then
        return val9
    elseif style == 'arena' then
        return val10
    end
end

function UNITFRAME:UpdateHealthDefaultColor()
    local color = C.DB.Unitframe.HealthColor
    colors.health = { color.r, color.g, color.b }
end

function UNITFRAME:UpdateClassColor()
    local classColors = C.ClassColors
    for class, value in pairs(classColors) do
        colors.class[class] = { value.r, value.g, value.b }
    end
end

local function replacePowerColor(name, index, color)
    colors.power[name] = color
    colors.power[index] = colors.power[name]
end

-- Colors

do
    replacePowerColor('MANA', 0, { 0.06, 0.56, 0.89 })
    replacePowerColor('RAGE', 1, { 0.94, 0.19, 0.18 })
    replacePowerColor('FOCUS', 2, { 0.84, 0.51, 0.37 })
    replacePowerColor('ENERGY', 3, { 0.94, 0.19, 0.18 })
    replacePowerColor('COMBO_POINTS', 4, { 1, 0.77, 0.08 })
    replacePowerColor('RUNES', 5, { 0.22, 0.95, 0.97 })
    replacePowerColor('RUNIC_POWER', 6, { 0.22, 0.95, 0.97 })
    replacePowerColor('SOUL_SHARDS', 7, { 0.65, 0.45, 1 })
    replacePowerColor('LUNAR_POWER', 8, { 0.65, 0.45, 1 })
    replacePowerColor('HOLY_POWER', 9, { 1, 0.77, 0.08 })
    replacePowerColor('MAELSTROM', 11, { 0.94, 0.19, 0.18 })
    replacePowerColor('CHI', 12, { 0.18, 0.85, 0.59 })
    replacePowerColor('INSANITY', 13, { 0.65, 0.45, 1 })
    replacePowerColor('ARCANE_CHARGES', 16, { 0.22, 0.95, 0.97 })
    replacePowerColor('FURY', 17, { 0.94, 0.19, 0.18 })
    replacePowerColor('PAIN', 18, { 0.94, 0.19, 0.18 })

    colors.power.max = {
        COMBO_POINTS = { 161 / 255, 92 / 255, 255 / 255 },
        SOUL_SHARDS = { 255 / 255, 26 / 255, 48 / 255 },
        LUNAR_POWER = { 161 / 255, 92 / 255, 255 / 255 },
        HOLY_POWER = { 255 / 255, 26 / 255, 48 / 255 },
        CHI = { 0 / 255, 143 / 255, 247 / 255 },
        ARCANE_CHARGES = { 5 / 255, 96 / 255, 250 / 255 },
    }

    colors.runes = {
        [1] = { 0.91, 0.23, 0.21 }, -- Blood
        [2] = { 0.23, 0.67, 0.97 }, -- Frost
        [3] = { 0.41, 0.97, 0.21 }, -- Unholy
    }

    colors.debuff = {
        Curse = { 0.6, 0.2, 1.0 },
        Disease = { 0.6, 0.4, 0.0 },
        Magic = { 0.2, 0.5, 1.0 },
        Poison = { 0.2, 0.8, 0.2 },
        none = { 1.0, 0.1, 0.2 }, -- Physical, etc.
    }

    colors.reaction = {
        [1] = { 223 / 255, 54 / 255, 15 / 255 }, -- Hated / Enemy
        [2] = { 223 / 255, 54 / 255, 15 / 255 },
        [3] = { 223 / 255, 54 / 255, 15 / 255 },
        [4] = { 232 / 255, 190 / 255, 54 / 255 },
        [5] = { 74 / 255, 209 / 255, 68 / 255 },
        [6] = { 74 / 255, 209 / 255, 68 / 255 },
        [7] = { 74 / 255, 209 / 255, 68 / 255 },
        [8] = { 74 / 255, 209 / 255, 68 / 255 },
        [9] = { 69 / 255, 209 / 255, 155 / 255 }, -- Paragon (Reputation)
    }

    colors.smooth = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
    colors.disconnected = { 0.5, 0.5, 0.5 }
end

-- Backdrop

local function onEnter(self)
    UnitFrame_OnEnter(self)
    self.__highlight:Show()
end

local function onLeave(self)
    UnitFrame_OnLeave(self)
    self.__highlight:Hide()
end

function UNITFRAME:CreateBackdrop(self, onKeyDown)
    local hl = self:CreateTexture(nil, 'OVERLAY')
    hl:SetAllPoints()
    hl:SetTexture('Interface\\PETBATTLES\\PetBattle-SelectedPetGlow')
    hl:SetTexCoord(0, 1, 0.5, 1)
    hl:SetVertexColor(0.6, 0.6, 0.6)
    hl:SetBlendMode('ADD')
    hl:Hide()

    self.__highlight = hl

    self:RegisterForClicks(onKeyDown and 'AnyDown' or 'AnyUp')
    self:HookScript('OnEnter', onEnter)
    self:HookScript('OnLeave', onLeave)

    local bg = F.SetBD(self, 0.45)
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    bg:SetFrameStrata('BACKGROUND')

    self.__bg = bg
    self.__sd = bg.__shadow
end

-- 当前选中目标白色边框
-- 只对小队/团队框体生效

local function updateTargetBorder(self)
    if not self.__sd then
        return
    end

    if UnitIsUnit('target', self.unit) then
        self.__tarBorder:Show()
        self.__sd:SetBackdropBorderColor(1, 1, 1, 0.35)
    else
        self.__tarBorder:Hide()
        self.__sd:SetBackdropBorderColor(0, 0, 0, 0.35)
    end
end

function UNITFRAME:CreateTargetBorder(self)
    local sd = F.CreateBDFrame(self, 0)
    sd:SetBackdropBorderColor(1, 1, 1)
    -- sd:SetFrameLevel(self:GetFrameLevel() + 5)
    sd:Hide()

    self.__tarBorder = sd

    self:RegisterEvent('PLAYER_TARGET_CHANGED', updateTargetBorder, true)
    self:RegisterEvent('GROUP_ROSTER_UPDATE', updateTargetBorder, true)
end

-- 目标/焦点发生变化时音效提示

do
    local SELECT_AGGRO = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
    local SELECT_NPC = SOUNDKIT.IG_CHARACTER_NPC_SELECT
    local SELECT_NEUTRAL = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
    local SELECT_LOST = SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT
    local playID

    function UNITFRAME:SOUNDKIT_FINISHED(_, soundID)
        if playID == soundID then
            playID = nil
        end
    end

    local function targetSound(event, unit, _)
        if playID then
            return -- dont play more
        elseif not UnitExists(unit) then
            PlaySound(SELECT_LOST, nil, nil, true)
        elseif not C_PlayerInteractionManager.IsReplacingUnit() then
            if UnitIsEnemy(unit, 'player') then
                PlaySound(SELECT_AGGRO, nil, nil, true)
            elseif UnitIsFriend(unit, 'player') then
                PlaySound(SELECT_NPC, nil, nil, true)
            else
                PlaySound(SELECT_NEUTRAL, nil, nil, true)
            end
        end
    end

    function UNITFRAME:PLAYER_FOCUS_CHANGED()
        if C.DB.Unitframe.TargetSound then
            targetSound(nil, 'focus')
        end
    end

    function UNITFRAME:PLAYER_TARGET_CHANGED()
        if C.DB.Unitframe.TargetSound then
            targetSound(nil, 'target')
        end
    end

    function UNITFRAME:CreateTargetSound()
        if C.DB.Unitframe.TargetSound then
            F:RegisterEvent('PLAYER_TARGET_CHANGED', UNITFRAME.PLAYER_TARGET_CHANGED)
            F:RegisterEvent('PLAYER_FOCUS_CHANGED', UNITFRAME.PLAYER_FOCUS_CHANGED)
            F:RegisterEvent('SOUNDKIT_FINISHED', UNITFRAME.SOUNDKIT_FINISHED)
        else
            F:UnregisterEvent('PLAYER_TARGET_CHANGED', UNITFRAME.PLAYER_TARGET_CHANGED)
            F:UnregisterEvent('PLAYER_FOCUS_CHANGED', UNITFRAME.PLAYER_FOCUS_CHANGED)
            F:UnregisterEvent('SOUNDKIT_FINISHED', UNITFRAME.SOUNDKIT_FINISHED)
        end
    end
end

-- 按住右ctrl键暂时禁用目标框体上的光环过滤
do
    function UNITFRAME:MODIFIER_STATE_CHANGED(key, state)
        if key ~= 'RCTRL' then
            return
        end

        for _, object in next, oUF.objects do
            local unit = object.realUnit or object.unit
            if unit == 'target' then
                local auras = object.Auras
                if state == 1 then -- modifier key pressed
                    auras.FilterAura = nil
                else
                    auras.FilterAura = UNITFRAME.FilterAura
                end
                auras:ForceUpdate()
                break
            end
        end
    end

    function UNITFRAME:PLAYER_REGEN_DISABLED()
        F:UnregisterEvent('MODIFIER_STATE_CHANGED', UNITFRAME.MODIFIER_STATE_CHANGED)
    end

    function UNITFRAME:PLAYER_REGEN_ENABLED()
        F:RegisterEvent('MODIFIER_STATE_CHANGED', UNITFRAME.MODIFIER_STATE_CHANGED)
    end

    function UNITFRAME:UpdateAuraFilter()
        F:RegisterEvent('PLAYER_REGEN_DISABLED', UNITFRAME.MODIFIER_STATE_CHANGED)
        F:RegisterEvent('PLAYER_REGEN_ENABLED', UNITFRAME.MODIFIER_STATE_CHANGED)

        if InCombatLockdown() then
            UNITFRAME:PLAYER_REGEN_DISABLED()
        else
            UNITFRAME:PLAYER_REGEN_ENABLED()
        end
    end
end


-- Remove blizz raid frame

function UNITFRAME:RemoveBlizzRaidFrame()
    if CompactPartyFrame then
        CompactPartyFrame:UnregisterAllEvents()
    end

    CompactRaidFrameManager_SetSetting('IsShown', '0')
    UIParent:UnregisterEvent('GROUP_ROSTER_UPDATE')
    CompactRaidFrameManager:UnregisterAllEvents()
    CompactRaidFrameManager:SetParent(F.HiddenFrame)
end

-- Make sure the state of each element is reliable #TODO

function UNITFRAME:UpdateAllElements()
    UNITFRAME:UpdatePortrait()
    UNITFRAME:UpdateGCDTicker()
    UNITFRAME:UpdateAuras()
    UNITFRAME:UpdateFader()
    UNITFRAME:UpdateClassPower()
    UNITFRAME:UpdateRaidTargetIndicator()
end

function UNITFRAME:OnLogin()
    UNITFRAME:InitFilters()
    UNITFRAME:SpawnUnits()
    UNITFRAME:UpdateAllElements()
end
