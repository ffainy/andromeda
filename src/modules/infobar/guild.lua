local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

local newBlock
local infoFrame, gName, gOnline, gRank, prevTime
local guildTable = {}

local function rosterButtonOnClick(self, btn)
    local name = guildTable[self.index][3]
    if btn == 'LeftButton' then
        if IsAltKeyDown() then
            C_PartyInfo.InviteUnit(name)
        elseif IsShiftKeyDown() then
            if MailFrame:IsShown() then
                MailFrameTab_OnClick(nil, 2)
                SendMailNameEditBox:SetText(name)
                SendMailNameEditBox:HighlightText()
            else
                local editBox = ChatEdit_ChooseBoxForSend()
                local hasText = (editBox:GetText() ~= '')
                ChatEdit_ActivateChat(editBox)
                editBox:Insert(name)
                if not hasText then
                    editBox:HighlightText()
                end
            end
        end
    else
        ChatFrame_OpenChat('/w ' .. name .. ' ', SELECTED_DOCK_FRAME)
    end
end

function INFOBAR:GuildPanel_CreateButton(parent, index)
    local button = CreateFrame('Button', nil, parent)
    button:SetSize(370, 20)
    button:SetPoint('TOPLEFT', 0, -(index - 1) * 20)
    button.HL = button:CreateTexture(nil, 'HIGHLIGHT')
    button.HL:SetAllPoints()
    button.HL:SetColorTexture(C.r, C.g, C.b, 0.2)

    local outline = ANDROMEDA_ADB.FontOutline

    button.level = F.CreateFS(
        button,
        C.Assets.Fonts.Regular, 13, outline or nil,
        'Level', nil, outline and 'NONE' or 'THICK'
    )
    button.level:SetPoint('TOP', button, 'TOPLEFT', 16, -4)

    button.class = button:CreateTexture(nil, 'ARTWORK')
    button.class:SetPoint('LEFT', 40, 0)
    button.class:SetSize(16, 16)
    button.class:SetTexture('Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES')

    button.name = F.CreateFS(
        button,
        C.Assets.Fonts.Regular, 13, outline or nil,
        'Name', nil, outline and 'NONE' or 'THICK',
        { 'LEFT', 70, 0 }
    )
    button.name:SetPoint('RIGHT', button, 'LEFT', 250, 0)
    button.name:SetJustifyH('LEFT')

    button.zone = F.CreateFS(
        button,
        C.Assets.Fonts.Regular, 13, outline or nil,
        'Zone', nil, outline and 'NONE' or 'THICK',
        {'RIGHT', -2, 0}
    )
    button.zone:SetPoint('LEFT', button.name, 'RIGHT', -10, 0)
    button.zone:SetJustifyH('RIGHT')
    button.zone:SetWordWrap(false)

    button:RegisterForClicks('AnyUp')
    button:SetScript('OnClick', rosterButtonOnClick)

    return button
end

function INFOBAR:GuildPanel_UpdateButton(button)
    local index = button.index
    local level, class, name, zone, status, guid = unpack(guildTable[index])

    local levelcolor = F:RgbToHex(GetQuestDifficultyColor(level))
    button.level:SetText(levelcolor .. level)

    F.ClassIconTexCoord(button.class, class)

    local namecolor = F:RgbToHex(F:ClassColor(class))
    local isTimerunning = guid and C_ChatInfo.IsTimerunningPlayer(guid)
    local playerName = isTimerunning and TimerunningUtil.AddSmallIcon(name) or name
    button.name:SetText(namecolor .. playerName .. status)

    local zonecolor = C.GREY_COLOR
    if UnitInRaid(name) or UnitInParty(name) then
        zonecolor = '|cff4c4cff'
    elseif GetRealZoneText() == zone then
        zonecolor = '|cff4cff4c'
    end
    button.zone:SetText(zonecolor .. zone)
end

