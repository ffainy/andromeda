-- Unlimited Map Pin Distance
-- Credit: XAAAM
-- https://github.com/XAAAM/UnlimitedMapPinDistance

local F, C, L = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')

UMPD = {}
UMPD.minDistance = 70
UMPD.fadeDistance = 113
UMPD.maxDistance = 0
UMPD.pinAlphaLong = 60
UMPD.pinAlphaShort = 100
UMPD.pinAlphaClamped = 100
UMPD.autoTrackPins = true
UMPD.timeDistance = true
UMPD.useMeters = false
UMPD.shortNumbers = false


_UMPD              = {}
_UMPD.init         = false
_UMPD.blizzEnabled = false

function UMPD_Init()
    _UMPD.init = true
    UMPD_Init = nil
    _UMPD:USER_WAYPOINT_UPDATED()
end

do
    -- Time to reach Pin
    SuperTrackedFrame.Time = SuperTrackedFrame:CreateFontString(nil, 'BACKGROUND', 'GameFontNormal')
    SuperTrackedFrame.Time:SetSize(0, 1)
    SuperTrackedFrame.Time:SetPoint('TOP', SuperTrackedFrame.DistanceText, 'BOTTOM', 0, 0)

    -- Override default SuperTrackedFrame:GetTargetAlphaBaseValue()
    function SuperTrackedFrame:GetTargetAlphaBaseValue()
        -- Update Alpha on Pin
        local d = C_Navigation.GetDistance()
        if (_UMPD.blizzEnabled) and ((d >= UMPD.minDistance and d <= UMPD.maxDistance) or (d >= UMPD.minDistance and UMPD.maxDistance == 0)) then
            if SuperTrackedFrame.isClamped then
                return UMPD.pinAlphaClamped / 100
            elseif d > UMPD.fadeDistance then
                return UMPD.pinAlphaLong / 100
            else
                return UMPD.pinAlphaShort / 100
            end
        else
            return 0
        end
    end

    -- Override default SuperTrackedFrame:UpdateDistanceText()
    function SuperTrackedFrame:UpdateDistanceText()
        if not SuperTrackedFrame.isClamped then
            local distance = C_Navigation.GetDistance()
            local measure = ' yds'
            -- Meters
            if UMPD.useMeters then
                distance = distance * 0.9144
                measure = ' m'
            end
            if UMPD.shortNumbers and distance > 1000 then
                SuperTrackedFrame.DistanceText:SetText(Round(distance / 100) / 10 .. 'K' .. measure)
            else
                SuperTrackedFrame.DistanceText:SetText(Round(distance) .. measure)
            end
        end
        SuperTrackedFrame.DistanceText:SetShown(not SuperTrackedFrame.isClamped)
        if UMPD.timeDistance then
            SuperTrackedFrame.Time:SetShown(not SuperTrackedFrame.isClamped)
        end
    end
end

-- Find Zone in command
local function findZone(z, s)
    for i = 0, 4000 do
        if C_Map.GetMapInfo(i) then
            local m = C_Map.GetMapInfo(i)
            if string.lower(m.name) == z then
                if s ~= 0 then
                    if m.parentMapID == s then
                        return i
                    end
                else
                    return i
                end
            end
        end
    end
    return 0
end

-- Time to reach Pin
local function UpdateTimeDistance(a)
    if UMPD.timeDistance and C_SuperTrack.IsSuperTrackingAnything() then
        local d = C_Navigation.GetDistance()

        -- New / Changed Pin
        if a then
            -- Cancel Prev Timer if it exists
            if _UMPD.distanceTimer then
                _UMPD.distanceTimer:Cancel()
            end

            -- Reset & Start New Timer
            _UMPD.distanceLast = 0
            _UMPD.distanceTimer = C_Timer.NewTicker(1, function() UpdateTimeDistance(false) end)
        end

        -- Calculate
        if _UMPD.distanceLast > 0 then
            local s = (_UMPD.distanceLast - d)
            if s > 0 then
                local t = d / s
                if t > 0 then
                    SuperTrackedFrame.Time:SetText(TIMER_MINUTES_DISPLAY:format(floor(t / 60), floor(t % 60)))
                else
                    SuperTrackedFrame.Time:SetText('')
                end
            end
        end
        _UMPD.distanceLast = d
    else
        if _UMPD.distanceTimer then
            _UMPD.distanceTimer:Cancel()
        end
        _UMPD.distanceLast = 0
        SuperTrackedFrame.Time:SetText('')
    end
