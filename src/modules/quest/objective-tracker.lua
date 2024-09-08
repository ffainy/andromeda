local F, C, L = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')


local trackers = {
    _G['ScenarioObjectiveTracker'],
    _G['BonusObjectiveTracker'],
    _G['UIWidgetObjectiveTracker'],
    _G['CampaignQuestObjectiveTracker'],
    _G['QuestObjectiveTracker'],
    _G['AdventureObjectiveTracker'],
    _G['AchievementObjectiveTracker'],
    _G['MonthlyActivitiesObjectiveTracker'],
    _G['ProfessionsRecipeTracker'],
    _G['WorldQuestObjectiveTracker'],
}

-- Auto collapse Objective Tracker

local function toggleTracker()
    local inInstance, instanceType = IsInInstance()

    if inInstance then
        if instanceType == 'party' or instanceType == 'scenario' then
            F:Delay(1, function()
                for i = 3, #trackers do
                    trackers[i]:SetCollapsed(true)
                end
            end)
        else
            F:Delay(1, function()
                ObjectiveTrackerFrame:SetCollapsed(true)
            end)
        end
    else
        if not InCombatLockdown() then
            for i = 3, #trackers do
                if trackers[i].isCollapsed then
                    trackers[i]:SetCollapsed(false)
                end
            end
            if ObjectiveTrackerFrame.isCollapsed then
                ObjectiveTrackerFrame:SetCollapsed(false)
            end
        end
    end
end

function QUEST:TrackerAutoCollapse()
    if C.DB.Quest.AutoCollapseTracker then
        F:RegisterEvent('PLAYER_ENTERING_WORLD', toggleTracker)
    end
end

-- Make tracker movable

function QUEST:TrackerMover()
    local anchor = CreateFrame('Frame', 'ObjectiveTrackerMover', UIParent)
    anchor:SetSize(240, 50)

    F.Mover(anchor, L['ObjectiveTracker'], 'ObjectiveTracker', { 'TOPRIGHT', UIParent, 'TOPRIGHT', -C.UI_GAP, -60 })

    local ot = ObjectiveTrackerFrame
    ot:ClearAllPoints()
    ot:SetPoint('TOPRIGHT', anchor)
    ot:SetScale(1)
    ot:SetClampedToScreen(false)
    ot:SetMovable(true)

    if ot:IsMovable() then
        ot:SetUserPlaced(true)
    end

    F:DisableEditMode(ot)

    hooksecurefunc(ot, 'SetPoint', function(_, _, parent)
        if parent ~= anchor then
            ot:ClearAllPoints()
            ot:SetPoint('TOPRIGHT', anchor)
        end
    end)

    local height = C.SCREEN_HEIGHT / 1.5 * C.MULT
    ot:SetHeight(height)
    hooksecurefunc(ot, 'SetHeight', function(_, h)
        if h ~= height then
            ot:SetHeight(height)
        end
    end)
end
