local F, C, L = unpack(select(2, ...))
local A = F:GetModule('Announcement')

local function getQuestLinkOrName(questID)
    return GetQuestLink(questID) or C_QuestLog.GetTitleForQuestID(questID) or ''
end

local function acceptText(questID, daily)
    local title = getQuestLinkOrName(questID)
    if daily then
        return format('%s [%s]%s', L['Quest accept:'], DAILY, title)
    else
        return format('%s %s', L['Quest accept:'], title)
    end
end

local function completeText(questID)
    return format('%s %s', getQuestLinkOrName(questID), QUEST_COMPLETE)
end

local function getPattern(pattern)
    pattern = gsub(pattern, '%(', '%%%1')
    pattern = gsub(pattern, '%)', '%%%1')
    pattern = gsub(pattern, '%%%d?$?.', '(.+)')
    return format('^%s$', pattern)
end

local questMatches = {
    ['Found'] = getPattern(ERR_QUEST_ADD_FOUND_SII),
    ['Item'] = getPattern(ERR_QUEST_ADD_ITEM_SII),
    ['Kill'] = getPattern(ERR_QUEST_ADD_KILL_SII),
    ['PKill'] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
    ['ObjectiveComplete'] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
    ['QuestComplete'] = getPattern(ERR_QUEST_COMPLETE_S),
    ['QuestFailed'] = getPattern(ERR_QUEST_FAILED_S),
}

function A:FindQuestProgress(_, msg)
    for _, pattern in pairs(questMatches) do
        if strmatch(msg, pattern) then
            local _, _, _, cur, max = strfind(msg, '(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$')
            cur, max = tonumber(cur), tonumber(max)
            if cur and max and max >= 10 then
                if mod(cur, floor(max / 5)) == 0 then
                    A:SendMessage(msg, A:GetChannel(true))
                end
            else
                A:SendMessage(msg, A:GetChannel(true))
            end
            break
        end
    end
end

local WQcache = {}
function A:FindQuestAccept(questID)
    if not questID then return end
    if C_QuestLog.IsWorldQuest(questID) and WQcache[questID] then return end

    WQcache[questID] = true

    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    if tagInfo and tagInfo.worldQuestType == _G['LE_QUEST_TAG_TYPE_PROFESSION'] then return end

    local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
    if questLogIndex then
        local info = C_QuestLog.GetInfo(questLogIndex)
        if info then
            A:SendMessage(acceptText(questID, info.frequency == _G['LE_QUEST_FREQUENCY_DAILY']), A:GetChannel(true))
        end
    end
end

local completedQuest = {}
local initComplete

function A:FindQuestComplete()
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questID = C_QuestLog.GetQuestIDForLogIndex(i)
        local isComplete = questID and C_QuestLog.IsComplete(questID)
        if type(questID) == 'number' then
            if isComplete and not completedQuest[questID] and not C_QuestLog.IsWorldQuest(questID) then
                if initComplete then
                    A:SendMessage(completeText(questID), A:GetChannel(true))
                end
                completedQuest[questID] = true
            end
        end
    end

    initComplete = true
end

function A:FindWorldQuestComplete(questID)
    if C_QuestLog.IsWorldQuest(questID) then
        if questID and not completedQuest[questID] then
            A:SendMessage(completeText(questID), A:GetChannel(true))
            completedQuest[questID] = true
        end
    end
end

function A:QuestProgress()
    if C.DB.Announcement.QuestProgress then
        F:RegisterEvent('QUEST_ACCEPTED', A.FindQuestAccept)
        F:RegisterEvent('QUEST_LOG_UPDATE', A.FindQuestComplete)
        F:RegisterEvent('QUEST_TURNED_IN', A.FindWorldQuestComplete)
        F:RegisterEvent('UI_INFO_MESSAGE', A.FindQuestProgress)
    else
        wipe(completedQuest)
        F:UnregisterEvent('QUEST_ACCEPTED', A.FindQuestAccept)
        F:UnregisterEvent('QUEST_LOG_UPDATE', A.FindQuestComplete)
        F:UnregisterEvent('QUEST_TURNED_IN', A.FindWorldQuestComplete)
        F:UnregisterEvent('UI_INFO_MESSAGE', A.FindQuestProgress)
    end
end
