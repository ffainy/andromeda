local F, C = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')

local completedQuest = {}
local initComplete

local function checkNormalQuest()
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questID = C_QuestLog.GetQuestIDForLogIndex(i)
        local isComplete = questID and C_QuestLog.IsComplete(questID)
        if type(questID) == 'number' and isComplete and not completedQuest[questID] and not C_QuestLog.IsWorldQuest(questID) then
            if initComplete then
                PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, 'Master')
            end

            completedQuest[questID] = true
        end
    end

    initComplete = true
end

local function checkWorldQuest(_,questID)
    if C_QuestLog.IsWorldQuest(questID) then
        if questID and not completedQuest[questID] then
            PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, 'Master')

            completedQuest[questID] = true
        end
    end
end

function QUEST:CompletedSound()
    if C.DB.Quest.CompletedSound then
        F:RegisterEvent('QUEST_LOG_UPDATE', checkNormalQuest)
        F:RegisterEvent('QUEST_TURNED_IN', checkWorldQuest)
    else
        wipe(completedQuest)
        F:UnregisterEvent('QUEST_LOG_UPDATE', checkNormalQuest)
        F:UnregisterEvent('QUEST_TURNED_IN', checkWorldQuest)
    end
end

function QUEST:OnLogin()
    QUEST:CompletedSound()
    QUEST:WowheadLink()
    QUEST:TrackerMover()
    QUEST:TrackerAutoCollapse()
end
