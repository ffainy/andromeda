local F, C, L = unpack(select(2, ...))
local CHAT = F:GetModule('Chat')

local function updateAnchor(self, _, _, _, x, y)
    if not C.DB.Chat.Lock then
        return
    end

    if InCombatLockdown() then
        return
    end

    if not (x == C.UI_GAP and y == C.UI_GAP) then
        self:ClearAllPoints()
        self:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', C.UI_GAP, C.UI_GAP)
        self:SetWidth(C.DB.Chat.Width)
        self:SetHeight(C.DB.Chat.Height)
    end
end

local isScaling = false
function CHAT:UpdateSizeAndPosition()
    if not C.DB.Chat.Lock then
        return
    end

    if isScaling then
        return
    end
    isScaling = true

    if ChatFrame1:IsMovable() then
        ChatFrame1:SetUserPlaced(true)
    end

    if ChatFrame1.FontStringContainer then
        ChatFrame1.FontStringContainer:SetOutside(ChatFrame1)
    end

    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', C.UI_GAP, C.UI_GAP)
    ChatFrame1:SetSize(C.DB.Chat.Width, C.DB.Chat.Height)

    isScaling = false
end

function CHAT:SetupSizeAndPosition()
    if C.DB.Chat.Lock then
        CHAT:UpdateSizeAndPosition()
        F:RegisterEvent('UI_SCALE_CHANGED', CHAT.UpdateSizeAndPosition)
        hooksecurefunc(ChatFrame1, 'SetPoint', updateAnchor)
        FCF_SavePositionAndDimensions(ChatFrame1)
    end
end

function CHAT:TabSetAlpha(alpha)
    if self.glow:IsShown() and alpha ~= 1 then
        self:SetAlpha(1)
    end
end

function CHAT:UpdateTabColors(selected)
    if selected then
        self.Text:SetTextColor(1, 0.8, 0)
        self.whisperIndex = 0
    else
        self.Text:SetTextColor(0.5, 0.5, 0.5)
    end

    if self.whisperIndex == 1 then
        self.glow:SetVertexColor(1, 0.5, 1)
    elseif self.whisperIndex == 2 then
        self.glow:SetVertexColor(0, 1, 0.96)
    else
        self.glow:SetVertexColor(1, 0.8, 0)
    end
end

function CHAT:UpdateTabEventColors(event)
    local tab = _G[self:GetName() .. 'Tab']
    local selected = GeneralDockManager.selected:GetID() == tab:GetID()
    if event == 'CHAT_MSG_WHISPER' then
        tab.whisperIndex = 1
        CHAT.UpdateTabColors(tab, selected)
    elseif event == 'CHAT_MSG_BN_WHISPER' then
        tab.whisperIndex = 2
        CHAT.UpdateTabColors(tab, selected)
    end
end

local function updateEditboxFont(editbox)
    local font = C.Assets.Fonts.Bold
    local outline = ANDROMEDA_ADB.FontOutline
    local fontSize = C.DB.Chat.EditboxFontSize

    editbox:SetFont(font, fontSize or 14, outline and 'OUTLINE' or '')
    editbox.header:SetFont(font, fontSize or 14, outline and 'OUTLINE' or '')
end

local chatEditboxes = {}
local function updateEditBoxAnchor(eb)
    local parent = eb.__owner
    eb:ClearAllPoints()
    if C.DB.Chat.BottomEditBox then
        eb:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', 4, -10)
        eb:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -15, -34)
    else
        eb:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 4, 26)
        eb:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -15, 50)
    end
end

function CHAT:ToggleEditBoxAnchor()
    for _, eb in pairs(chatEditboxes) do
        updateEditboxFont(eb)
        updateEditBoxAnchor(eb)
    end
end

local function updateTextFading(self)
    self:SetFading(C.DB.Chat.TextFading)
    self:SetTimeVisible(C.DB.Chat.TimeVisible)
    self:SetFadeDuration(C.DB.Chat.FadeDuration)
end

function CHAT:UpdateTextFading()
    for i = 1, NUM_CHAT_WINDOWS do
        updateTextFading(_G['ChatFrame' .. i])
    end
end

