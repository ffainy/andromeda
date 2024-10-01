local F = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

function THEME:ReskinPGF()
    if not _G.ANDROMEDA_ADB.ReskinPremadeGroupsFilter then
        return
    end

    if not C_AddOns.IsAddOnLoaded('PremadeGroupsFilter') then
        return
    end

    local DungeonPanel = _G['PremadeGroupsFilterDungeonPanel']
    if not DungeonPanel then
        return
    end

    local ArenaPanel = _G['PremadeGroupsFilterArenaPanel']
    local RBGPanel = _G['PremadeGroupsFilterRBGPanel']
    local RaidPanel = _G['PremadeGroupsFilterRaidPanel']
    local MiniPanel = _G['PremadeGroupsFilterMiniPanel']
    local RolePanel = _G['PremadeGroupsFilterRolePanel']
    local PGFDialog = _G['PremadeGroupsFilterDialog']

    local names = {
        'Difficulty',
        'MPRating',
        'Members',
        'Tanks',
        'Heals',
        'DPS',
        'Partyfit',
        'BLFit',
        'BRFit',
        'Defeated',
        'MatchingId',
        'PvPRating',
        'NotDeclined',
    }

    local function handleDropdown(drop)
        F.StripTextures(drop)

        local bg = F.CreateBDFrame(drop, 0, true)
        bg:SetPoint('TOPLEFT', 16, -4)
        bg:SetPoint('BOTTOMRIGHT', -18, 8)
        F.CreateSD(bg)

        local down = drop.Button
        down:ClearAllPoints()
        down:SetPoint('RIGHT', bg, -2, 0)
        F.ReskinArrow(down, 'down')
    end

    local function handleGroup(panel)
        for _, name in pairs(names) do
            local frame = panel.Group[name]
            if frame then
                local check = frame.Act
                if check then
                    check:SetSize(18, 18)
                    check:SetPoint('TOPLEFT', 4, -2)
                    F.ReskinCheckbox(check, true)
                end
                local input = frame.Min
                if input then
                    F.ReskinEditbox(input)
                    F.ReskinEditbox(frame.Max)
                end
                if frame.DropDown then
                    handleDropdown(frame.DropDown)
                end
            end
        end

        F.ReskinEditbox(panel.Advanced.Expression)
    end

    local styled
    hooksecurefunc(PGFDialog, 'Show', function(self)
        if styled then
            return
        end
        styled = true

        F.StripTextures(self)
        F.SetBD(self):SetAllPoints()
        F.ReskinClose(self.CloseButton)
        F.ReskinButton(self.ResetButton)
        F.ReskinButton(self.RefreshButton)

        F.ReskinEditbox(MiniPanel.Advanced.Expression)
        F.ReskinEditbox(MiniPanel.Sorting.Expression)

        local button = self.MaxMinButtonFrame
        if button.MinimizeButton then
            F.ReskinArrow(button.MinimizeButton, 'down')
            button.MinimizeButton:ClearAllPoints()
            button.MinimizeButton:SetPoint('RIGHT', self.CloseButton, 'LEFT', -3, 0)
            F.ReskinArrow(button.MaximizeButton, 'up')
            button.MaximizeButton:ClearAllPoints()
            button.MaximizeButton:SetPoint('RIGHT', self.CloseButton, 'LEFT', -3, 0)
        end

        handleGroup(RaidPanel)
        handleGroup(DungeonPanel)
        handleGroup(ArenaPanel)
        handleGroup(RBGPanel)
        handleGroup(RolePanel)

        for i = 1, 8 do
            local dungeon = DungeonPanel.Dungeons['Dungeon' .. i]
            local check = dungeon and dungeon.Act
            if check then
                check:SetSize(18, 18)
                check:SetPoint('TOPLEFT', 4, -2)
                F.ReskinCheckbox(check, true)
            end
        end
    end)

    hooksecurefunc(PGFDialog, 'ResetPosition', function(self)
        self:ClearAllPoints()
        self:SetPoint('TOPLEFT', PVEFrame, 'TOPRIGHT', 2, 0)
    end)

    local button = _G['UsePGFButton']
    if button then
        F.ReskinCheckbox(button)
        button.text:SetWidth(35)
    end

    local popup = _G['PremadeGroupsFilterStaticPopup']
    if popup then
        F.StripTextures(popup)
        F.SetBD(popup)
        F.ReskinEditbox(popup.EditBox)
        F.ReskinButton(popup.Button1)
        F.ReskinButton(popup.Button2)
    end
end
