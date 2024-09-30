local F, C, L = unpack(select(2, ...))
local CHAT = F:GetModule('Chat')

local chatFrame = SELECTED_DOCK_FRAME
local editBox = chatFrame.editBox
local buttonsList = {}

local nameStr
if GetCVar('portal') == 'CN' then
    nameStr = '大脚世界频道'
elseif GetCVar('portal') == 'KR' then
    nameStr = '組隊頻道'
end

local buttonsData = {
    {
        1, 1, 1,
        SAY .. '/' .. YELL,
        function(_, btn)
            if btn == 'RightButton' then
                ChatFrame_OpenChat('/y ', chatFrame)
            else
                ChatFrame_OpenChat('/s ', chatFrame)
            end
        end,
    },
    {
        1, 0.5, 1,
        WHISPER,
        function(_, btn)
            if btn == 'RightButton' then
                ChatFrame_ReplyTell(chatFrame)
                if not editBox:IsVisible() or editBox:GetAttribute('chatType') ~= 'WHISPER' then
                    ChatFrame_OpenChat('/w ', chatFrame)
                end
            else
                if UnitExists('target') and UnitName('target') and UnitIsPlayer('target') and GetDefaultLanguage('player') == GetDefaultLanguage('target') then
                    local name = GetUnitName('target', true)
                    ChatFrame_OpenChat('/w ' .. name .. ' ', chatFrame)
                else
                    ChatFrame_OpenChat('/w ', chatFrame)
                end
            end
        end,
    },
    {
        0.65, 0.65, 1,
        PARTY,
        function()
            ChatFrame_OpenChat('/p ', chatFrame)
        end,
    },
    {
        1, 0.5, 0,
        INSTANCE .. '/' .. RAID,
        function()
            if IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() then
                ChatFrame_OpenChat('/i ', chatFrame)
            else
                ChatFrame_OpenChat('/raid ', chatFrame)
            end
        end,
    },
    {
        0.25, 1, 0.25,
        GUILD .. '/' .. OFFICER,
        function(_, btn)
            if btn == 'RightButton' and C_GuildInfo.IsGuildOfficer() then
                ChatFrame_OpenChat('/o ', chatFrame)
            else
                ChatFrame_OpenChat('/g ', chatFrame)
            end
        end,
    },
}

local helpTip = {
    text = L["Press TAB key to switch available channels, it's a bit silly to click on bars all the time."],
    buttonStyle = HelpTip.ButtonStyle.GotIt,
    targetPoint = HelpTip.Point.TopEdgeCenter,
    offsetY = 50,
    onAcknowledgeCallback = F.HelpInfoAcknowledge,
    callbackArg = 'ChatSwitch',
}

local function showHelpTip()
    if not ANDROMEDA_ADB['HelpTips']['ChatSwitch'] then
        HelpTip:Show(ChatFrame1, helpTip)
    end
end

local function bar_OnEnter()
    F:UIFrameFadeIn(CHAT.ChannelBar, 0.3, CHAT.ChannelBar:GetAlpha(), 1)
end

local function bar_OnLeave()
    F:UIFrameFadeOut(CHAT.ChannelBar, 0.3, CHAT.ChannelBar:GetAlpha(), 0.2)
end

local function createBar()
    local channelBar = CreateFrame('Frame', C.ADDON_TITLE .. 'ChannelBar', ChatFrame1)
    channelBar:SetSize(ChatFrame1:GetWidth(), 5)
    channelBar:SetPoint('TOPLEFT', ChatFrame1, 'BOTTOMLEFT', 0, -6)
    channelBar:SetAlpha(0.2)
    CHAT.ChannelBar = channelBar
end

local function createButton(r, g, b, text, func)
    local bu = CreateFrame('Button', nil, CHAT.ChannelBar, 'SecureActionButtonTemplate, BackdropTemplate')
    bu:SetSize(30, 3)
    F.PixelIcon(bu, C.Assets.Textures.StatusbarNormal, true)
    F.CreateSD(bu)
    bu.Icon:SetVertexColor(r, g, b)
    bu:SetHitRectInsets(0, 0, -8, -8)
    bu:RegisterForClicks('AnyUp')
    if text then
        F.AddTooltip(bu, 'ANCHOR_TOP', F:RgbToHex(r, g, b) .. text)
    end
    if func then
        bu:SetScript('OnClick', func)
        bu:HookScript('OnClick', showHelpTip)
    end

    tinsert(buttonsList, bu)
    return bu