end

-- Slash
SLASH_UMPD1 = '/uway'

if not C_AddOns.IsAddOnLoaded('SlashPin') then
    SLASH_UMPD2 = '/pin'
end

if not C_AddOns.IsAddOnLoaded('TomTom') then
    SLASH_UMPD3 = '/way'
end

SlashCmdList['UMPD'] = function(msg)
    local zoneFound = 0
    msg = msg and string.lower(msg)

    local wrongseparator = '(%d)' .. (tonumber('1.1') and ',' or '.') .. '(%d)'
    local rightseparator = '%1' .. (tonumber('1.1') and '.' or ',') .. '%2'

    local tokens = {}
    msg = msg:gsub('(%d)[%.,] (%d)', '%1 %2'):gsub(wrongseparator, rightseparator)
    for token in msg:gmatch('%S+') do
        table.insert(tokens, token)
    end

    for i = 1, #tokens do
        local token = tokens[i]
        if tonumber(token) then
            zoneFound = i - 1
            break
        end
    end

    local c = {}
    local p = 'player'
    local u = C_Map.GetBestMapForUnit(p)
    local m = C_Map.GetPlayerMapPosition(u, p)

    c.z, c.x, c.y = table.concat(tokens, ' ', 1, zoneFound), select(zoneFound + 1, unpack(tokens))

    if c.x and c.y then
        if c.z and string.len(c.z) > 1 then
            c.t = string.match(c.z, '%#([0-9]+)')

            if c.t then
                u = c.t
            else
                c.s = string.match(c.z, ":([a-z%s'`]+)")
                c.z = string.match(c.z, "([a-z%s'`]+)")
                c.z = string.gsub(c.z, '[ \t]+%f[\r\n%z]', '')
            end

            local sub = 0
            if c.s and string.len(c.s) > 0 then
                c.s = string.gsub(c.s, '[ \t]+%f[\r\n%z]', '')
                sub = findZone(c.s, 0)
            end
            local zone = findZone(c.z, sub)
            if zone ~= 0 then
                u = zone
            end
        end

        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(u, tonumber(c.x) / 100, tonumber(c.y) / 100))
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
end

-- Event Handling
function _UMPD:USER_WAYPOINT_UPDATED()
    if C_Map.HasUserWaypoint() == true then
        C_Timer.After(0, function()
            if UMPD.autoTrackPins == true then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end)
    end
end

function _UMPD:SUPER_TRACKING_CHANGED()
    if C_SuperTrack.IsSuperTrackingQuest() then
        C_SuperTrack.SetSuperTrackedUserWaypoint(false)
    end
    if C_SuperTrack.IsSuperTrackingAnything() then
        UpdateTimeDistance(true)
    end
end

function _UMPD:CVAR_UPDATE()
    if GetCVar('showInGameNavigation') == '1' then
        _UMPD.blizzEnabled = true
    else
        _UMPD.blizzEnabled = false
    end
end

local f = CreateFrame('Frame')
f:SetScript('OnEvent', function(self, event, ...)
    if event == 'PLAYER_LOGIN' and _UMPD.init == false then
        _UMPD:CVAR_UPDATE()
        UMPD_Init()
    elseif _UMPD.init == true then
        if event == 'USER_WAYPOINT_UPDATED' then
            _UMPD:USER_WAYPOINT_UPDATED()
        elseif event == 'SUPER_TRACKING_CHANGED' then
            _UMPD:SUPER_TRACKING_CHANGED()
        elseif event == 'CVAR_UPDATE' then
            _UMPD:CVAR_UPDATE()
        end
    end
end)
f:RegisterEvent('USER_WAYPOINT_UPDATED')
f:RegisterEvent('SUPER_TRACKING_CHANGED')
f:RegisterEvent('PLAYER_LOGIN')
f:RegisterEvent('CVAR_UPDATE')