local function updateBackground(frame)
    if C.DB.Chat.BackgroundType == 1 then
        if frame.bg then
            frame.bg:Hide()
        end
        frame:DisableDrawLayer('BORDER')
        frame:DisableDrawLayer('BACKGROUND')
    elseif C.DB.Chat.BackgroundType == 2 then
        if frame.bg then
            frame.bg:Hide()
        end
        frame:EnableDrawLayer('BORDER')
        frame:EnableDrawLayer('BACKGROUND')
    elseif C.DB.Chat.BackgroundType == 3 then
        frame:DisableDrawLayer('BORDER')
        frame:DisableDrawLayer('BACKGROUND')
        if frame.bg then
            frame.bg:Show()
        else
            frame.bg = F.SetBD(frame, C.DB.Chat.BackgroundAlpha)
        end
    end
end

function CHAT:SetupBackground()
    for _, chatFrameName in ipairs(CHAT_FRAMES) do
        local frame = _G[chatFrameName]
        updateBackground(frame)
        if frame.bg then
            frame.bg:SetBackdropColor(0, 0, 0, C.DB.Chat.BackgroundAlpha)
            frame.bg:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end
end

local function setupChatFrame(frame)
    if not frame or frame.styled then
        return
    end

    local name = frame:GetName()
    local maxLines = 1024

    local font = C.Assets.Fonts.Bold
    local outline = ANDROMEDA_ADB.FontOutline
    local fontSize = select(2, frame:GetFont())
    frame:SetFont(font, fontSize, outline and 'OUTLINE' or '')
    frame:SetShadowColor(0, 0, 0, outline and 0 or 1)
    frame:SetShadowOffset(2, -2)

    if frame:GetMaxLines() < maxLines then
        frame:SetMaxLines(maxLines)
    end

    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetClampedToScreen(false)

    local eb = _G[name .. 'EditBox']
    eb:SetAltArrowKeyMode(false)
    eb:SetClampedToScreen(true)
    eb.__owner = frame
    updateEditBoxAnchor(eb)
    updateEditboxFont(eb)
    eb.bd = F.SetBD(eb)
    tinsert(chatEditboxes, eb)

    for i = 3, 8 do
        select(i, eb:GetRegions()):SetAlpha(0)
    end

    local lang = _G[name .. 'EditBoxLanguage']
    lang:GetRegions():SetAlpha(0)
    lang:SetPoint('TOPLEFT', eb, 'TOPRIGHT', 5, 0)
    lang:SetPoint('BOTTOMRIGHT', eb, 'BOTTOMRIGHT', 29, 0)
    lang.bd = F.SetBD(lang)

    local tab = _G[name .. 'Tab']
    tab:SetAlpha(1)
    tab.Text:SetFont(C.Assets.Fonts.Bold, 12, C.DB.Chat.FontOutline and 'OUTLINE' or '')
    tab.Text:SetShadowColor(0, 0, 0, C.DB.Chat.FontOutline and 0 or 1)
    tab.Text:SetShadowOffset(2, -2)
    F.StripTextures(tab, 7)
    hooksecurefunc(tab, 'SetAlpha', CHAT.TabSetAlpha)

    if CHAT_OPTIONS then
        CHAT_OPTIONS.HIDE_FRAME_ALERTS = true
    end                              -- only flash whisper
    SetCVar('chatStyle', 'classic')  -- #TODO: hide chatStyle option
    SetCVar('chatMouseScroll', 1)    -- enable mousescroll
    SetCVar('whisperMode', 'inline') -- blizz reset this on NPE
    CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)

    CHAT:UpdateTextFading()
    CHAT:SetupSizeAndPosition()

    F.HideObject(frame.buttonFrame)
    F.HideObject(ChatFrameMenuButton)
    F.HideObject(QuickJoinToastButton)

    if C.DB.Chat.VoiceButton then
        ChatFrameChannelButton:ClearAllPoints()
        ChatFrameChannelButton:SetPoint('TOPRIGHT', ChatFrame1, 'TOPLEFT', -6, -26)
        ChatFrameChannelButton:SetParent(UIParent)
        CHAT.VoiceButton = ChatFrameChannelButton
    else
        F.HideObject(ChatFrameChannelButton)
        F.HideObject(ChatFrameToggleVoiceDeafenButton)
        F.HideObject(ChatFrameToggleVoiceMuteButton)
    end

    frame.oldAlpha = frame.oldAlpha or 0 -- fix blizz error

    frame:HookScript('OnMouseWheel', CHAT.OnMouseScroll)

    frame.styled = true
