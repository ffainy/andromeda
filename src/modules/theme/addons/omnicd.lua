local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function updateBorderVisibility(self)
    local parent = self:GetParent()
    if not parent or not parent.__styled then
        return
    end

    parent.__styled:SetShown(self:IsShown())
end

local function handleBar()
    local ocd = _G['OmniCD'][1]
    hooksecurefunc(ocd.Party, 'AcquireStatusBar', function(P, icon)
        if icon.statusBar then
            if not icon.statusBar.__styled then
                icon.statusBar.__styled = CreateFrame('Frame', nil, icon.statusBar)
                icon.statusBar.__styled:SetFrameLevel(icon.statusBar:GetFrameLevel() - 1)

                if icon.statusBar.borderTop then
                    hooksecurefunc(icon.statusBar.borderTop, 'SetShown', updateBorderVisibility)
                    hooksecurefunc(icon.statusBar.borderTop, 'Hide', updateBorderVisibility)
                    hooksecurefunc(icon.statusBar.borderTop, 'Show', updateBorderVisibility)
                end
            end

            local x = icon:GetSize()
            icon.statusBar.__styled:ClearAllPoints()
            icon.statusBar.__styled:SetPoint('TOPLEFT', icon.statusBar, 'TOPLEFT', -x - 1, 0)
            icon.statusBar.__styled:SetPoint('BOTTOMRIGHT', icon.statusBar, 'BOTTOMRIGHT', 0, 0)
            F.CreateSD(icon.statusBar.__styled)
        end
    end)
end

local function handleIcon()
    local ocd = _G['OmniCD'][1]
    hooksecurefunc(ocd.Party, 'AcquireIcon', function(_, barFrame, iconIndex, unitBar)
        local icon = barFrame.icons[iconIndex]
        if icon and not icon.__styled then
            F.CreateSD(icon)
            icon.__styled = true
        end
    end)
end

local function reskinOmniCD()
    if not ANDROMEDA_ADB.ReskinOmniCD then
        return
    end

    handleBar()
    handleIcon()
end

THEME:RegisterSkin('OmniCD', reskinOmniCD)
