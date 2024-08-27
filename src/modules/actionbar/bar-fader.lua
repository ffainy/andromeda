-- Credit: elvui, ndui_plus

local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local lab = F.Libs.LibActionButton
local handledbuttons = {}

local barsList = {
    ['FadeBar1'] = C.ADDON_TITLE .. 'ActionBar1',
    ['FadeBar2'] = C.ADDON_TITLE .. 'ActionBar2',
    ['FadeBar3'] = C.ADDON_TITLE .. 'ActionBar3',
    ['FadeBar4'] = C.ADDON_TITLE .. 'ActionBar4',
    ['FadeBar5'] = C.ADDON_TITLE .. 'ActionBar5',
    ['FadeBar6'] = C.ADDON_TITLE .. 'ActionBar6',
    ['FadeBar7'] = C.ADDON_TITLE .. 'ActionBar7',
    ['FadeBar8'] = C.ADDON_TITLE .. 'ActionBar8',
    ['FadeBarPet'] = C.ADDON_TITLE .. 'ActionBarPet',
    ['FadeBarStance'] = C.ADDON_TITLE .. 'ActionBarStance',
}

local options = {
    Instance = {
        enable = function(self)
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
        end,
        events = { 'PLAYER_ENTERING_WORLD', 'ZONE_CHANGED_NEW_AREA' },
    },
    Vehicle = {
        enable = function(self)
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
            self:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR')
            self:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')
            self:RegisterEvent('ACTIONBAR_PAGE_CHANGED')
        end,
        events = {
            'PLAYER_ENTERING_WORLD',
            'UPDATE_BONUS_ACTIONBAR',
            'UPDATE_VEHICLE_ACTIONBAR',
            'UPDATE_OVERRIDE_ACTIONBAR',
            'ACTIONBAR_PAGE_CHANGED',
        },
    },
    Combat = {
        enable = function(self)
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterUnitEvent('UNIT_FLAGS', 'player')
        end,
        events = { 'PLAYER_REGEN_ENABLED', 'PLAYER_REGEN_DISABLED', 'UNIT_FLAGS' },
    },
    Target = {
        enable = function(self)
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end,
        events = { 'PLAYER_TARGET_CHANGED' },
    },
    Casting = {
        enable = function(self)
            self:RegisterUnitEvent('UNIT_SPELLCAST_START', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', 'player')
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', 'player')
        end,
        events = {
            'UNIT_SPELLCAST_START',
            'UNIT_SPELLCAST_STOP',
            'UNIT_SPELLCAST_CHANNEL_START',
            'UNIT_SPELLCAST_CHANNEL_STOP',
        },
    },
    Health = {
        enable = function(self)
            self:RegisterUnitEvent('UNIT_HEALTH', 'player')
        end,
        events = { 'UNIT_HEALTH' },
    },
}

local function fadeBlingTexture(cooldown, alpha)
    if not cooldown then
        return
    end

    cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or C.Assets.Textures.Blank)
end

local function fadeBlings(alpha)
    for _, button in pairs(ACTIONBAR.buttons) do
        fadeBlingTexture(button.cooldown, alpha)
    end
end

local function clearTimers(object)
    if object.delayTimer then
        F:CancelTimer(object.delayTimer)
        object.delayTimer = nil
    end
end

local function delayFadeOut(frame, timeToFade, startAlpha, endAlpha)
    clearTimers(frame)

    if C.DB.Actionbar.Delay > 0 then
        frame.delayTimer = F:ScheduleTimer(F.UIFrameFadeOut, C.DB.Actionbar.Delay, F, frame, timeToFade, startAlpha,
            endAlpha)
    else
        F:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    end
end

function ACTIONBAR:ButtonOnEnter()
    local parent = ACTIONBAR.fadeParent

    if not parent.mouseLock then
        clearTimers(parent)
        F:UIFrameFadeIn(parent, C.DB.Actionbar.FadeInDuration, parent:GetAlpha(), C.DB.Actionbar.FadeInAlpha)
        fadeBlings(C.DB.Actionbar.FadeInAlpha)
    end
end

function ACTIONBAR:ButtonOnLeave()
    local parent = ACTIONBAR.fadeParent

    if not parent.mouseLock then
        delayFadeOut(parent, C.DB.Actionbar.FadeOutDuration, parent:GetAlpha(), C.DB.Actionbar.FadeOutAlpha)
        fadeBlings(C.DB.Actionbar.FadeOutAlpha)
    end
end

local function flyoutButtonAnchor(frame)
    local parent = frame:GetParent()
    local _, parentAnchorButton = parent:GetPoint()
    if not handledbuttons[parentAnchorButton] then
        return
    end

    return parentAnchorButton
end

