local F, C, L = unpack(select(2, ...))
local ECF = F:RegisterModule('EnhancedChallengeFrame')

local hasAngryKeystones
local frame
local WeeklyRunsThreshold = 10

function ECF:GuildBest_UpdateTooltip()
    local leaderInfo = self.leaderInfo
    if not leaderInfo then
        return
    end

    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    local name = C_ChallengeMode.GetMapUIInfo(leaderInfo.mapChallengeModeID)
    GameTooltip:SetText(name, 1, 1, 1)
    GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
    for i = 1, #leaderInfo.members do
        local classColorStr = strsub(F:RgbToHex(F:ClassColor(leaderInfo.members[i].classFileName)), 3, 10)
        GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr, leaderInfo.members[i].name))
    end
    GameTooltip:Show()
end

function ECF:GuildBest_Create()
    frame = CreateFrame('Frame', nil, ChallengesFrame, 'BackdropTemplate')
    frame:SetPoint('BOTTOMRIGHT', -8, 75)
    frame:SetSize(170, 105)
    F.CreateBD(frame, 0.3)

    local outline = ANDROMEDA_ADB.FontOutline
    F.CreateFS(
        frame,
        C.Assets.Fonts.Regular, 14, outline or nil,
        GUILD, nil, outline and 'NONE' or 'THICK',
        { 'TOPLEFT', 16, -6 }
    )

    frame.entries = {}
    for i = 1, 4 do
        local entry = CreateFrame('Frame', nil, frame)
        entry:SetPoint('LEFT', 10, 0)
        entry:SetPoint('RIGHT', -10, 0)
        entry:SetHeight(18)
        entry.CharacterName = F.CreateFS(entry, C.Assets.Fonts.Regular, 12, outline or nil, '', nil,
            outline and 'NONE' or 'THICK', 'LEFT', 6, 0)
        entry.CharacterName:SetPoint('RIGHT', -30, 0)
        entry.CharacterName:SetJustifyH('LEFT')
        entry.Level = F.CreateFS(entry, C.Assets.Fonts.Regular, 12, outline or nil, '', nil,
            outline and 'NONE' or 'THICK')
        entry.Level:SetJustifyH('LEFT')
        entry.Level:ClearAllPoints()
        entry.Level:SetPoint('LEFT', entry, 'RIGHT', -22, 0)
        entry:SetScript('OnEnter', self.GuildBest_UpdateTooltip)
        entry:SetScript('OnLeave', F.HideTooltip)
        if i == 1 then
            entry:SetPoint('TOP', frame, 0, -26)
        else
            entry:SetPoint('TOP', frame.entries[i - 1], 'BOTTOM')
        end

        frame.entries[i] = entry
    end

    if not hasAngryKeystones then
        ChallengesFrame.WeeklyInfo.Child.Description:SetPoint('CENTER', 0, 20)
    end

    -- Details key window
    if SlashCmdList.KEYSTONE then
        local button = CreateFrame('Button', nil, frame)
        button:SetSize(20, 20)
        button:SetPoint('TOPRIGHT', -12, -5)
        button:SetScript('OnClick', function()
            if _G['DetailsKeystoneInfoFrame'] and _G['DetailsKeystoneInfoFrame']:IsShown() then
                _G['DetailsKeystoneInfoFrame']:Hide()
            else
                SlashCmdList.KEYSTONE()
            end
        end)

        local tex = button:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture('Interface\\Buttons\\UI-GuildButton-PublicNote-Up')
        tex:SetVertexColor(0, 1, 0)

        local hl = button:CreateTexture(nil, 'HIGHLIGHT')
        hl:SetAllPoints()
        hl:SetTexture('Interface\\Buttons\\UI-GuildButton-PublicNote-Up')
    end

    if _G['RaiderIO_GuildWeeklyFrame'] then
        F.HideObject(_G['RaiderIO_GuildWeeklyFrame'])
    end
end

function ECF:GuildBest_SetUp(leaderInfo)
    self.leaderInfo = leaderInfo
    local str = CHALLENGE_MODE_GUILD_BEST_LINE
    if leaderInfo.isYou then
        str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
    end

    local classColorStr = strsub(F:RgbToHex(F:ClassColor(leaderInfo.classFileName)), 3, 10)
    self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
    self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
function ECF:GuildBest_Update()
    if not frame then
        ECF:GuildBest_Create()
    end
    if self.leadersAvailable then
        local leaders = C_ChallengeMode.GetGuildLeaders()
        if leaders and #leaders > 0 then
            for i = 1, #leaders do
                ECF.GuildBest_SetUp(frame.entries[i], leaders[i])
            end
            frame:Show()
        else
            frame:Hide()
        end
    end

    if not resize and hasAngryKeystones then
        hooksecurefunc(self.WeeklyInfo.Child.WeeklyChest, 'SetPoint', function(frame, _, x, y)
            if x == 100 and y == -30 then
                frame:SetPoint('LEFT', 105, -5)
            end
        end)
        self.WeeklyInfo.Child.ThisWeekLabel:SetPoint('TOP', -135, -25)

        local schedule = _G['AngryKeystones'].Modules.Schedule
        frame:SetWidth(246)
        frame:ClearAllPoints()
        frame:SetPoint('BOTTOMLEFT', schedule.AffixFrame, 'TOPLEFT', 0, 10)

        local keystoneText = schedule.KeystoneText
        if keystoneText then
            keystoneText:SetFontObject(Game13Font)
            keystoneText:ClearAllPoints()
            keystoneText:SetPoint('TOP', self.WeeklyInfo.Child.DungeonScoreInfo.Score, 'BOTTOM', 0, -3)
        end

        resize = true
    end
