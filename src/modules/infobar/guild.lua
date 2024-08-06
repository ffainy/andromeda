local F, C, L = unpack(select(2, ...))
local INFOBAR = F:GetModule('InfoBar')

INFOBAR.GuildTable = {}

local infoFrame, gName, gOnline, gRank, prevTime

local function rosterButtonOnClick(self, btn)
    local name = INFOBAR.GuildTable[self.index][3]
    if btn == 'LeftButton' then
        if IsAltKeyDown() then
            C_PartyInfo.InviteUnit(name)
        elseif IsShiftKeyDown() then
            if _G.MailFrame:IsShown() then
                _G.MailFrameTab_OnClick(nil, 2)
                _G.SendMailNameEditBox:SetText(name)
                _G.SendMailNameEditBox:HighlightText()
            else
                local editBox = _G.ChatEdit_ChooseBoxForSend()
                local hasText = (editBox:GetText() ~= '')
                _G.ChatEdit_ActivateChat(editBox)
                editBox:Insert(name)
                if not hasText then
                    editBox:HighlightText()
                end
            end
        end
    else
        _G.ChatFrame_OpenChat('/w ' .. name .. ' ', _G.SELECTED_DOCK_FRAME)
    end
end

function INFOBAR:GuildPanel_CreateButton(parent, index)
    local button = CreateFrame('Button', nil, parent)
    button:SetSize(305, 20)
    button:SetPoint('TOPLEFT', 0, -(index - 1) * 20)
    button.HL = button:CreateTexture(nil, 'HIGHLIGHT')
    button.HL:SetAllPoints()
    button.HL:SetColorTexture(C.r, C.g, C.b, 0.2)

    local outline = _G.ANDROMEDA_ADB.FontOutline
    button.level =
        F.CreateFS(button, C.Assets.Fonts.Regular, 13, outline or nil, 'Level', nil, outline and 'NONE' or 'THICK')
    button.level:SetPoint('TOP', button, 'TOPLEFT', 16, -4)
    button.class = button:CreateTexture(nil, 'ARTWORK')
    button.class:SetPoint('LEFT', 40, 0)
    button.class:SetSize(16, 16)
    button.class:SetTexture('Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES')
    button.name = F.CreateFS(
        button,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        'Name',
        nil,
        outline and 'NONE' or 'THICK',
        'LEFT',
        70,
        0
    )
    button.name:SetPoint('RIGHT', button, 'LEFT', 185, 0)
    button.name:SetJustifyH('LEFT')
    button.zone = F.CreateFS(
        button,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        'Zone',
        nil,
        outline and 'NONE' or 'THICK',
        'RIGHT',
        -2,
        0
    )
    button.zone:SetPoint('LEFT', button, 'RIGHT', -120, 0)
    button.zone:SetJustifyH('RIGHT')
    button.zone:SetWordWrap(false)

    button:RegisterForClicks('AnyUp')
    button:SetScript('OnClick', rosterButtonOnClick)

    return button
end

function INFOBAR:GuildPanel_UpdateButton(button)
    local index = button.index
    local level, class, name, zone, status, guid = unpack(INFOBAR.guildTable[index])

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
    local scrollFrame = _G[C.ADDON_TITLE .. 'GuildInfobarScrollFrame']
    local usedHeight = 0
    local buttons = scrollFrame.buttons
    local height = scrollFrame.buttonHeight
    local numMemberButtons = infoFrame.numMembers
    local offset = _G.HybridScrollFrame_GetOffset(scrollFrame)

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

    _G.HybridScrollFrame_Update(scrollFrame, numMemberButtons * height, usedHeight)
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
        if _G.ANDROMEDA_ADB['GuildSortOrder'] then
            return a[_G.ANDROMEDA_ADB['GuildSortBy']] < b[_G.ANDROMEDA_ADB['GuildSortBy']]
        else
            return a[_G.ANDROMEDA_ADB['GuildSortBy']] > b[_G.ANDROMEDA_ADB['GuildSortBy']]
        end
    end
end

function INFOBAR:GuildPanel_SortUpdate()
    sort(INFOBAR.GuildTable, sortRosters)
    INFOBAR:GuildPanel_Update()
end

