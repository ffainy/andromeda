local F, C = unpack(select(2, ...))
local GUI = F:GetModule('GUI')
local TUTORIAL = F:GetModule('Tutorial')
local LOGO = F:GetModule('Logo')

F:RegisterSlashCommand('/and', function(msg)
    local str, _ = strsplit(' ', strlower(msg), 2)

    if strmatch(str, 'reset') or strmatch(str, 'init') then
        StaticPopup_Show('ANDROMEDA_RESET_ALL')
    elseif strmatch(str, 'install') or strmatch(str, 'tutorial') then
        TUTORIAL:HelloWorld()
    elseif strmatch(str, 'unlock') or strmatch(str, 'layout') then
        F:MoverConsole()
    elseif strmatch(str, 'gui') or strmatch(str, 'config') then
        F.ToggleGUI()
    elseif strmatch(str, 'help') or strmatch(str, 'cheatsheet') then
        GUI:ToggleCheatSheet()
    elseif strmatch(str, 'logo') then
        if not LOGO.logoFrame then
            LOGO:Logo_Create()
        end
        LOGO.logoFrame:Show()
    elseif strmatch(str, 'clickbinding') or strmatch(str, 'cb') then
        if InClickBindingMode() then
            ClickBindingFrame.SaveButton:Click()
        else
            ToggleClickBindingFrame()
        end
    elseif strmatch(str, 'keybinding') or strmatch(str, 'kb') then
        SlashCmdList['ANDROMEDA_KEY_BINDING']('')
    elseif strmatch(str, 'ver') or strmatch(str, 'version') then
        F.Print('version: %s', C.ADDON_VERSION)
    else
        GUI:ToggleCheatSheet()
        PlaySoundFile(C.Assets.Sounds.PhubIntro, 'Master')
    end
end)

-- Leave group
F:RegisterSlashCommand('/lg', function()
    C_PartyInfo.LeaveParty()
end)

--	Disband party or raid
F:RegisterSlashCommand('/disband', function()
    StaticPopup_Show('ANDROMEDA_DISBAND_GROUP')
end)

--	Convert party raid
F:RegisterSlashCommand('/convert', function()
    if GetNumGroupMembers() > 0 then
        if UnitInRaid('player') and (UnitIsGroupLeader('player')) then
            C_PartyInfo.ConvertToParty()
        elseif UnitInParty('player') and (UnitIsGroupLeader('player')) then
            C_PartyInfo.ConvertToRaid()
        end
    else
        F.Print('|cffff2020' .. ERR_NOT_IN_GROUP .. '|r')
    end
end)

-- Ready check
F:RegisterSlashCommand('/rdc', function()
    DoReadyCheck()
end)

-- Role poll
F:RegisterSlashCommand('/role', function()
    InitiateRolePoll()
end)

-- Reset instance
F:RegisterSlashCommand('/ri', function()
    ResetInstances()
end)

-- Teleport LFG instance
F:RegisterSlashCommand('/tp', function()
    LFGTeleport(IsInLFGDungeon())
end)

-- Take screenshot
F:RegisterSlashCommand('/ss', function()
    Screenshot()
end)

-- Mount special pose
F:RegisterSlashCommand('/ms', function()
    if IsMounted() then
        DoEmote('MOUNTSPECIAL')
    else
        F.Print('You are |cffff2020NOT|r mounted.')
    end
end)

-- Set BattleNet broadcast
F:RegisterSlashCommand('/bb', function(msg)
    BNSetCustomMessage(msg)
end)

-- Switch specialization
F:RegisterSlashCommand('/spec', function(msg)
    local specID = tonumber(msg)
    if specID then
        local canUse, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI()
        if canUse then
            if GetSpecialization() ~= specID then
                SetSpecialization(specID)
            end
        else
            F.Print('|cffff2020' .. failureReason)
        end
    else
        F.Print('Please enter the |cffff2020SPECIALIZATION NUMBER|r.')
    end
end)

-- Whisper current target
hooksecurefunc('ChatEdit_OnSpacePressed', function(editBox)
    if editBox:GetText():sub(1, 3) == '/tt' and (UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target')) then
        editBox:SetText(SLASH_SMART_WHISPER1 .. ' ' .. GetUnitName('target', true):gsub(' ', '') .. ' ')
        ChatEdit_ParseText(editBox, 0)
    end
end)

F:RegisterSlashCommand('/tt', function(msg)
    if UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target') then
        SendChatMessage(msg, 'WHISPER', nil, GetUnitName('target', true))
    end
end)

-- Support cmd /way if TomTom disabled
do
    local pointString = C.INFO_COLOR .. '|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a%s (%s, %s)%s]|h|r'

    local function GetCorrectCoord(x)
        x = tonumber(x)
        if x then
            if x > 100 then
                return 100
            elseif x < 0 then
                return 0
            end

            return x
        end
    end

    F:RegisterSlashCommand('/way', function(msg)
        if C_AddOns.IsAddOnLoaded('TomTom') then
            return
        end
        msg = gsub(msg, '(%d)[%.,] (%d)', '%1 %2')
        local x, y, z = strmatch(msg, '(%S+)%s(%S+)(.*)')
        if x and y then
            local mapID = C_Map.GetBestMapForUnit('player')
            if mapID then
                local mapInfo = C_Map.GetMapInfo(mapID)
                local mapName = mapInfo and mapInfo.name
                if mapName then
                    x = GetCorrectCoord(x)
                    y = GetCorrectCoord(y)

                    if x and y then
                        print(format(pointString, mapID, x * 100, y * 100, mapName, x, y, z or ''))

                        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x / 100, y / 100))
                        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                    end
                end
            end
        end
    end)
end

-- Clear chat
F:RegisterSlashCommand('/clear', function()
    for i = 1, NUM_CHAT_WINDOWS do
        _G[format('ChatFrame%d', i)]:Clear()
    end
end)


