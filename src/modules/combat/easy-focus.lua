local F, C = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')
local oUF = F.Libs.oUF

local modifier
local mouseButton = '1' -- 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons if there are any
local pending = {}

function COMBAT:Focuser_Setup()
    if not C.DB.Combat.EasyFocusOnUnitframe then
        return
    end

    if not self or self.focuser then
        return
    end

    local name = self.GetName and self:GetName()
    if name and strmatch(name, 'oUF_NPs') then
        return
    end

    if not InCombatLockdown() then
        local index = C.DB.Combat.EasyFocusKey
        if index == 1 then
            modifier = 'control'
        elseif index == 2 then
            modifier = 'alt'
        elseif index == 3 then
            modifier = 'shift'
        elseif index == 4 then
            return
        end
        self:SetAttribute(modifier .. '-type' .. mouseButton, 'focus')
        self.focuser = true
        pending[self] = nil
    else
        pending[self] = true
    end
end

function COMBAT:Focuser_CreateFrameHook(name, _, template)
    if name and template == 'SecureUnitButtonTemplate' then
        COMBAT.Focuser_Setup(_G[name])
    end
end

function COMBAT.Focuser_OnEvent(event)
    if event == 'PLAYER_REGEN_ENABLED' then
        if next(pending) then
            for frame in next, pending do
                COMBAT.Focuser_Setup(frame)
            end
        end
    else
        for _, object in next, oUF.objects do
            if not object.focuser then
                COMBAT.Focuser_Setup(object)
            end
        end
    end
end

function COMBAT:EasyFocus()
    if not C.DB.Combat.EasyFocus then
        return
    end

    local index = C.DB.Combat.EasyFocusKey
    if index == 1 then
        modifier = 'control'
    elseif index == 2 then
        modifier = 'alt'
    elseif index == 3 then
        modifier = 'shift'
    elseif index == 4 then
        return
    end

    -- Keybinding override so that models can be shift/alt/ctrl+clicked
    local f = CreateFrame('CheckButton', 'FocuserButton', UIParent, 'SecureActionButtonTemplate')
    f:SetAttribute('type1', 'macro')
    f:SetAttribute('macrotext', '/focus mouseover')
    SetOverrideBindingClick(_G.FocuserButton, true, modifier .. '-BUTTON' .. mouseButton, 'FocuserButton')
    f:RegisterForClicks('LeftButtonDown')

    hooksecurefunc('CreateFrame', COMBAT.Focuser_CreateFrameHook)
    COMBAT:Focuser_OnEvent()
    F:RegisterEvent('PLAYER_REGEN_ENABLED', COMBAT.Focuser_OnEvent)
    F:RegisterEvent('GROUP_ROSTER_UPDATE', COMBAT.Focuser_OnEvent)
end