local function sortHeaderOnClick(self)
    _G.ANDROMEDA_ADB['GuildSortBy'] = self.index
    _G.ANDROMEDA_ADB['GuildSortOrder'] = not _G.ANDROMEDA_ADB['GuildSortOrder']
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

    infoFrame = CreateFrame('Frame', C.ADDON_TITLE .. 'GuildInfobar', INFOBAR.Bar)
    infoFrame:SetSize(335, 495)
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

    local outline = _G.ANDROMEDA_ADB.FontOutline
    gName = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Bold,
        16,
        outline or nil,
        'Guild',
        nil,
        outline and 'NONE' or 'THICK',
        'TOPLEFT',
        15,
        -10
    )
    gOnline = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        'Online',
        nil,
        outline and 'NONE' or 'THICK',
        'TOPLEFT',
        15,
        -35
    )
    -- gApps = F.CreateFS(infoFrame, C.Assets.Fonts.Regular, 13, outline or nil, 'Applications', nil, outline and 'NONE' or 'THICK', 'TOPRIGHT', -15, -35)
    gRank = F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        'Rank',
        nil,
        outline and 'NONE' or 'THICK',
        'TOPLEFT',
        15,
        -51
    )

    local bu = {}
    local width = { 30, 35, 126, 126 }
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
    F.CreateFS(bu[1], C.Assets.Fonts.Regular, 13, outline or nil, _G.LEVEL, nil, outline and 'NONE' or 'THICK')
    F.CreateFS(bu[2], C.Assets.Fonts.Regular, 13, outline or nil, _G.CLASS, nil, outline and 'NONE' or 'THICK')
    F.CreateFS(
        bu[3],
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        _G.NAME,
        nil,
        outline and 'NONE' or 'THICK',
        'LEFT',
        5,
        0
    )
    F.CreateFS(
        bu[4],
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        _G.ZONE,
        nil,
        outline and 'NONE' or 'THICK',
        'RIGHT',
        -5,
        0
    )

    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        C.LINE_STRING,
        nil,
        outline and 'NONE' or 'THICK',
        'BOTTOMRIGHT',
        -12,
        58
    )
    local whspInfo = C.INFO_COLOR .. C.MOUSE_RIGHT_BUTTON .. L['Whisper']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        whspInfo,
        nil,
        outline and 'NONE' or 'THICK',
        'BOTTOMRIGHT',
        -15,
        42
    )
    local invtInfo = C.INFO_COLOR .. 'ALT +' .. C.MOUSE_LEFT_BUTTON .. L['Invite']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        invtInfo,
        nil,
        outline and 'NONE' or 'THICK',
        'BOTTOMRIGHT',
        -15,
        26
    )
    local copyInfo = C.INFO_COLOR .. 'SHIFT +' .. C.MOUSE_LEFT_BUTTON .. L['Copy Name']
    F.CreateFS(
        infoFrame,
        C.Assets.Fonts.Regular,
        13,
        outline or nil,
        copyInfo,
        nil,
        outline and 'NONE' or 'THICK',
        'BOTTOMRIGHT',
        -15,
        10
    )

    local scrollFrame =
        CreateFrame('ScrollFrame', C.ADDON_TITLE .. 'GuildInfobarScrollFrame', infoFrame, 'HybridScrollFrameTemplate')
    scrollFrame:SetSize(305, 320)
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

    wipe(INFOBAR.GuildTable)
    local count = 0
    local total, _, online = GetNumGuildMembers()
    local guildName, guildRank = GetGuildInfo('player')

    gName:SetText(F:RgbToHex({ 0.9, 0.8, 0.6 }) .. '<' .. (guildName or '') .. '>')
    gOnline:SetText(format(C.INFO_COLOR .. '%s:' .. ' %d/%d', _G.GUILD_ONLINE_LABEL, online, total))
    -- gApps:SetText(format(C.INFO_COLOR .. _G.GUILDINFOTAB_APPLICANTS, GetNumGuildApplicants()))
    gRank:SetText(C.INFO_COLOR .. _G.RANK .. ': ' .. (guildRank or ''))

    for i = 1, total do
        local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile, _, _, guid =
            GetGuildRosterInfo(i)
        if connected or mobile then
            if mobile and not connected then
                zone = _G.REMOTE_CHAT
                if status == 1 then
                    status = '|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t'
                elseif status == 2 then
                    status = '|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t'
                else
                    status = _G.ChatFrame_GetMobileEmbeddedTexture(73 / 255, 177 / 255, 73 / 255)
                end
            else
                if status == 1 then
                    status = '|T' .. _G.FRIENDS_TEXTURE_AFK .. ':14:14:0:0:16:16:1:15:1:15|t'
                elseif status == 2 then
                    status = '|T' .. _G.FRIENDS_TEXTURE_DND .. ':14:14:0:0:16:16:1:15:1:15|t'
                else
                    status = ' '
                end
            end
            if not zone then
                zone = _G.UNKNOWN
            end

            count = count + 1

            if not INFOBAR.GuildTable[count] then
                INFOBAR.GuildTable[count] = {}
            end
            INFOBAR.GuildTable[count][1] = level
            INFOBAR.GuildTable[count][2] = class
            INFOBAR.GuildTable[count][3] = Ambiguate(name, 'none')
            INFOBAR.GuildTable[count][4] = zone
            INFOBAR.GuildTable[count][5] = status
            INFOBAR.guildTable[count][6] = guid
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

    if not _G.CommunitiesFrame then
        C_AddOns.LoadAddOn('Blizzard_Communities')
    end

    if _G.CommunitiesFrame then
        ToggleFrame(_G.CommunitiesFrame)
    end
end

local function Block_OnEvent(self, event, arg1)
    if not IsInGuild() then
        self.text:SetText(_G.GUILD .. ': ' .. C.MY_CLASS_COLOR .. _G.NONE)
        return
    end

    if event == 'GUILD_ROSTER_UPDATE' then
        if arg1 then
            C_GuildInfo.GuildRoster()
        end
    end

    local online = select(3, GetNumGuildMembers())
    self.text:SetText(_G.GUILD .. ': ' .. C.MY_CLASS_COLOR .. online)

    if infoFrame and infoFrame:IsShown() then
        INFOBAR:GuildPanel_Refresh()
        INFOBAR:GuildPanel_SortUpdate()
    end
end

local function Block_OnEnter(self)
    if not IsInGuild() then
        return
    end
    if _G[C.ADDON_TITLE .. 'FriendsFrame'] and _G[C.ADDON_TITLE .. 'FriendsFrame']:IsShown() then
        _G[C.ADDON_TITLE .. 'FriendsFrame']:Hide()
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

    local guild = INFOBAR:RegisterNewBlock('guild', 'RIGHT', 150)
    guild.onEvent = Block_OnEvent
    guild.onEnter = Block_OnEnter
    guild.onLeave = Block_OnLeave
    guild.onMouseUp = Block_OnMouseUp
    guild.eventList = { 'PLAYER_ENTERING_WORLD', 'GUILD_ROSTER_UPDATE', 'PLAYER_GUILD_UPDATE' }

    INFOBAR.GuildBlock = guild
end