end

function CHAT:SetupToastFrame()
    BNToastFrame:SetClampedToScreen(true)
    BNToastFrame:SetClampRectInsets(-C.UI_GAP, C.UI_GAP, C.UI_GAP, -C.UI_GAP)

    VoiceChatPromptActivateChannel:SetClampedToScreen(true)
    VoiceChatPromptActivateChannel:SetClampRectInsets(-C.UI_GAP, C.UI_GAP, C.UI_GAP, -C.UI_GAP)

    VoiceChatChannelActivatedNotification:SetClampedToScreen(true)
    VoiceChatChannelActivatedNotification:SetClampRectInsets(-C.UI_GAP, C.UI_GAP, C.UI_GAP, -C.UI_GAP)

    ChatAlertFrame:SetClampedToScreen(true)
    ChatAlertFrame:SetClampRectInsets(-C.UI_GAP, C.UI_GAP, C.UI_GAP, -C.UI_GAP)
end

function CHAT:SetupChatFrame()
    for i = 1, NUM_CHAT_WINDOWS do
        setupChatFrame(_G['ChatFrame' .. i])
    end
end

local function setupTemporaryWindow()
    for _, chatFrameName in ipairs(CHAT_FRAMES) do
        local frame = _G[chatFrameName]
        if frame.isTemporary then
            CHAT.SetupChatFrame(frame)
        end
    end
end

function CHAT:SetupTemporaryWindow()
    hooksecurefunc('FCF_OpenTemporaryWindow', setupTemporaryWindow)
end

function CHAT:UpdateEditBoxBorderColor()
    hooksecurefunc('ChatEdit_UpdateHeader', function()
        local editBox = ChatEdit_ChooseBoxForSend()
        local mType = editBox:GetAttribute('chatType')
        if mType == 'CHANNEL' then
            local id = GetChannelName(editBox:GetAttribute('channelTarget'))
            if id == 0 then
                editBox.bd:SetBackdropBorderColor(0, 0, 0)
            else
                editBox.bd:SetBackdropBorderColor(
                    ChatTypeInfo[mType .. id].r,
                    ChatTypeInfo[mType .. id].g,
                    ChatTypeInfo[mType .. id].b
                )
            end
        elseif mType == 'SAY' then
            editBox.bd:SetBackdropBorderColor(0, 0, 0)
        else
            editBox.bd:SetBackdropBorderColor(
                ChatTypeInfo[mType].r,
                ChatTypeInfo[mType].g,
                ChatTypeInfo[mType].b
            )
        end
    end)
end

-- Swith channels by Tab
local cycles = {
    {
        chatType = 'SAY',
        IsActive = function()
            return true
        end,
    },
    {
        chatType = 'PARTY',
        IsActive = function()
            return IsInGroup()
        end,
    },
    {
        chatType = 'RAID',
        IsActive = function()
            return IsInRaid()
        end,
    },
    {
        chatType = 'INSTANCE_CHAT',
        IsActive = function()
            return IsPartyLFG() or C_PartyInfo.IsPartyWalkIn()
        end,
    },
    {
        chatType = 'GUILD',
        IsActive = function()
            return IsInGuild()
        end,
    },
    {
        chatType = 'OFFICER',
        IsActive = function()
            return C_GuildInfo.IsGuildOfficer()
        end,
    },
    {
        chatType = 'CHANNEL',
        IsActive = function(_, editbox)
            if CHAT.InWorldChannel and CHAT.WorldChannelID then
                editbox:SetAttribute('channelTarget', CHAT.WorldChannelID)
                return true
            end
        end,
    },
    {
        chatType = 'SAY',
        IsActive = function()
            return true
        end,
    },
}

function CHAT:SwitchToChannel(chatType)
    self:SetAttribute('chatType', chatType)
    ChatEdit_UpdateHeader(self)
end

