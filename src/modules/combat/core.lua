local F, C = unpack(select(2, ...))
local COMBAT = F:GetModule('Combat')





function COMBAT:OnLogin()
    if not C.DB.Combat.Enable then
        return
    end

    COMBAT:SmartTab()
    COMBAT:EasyFocus()
    COMBAT:EasyMark()
    COMBAT:BuffReminder()
    COMBAT:CooldownPulse()
end