end

local function updateChannelInfo()
    local icon = CHAT.ChannelBar.WorldChannelButton.Icon
    local id = GetChannelName(nameStr)
    if not id or id == 0 then
        CHAT.InWorldChannel = false
        CHAT.WorldChannelID = nil
        icon:SetVertexColor(1, 0.1, 0.1)
    else
        CHAT.InWorldChannel = true
        CHAT.WorldChannelID = id
        icon:SetVertexColor(0, 0.8, 1)
    end
end

local function checkChannelStatus()
    F:Delay(0.2, updateChannelInfo)
end

local function createChannelButtons()
    for _, info in pairs(buttonsData) do
        createButton(unpack(info))
    end
end

local function createRollButton()
    local rollButton = createButton(0.8, 1, 0.6, LOOT_ROLL)
    rollButton:SetAttribute('type', 'macro')
    rollButton:SetAttribute('macrotext', '/roll')
    rollButton:RegisterForClicks('AnyUp', 'AnyDown')
    CHAT.ChannelBar.RollButton = rollButton
end

local function createLogButton()
    local clButton = createButton(1, 1, 0, BINDING_NAME_TOGGLECOMBATLOG)
    clButton:SetAttribute('type', 'macro')
    clButton:SetAttribute('macrotext', '/combatlog')
    clButton:RegisterForClicks('AnyUp', 'AnyDown')
    CHAT.ChannelBar.LoggingButton = clButton
end

local function lobbyButton_OnClick(self, btn)
    if CHAT.InWorldChannel then
        if btn == 'RightButton' then
            LeaveChannelByName(nameStr)
            F.Print('|cffd82026' .. QUIT .. '|r ' .. C.INFO_COLOR .. L['World Channel'])
            CHAT.InWorldChannel = false
        elseif CHAT.WorldChannelID then
            ChatFrame_OpenChat('/' .. CHAT.WorldChannelID, chatFrame)
        end
    else
        JoinPermanentChannel(nameStr, nil, 1)
        ChatFrame_AddChannel(ChatFrame1, nameStr)
        F.Print('|cff27ba24' .. JOIN .. '|r ' .. C.INFO_COLOR .. L['World Channel'])
        CHAT.InWorldChannel = true
    end
end

local function createLobbyButton()
    if GetCVar('portal') == 'CN' or GetCVar('portal') == 'KR' then
        local wcButton = createButton(0, 0.8, 1, L['World Channel'])
        CHAT.ChannelBar.WorldChannelButton = wcButton

        checkChannelStatus()
        F:RegisterEvent('CHANNEL_UI_UPDATE', checkChannelStatus)
        hooksecurefunc('ChatConfigChannelSettings_UpdateCheckboxes', checkChannelStatus) -- toggle in chatconfig

        wcButton:SetScript('OnClick', lobbyButton_OnClick)
    end
end

function CHAT:UpdateChannelBar()
    CHAT.ChannelBar:SetSize(ChatFrame1:GetWidth(), 5)

    for i = 1, #buttonsList do
        if i == 1 then
            buttonsList[i]:SetPoint('LEFT')
        else
            buttonsList[i]:SetPoint('LEFT', buttonsList[i - 1], 'RIGHT', 5, 0)
        end

        local buttonWidth = (ChatFrame1:GetWidth() - (#buttonsList - 1) * 5) / #buttonsList
        buttonsList[i]:SetWidth(buttonWidth)

        buttonsList[i]:HookScript('OnEnter', bar_OnEnter)
        buttonsList[i]:HookScript('OnLeave', bar_OnLeave)
    end
end

function CHAT:CreateChannelBar()
    if not C.DB.Chat.ChannelBar then
        return
    end

    createBar()
    createChannelButtons()
    createRollButton()
    createLogButton()
    createLobbyButton()

    CHAT:UpdateChannelBar()
end