function CHAT:UpdateTabChannelSwitch()
    if strsub(self:GetText(), 1, 1) == '/' then
        return
    end

    local isShiftKeyDown = IsShiftKeyDown()
    local currentType = self:GetAttribute('chatType')
    if isShiftKeyDown and (currentType == 'WHISPER' or currentType == 'BN_WHISPER') then
        CHAT.SwitchToChannel(self, 'SAY')
        return
    end

    local numCycles = #cycles
    for i = 1, numCycles do
        local cycle = cycles[i]
        if currentType == cycle.chatType then
            local from, to, step = i + 1, numCycles, 1
            if isShiftKeyDown then
                from, to, step = i - 1, 1, -1
            end
            for j = from, to, step do
                local nextCycle = cycles[j]
                if nextCycle:IsActive(self) then
                    CHAT.SwitchToChannel(self, nextCycle.chatType)
                    return
                end
            end
        end
    end
end

-- Quick scroll
local chatScrollTip = {
    text = L['Scroll multi-lines by holding CTRL key, and scroll to top or bottom by holding SHIFT key.'],
    buttonStyle = HelpTip.ButtonStyle.GotIt,
    targetPoint = HelpTip.Point.RightEdgeCenter,
    onAcknowledgeCallback = F.HelpInfoAcknowledge,
    callbackArg = 'ChatScroll',
}
function CHAT:OnMouseScroll(dir)
    if not ANDROMEDA_ADB.HelpTips.ChatScroll then
        HelpTip:Show(ChatFrame1, chatScrollTip)
    end

    if dir > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        elseif IsControlKeyDown() then
            self:ScrollUp()
            self:ScrollUp()
        end
    else
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        elseif IsControlKeyDown() then
            self:ScrollDown()
            self:ScrollDown()
        end
    end
end

-- Smart bubble
local function updateChatBubble()
    local name, instType = GetInstanceInfo()
    if
        name
        and (
            instType == 'raid'
            or instType == 'party'
            or instType == 'scenario'
            or instType == 'pvp'
            or instType == 'arena'
        )
    then
        SetCVar('chatBubbles', 1)
    else
        SetCVar('chatBubbles', 0)
    end
end

function CHAT:AutoToggleChatBubble()
    if not C.DB.Chat.SmartChatBubble then
        return
    end

    F:RegisterEvent('PLAYER_ENTERING_WORLD', updateChatBubble)
end

-- Auto invite by whisper
local whisperList = {}
function CHAT:UpdateWhisperList()
    F:SplitList(whisperList, C.DB.Chat.InviteKeyword, true)
end

function CHAT:IsUnitInGuild(unitName)
    if not unitName then
        return
    end
    for i = 1, GetNumGuildMembers() do
        local name = GetGuildRosterInfo(i)
        if name and Ambiguate(name, 'none') == Ambiguate(unitName, 'none') then
            return true
        end
    end

    return false
end

function CHAT.OnChatWhisper(event, ...)
    local msg, author, _, _, _, _, _, _, _, _, _, guid, presenceID = ...
    for word in pairs(whisperList) do
        if
            (not IsInGroup() or UnitIsGroupLeader('player') or UnitIsGroupAssistant('player'))
            and strlower(msg) == strlower(word)
        then
            if event == 'CHAT_MSG_BN_WHISPER' then
                local accountInfo = C_BattleNet.GetAccountInfoByID(presenceID)
                if accountInfo then
                    local gameAccountInfo = accountInfo.gameAccountInfo
                    local gameID = gameAccountInfo.gameAccountID
                    if gameID then
                        local charName = gameAccountInfo.characterName
                        local realmName = gameAccountInfo.realmName
                        if
                            CanCooperateWithGameAccount(accountInfo)
                            and (not C.DB.Chat.GuildOnly or CHAT:IsUnitInGuild(charName .. '-' .. realmName))
                        then
                            BNInviteFriend(gameID)
                        end
                    end
                end
            else
                if not C.DB.Chat.GuildOnly or IsGuildMember(guid) then
                    C_PartyInfo.InviteUnit(author)
                end
            end
        end
    end
end

function CHAT:WhisperInvite()
    if not C.DB.Chat.WhisperInvite then
        return
    end
    self:UpdateWhisperList()
    F:RegisterEvent('CHAT_MSG_WHISPER', CHAT.OnChatWhisper)
    F:RegisterEvent('CHAT_MSG_BN_WHISPER', CHAT.OnChatWhisper)
end

