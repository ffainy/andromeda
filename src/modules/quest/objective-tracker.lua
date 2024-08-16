local F, C, L = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')

local progressColors = {
    start = { r = 1.000, g = 0.647, b = 0.008 },
    complete = { r = 0.180, g = 0.835, b = 0.451 },
}

local function setTextColorHook(text)
    if not text.Hooked then
        local SetTextColorOld = text.SetTextColor
        text.SetTextColor = function(self, r, g, b, a)
            if r == OBJECTIVE_TRACKER_COLOR['Header'].r and g == OBJECTIVE_TRACKER_COLOR['Header'].g and b == OBJECTIVE_TRACKER_COLOR['Header'].b then
                r = 216 / 255
                g = 197 / 255
                b = 136 / 255
            elseif r == OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].r and g == OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].g and b == OBJECTIVE_TRACKER_COLOR['HeaderHighlight'].b then
                r = 216 / 255
                g = 181 / 255
                b = 136 / 255
            end
            SetTextColorOld(self, r, g, b, a)
        end
        text:SetTextColor(OBJECTIVE_TRACKER_COLOR['Header'].r, OBJECTIVE_TRACKER_COLOR['Header'].g,
            OBJECTIVE_TRACKER_COLOR['Header'].b, 1)
        text.Hooked = true
    end
end

local function getProgressColor(progress)
    local r = (progressColors.complete.r - progressColors.start.r) * progress + progressColors.start.r
    local g = (progressColors.complete.g - progressColors.start.g) * progress + progressColors.start.g
    local b = (progressColors.complete.r - progressColors.start.b) * progress + progressColors.start.b

    local addition = 0.35
    r = min(r + abs(0.5 - progress) * addition, r)
    g = min(g + abs(0.5 - progress) * addition, g)
    b = min(b + abs(0.5 - progress) * addition, b)

    return { r = r, g = g, b = b }
end

function QUEST:HandleHeaderText()
    local frame = ObjectiveTrackerFrame.MODULES
    if not frame then
        return
    end

    local outline = _G['ANDROMEDA_ADB']['FontOutline']
    for i = 1, #frame do
        local modules = frame[i]
        if modules and modules.Header and modules.Header.Text then
            F.SetFS(modules.Header.Text, C.Assets.Fonts.Header, 15, outline or nil, nil, 'CLASS',
                outline and 'NONE' or 'THICK')
        end
    end
end

function QUEST:HandleTitleText(text)
    local font = C.Assets.Fonts.Bold
    local outline = _G['ANDROMEDA_ADB']['FontOutline']
    F.SetFS(text, font, 14, outline or nil, nil, 'YELLOW', outline and 'NONE' or 'THICK')

    local height = text:GetStringHeight() + 2
    if height ~= text:GetHeight() then
        text:SetHeight(height)
    end

    setTextColorHook(text)
end

function QUEST:HandleInfoText(text)
    self:ColorfulProgression(text)

    local font = C.Assets.Fonts.Regular
    local outline = _G['ANDROMEDA_ADB']['FontOutline']
    F.SetFS(text, font, 13, outline or nil, nil, nil, outline and 'NONE' or 'THICK')
    text:SetHeight(text:GetStringHeight())

    local line = text:GetParent()
    local dash = line.Dash or line.Icon

    dash:Hide()
    text:ClearAllPoints()
    text:SetPoint('TOPLEFT', dash, 'TOPLEFT', 0, 0)
end

function QUEST:ScenarioObjectiveBlock_UpdateCriteria()
    if _G['ScenarioObjectiveBlock'] then
        local childs = { _G['ScenarioObjectiveBlock']:GetChildren() }
        for _, child in pairs(childs) do
            if child.Text then
                QUEST:HandleInfoText(child.Text)
            end
        end
    end
end

function QUEST:ColorfulProgression(text)
    if not text then
        return
    end

    local info = text:GetText()
    if not info then
        return
    end

    local current, required, details = strmatch(info, '^(%d-)/(%d-) (.+)')

    if not (current and required and details) then
        details, current, required = strmatch(info, '(.+): (%d-)/(%d-)$')
    end

    if not (current and required and details) then
        return
    end

    local progress = tonumber(current) / tonumber(required)

    info = F:CreateColorString(current .. '/' .. required, getProgressColor(progress))
    info = info .. ' ' .. details

    text:SetText(info)
end

do
    local dash = OBJECTIVE_TRACKER_DASH_WIDTH
    function QUEST:UpdateTextWidth()
        OBJECTIVE_TRACKER_DASH_WIDTH = dash
    end
end

function QUEST:RestyleObjectiveTrackerText()
    self:UpdateTextWidth()

    local trackerModules = {
        _G['UI_WIDGET_TRACKER_MODULE'],
        _G['BONUS_OBJECTIVE_TRACKER_MODULE'],
        _G['WORLD_QUEST_TRACKER_MODULE'],
        _G['CAMPAIGN_QUEST_TRACKER_MODULE'],
        _G['QUEST_TRACKER_MODULE'],
        _G['ACHIEVEMENT_TRACKER_MODULE'],
        _G['MONTHLY_ACTIVITIES_TRACKER_MODULE'],
    }

    for _, module in pairs(trackerModules) do
        hooksecurefunc(module, 'AddObjective', function(_, block)
            if not block then
                return
            end

            if block.HeaderText then
                QUEST:HandleTitleText(block.HeaderText)
            end

            if block.currentLine then
                if block.currentLine.objectiveKey == 0 then -- 世界任务标题
                    QUEST:HandleTitleText(block.currentLine.Text)
                else
                    QUEST:HandleInfoText(block.currentLine.Text)
                end
            end
        end)
    end

    hooksecurefunc(ObjectiveTrackerModule_AddBlock, 'AddBlock', QUEST.HandleHeaderText)
    hooksecurefunc('ScenarioObjectiveTracker', 'UpdateCriteria', QUEST.ScenarioObjectiveBlock_UpdateCriteria)

    F.Delay(1, function()
        for _, child in pairs({ _G['ObjectiveTrackerBlocksFrame']:GetChildren() }) do
            if child and child.HeaderText then
                setTextColorHook(child.HeaderText)
            end
        end
    end)

    --ObjectiveTracker_Update()
end

-- Auto collapse Objective Tracker

local headers = {
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

local function toggleTracker()
    local inInstance, instanceType = IsInInstance()

    if inInstance then
        if instanceType == 'party' or instanceType == 'scenario' then
            F:Delay(1, function()
                for i = 3, #headers do
                    headers[i]:SetCollapsed(true)
                end
            end)
        else
            F:Delay(1, function()
                ObjectiveTrackerFrame:SetCollapsed(true)
            end)
        end
    else
        if not InCombatLockdown() then
            for i = 3, #headers do
                if headers[i].isCollapsed then
                    headers[i]:SetCollapsed(false)
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


