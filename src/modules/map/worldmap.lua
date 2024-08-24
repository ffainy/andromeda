local F, C, L = unpack(select(2, ...))
local MAP = F:GetModule('Map')

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords

function MAP:GetPlayerMapPos(mapID)
    if not mapID then
        return
    end
    tempVec2D.x, tempVec2D.y = UnitPosition('player')
    if not tempVec2D.x then
        return
    end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local pos1 = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
        local pos2 = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
        if not pos1 or not pos2 then
            return
        end
        mapRect = { pos1, pos2 }
        mapRect[2]:Subtract(mapRect[1])

        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return tempVec2D.y / mapRect[2].y, tempVec2D.x / mapRect[2].x
end

function MAP:GetCursorCoords()
    local WorldMapFrame = WorldMapFrame
    if not WorldMapFrame.ScrollContainer:IsMouseOver() then
        return
    end

    local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
    if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
        return
    end
    return cursorX, cursorY
end

local function CoordsFormat(owner, none)
    local text = none and ': --, --' or ': %.1f, %.1f'
    return owner .. C.INFO_COLOR .. text
end

function MAP:UpdateCoords(elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed > 0.1 then
        local cursorX, cursorY = MAP:GetCursorCoords()
        if cursorX and cursorY then
            cursorCoords:SetFormattedText(CoordsFormat(L['Cursor']), 100 * cursorX, 100 * cursorY)
        else
            cursorCoords:SetText(CoordsFormat(L['Cursor'], true))
        end

        if not currentMapID then
            playerCoords:SetText(CoordsFormat(PLAYER, true))
        else
            local x, y = MAP:GetPlayerMapPos(currentMapID)
            if not x or (x == 0 and y == 0) then
                playerCoords:SetText(CoordsFormat(PLAYER, true))
            else
                playerCoords:SetFormattedText(CoordsFormat(PLAYER), 100 * x, 100 * y)
            end
        end

        self.elapsed = 0
    end
end

function MAP:UpdateMapID()
    if self:GetMapID() == C_Map.GetBestMapForUnit('player') then
        currentMapID = self:GetMapID()
    else
        currentMapID = nil
    end
end

function MAP:AddCoords()
    if not C.DB.Map.Coords then
        return
    end

    local WorldMapFrame = WorldMapFrame
    local outline = ANDROMEDA_ADB.FontOutline
    playerCoords = F.CreateFS(
        WorldMapFrame.BorderFrame, C.Assets.Fonts.Bold, 12, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'BOTTOMLEFT', 150, 10 }
    )
    cursorCoords = F.CreateFS(
        WorldMapFrame.BorderFrame, C.Assets.Fonts.Bold, 12, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'LEFT', playerCoords, 'RIGHT', 20, 0 }
    )

    F.HideObject(WorldMapFrame.BorderFrame.Tutorial)

    hooksecurefunc(WorldMapFrame, 'OnFrameSizeChanged', MAP.UpdateMapID)
    hooksecurefunc(WorldMapFrame, 'OnMapChanged', MAP.UpdateMapID)

    local CoordsUpdater = CreateFrame('Frame', nil, WorldMapFrame.BorderFrame)
    CoordsUpdater:SetScript('OnUpdate', MAP.UpdateCoords)
end

function MAP:UpdateMapScale()
    if self.isMaximized and self:GetScale() ~= C.DB.Map.MaxWorldMapScale then
        self:SetScale(C.DB.Map.MaxWorldMapScale)
    elseif not self.isMaximized and self:GetScale() ~= C.DB.Map.WorldMapScale then
        self:SetScale(C.DB.Map.WorldMapScale)
    end
end

function MAP:UpdateMapAnchor()
    MAP.UpdateMapScale(self)
    F.RestoreMF(self)
end

function MAP:WorldMapScale()
    local WorldMapFrame = WorldMapFrame

    F.CreateMF(WorldMapFrame, nil, true)
    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', self.UpdateMapAnchor)
end

function MAP:SetupWorldMap()
    local WorldMapFrame = WorldMapFrame
    -- Remove from frame manager
    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint('CENTER') -- init anchor
    WorldMapFrame:SetAttribute('UIPanelLayout-area', nil)
    WorldMapFrame:SetAttribute('UIPanelLayout-enabled', false)
    WorldMapFrame:SetAttribute('UIPanelLayout-allowOtherPanels', true)
    tinsert(UISpecialFrames, 'WorldMapFrame')

    -- Hide stuff
    WorldMapFrame.BlackoutFrame:SetAlpha(0)
    WorldMapFrame.BlackoutFrame:EnableMouse(false)

    MAP:WorldMapScale()
    MAP:AddCoords()
    MAP:WorldMapReveal()
end

function MAP:OnLogin()
    if not C.DB.Map.Enable then
        return
    end

    MAP:SetupWorldMap()
    MAP:SetupMinimap()
end
