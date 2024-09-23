local F, C, L = unpack(select(2, ...))
local RT = F:RegisterModule('RaidTool')

local buffsList = {
    [1] = {
        -- 合剂
        431971, -- 淬火侵攻合剂
        431972, -- 淬火矫健合剂
        431973, -- 淬火全能合剂
        431974, -- 淬火精通合剂
        432021, -- 炼金混沌合剂
    },
    [2] = {     -- 食物
        104273, -- 进食充分
        462210, -- 丰盛进食充分
    },
    [3] = {
        -- 10%智力
        1459,
        264760,
    },
    [4] = {
        -- 10%耐力
        21562,
        264764,
    },
    [5] = {
        -- 10%攻强
        6673,
        264761,
    },
    [6] = {
        -- 符文
        453250, -- 晶化强化符文
    },
}

function RT:RaidTool_Visibility(frame)
    if IsInGroup() then
        frame:Show()
    else
        frame:Hide()
    end
end

function RT:RaidTool_Header()
    local frame = CreateFrame('Button', nil, UIParent)
    frame:SetSize(120, 28)
    frame:SetFrameLevel(2)
    F.ReskinButton(frame)
    F.Mover(frame, L['RaidTool'], 'RaidTool', { 'TOP', 0, -30 })

    RT:RaidTool_Visibility(frame)
    F:RegisterEvent('GROUP_ROSTER_UPDATE', function()
        RT:RaidTool_Visibility(frame)
    end)

    frame:RegisterForClicks('AnyUp')
    frame:SetScript('OnClick', function(self, btn)
        if btn == 'LeftButton' then
            local menu = self.menu
            F:TogglePanel(menu)

            if menu:IsShown() then
                menu:ClearAllPoints()
                if RT:IsFrameOnTop(self) then
                    menu:SetPoint('TOP', self, 'BOTTOM', 0, -3)
                else
                    menu:SetPoint('BOTTOM', self, 'TOP', 0, 3)
                end

                self.buttons[2].text:SetText(IsInRaid() and CONVERT_TO_PARTY or CONVERT_TO_RAID)
            end
        end
    end)
    frame:SetScript('OnDoubleClick', function(_, btn)
        if btn == 'RightButton' and (IsPartyLFG() and IsLFGComplete() or not IsInInstance()) then
            C_PartyInfo.LeaveParty()
        end
    end)
    -- frame:SetScript('OnHide', function(self)
    -- 	self.bg:SetBackdropColor(0, 0, 0, .5)
    -- 	self.bg:SetBackdropBorderColor(0, 0, 0, 1)
    -- end)

    return frame
end

function RT:IsFrameOnTop(frame)
    local y = select(2, frame:GetCenter())
    local screenHeight = UIParent:GetTop()
    return y > screenHeight / 2
end

function RT:GetRaidMaxGroup()
    local _, instType, difficulty = GetInstanceInfo()
    if (instType == 'party' or instType == 'scenario') and not IsInRaid() then
        return 1
    elseif instType ~= 'raid' then
        return 8
    elseif difficulty == 8 or difficulty == 1 or difficulty == 2 then
        return 1
    elseif difficulty == 14 or difficulty == 15 or (difficulty == 24 and instType == 'raid') then
        return 6
    elseif difficulty == 16 then
        return 4
    elseif difficulty == 3 or difficulty == 5 then
        return 2
    elseif difficulty == 9 then
        return 8
    else
        return 5
    end
end

local eventList = {
    'GROUP_ROSTER_UPDATE',
    'UPDATE_ACTIVE_BATTLEFIELD',
    'UNIT_FLAGS',
    'PLAYER_FLAGS_CHANGED',
    'PLAYER_ENTERING_WORLD',
}

