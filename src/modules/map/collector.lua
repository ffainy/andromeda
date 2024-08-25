local F, C, L = unpack(select(2, ...))
local MAP = F:GetModule('Map')

local buttonBlackList = {
    ['MiniMapLFGFrame'] = true,
    ['BattlefieldMinimap'] = true,
    ['MinimapBackdrop'] = true,
    ['TimeManagerClockButton'] = true,
    ['FeedbackUIButton'] = true,
    ['MiniMapBattlefieldFrame'] = true,
    ['QueueStatusButton'] = true,
    ['QueueStatusMinimapButton'] = true,
    ['GarrisonLandingPageMinimapButton'] = true,
    ['MinimapZoneTextButton'] = true,
    [C.ADDON_TITLE .. 'MinimapAddOnIconCollectorTray'] = true,
    [C.ADDON_TITLE .. 'MinimapAddOnIconCollector'] = true,
}

local ignoredButtons = {
    ['GatherMatePin'] = true,
    ['HandyNotes.-Pin'] = true,
    ['TTMinimapButton'] = true,
}

local isGoodLookingIcon = {
    ['Narci_MinimapButton'] = true,
}

local function updateCollectorTip(bu)
    bu.text = C.MOUSE_RIGHT_BUTTON
        .. L['Auto Hide']
        .. ': '
        ..
        (ANDROMEDA_ADB['MinimapAddOnCollector'] and '|cff55ff55' .. VIDEO_OPTIONS_ENABLED or '|cffff5555' .. VIDEO_OPTIONS_DISABLED)
end

local function hideCollectorTray()
    Minimap.AddOnCollectorTray:Hide()
end

local function clickFunc(force)
    if force == 1 or ANDROMEDA_ADB['MinimapAddOnCollector'] then
        F:UIFrameFadeOut(Minimap.AddOnCollectorTray, 0.5, 1, 0)
        F:Delay(0.5, hideCollectorTray)
    end
end

local function isButtonIgnored(name)
    for addonName in pairs(ignoredButtons) do
        if strmatch(name, addonName) then
            return true
        end
    end
end

local iconsPerRow = 5
local rowMult = iconsPerRow / 2 - 1
local currentIndex, pendingTime, timeThreshold = 0, 5, 12
local buttons, numMinimapChildren = {}, 0
local removedTextures = {
    [136430] = true,
    [136467] = true,
}

local function reskinAddOnIcon(child, name)
    for j = 1, child:GetNumRegions() do
        local region = select(j, child:GetRegions())
        if region:IsObjectType('Texture') then
            local texture = region:GetTexture() or ''
            if removedTextures[texture] or strfind(texture, 'Interface\\CharacterFrame') or strfind(texture, 'Interface\\Minimap') then
                region:SetTexture(nil)
            end

            if not region.__ignored then
                region:ClearAllPoints()
                region:SetAllPoints()
            end

            if not isGoodLookingIcon[name] then
                region:SetTexCoord(unpack(C.TEX_COORD))
            end
        end
        child:SetSize(24, 24)
        child.bg = F.CreateBDFrame(child, 1)
        child.bg:SetBackdropBorderColor(0, 0, 0)
    end

    tinsert(buttons, child)
end

local function killAddOnIcon()
    for _, child in pairs(buttons) do
        if not child.styled then
            child:SetParent(Minimap.AddOnCollectorTray)
            if child:HasScript('OnDragStop') then
                child:SetScript('OnDragStop', nil)
            end
            if child:HasScript('OnDragStart') then
                child:SetScript('OnDragStart', nil)
            end
            if child:HasScript('OnClick') then
                child:HookScript('OnClick', clickFunc)
            end

            if child:IsObjectType('Button') then
                child:SetHighlightTexture(C.Assets.Textures.Backdrop) -- prevent nil function
                child:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            elseif child:IsObjectType('Frame') then
                child.highlight = child:CreateTexture(nil, 'HIGHLIGHT')
                child.highlight:SetAllPoints()
                child.highlight:SetColorTexture(1, 1, 1, 0.25)
            end

            -- Naughty Addons
            local name = child:GetName()
            if name == 'DBMMinimapButton' then
                child:SetScript('OnMouseDown', nil)
                child:SetScript('OnMouseUp', nil)
            elseif name == 'BagSync_MinimapButton' then
                child:HookScript('OnMouseUp', clickFunc)
            elseif name == 'WIM3MinimapButton' then
                child.SetParent = nop
                child:SetFrameStrata('DIALOG')
                child.SetFrameStrata = nop
            end

            child.styled = true
        end
    end
