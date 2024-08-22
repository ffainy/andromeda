local F, C, L = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')

local linkQuest = 'http://www.wowhead.com/quest=%d'
local linkAchievement = 'http://www.wowhead.com/achievement=%d'

local ID
local headers = {
    BonusObjectiveTracker,
    CampaignQuestObjectiveTracker,
    QuestObjectiveTracker,
    AchievementObjectiveTracker,
    WorldQuestObjectiveTracker,
}

-- Right click on quest or achievement on the ObjectiveTracker to get the wowhead link

local function insertMenu()
    for i = 1, #headers do
        local tracker = headers[i]
        if tracker then
            hooksecurefunc(tracker, 'OnBlockHeaderClick', function(_, block)
                ID = block.id
            end)
        end
    end

    Menu.ModifyMenu('MENU_QUEST_OBJECTIVE_TRACKER', function(_, rootDescription)
        rootDescription:CreateButton(L['Wowhead Link'], function()
            local text = linkQuest:format(ID)
            StaticPopup_Show('ANDROMEDA_WOWHEAD_LINK', _, _, text)
        end)
    end)

    Menu.ModifyMenu('MENU_BONUS_OBJECTIVE_TRACKER', function(_, rootDescription)
        rootDescription:CreateButton(L['Wowhead Link'], function()
            local text = linkQuest:format(ID)
            StaticPopup_Show('ANDROMEDA_WOWHEAD_LINK', _, _, text)
        end)
    end)

    Menu.ModifyMenu('MENU_ACHIEVEMENT_TRACKER', function(_, rootDescription)
        rootDescription:CreateButton(L['Wowhead Link'], function()
            local text = linkAchievement:format(ID)
            StaticPopup_Show('ANDROMEDA_WOWHEAD_LINK', _, _, text)
        end)
    end)
end

-- Hold ctrl and click on the achievement in the AchievementUI to get the wowhead link

local function hook(event, addon)
    if addon == 'Blizzard_AchievementUI' then
        hooksecurefunc(AchievementTemplateMixin, 'OnClick', function(self)
            local elementData = self:GetElementData()
            if elementData and elementData.id and IsControlKeyDown() then
                local text = linkAchievement:format(elementData.id)
                StaticPopup_Show('ANDROMEDA_WOWHEAD_LINK', nil, nil, text)
            end
        end)

        F:UnregisterEvent(event, hook)
    end
end

function QUEST:WowheadLink()
    if not C.DB.Quest.WowheadLink then
        return
    end

    insertMenu()
    F:RegisterEvent('ADDON_LOADED', hook)
end
