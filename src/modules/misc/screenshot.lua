local F, C, L = unpack(select(2, ...))
local ass = F:RegisterModule('AutoScreenshot')

function ass.takeScreenshot(event)
    if C.DB.autoScreenshot.printMsg then
        F.Print(format(L['taking screenshot (%s) (%s)'], event, date()))
    end

    if C.DB.autoScreenshot.hideUI then
        UIParent:Hide()
        F:Delay(0.5, function()
            Screenshot()
        end)
        F:Delay(0.55, function()
            UIParent:Show()
        end)
    else
        F:Delay(0.5, function()
            Screenshot()
        end)
    end
end

function ass.PlayerStartdMoving(event) -- debug
    ass.takeScreenshot(event)
end

function ass.AchievementEarned(event, alreadyEarned)
    if alreadyEarned then
        return
    end

    ass.takeScreenshot(event)
end

function ass.ChallengeModeCompleted(event)
    ChallengeModeCompleteBanner:HookScript('OnShow', function()
        ass.takeScreenshot(event)
    end)
end

function ass.PlayerLevelUp(event)
    ass.takeScreenshot(event)
end

function ass.PlayerDead(event)
    ass.takeScreenshot(event)
end

function ass.UpdateConfig()
    local db = C.DB.autoScreenshot
    if db.enable and db.playerStartedMoving then
        F:RegisterEvent('PLAYER_STARTED_MOVING', ass.PlayerStartdMoving)
    else
        F:UnregisterEvent('PLAYER_STARTED_MOVING', ass.PlayerStartdMoving)
    end

    if db.enable and db.achievementEarned then
        F:RegisterEvent('ACHIEVEMENT_EARNED', ass.AchievementEarned)
    else
        F:UnregisterEvent('ACHIEVEMENT_EARNED', ass.AchievementEarned)
    end

    if db.enable and db.challengeModeCompleted then
        F:RegisterEvent('CHALLENGE_MODE_COMPLETED', ass.ChallengeModeCompleted)
    else
        F:UnregisterEvent('CHALLENGE_MODE_COMPLETED', ass.ChallengeModeCompleted)
    end

    if db.enable and db.playerLevelUp then
        F:RegisterEvent('PLAYER_LEVEL_UP', ass.PlayerLevelUp)
    else
        F:UnregisterEvent('PLAYER_LEVEL_UP', ass.PlayerLevelUp)
    end

    if db.enable and db.playerDead then
        F:RegisterEvent('PLAYER_DEAD', ass.PlayerDead)
    else
        F:UnregisterEvent('PLAYER_DEAD', ass.PlayerDead)
    end
end

function ass:OnLogin()
    if not C.DB.autoScreenshot.enable then
        return
    end

    ass.UpdateConfig()
end
