local F, C, L = unpack(select(2, ...))
local NOTIFICATION = F:GetModule('Notification')

local alertBagsFull
local shouldAlert = false
local last = 0

local function onUpdate(self, elapsed)
    last = last + elapsed
    if last > 1 then
        self:SetScript('OnUpdate', nil)
        last = 0
        shouldAlert = true
        alertBagsFull(self)
    end
end

alertBagsFull = function(self)
    local totalFree = 0
    for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i)
        if bagFamily == 0 then
            totalFree = totalFree + freeSlots
        end
    end

    if totalFree == 0 then
        if shouldAlert then
            F:CreateNotification(INVTYPE_BAG, TUTORIAL_TITLE58, nil, 'Interface\\ICONS\\INV_Misc_Bag_08')
            shouldAlert = false
        else
            self:SetScript('OnUpdate', onUpdate)
        end
    else
        shouldAlert = false
    end
end

function NOTIFICATION:BagsFull()
    if not C.DB.Notification.BagsFull then return end

    local f = CreateFrame('Frame')
    f:RegisterEvent('BAG_UPDATE')
    f:RegisterEvent('PLAYER_ENTERING_WORLD')
    f:SetScript('OnEvent', function(self, event)
        if event == 'BAG_UPDATE' then
            alertBagsFull(self)
        end
    end)
end