end

function ECF.GuildBest_OnLoad(event, addon)
    if addon == 'Blizzard_ChallengesUI' then
        hooksecurefunc(ChallengesFrame, 'Update', ECF.GuildBest_Update)
        ECF:KeystoneInfo_Create()
        ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript('OnEnter', ECF.KeystoneInfo_WeeklyRuns)

        F:UnregisterEvent(event, ECF.GuildBest_OnLoad)
    end
end

local function sortHistory(entry1, entry2)
    if entry1.level == entry2.level then
        return entry1.mapChallengeModeID < entry2.mapChallengeModeID
    else
        return entry1.level > entry2.level
    end
end

function ECF:KeystoneInfo_WeeklyRuns()
    local runHistory = C_MythicPlus.GetRunHistory(false, true)
    local numRuns = runHistory and #runHistory

    if numRuns > 0 then
        local isShiftKeyDown = IsShiftKeyDown()

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            isShiftKeyDown and CHALLENGE_MODE_THIS_WEEK or format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold),
            '(' .. numRuns .. ')',
            0.6, 0.8, 1
        )
        sort(runHistory, sortHistory)

        for i = 1, isShiftKeyDown and numRuns or WeeklyRunsThreshold do
            local runInfo = runHistory[i]
            if not runInfo then
                break
            end

            local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID)
            local r, g, b = 0, 1, 0
            if not runInfo.completed then
                r, g, b = 1, 0, 0
            end
            GameTooltip:AddDoubleLine(name, 'Lv.' .. runInfo.level, 1, 1, 1, r, g, b)
        end

        if not isShiftKeyDown then
            GameTooltip:AddLine(L['Hold SHIFT for more details'], 0.6, 0.8, 1)
        end

        GameTooltip:Show()
    end
end

function ECF:KeystoneInfo_Create()
    local texture = C_Item.GetItemIconByID(158923) or 525134
    local iconColor = C.QualityColors[Enum.ItemQuality.Epic or 4]
    local button = CreateFrame('Frame', nil, ChallengesFrame.WeeklyInfo, 'BackdropTemplate')
    button:SetPoint('BOTTOMLEFT', 10, 67)
    button:SetSize(35, 35)
    F.PixelIcon(button, texture, true)
    button.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
    button:SetScript('OnEnter', function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:AddLine(L['Account Keystones'])
        for name, info in pairs(ANDROMEDA_ADB.KeystoneInfo) do
            local newName = Ambiguate(name, 'none')
            local mapID, level, class, faction = strsplit(':', info)
            local color = F:RgbToHex(F:ClassColor(class))
            local factionColor = faction == 'Horde' and '|cffff5040' or '|cff00adf0'
            local dungeon = C_ChallengeMode.GetMapUIInfo(tonumber(mapID))
            GameTooltip:AddDoubleLine(format(color .. '%s:|r', newName),
                format('%s%s(%s)|r', factionColor, dungeon, level))
        end
        GameTooltip:AddDoubleLine(' ', C.LINE_STRING)
        GameTooltip:AddDoubleLine(' ', C.MOUSE_LEFT_BUTTON .. GREAT_VAULT_REWARDS .. ' ', 1, 1, 1, 0.6, 0.8, 1)
        GameTooltip:AddDoubleLine(' ', C.MOUSE_MIDDLE_BUTTON .. L['Delete keystones info'] .. ' ', 1, 1, 1, 0.6, 0.8, 1)
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave', F.HideTooltip)
    button:SetScript('OnMouseUp', function(_, btn)
        if btn == 'LeftButton' then
            if not WeeklyRewardsFrame then
                WeeklyRewards_LoadUI()
            end
            F:TogglePanel(WeeklyRewardsFrame)
        elseif btn == 'MiddleButton' then
            wipe(ANDROMEDA_ADB.KeystoneInfo)
            ECF:KeystoneInfo_Update() -- update own keystone info after reset
        end
    end)
end

function ECF:KeystoneInfo_UpdateBag()
    local keystoneMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    if keystoneMapID then
        return keystoneMapID, C_MythicPlus.GetOwnedKeystoneLevel()
    end
end

function ECF:KeystoneInfo_Update()
    local mapID, keystoneLevel = ECF:KeystoneInfo_UpdateBag()
    if mapID then
        ANDROMEDA_ADB['KeystoneInfo'][C.MY_FULL_NAME] = mapID ..
            ':' .. keystoneLevel .. ':' .. C.MY_CLASS .. ':' .. C.MY_FACTION
    else
        ANDROMEDA_ADB['KeystoneInfo'][C.MY_FULL_NAME] = nil
    end
end

function ECF:OnLogin()
    hasAngryKeystones = C_AddOns.IsAddOnLoaded('AngryKeystones')
    F:RegisterEvent('ADDON_LOADED', ECF.GuildBest_OnLoad)

    ECF:KeystoneInfo_Update()
    F:RegisterEvent('BAG_UPDATE', ECF.KeystoneInfo_Update)
end