end

local function collectRubbish()
    local numChildren = Minimap:GetNumChildren()
    if numChildren ~= numMinimapChildren then
        for i = 1, numChildren do
            local child = select(i, Minimap:GetChildren())
            local name = child and child.GetName and child:GetName()
            if name and not child.isExamed and not buttonBlackList[name] then
                if (child:IsObjectType('Button') or strmatch(strupper(name), 'BUTTON')) and not isButtonIgnored(name) then
                    reskinAddOnIcon(child, name)
                end
                child.isExamed = true
            end
        end

        numMinimapChildren = numChildren
    end

    killAddOnIcon()

    currentIndex = currentIndex + 1
    if currentIndex < timeThreshold then
        F:Delay(pendingTime, collectRubbish)
    end
end

local shownButtons = {}
local function sortRubbish()
    if #buttons == 0 then
        return
    end

    wipe(shownButtons)
    for _, button in pairs(buttons) do
        if next(button) and button:IsShown() then -- fix for fuxking AHDB
            tinsert(shownButtons, button)
        end
    end

    local numShown = #shownButtons
    local row = numShown == 0 and 1 or F:Round((numShown + rowMult) / iconsPerRow)
    local newHeight = row * 24
    Minimap.AddOnCollectorTray:SetHeight(newHeight)

    for index, button in pairs(shownButtons) do
        button:ClearAllPoints()
        if index == 1 then
            button:SetPoint('BOTTOMRIGHT', Minimap.AddOnCollectorTray, -3, 3)
        elseif row > 1 and mod(index, row) == 1 or row == 1 then
            button:SetPoint('RIGHT', shownButtons[index - row], 'LEFT', -3, 0)
        else
            button:SetPoint('BOTTOM', shownButtons[index - 1], 'TOP', 0, 3)
        end
    end
end

local function buttonOnClick(self, btn)
    if btn == 'RightButton' then
        ANDROMEDA_ADB['MinimapAddOnCollector'] = not ANDROMEDA_ADB['MinimapAddOnCollector']
        updateCollectorTip(Minimap.AddOnCollector)
        Minimap.AddOnCollector:GetScript('OnEnter')(Minimap.AddOnCollector)
    else
        if Minimap.AddOnCollectorTray:IsShown() then
            clickFunc(1)
        else
            sortRubbish()
            F:UIFrameFadeIn(Minimap.AddOnCollectorTray, 0.5, 0, 1)
        end
    end
end

function MAP:AddOnIconCollector()
    if not C.DB.Map.Collector then
        return
    end

    local bu = CreateFrame('Button', C.ADDON_TITLE .. 'MinimapAddOnIconCollector', Minimap)
    bu:SetSize(20, 20)
    bu:SetPoint('TOPRIGHT', -4, -Minimap.halfDiff - 8)
    bu:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    bu.Icon = bu:CreateTexture(nil, 'ARTWORK')
    bu.Icon:SetAllPoints()
    bu.Icon:SetTexture(C.Assets.Textures.MinimapTray)
    bu:SetHighlightTexture(C.Assets.Textures.MinimapTray)
    F.AddTooltip(bu, 'ANCHOR_LEFT', C.INFO_COLOR .. L['AddOns Icon Collector'])
    updateCollectorTip(bu)
    Minimap.AddOnCollector = bu

    local tray = CreateFrame('Frame', C.ADDON_TITLE .. 'MinimapAddOnIconCollectorTray', Minimap)
    tray:SetPoint('BOTTOMRIGHT', Minimap, 'TOPRIGHT', 0, -Minimap.halfDiff)
    tray:SetSize(Minimap:GetWidth(), 24)
    tray:Hide()
    Minimap.AddOnCollectorTray = tray

    F:SplitList(ignoredButtons, ANDROMEDA_ADB['IgnoredAddOns'])

    bu:SetScript('OnClick', buttonOnClick)

    collectRubbish()
end

function MAP:SetupACF()
    local frame = AddonCompartmentFrame
    if C.DB.Map.Collector then
        F.HideObject(frame)
    else
        frame:ClearAllPoints()
        frame:SetPoint('BOTTOMRIGHT', Minimap, -26, 2)
        frame:SetFrameLevel(999)
        F.StripTextures(frame)
        F.SetBD(frame)
    end
end