function RT:RaidTool_RoleCount(parent)
    local outline = ANDROMEDA_ADB.FontOutline
    local roleIndex = { 'TANK', 'HEALER', 'DAMAGER' }
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetAllPoints()
    local role = {}
    for i = 1, 3 do
        role[i] = frame:CreateTexture(nil, 'OVERLAY')
        role[i]:SetPoint('LEFT', 36 * i - 34, 0)
        role[i]:SetSize(32, 32)
        F.ReskinSmallRole(role[i], roleIndex[i])

        role[i].text = F.CreateFS(
            frame,
            C.Assets.Fonts.Condensed, 12, outline or nil,
            '0', 'YELLOW', outline and 'NONE' or 'THICK'
        )
        role[i].text:ClearAllPoints()
        role[i].text:SetPoint('CENTER', role[i], 'RIGHT', 2, 0)
    end

    local raidCounts = { totalTANK = 0, totalHEALER = 0, totalDAMAGER = 0 }

    local function updateRoleCount()
        for k in pairs(raidCounts) do
            raidCounts[k] = 0
        end

        local maxgroup = RT:GetRaidMaxGroup()
        for i = 1, GetNumGroupMembers() do
            local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
            if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= 'NONE' then
                raidCounts['total' .. assignedRole] = raidCounts['total' .. assignedRole] + 1
            end
        end

        role[1].text:SetText(raidCounts.totalTANK)
        role[2].text:SetText(raidCounts.totalHEALER)
        role[3].text:SetText(raidCounts.totalDAMAGER)
    end

    for _, event in next, eventList do
        F:RegisterEvent(event, updateRoleCount)
    end

    parent.roleFrame = frame
end