-- Whisper sound
CHAT.MuteCache = {}
local whisperEvents = {
    ['CHAT_MSG_WHISPER'] = true,
    ['CHAT_MSG_BN_WHISPER'] = true,
}
function CHAT:PlayWhisperSound(event, _, author)
    if not C.DB.Chat.WhisperSound then
        return
    end

    if whisperEvents[event] then
        local name = Ambiguate(author, 'none')
        local currentTime = GetTime()

        if CHAT.MuteCache[name] == currentTime then
            return
        end

        if not self.soundTimer or currentTime > self.soundTimer then
            if event == 'CHAT_MSG_WHISPER' then
                PlaySoundFile(C.Assets.Sounds.Whisper, 'Master')
            elseif event == 'CHAT_MSG_BN_WHISPER' then
                PlaySoundFile(C.Assets.Sounds.WhisperBattleNet, 'Master')
            end
        end

        self.soundTimer = currentTime + C.DB.Chat.SoundThreshold
    end
end

-- Whisper sticky
function CHAT:WhisperSticky()
    if C.DB.Chat.WhisperSticky then
        ChatTypeInfo['WHISPER'].sticky = 1
        ChatTypeInfo['BN_WHISPER'].sticky = 1
    else
        ChatTypeInfo['WHISPER'].sticky = 0
        ChatTypeInfo['BN_WHISPER'].sticky = 0
    end
end

-- Alt+Click to Invite player
function CHAT:AltClickToInvite(link)
    if IsAltKeyDown() then
        local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
        local player = link:match('^player:([^:]+)')
        local bplayer = link:match('^BNplayer:([^:]+)')
        if player then
            C_PartyInfo.InviteUnit(player)
        elseif bplayer then
            local _, value = strmatch(link, '(%a+):(.+)')
            local _, bnID = strmatch(value, '([^:]*):([^:]*):')
            if not bnID then
                return
            end
            local accountInfo = C_BattleNet.GetAccountInfoByID(bnID)
            if
                accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW
                and CanCooperateWithGameAccount(accountInfo)
            then
                BNInviteFriend(accountInfo.gameAccountInfo.gameAccountID)
            end
        end
        ChatEdit_OnEscapePressed(ChatFrameEditBox) -- Secure hook opens whisper, so closing it.
    end
end

-- (、) -> (/)
function CHAT:PauseToSlash()
    hooksecurefunc('ChatEdit_OnTextChanged', function(self, userInput)
        local text = self:GetText()
        if userInput then
            if text == '、' then
                self:SetText('/')
            end
        end
    end)
end

-- Save slash command typo
local function postHook(chat, text)
    if text and strfind(text, HELP_TEXT_SIMPLE) then
        ChatEdit_AddHistory(chat.editBox)
    end
end

function CHAT:SaveSlashCommandTypo()
    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            hooksecurefunc(_G['ChatFrame' .. i], 'AddMessage', postHook)
        end
    end
end

-- Show role icon in chat
local msgEvents = {
    CHAT_MSG_SAY = 1,
    CHAT_MSG_YELL = 1,
    CHAT_MSG_WHISPER = 1,
    CHAT_MSG_WHISPER_INFORM = 1,
    CHAT_MSG_PARTY = 1,
    CHAT_MSG_PARTY_LEADER = 1,
    CHAT_MSG_INSTANCE_CHAT = 1,
    CHAT_MSG_INSTANCE_CHAT_LEADER = 1,
    CHAT_MSG_RAID = 1,
    CHAT_MSG_RAID_LEADER = 1,
    CHAT_MSG_RAID_WARNING = 1,
}

local roleIcons = {
    TANK = F:TextureString(C.Assets.Textures.RoleTank, ':14:14'),
    HEALER = F:TextureString(C.Assets.Textures.RoleHealer, ':14:14'),
    DAMAGER = F:TextureString(C.Assets.Textures.RoleDamager, ':14:14'),
}

local GetColoredName_orig = GetColoredName
local function getColoredName(event, arg1, arg2, ...)
    local ret = GetColoredName_orig(event, arg1, arg2, ...)

    if msgEvents[event] then
        local role = UnitGroupRolesAssigned(arg2)

        if role == 'NONE' and arg2:match(' *- *' .. GetRealmName() .. '$') then
            role = UnitGroupRolesAssigned(arg2:gsub(' *-[^-]+$', ''))
        end

        if role and role ~= 'NONE' then
            ret = roleIcons[role] .. '' .. ret
        end
    end

    return ret