function INFOBAR:GuildPanel_Update()
    local scrollFrame = _G[C.ADDON_TITLE .. 'InfobarGuildScrollFrame']
    local usedHeight = 0
    local buttons = scrollFrame.buttons
    local height = scrollFrame.buttonHeight
    local numMemberButtons = infoFrame.numMembers
    local offset = HybridScrollFrame_GetOffset(scrollFrame)

    for i = 1, #buttons do
        local button = buttons[i]
        local index = offset + i
        if index <= numMemberButtons then
            button.index = index
            INFOBAR:GuildPanel_UpdateButton(button)
            usedHeight = usedHeight + height
            button:Show()
        else
            button.index = nil
            button:Hide()
        end
    end

    HybridScrollFrame_Update(scrollFrame, numMemberButtons * height, usedHeight)
end

function INFOBAR:GuildPanel_OnMouseWheel(delta)
    local scrollBar = self.scrollBar
    local step = delta * self.buttonHeight
    if IsShiftKeyDown() then
        step = step * 15
    end
    scrollBar:SetValue(scrollBar:GetValue() - step)
    INFOBAR:GuildPanel_Update()
end

local function sortRosters(a, b)
    if a and b then
        if ANDROMEDA_ADB['GuildSortOrder'] then
            return a[ANDROMEDA_ADB['GuildSortBy']] < b[ANDROMEDA_ADB['GuildSortBy']]
        else
            return a[ANDROMEDA_ADB['GuildSortBy']] > b[ANDROMEDA_ADB['GuildSortBy']]
        end
    end
end

function INFOBAR:GuildPanel_SortUpdate()
    sort(guildTable, sortRosters)
    INFOBAR:GuildPanel_Update()
end

local function sortHeaderOnClick(self)
    ANDROMEDA_ADB['GuildSortBy'] = self.index
    ANDROMEDA_ADB['GuildSortOrder'] = not ANDROMEDA_ADB['GuildSortOrder']
    INFOBAR:GuildPanel_SortUpdate()
end

