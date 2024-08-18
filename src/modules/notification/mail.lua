local F, C = unpack(select(2, ...))
local NOTIFICATION = F:GetModule('Notification')

local hasMail = false
local function checkMail()
    local newMail = HasNewMail()
    if hasMail ~= newMail then
        hasMail = newMail
        if hasMail then
            F:CreateNotification(MAIL_LABEL, HAVE_MAIL, nil, 'Interface\\ICONS\\INV_Letter_20')
        end
    end
end

function NOTIFICATION:NewMail()
    if not C.DB.Notification.NewMail then
        return
    end

    F:RegisterEvent('UPDATE_PENDING_MAIL', checkMail)
end