function ACTIONBAR:FlyoutButtonOnEnter()
    local anchor = flyoutButtonAnchor(self)
    if anchor then
        ACTIONBAR.ButtonOnEnter(anchor)
    end
end

function ACTIONBAR:FlyoutButtonOnLeave()
    local anchor = flyoutButtonAnchor(self)
    if anchor then
        ACTIONBAR.ButtonOnLeave(anchor)
    end
end

function ACTIONBAR:FadeParentOnEvent(event)
    if
        (event == 'ACTIONBAR_SHOWGRID')
        or (C.DB.Actionbar.Instance and IsInInstance())
        or (C.DB.Actionbar.Vehicle and ((HasVehicleActionBar() and UnitVehicleSkin('player') and UnitVehicleSkin('player') ~= '') or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= '')))
        or (C.DB.Actionbar.Combat and UnitAffectingCombat('player'))
        or (C.DB.Actionbar.Target and (UnitExists('target') or UnitExists('focus')))
        or (C.DB.Actionbar.Casting and (UnitCastingInfo('player') or UnitChannelInfo('player')))
        or (C.DB.Actionbar.Health and (UnitHealth('player') ~= UnitHealthMax('player')))
    then
        self.mouseLock = true

        clearTimers(ACTIONBAR.fadeParent)
        F:UIFrameFadeIn(self, C.DB.Actionbar.FadeInDuration, self:GetAlpha(), C.DB.Actionbar.FadeInAlpha)
        fadeBlings(C.DB.Actionbar.FadeInAlpha)
    else
        self.mouseLock = false

        delayFadeOut(self, C.DB.Actionbar.FadeOutDuration, self:GetAlpha(), C.DB.Actionbar.FadeOutAlpha)
        fadeBlings(C.DB.Actionbar.FadeOutAlpha)
    end
end

function ACTIONBAR:UpdateFaderSettings()
    for key, option in pairs(options) do
        if C.DB.Actionbar[key] then
            if option.enable then
                option.enable(ACTIONBAR.fadeParent)
            end
        else
            if option.events and next(option.events) then
                for _, event in ipairs(option.events) do
                    ACTIONBAR.fadeParent:UnregisterEvent(event)
                end
            end
        end
    end
end

local function updateAfterCombat(event)
    ACTIONBAR:UpdateFaderState()
    F:UnregisterEvent(event, updateAfterCombat)
end

function ACTIONBAR:UpdateFaderState()
    if InCombatLockdown() then
        F:RegisterEvent('PLAYER_REGEN_ENABLED', updateAfterCombat)
        return
    end

    for key, name in pairs(barsList) do
        local bar = _G[name]
        if bar then
            bar:SetParent(C.DB.Actionbar[key] and ACTIONBAR.fadeParent or UIParent)
        end
    end

    if not ACTIONBAR.isHooked then
        for _, button in ipairs(ACTIONBAR.buttons) do
            button:HookScript('OnEnter', ACTIONBAR.ButtonOnEnter)
            button:HookScript('OnLeave', ACTIONBAR.ButtonOnLeave)

            handledbuttons[button] = true
        end

        ACTIONBAR.isHooked = true
    end
end

function ACTIONBAR:SetupFlyoutButton(button)
    button:HookScript('OnEnter', ACTIONBAR.FlyoutButtonOnEnter)
    button:HookScript('OnLeave', ACTIONBAR.FlyoutButtonOnLeave)
end

function ACTIONBAR:LAB_FlyoutCreated(button)
    ACTIONBAR:SetupFlyoutButton(button)
end

function ACTIONBAR:SetupLABFlyout()
    for _, button in next, lab.FlyoutButtons do
        ACTIONBAR:SetupFlyoutButton(button)
    end

    lab:RegisterCallback('OnFlyoutButtonCreated', ACTIONBAR.LAB_FlyoutCreated)
end

function ACTIONBAR:BarFader()
    if not C.DB.Actionbar.Fader then
        return
    end

    ACTIONBAR.fadeParent = CreateFrame(
        'Frame', C.ADDON_TITLE .. 'ActionbarFadeParent', UIParent,
        'SecureHandlerStateTemplate'
    )
    ACTIONBAR.fadeParent:SetAlpha(C.DB.Actionbar.FadeOutAlpha)
    ACTIONBAR.fadeParent:RegisterEvent('ACTIONBAR_SHOWGRID')
    ACTIONBAR.fadeParent:RegisterEvent('ACTIONBAR_HIDEGRID')
    ACTIONBAR.fadeParent:SetScript('OnEvent', ACTIONBAR.FadeParentOnEvent)

    RegisterStateDriver(ACTIONBAR.fadeParent, 'visibility', '[petbattle] hide; show')

    ACTIONBAR:UpdateFaderSettings()
    ACTIONBAR:UpdateFaderState()
    ACTIONBAR:SetupLABFlyout()
end