local function isPanelCanHide(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 0.1 then
        if not infoFrame:IsMouseOver() then
            self:Hide()
            self:SetScript('OnUpdate', nil)
        end

        self.timer = 0
    end
end

function INFOBAR:GuildPanel_Init()
    if infoFrame then
        infoFrame:Show()
        return
    end

    local anchorTop = C.DB.Infobar.AnchorTop

    infoFrame = CreateFrame('Frame', C.ADDON_TITLE .. 'InfoBarGuildFrame', INFOBAR.Bar)
    infoFrame:SetSize(400, 495) -- 335
    infoFrame:SetPoint(
        anchorTop and 'TOP' or 'BOTTOM',
        INFOBAR.GuildBlock,
        anchorTop and 'BOTTOM' or 'TOP',
        0,
        anchorTop and -6 or 6
    )
    infoFrame:SetClampedToScreen(true)
    infoFrame:SetFrameStrata('TOOLTIP')
    F.SetBD(infoFrame)

    infoFrame:SetScript('OnLeave', function(self)
        self:SetScript('OnUpdate', isPanelCanHide)
    end)

    local outline = ANDROMEDA_ADB.FontOutline
    gName = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Bold, 16, outline or nil,
        'Guild', nil, outline and 'NONE' or 'THICK',
        { 'TOPLEFT', 15, -10 }
    )
    gOnline = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        'Online', nil, outline and 'NONE' or 'THICK',
        { 'TOPLEFT', 15, -35 }
    )
    gRank = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        'Rank', nil, outline and 'NONE' or 'THICK',
        { 'TOPLEFT', 15, -51 }
    )

    local bu = {}
    local width = { 30, 35, 191, 126 }
    for i = 1, 4 do
        bu[i] = CreateFrame('Button', nil, infoFrame)
        bu[i]:SetSize(width[i], 22)
        bu[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
        if i == 1 then
            bu[i]:SetPoint('TOPLEFT', 12, -75)
        else
            bu[i]:SetPoint('LEFT', bu[i - 1], 'RIGHT', -2, 0)
        end
        bu[i].HL = bu[i]:CreateTexture(nil, 'HIGHLIGHT')
        bu[i].HL:SetAllPoints(bu[i])
        bu[i].HL:SetColorTexture(C.r, C.g, C.b, 0.2)
        bu[i].index = i
        bu[i]:SetScript('OnClick', sortHeaderOnClick)
    end
    F.CreateFS(
        bu[1],
        C.Assets.Fonts.Regular, 13, outline or nil,
        LEVEL, nil, outline and 'NONE' or 'THICK'
    )
    F.CreateFS(
        bu[2],
        C.Assets.Fonts.Regular, 13, outline or nil,
        CLASS, nil, outline and 'NONE' or 'THICK'
    )
    F.CreateFS(
        bu[3],
        C.Assets.Fonts.Regular, 13, outline or nil,
        NAME,
        nil, outline and 'NONE' or 'THICK',
        { 'LEFT', 5, 0 }
    )
    F.CreateFS(
        bu[4],
        C.Assets.Fonts.Regular, 13, outline or nil,
        ZONE, nil, outline and 'NONE' or 'THICK',
        { 'RIGHT', -5, 0 }
    )

    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        C.LINE_STRING, nil, outline and 'NONE' or 'THICK',
        { 'BOTTOMRIGHT', -12, 58 }
    )
    local whspInfo = C.MOUSE_RIGHT_BUTTON .. L['Whisper']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        whspInfo, {0.9, 0.8, 0.6}, outline and 'NONE' or 'THICK',
        { 'BOTTOMRIGHT', -15, 42 }
    )
    local invtInfo = 'ALT +' .. C.MOUSE_LEFT_BUTTON .. L['Invite']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        invtInfo, {0.9, 0.8, 0.6}, outline and 'NONE' or 'THICK',
        { 'BOTTOMRIGHT', -15, 26 }
    )
    local copyInfo = 'SHIFT +' .. C.MOUSE_LEFT_BUTTON .. L['Copy Name']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular, 13, outline or nil,
        copyInfo, {0.9, 0.8, 0.6}, outline and 'NONE' or 'THICK',
        { 'BOTTOMRIGHT', -15, 10 }
    )

    local scrollFrame = CreateFrame('ScrollFrame', C.ADDON_TITLE .. 'InfobarGuildScrollFrame', infoFrame,
        'HybridScrollFrameTemplate')
    scrollFrame:SetSize(370, 320)
    scrollFrame:SetPoint('TOPLEFT', 10, -100)
    infoFrame.scrollFrame = scrollFrame

    local scrollBar = CreateFrame('Slider', '$parentScrollBar', scrollFrame, 'HybridScrollBarTemplate')
    scrollBar.doNotHide = true
    F.ReskinScroll(scrollBar)
    scrollFrame.scrollBar = scrollBar

    local scrollChild = scrollFrame.scrollChild
    local numButtons = 16 + 1
    local buttonHeight = 22
    local buttons = {}
    for i = 1, numButtons do
        buttons[i] = INFOBAR:GuildPanel_CreateButton(scrollChild, i)
    end

    scrollFrame.buttons = buttons
    scrollFrame.buttonHeight = buttonHeight
    scrollFrame.update = INFOBAR.GuildPanel_Update
    scrollFrame:SetScript('OnMouseWheel', INFOBAR.GuildPanel_OnMouseWheel)
    scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
    scrollFrame:SetVerticalScroll(0)
    scrollFrame:UpdateScrollChildRect()
    scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
    scrollBar:SetValue(0)
end

F:Delay(5, function()
    if IsInGuild() then
        C_GuildInfo.GuildRoster()
    end
end)