function RT:RaidTool_UpdateRes(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > 0.1 then
        local chargeInfo = C_Spell.GetSpellCharges(20484)
        local charges = chargeInfo and chargeInfo.currentCharges
        local started = chargeInfo and chargeInfo.cooldownStartTime
        local duration = chargeInfo and chargeInfo.cooldownDuration
        if charges then
            local timer = duration - (GetTime() - started)
            if timer < 0 then
                self.Timer:SetText('--:--')
            else
                self.Timer:SetFormattedText('%d:%.2d', timer / 60, timer % 60)
            end
            self.Count:SetText(charges)
            if charges == 0 then
                self.Count:SetTextColor(1, 0, 0)
            else
                self.Count:SetTextColor(0, 1, 0)
            end
            self.__owner.resFrame:SetAlpha(1)
            self.__owner.roleFrame:SetAlpha(0)
        else
            self.__owner.resFrame:SetAlpha(0)
            self.__owner.roleFrame:SetAlpha(1)
        end

        self.elapsed = 0
    end
end

function RT:RaidTool_CombatRes(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetAllPoints()
    frame:SetAlpha(0)
    local res = CreateFrame('Frame', nil, frame)
    res:SetSize(22, 22)
    res:SetPoint('LEFT', 5, 0)
    F.PixelIcon(res, C_Spell.GetSpellTexture(20484))
    res.__owner = parent

    local outline = ANDROMEDA_ADB.FontOutline
    res.Count = F.CreateFS(
        res,
        C.Assets.Fonts.Regular, 14, outline or nil, '0',
        nil, outline and 'NONE' or 'THICK'
    )
    res.Count:ClearAllPoints()
    res.Count:SetPoint('LEFT', res, 'RIGHT', 10, 0)
    res.Timer = F.CreateFS(
        frame,
        C.Assets.Fonts.Regular, 14, outline or nil,
        '00:00', nil, outline and 'NONE' or 'THICK',
        'RIGHT', -5, 0
    )
    res:SetScript('OnUpdate', RT.RaidTool_UpdateRes)

    parent.resFrame = frame
end

function RT:RaidTool_ReadyCheck(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
    frame:SetSize(120, 50)
    frame:Hide()
    frame:SetScript('OnMouseUp', function(self)
        self:Hide()
    end)
    F.SetBD(frame)

    local outline = ANDROMEDA_ADB.FontOutline
    F.CreateFS(
        frame,
        C.Assets.Fonts.Regular, 14, outline or nil,
        READY_CHECK, nil, outline and 'NONE' or 'THICK',
        'TOP', 0, -8
    )
    local rc = F.CreateFS(
        frame,
        C.Assets.Fonts.Regular, 14, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        'TOP', 0, -28
    )

    local count, total
    local function hideRCFrame()
        frame:Hide()
        rc:SetText('')
        count, total = 0, 0
    end

    local function updateReadyCheck(event)
        if event == 'READY_CHECK_FINISHED' then
            if count == total then
                rc:SetTextColor(0, 1, 0)
            else
                rc:SetTextColor(1, 0, 0)
            end
            F:Delay(5, hideRCFrame)
        else
            count, total = 0, 0

            frame:ClearAllPoints()
            if RT:IsFrameOnTop(parent) then
                frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
            else
                frame:SetPoint('BOTTOM', parent, 'TOP', 0, 3)
            end
            frame:Show()

            local maxgroup = RT:GetRaidMaxGroup()
            for i = 1, GetNumGroupMembers() do
                local name, _, subgroup, _, _, _, _, online = GetRaidRosterInfo(i)
                if name and online and subgroup <= maxgroup then
                    total = total + 1
                    local status = GetReadyCheckStatus(name)
                    if status and status == 'ready' then
                        count = count + 1
                    end
                end
            end
            rc:SetText(count .. ' / ' .. total)
            if count == total then
                rc:SetTextColor(0, 1, 0)
            else
                rc:SetTextColor(1, 1, 0)
            end
        end
    end
    F:RegisterEvent('READY_CHECK', updateReadyCheck)
    F:RegisterEvent('READY_CHECK_CONFIRM', updateReadyCheck)
    F:RegisterEvent('READY_CHECK_FINISHED', updateReadyCheck)
end

function RT:RaidTool_Marker(parent)
    local markerButton = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
    if not markerButton then
        for _, addon in next, { 'Blizzard_CUFProfiles', 'Blizzard_CompactRaidFrames' } do
            C_AddOns.EnableAddOn(addon)
            C_AddOns.LoadAddOn(addon)
        end
    end
    if markerButton then
        markerButton:ClearAllPoints()
        markerButton:SetPoint('RIGHT', parent, 'LEFT', -4, 0)
        markerButton:SetParent(parent)
        markerButton:SetSize(28, 28)

        for i = 1, 9 do
            select(i, markerButton:GetRegions()):SetAlpha(0)
        end

        F.ReskinButton(markerButton)
        markerButton:SetNormalTexture('Interface\\RaidFrame\\Raid-WorldPing')
        markerButton:GetNormalTexture():SetVertexColor(0.2, 1, 0.2)
        markerButton:HookScript('OnMouseUp', function()
            if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader('player') or UnitIsGroupAssistant('player') then
                return
            end
            UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
        end)
    end
end

function RT:RaidTool_BuffChecker(parent)
    local frame = CreateFrame('Button', nil, parent)
    frame:SetPoint('RIGHT', parent, 'LEFT', -5, 0)
    frame:SetSize(28, 28)
    F.ReskinButton(frame)

    local icon = frame:CreateTexture(nil, 'ARTWORK')
    icon:SetOutside()
    icon:SetAtlas('GM-icon-readyCheck')

    local BuffName = { L['Flask'], POWER_TYPE_FOOD, SPELL_STAT4_NAME, RAID_BUFF_2, RAID_BUFF_3, RUNES }
    local NoBuff, numGroups, numPlayer = {}, 6, 0
    for i = 1, numGroups do
        NoBuff[i] = {}
    end

    local debugMode = false
    local function sendMsg(text)
        if debugMode then
            print(text)
        else
            SendChatMessage(text, IsPartyLFG() and 'INSTANCE_CHAT' or IsInRaid() and 'RAID' or 'PARTY')
        end
    end

    local function sendResult(i)
        local count = #NoBuff[i]
        if count > 0 then
            if count >= numPlayer then
                sendMsg(L['Lack of'] .. BuffName[i] .. ': ' .. ALL .. PLAYER)
            elseif count >= 5 and i > 2 then
                sendMsg(L['Lack of'] .. BuffName[i] .. ': ' .. format(L['%s players'], count))
            else
                local str = L['Lack of'] .. BuffName[i] .. ': '
                for j = 1, count do
                    str = str .. NoBuff[i][j] .. (j < #NoBuff[i] and ', ' or '')
                    if #str > 230 then
                        sendMsg(str)
                        str = ''
                    end
                end
                sendMsg(str)
            end
        end
    end

    local function scanBuff()
        for i = 1, numGroups do
            wipe(NoBuff[i])
        end
        numPlayer = 0

        local maxgroup = RT:GetRaidMaxGroup()
        for i = 1, GetNumGroupMembers() do
            local name, _, subgroup, _, _, _, _, online, isDead = GetRaidRosterInfo(i)
            if name and online and subgroup <= maxgroup and not isDead then
                numPlayer = numPlayer + 1
                for j = 1, numGroups do
                    local HasBuff
                    local buffTable = buffsList[j]
                    for k = 1, #buffTable do
                        local buffName = C_Spell.GetSpellName(buffTable[k])
                        if buffName and C_UnitAuras.GetAuraDataBySpellName(name, buffName) then
                            HasBuff = true
                            break
                        end
                    end
                    if not HasBuff then
                        name = strsplit('-', name) -- remove realm name
                        tinsert(NoBuff[j], name)
                    end
                end
            end
        end
        if not C.DB.General.RuneCheck then
            NoBuff[numGroups] = {}
        end

        if
            #NoBuff[1] == 0
            and #NoBuff[2] == 0
            and #NoBuff[3] == 0
            and #NoBuff[4] == 0
            and #NoBuff[5] == 0
            and #NoBuff[6] == 0
        then
            sendMsg(L['All Buffs Ready!'])
        else
            sendMsg(L['Raid Buff Checker:'])
            for i = 1, 5 do
                sendResult(i)
            end
            if C.DB.General.RuneCheck then
                sendResult(numGroups)
            end
        end
    end

    local potionCheck = C_AddOns.IsAddOnLoaded('MRT')

    frame:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -3)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L['Group Tool'])
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(C.MOUSE_LEFT_BUTTON .. C.INFO_COLOR .. L['Check Status'], 0, 0.6, 1)

        if potionCheck then
            GameTooltip:AddDoubleLine(C.MOUSE_RIGHT_BUTTON .. C.INFO_COLOR .. L['MRT Potion Check'], 0, 0.6, 1)
        end
        GameTooltip:Show()
    end)
    frame:HookScript('OnLeave', F.HideTooltip)

    local reset = true
    F:RegisterEvent('PLAYER_REGEN_ENABLED', function()
        reset = true
    end)

    frame:HookScript('OnMouseDown', function(_, btn)
        if btn == 'LeftButton' then
            scanBuff()
        elseif potionCheck then
            SlashCmdList['mrtSlash']('potionchat')
        end
    end)
end

function RT:RaidTool_CountDown(parent)
    local frame = CreateFrame('Button', nil, parent)
    frame:SetPoint('LEFT', parent, 'RIGHT', 5, 0)
    frame:SetSize(28, 28)
    F.ReskinButton(frame)

    local icon = frame:CreateTexture(nil, 'ARTWORK')
    icon:SetOutside()
    icon:SetAtlas('GM-icon-countdown')

    frame:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L['Raid Tool'], 0, 0.6, 1)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(C.MOUSE_LEFT_BUTTON .. C.INFO_COLOR .. READY_CHECK)
        GameTooltip:AddDoubleLine(C.MOUSE_RIGHT_BUTTON .. C.INFO_COLOR .. L['Start/Cancel count down'])
        GameTooltip:Show()
    end)
    frame:HookScript('OnLeave', F.HideTooltip)

    local reset = true
    F:RegisterEvent('PLAYER_REGEN_ENABLED', function()
        reset = true
    end)

    frame:HookScript('OnMouseDown', function(_, btn)
        if btn == 'LeftButton' then
            if InCombatLockdown() then
                UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_IN_COMBAT)
                return
            end
            if IsInGroup() and (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid())) then
                DoReadyCheck()
            else
                UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
            end
        else
            if IsInGroup() and (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid())) then
                if C_AddOns.IsAddOnLoaded('DBM-Core') then
                    if reset then
                        SlashCmdList['DEADLYBOSSMODS']('pull ' .. C.DB['General']['RaidToolCountdown'])
                    else
                        SlashCmdList['DEADLYBOSSMODS']('pull 0')
                    end
                    reset = not reset
                elseif C_AddOns.IsAddOnLoaded('BigWigs') then
                    if not SlashCmdList['BIGWIGSPULL'] then
                        C_AddOns.LoadAddOn('BigWigs_Plugins')
                    end
                    if reset then
                        SlashCmdList['BIGWIGSPULL'](C.DB['General']['RaidToolCountdown'])
                    else
                        SlashCmdList['BIGWIGSPULL']('0')
                    end
                    reset = not reset
                else
                    UIErrorsFrame:AddMessage(C.RED_COLOR .. L['You can not do it without DBM or BigWigs!'])
                end
            else
                UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
            end
        end
    end)
