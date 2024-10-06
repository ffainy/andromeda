local F, C = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

local scripts = {
    'OnShow',
    'OnHide',
    'OnEvent',
    'OnEnter',
    'OnLeave',
    'OnUpdate',
    'OnValueChanged',
    'OnClick',
    'OnMouseDown',
    'OnMouseUp',
}

local framesToHide = {
    MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight,
    MultiBar5, MultiBar6, MultiBar7,
    OverrideActionBar, PossessActionBar, PetActionBar,
    BagsBar, MicroMenu,
}

local framesToDisable = {
    MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight,
    MultiBar5, MultiBar6, MultiBar7,
    PossessActionBar, PetActionBar,
    MicroButtonAndBagsBar, StatusTrackingBarManager, MainMenuBarVehicleLeaveButton,
    OverrideActionBar,
    OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar,
    OverrideActionBarPitchFrame,
    BagsBar, MicroMenu,
}

local function disableAllScripts(frame)
    for _, script in next, scripts do
        if frame:HasScript(script) then
            frame:SetScript(script, nil)
        end
    end
end

local function buttonEventsRegisterFrame(self, added)
    local frames = self.frames
    for index = #frames, 1, -1 do
        local frame = frames[index]
        local wasAdded = frame == added
        if not added or wasAdded then
            if not strmatch(frame:GetName(), 'ExtraActionButton%d') then
                self.frames[index] = nil
            end

            if wasAdded then
                break
            end
        end
    end
end

local function disableDefaultBarEvents() -- credit: Simpy
    -- shut down some events for things we dont use
    ActionBarController:UnregisterAllEvents()
    ActionBarController:RegisterEvent('SETTINGS_LOADED')        -- this is needed for page controller to spawn properly
    ActionBarController:RegisterEvent('UPDATE_EXTRA_ACTIONBAR') -- this is needed to let the ExtraActionBar show
    ActionBarActionEventsFrame:UnregisterAllEvents()

    -- used for ExtraActionButton and TotemBar (on wrath)
    ActionBarButtonEventsFrame:UnregisterAllEvents()
    ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_SLOT_CHANGED')    -- needed to let the ExtraActionButton show and Totems to swap
    ActionBarButtonEventsFrame:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN') -- needed for cooldowns of them both
    hooksecurefunc(ActionBarButtonEventsFrame, 'RegisterFrame', buttonEventsRegisterFrame)
    buttonEventsRegisterFrame(ActionBarButtonEventsFrame)
end

function ACTIONBAR:RemoveBlizzStuff()
    for _, frame in next, framesToHide do
        frame:SetParent(F.HiddenFrame)
    end

    for _, frame in next, framesToDisable do
        frame:UnregisterAllEvents()
        disableAllScripts(frame)
    end

    disableDefaultBarEvents()

    -- Fix maw block anchor
    MainMenuBarVehicleLeaveButton:RegisterEvent('PLAYER_ENTERING_WORLD')

    -- Update token panel, some alts may hide token as default
    SetCVar('showTokenFrame', 1)

    -- Hide blizzard expbar
    StatusTrackingBarManager:UnregisterAllEvents()
    StatusTrackingBarManager:Hide()
end