end

function CHAT:AddRoleIcon()
    if not C.DB.Chat.GroupRoleIcon then
        return
    end

    GetColoredName = getColoredName
end

-- Disable pet battle tab
local old = FCFManager_GetNumDedicatedFrames
function FCFManager_GetNumDedicatedFrames(...)
    return select(1, ...) ~= 'PET_BATTLE_COMBAT_LOG' and old(...) or 1
end

-- Disable profanity filter
local sideEffectFixed
local function fixLanguageFilterSideEffects()
    if sideEffectFixed then
        return
    end
    sideEffectFixed = true

    local outline = ANDROMEDA_ADB.FontOutline
    F.CreateFS(
        HelpFrame,
        C.Assets.Fonts.Bold, 14, outline or nil,
        L['You need to uncheck language filter in GUI and reload UI to get access into CN BattleNet support.'],
        'YELLOW', outline and 'NONE' or 'THICK',
        { 'TOP', 0, 30 }
    )

    local OLD_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
    function C_BattleNet.GetFriendGameAccountInfo(...)
        local gameAccountInfo = OLD_GetFriendGameAccountInfo(...)
        if gameAccountInfo then
            gameAccountInfo.isInCurrentRegion = true
        end
        return gameAccountInfo
    end

    local OLD_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
    function C_BattleNet.GetFriendAccountInfo(...)
        local accountInfo = OLD_GetFriendAccountInfo(...)
        if accountInfo and accountInfo.gameAccountInfo then
            accountInfo.gameAccountInfo.isInCurrentRegion = true
        end
        return accountInfo
    end
end

function CHAT:UpdateLanguageFilter()
    if C.DB.Chat.DisableProfanityFilter then
        if GetCVar('portal') == 'CN' then
            ConsoleExec('portal TW')
            fixLanguageFilterSideEffects()
        end
        SetCVar('profanityFilter', 0)
    else
        if sideEffectFixed then
            ConsoleExec('portal CN')
        end
        SetCVar('profanityFilter', 1)
    end
end

function CHAT:OnLogin()
    if not C.DB.Chat.Enable then
        return
    end

    hooksecurefunc('FCFTab_UpdateColors', CHAT.UpdateTabColors)
    hooksecurefunc('FloatingChatFrame_OnEvent', CHAT.UpdateTabEventColors)
    hooksecurefunc('ChatFrame_MessageEventHandler', CHAT.PlayWhisperSound)
    hooksecurefunc('ChatEdit_CustomTabPressed', CHAT.UpdateTabChannelSwitch)
    hooksecurefunc('SetItemRef', CHAT.AltClickToInvite)

    CHAT:SetupChatFrame()
    CHAT:SetupBackground()
    CHAT:SetupToastFrame()
    CHAT:SetupTemporaryWindow()
    CHAT:UpdateEditBoxBorderColor()
    CHAT:ChatFilter()
    CHAT:ShortenChannelNames()
    CHAT:ChatCopy()
    CHAT:UrlCopy()
    CHAT:WhisperSticky()
    CHAT:AutoToggleChatBubble()
    CHAT:PauseToSlash()
    CHAT:SaveSlashCommandTypo()
    CHAT:WhisperInvite()
    CHAT:CreateChannelBar()
    CHAT:AddRoleIcon()
    CHAT:UpdateLanguageFilter()
    CHAT:HideInCombat()

    -- Extra elements in chat tab menu
    do
        -- Font size
        local function isSelected(height)
            local _, fontHeight = FCF_GetCurrentChatFrame():GetFont()
            return height == floor(fontHeight + 0.5)
        end

        local function setSelected(height)
            FCF_SetChatWindowFontSize(nil, FCF_GetChatFrameByID(CURRENT_CHAT_FRAME_ID), height)
        end

        Menu.ModifyMenu('MENU_FCF_TAB', function(self, rootDescription, data)
            local fontSizeSubmenu = rootDescription:CreateButton(C.INFO_COLOR .. L['More font size'])
            for i = 10, 30 do
                fontSizeSubmenu:CreateRadio((format(FONT_SIZE_TEMPLATE, i)), isSelected, setSelected, i)
            end
        end)
    end
end