end

function RT:RaidTool_CreateMenu(parent)
    local frame = CreateFrame('Frame', nil, parent)
    frame:SetPoint('TOP', parent, 'BOTTOM', 0, -3)
    frame:SetSize(182, 70)
    F.SetBD(frame)
    frame:Hide()

    local function updateDelay(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 0.1 then
            if not frame:IsMouseOver() then
                self:Hide()
                self:SetScript('OnUpdate', nil)
            end

            self.elapsed = 0
        end
    end

    frame:SetScript('OnLeave', function(self)
        self:SetScript('OnUpdate', updateDelay)
    end)

    local buttons = {
        {
            TEAM_DISBAND,
            function()
                if UnitIsGroupLeader('player') then
                    StaticPopup_Show('ANDROMEDA_DISBAND_GROUP')
                else
                    UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            CONVERT_TO_RAID,
            function()
                if UnitIsGroupLeader('player') and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
                    if IsInRaid() then
                        C_PartyInfo.ConvertToParty()
                    else
                        C_PartyInfo.ConvertToRaid()
                    end
                    frame:Hide()
                    frame:SetScript('OnUpdate', nil)
                else
                    UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            ROLE_POLL,
            function()
                if
                    IsInGroup()
                    and not HasLFGRestrictions()
                    and (UnitIsGroupLeader('player') or (UnitIsGroupAssistant('player') and IsInRaid()))
                then
                    InitiateRolePoll()
                else
                    UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_LEADER)
                end
            end,
        },
        {
            RAID_CONTROL,
            function()
                ToggleFriendsFrame(3)
            end,
        },
    }

    local bu = {}
    for i, j in pairs(buttons) do
        bu[i] = F.CreateButton(frame, 84, 28, j[1], 12)
        bu[i]:SetPoint(mod(i, 2) == 0 and 'TOPRIGHT' or 'TOPLEFT', mod(i, 2) == 0 and -5 or 5, i > 2 and -37 or -5)
        bu[i]:SetScript('OnClick', j[2])
    end

    parent.menu = frame
    parent.buttons = bu
end

function RT:RaidTool_Misc()
    -- UIWidget reanchor
    if not UIWidgetTopCenterContainerFrame:IsMovable() then -- can be movable for some addons, eg BattleInfo
        UIWidgetTopCenterContainerFrame:ClearAllPoints()
        UIWidgetTopCenterContainerFrame:SetPoint('TOP', 0, -35)
    end
end

function RT:OnLogin()
    if not C.DB.General.RaidTool then
        return
    end

    local frame = RT:RaidTool_Header()
    RT:RaidTool_RoleCount(frame)
    RT:RaidTool_CombatRes(frame)
    RT:RaidTool_ReadyCheck(frame)
    RT:RaidTool_Marker(frame)
    RT:RaidTool_BuffChecker(frame)
    RT:RaidTool_CreateMenu(frame)
    RT:RaidTool_CountDown(frame)
    RT:RaidTool_Misc()
end