function INFOBAR:GuildPanel_Refresh()
    local thisTime = GetTime()
    if not prevTime or (thisTime - prevTime > 5) then
        C_GuildInfo.GuildRoster()
        prevTime = thisTime
    end

    wipe(guildTable)
    local count = 0
    local total, _, online = GetNumGuildMembers()
    local guildName, guildRank = GetGuildInfo('player')

    gName:SetText(F:RgbToHex({ 0.9, 0.8, 0.6 }) .. '<' .. (guildName or '') .. '>')
    gOnline:SetText(format(C.INFO_COLOR .. '%s:' .. ' %d/%d', GUILD_ONLINE_LABEL, online, total))
    gRank:SetText(C.INFO_COLOR .. RANK .. ': ' .. (guildRank or ''))

    for i = 1, total do
        local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile, _, _, guid = GetGuildRosterInfo(
        i)
        if connected or mobile then
            if mobile and not connected then
                zone = REMOTE_CHAT
                if status == 1 then
                    status = '|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t'
                elseif status == 2 then
                    status = '|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t'
                else
                    status = ChatFrame_GetMobileEmbeddedTexture(73 / 255, 177 / 255, 73 / 255)
                end
            else
                if status == 1 then
                    status = '|T' .. FRIENDS_TEXTURE_AFK .. ':14:14:0:0:16:16:1:15:1:15|t'
                elseif status == 2 then
                    status = '|T' .. FRIENDS_TEXTURE_DND .. ':14:14:0:0:16:16:1:15:1:15|t'
                else
                    status = ' '
                end
            end

            if not zone then
                zone = UNKNOWN
            end

            count = count + 1

            if not guildTable[count] then
                guildTable[count] = {}
            end

            guildTable[count][1] = level
            guildTable[count][2] = class
            guildTable[count][3] = Ambiguate(name, 'none')
            guildTable[count][4] = zone
            guildTable[count][5] = status
            guildTable[count][6] = guid
        end
    end

    infoFrame.numMembers = count
end

local function delayLeave()
    if MouseIsOver(infoFrame) then
        return
    end
    infoFrame:Hide()
end

local function Block_OnMouseUp(self)
    if not IsInGuild() then
        return
    end

    infoFrame:Hide()

    if not CommunitiesFrame then
        C_AddOns.LoadAddOn('Blizzard_Communities')
    end

    if CommunitiesFrame then
        ToggleFrame(CommunitiesFrame)
    end
end

local function Block_OnEvent(self, event, arg1)
    if not IsInGuild() then
        self.text:SetText(GUILD .. ': ' .. C.MY_CLASS_COLOR .. NONE)
        return
    end

    if event == 'GUILD_ROSTER_UPDATE' then
        if arg1 then
            C_GuildInfo.GuildRoster()
        end
    end

    local online = select(3, GetNumGuildMembers())
    self.text:SetText(GUILD .. ': ' .. C.MY_CLASS_COLOR .. online)

    if infoFrame and infoFrame:IsShown() then
        INFOBAR:GuildPanel_Refresh()
        INFOBAR:GuildPanel_SortUpdate()
    end
end

local function Block_OnEnter(self)
    if not IsInGuild() then
        return
    end

    local friendsFrame = _G[C.ADDON_TITLE .. 'InfoBarFriendsFrame']
    if friendsFrame and friendsFrame:IsShown() then
        friendsFrame:Hide()
    end

    INFOBAR:GuildPanel_Init()
    INFOBAR:GuildPanel_Refresh()
    INFOBAR:GuildPanel_SortUpdate()
end

local function Block_OnLeave(self)
    if not infoFrame then
        return
    end
    F:Delay(0.1, delayLeave)
end

function INFOBAR:CreateGuildBlock()
    if not C.DB.Infobar.Guild then
        return
    end

    newBlock = INFOBAR:RegisterNewBlock('guild', 'RIGHT', 150)
    newBlock.onEvent = Block_OnEvent
    newBlock.onEnter = Block_OnEnter
    newBlock.onLeave = Block_OnLeave
    newBlock.onMouseUp = Block_OnMouseUp
    newBlock.eventList = {
        'PLAYER_ENTERING_WORLD',
        'GUILD_ROSTER_UPDATE',
        'PLAYER_GUILD_UPDATE',
    }

    INFOBAR.GuildBlock = newBlock
end
