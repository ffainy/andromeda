-- Better World Quests
-- Credit: p3lim
-- https://github.com/p3lim-wow/BetterWorldQuests


local F, C, L = unpack(select(2, ...))
local QUEST = F:GetModule('Quest')

local hbd = F.Libs.HereBeDragons
local bwq = {}

local mapScale = 1
local parentScale = 1
local zoomFactor = 0.5
local showAzeroth = false
local showEvents = false
local modifier = 'ALT'

----------------------------------
-- utils.lua
----------------------------------

local CONTINENTS = {
    -- list of all continents and their sub-zones that have world quests
    [2274] = {         -- Khaz Algar
        [2248] = true, -- Isle of Dorn
        [2215] = true, -- Hallowfall
        [2214] = true, -- The Ringing Deeps
        [2255] = true, -- Azj-Kahet
        [2256] = true, -- Azj-Kahet - Lower
        [2213] = true, -- City of Threads
        [2216] = true, -- City of Threads - Lower
    },
    [1978] = {         -- Dragon Isles
        [2022] = true, -- The Walking Shores
        [2023] = true, -- Ohn'ahran Plains
        [2024] = true, -- The Azure Span
        [2025] = true, -- Thaldraszus
        [2151] = true, -- The Forbidden Reach
    },
    [1550] = {         -- Shadowlands
        [1525] = true, -- Revendreth
        [1533] = true, -- Bastion
        [1536] = true, -- Maldraxxus
        [1565] = true, -- Ardenwald
        [1543] = true, -- The Maw
    },
    [619] = {          -- Broken Isles
        [630] = true,  -- Azsuna
        [641] = true,  -- Val'sharah
        [650] = true,  -- Highmountain
        [634] = true,  -- Stormheim
        [680] = true,  -- Suramar
        [627] = true,  -- Dalaran
        [790] = true,  -- Eye of Azshara (world version)
        [646] = true,  -- Broken Shore
    },
    [424] = {          -- Pandaria
        [1530] = true, -- Vale of Eternal Blossoms (BfA)
    },
    [875] = {          -- Zandalar
        [862] = true,  -- Zuldazar
        [864] = true,  -- Vol'Dun
        [863] = true,  -- Nazmir
    },
    [876] = {          -- Kul Tiras
        [895] = true,  -- Tiragarde Sound
        [896] = true,  -- Drustvar
        [942] = true,  -- Stormsong Valley
    },
    [13] = {           -- Eastern Kingdoms
        [14] = true,   -- Arathi Highlands (Warfronts)
    },
    [12] = {           -- Kalimdor
        [62] = true,   -- Darkshore (Warfronts)
        [1527] = true, -- Uldum (BfA)
    },
    [947] = {          -- Azeroth
        [13] = true,   -- Eastern Kingdoms
        [12] = true,   -- Kalimdor
        [619] = true,  -- Broken Isles
        [875] = true,  -- Zandalar
        [876] = true,  -- Kul Tiras
        [424] = true,  -- Pandaria
        [1978] = true, -- Dragon Isles
        [2274] = true, -- Khaz Algar
    },
}

function bwq:IsParentMap(mapID)
    return not not CONTINENTS[mapID]
end

function bwq:IsChildMap(parentMapID, mapID)
    local mapInfo = C_Map.GetMapInfo(mapID)
    return parentMapID and mapID and mapInfo and mapInfo.parentMapID and mapInfo.parentMapID == parentMapID
end

function bwq:TranslatePosition(position, fromMapID, toMapID)
    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(fromMapID, position)
    local _, newPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, toMapID)
    return newPos
end

----------------------------------
-- settings.lua
----------------------------------

--[[ local function formatPercentage(value)
    return PERCENTAGE_STRING:format(math.floor((value * 100) + 0.5))
end

local settings = {
    {
        key = 'mapScale',
        type = 'slider',
        title = L['Map pin scale'],
        tooltip = L['The scale of world quest pins on the current map'],
        default = 1.25,
        minValue = 0.1,
        maxValue = 3,
        valueStep = 0.01,
        valueFormat = formatPercentage,
    },
    {
        key = 'parentScale',
        type = 'slider',
        title = L['Overview pin scale'],
        tooltip = L['The scale of world quest pins on a parent/continent map'],
        default = 1,
        minValue = 0.1,
        maxValue = 3,
        valueStep = 0.01,
        valueFormat = formatPercentage,
    },
    {
        key = 'zoomFactor',
        type = 'slider',
        title = L['Pin size zoom factor'],
        tooltip = L['How much extra scale to apply when map is zoomed'],
        default = 0.5,
        minValue = 0,
        maxValue = 1,
        valueStep = 0.01,
        valueFormat = formatPercentage,
    },
    {
        key = 'showEvents',
        type = 'toggle',
        title = L['Show events on continent'],
        default = false,
    },
    {
        key = 'showAzeroth',
        type = 'toggle',
        title = L['Show on Azeroth'],
        default = false,
    },
    {
        key = 'hideModifier',
        type = 'menu',
        title = L['Hold key to hide'],
        tooltip = L['Hold this key to temporarily hide all world quests'],
        default = 'ALT',
        options = {
            {value='NEVER', label=NEVER},
            {value='ALT', label=ALT_KEY},
            {value='CTRL', label=CTRL_KEY},
            {value='SHIFT', label=SHIFT_KEY},
        },
    },
} ]]

-- bwq:RegisterSettings('BetterWorldQuestsDB', settings)
-- bwq:RegisterSettingsSlash('/betterworldquests', '/bwq')
-- bwq:RegisterMapSettings('BetterWorldQuestsDB', settings)

----------------------------------
-- provider.lua
----------------------------------

-- local showAzeroth
-- bwq:RegisterOptionCallback('showAzeroth', function(value)
--     showAzeroth = value
-- end)

local provider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin)
provider:SetMatchWorldMapFilters(true)
provider:SetUsesSpellEffect(true)
provider:SetCheckBounties(true)

-- override GetPinTemplate to use our custom pin
function provider:GetPinTemplate()
    return 'BetterWorldQuestPinTemplate'
end

-- override ShouldOverrideShowQuest method to show pins on continent maps
function provider:ShouldOverrideShowQuest()
    -- just nop so we don't hit the default
end

-- override ShouldShowQuest method to show pins on parent maps
function provider:ShouldShowQuest(questInfo)
    local mapID = self:GetMap():GetMapID()
    if mapID == 947 then
        -- TODO: change option to only show when there's few?
        return showAzeroth
    end

    if WorldQuestDataProviderMixin.ShouldShowQuest(self, questInfo) then -- super
        return true
    end

    local mapInfo = C_Map.GetMapInfo(mapID)
    if mapInfo.mapType == Enum.UIMapType.Continent then
        return true
    end

    return bwq:IsChildMap(mapID, questInfo.mapID)
end

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
    if not dp.GetPinTemplates and type(dp.GetPinTemplate) == 'function' then
        if dp:GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
            WorldMapFrame:RemoveDataProvider(dp)
            break
        end
    end
end

-- add our own
WorldMapFrame:AddDataProvider(provider)

-- hook into changes
local function updateVisuals()
    -- update pins on changes
    if WorldMapFrame:IsShown() then
        provider:RefreshAllData()

        for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
            pin:RefreshVisuals()
            pin:ApplyCurrentScale()
        end
    end
end

-- bwq:RegisterOptionCallback('mapScale', updateVisuals)
-- bwq:RegisterOptionCallback('parentScale', updateVisuals)
-- bwq:RegisterOptionCallback('zoomFactor', updateVisuals)
-- bwq:RegisterOptionCallback('showAzeroth', updateVisuals)
-- bwq:RegisterOptionCallback('showEvents', updateVisuals)

-- change visibility
-- local modifier
local function toggleVisibility()
    local state = true
    if modifier == 'ALT' then
        state = not IsAltKeyDown()
    elseif modifier == 'SHIFT' then
        state = not IsShiftKeyDown()
    elseif modifier == 'CTRL' then
        state = not IsControlKeyDown()
    end

    for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
        pin:SetShown(state)
    end
end

WorldMapFrame:HookScript('OnHide', function()
    toggleVisibility()
end)

F:RegisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)

-- bwq:RegisterOptionCallback('hideModifier', function(value)
--     if value == 'NEVER' then
--         if bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:UnregisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = nil
--         toggleVisibility()
--     else
--         if not bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:RegisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = value
--     end
-- end)

----------------------------------
-- pin.lua
----------------------------------

-- local mapScale, parentScale, zoomFactor
-- bwq:RegisterOptionCallback('mapScale', function(value)
--     mapScale = value
-- end)
-- bwq:RegisterOptionCallback('parentScale', function(value)
--     parentScale = value
-- end)
-- bwq:RegisterOptionCallback('zoomFactor', function(value)
--     zoomFactor = value
-- end)

local FACTION_ASSAULT_ATLAS = UnitFactionGroup('player') == 'Horde' and 'worldquest-icon-horde' or
    'worldquest-icon-alliance'

BetterWorldQuestPinMixin = CreateFromMixins(WorldMap_WorldQuestPinMixin)
function BetterWorldQuestPinMixin:OnLoad()
    WorldMap_WorldQuestPinMixin.OnLoad(self) -- super

    -- recreate WorldQuestPinTemplate regions
    local TrackedCheck = self:CreateTexture(nil, 'OVERLAY', nil, 7)
    TrackedCheck:SetPoint('BOTTOM', self, 'BOTTOMRIGHT', 0, -2)
    TrackedCheck:SetAtlas('worldquest-emissary-tracker-checkmark', true)
    TrackedCheck:Hide()
    self.TrackedCheck = TrackedCheck

    local TimeLowFrame = CreateFrame('Frame', nil, self)
    TimeLowFrame:SetPoint('CENTER', 9, -9)
    TimeLowFrame:SetSize(22, 22)
    TimeLowFrame:Hide()
    self.TimeLowFrame = TimeLowFrame

    local TimeLowIcon = TimeLowFrame:CreateTexture(nil, 'OVERLAY')
    TimeLowIcon:SetAllPoints()
    TimeLowIcon:SetAtlas('worldquest-icon-clock')
    TimeLowFrame.Icon = TimeLowIcon

    -- add our own widgets
    local Reward = self:CreateTexture(nil, 'OVERLAY')
    Reward:SetPoint('CENTER', self.PushedTexture)
    Reward:SetSize(self:GetWidth() - 4, self:GetHeight() - 4)
    Reward:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Reward = Reward

    local RewardMask = self:CreateMaskTexture()
    RewardMask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
    RewardMask:SetAllPoints(Reward)
    Reward:AddMaskTexture(RewardMask)

    local Indicator = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    Indicator:SetPoint('CENTER', self, 'TOPLEFT', 4, -4)
    self.Indicator = Indicator

    local Reputation = self:CreateTexture(nil, 'OVERLAY', nil, 2)
    Reputation:SetPoint('CENTER', self, 'BOTTOM', 0, 2)
    Reputation:SetSize(10, 10)
    Reputation:SetAtlas('socialqueuing-icon-eye')
    Reputation:Hide()
    self.Reputation = Reputation

    local Bounty = self:CreateTexture(nil, 'OVERLAY', nil, 3)
    Bounty:SetAtlas('QuestNormal', true)
    Bounty:SetScale(0.65)
    Bounty:SetPoint('LEFT', self, 'RIGHT', -(Bounty:GetWidth() / 2), 0)
    self.Bounty = Bounty
end

function BetterWorldQuestPinMixin:RefreshVisuals()
    WorldMap_WorldQuestPinMixin.RefreshVisuals(self) -- super

    -- hide optional elements by default
    self.Bounty:Hide()
    self.Reward:Hide()
    self.Reputation:Hide()
    self.Indicator:Hide()
    self.Display.Icon:Hide()

    -- update scale
    local mapID = self:GetMap():GetMapID()
    if mapID == 947 then
        self:SetScalingLimits(1, parentScale / 2, (parentScale / 2) + zoomFactor)
    elseif bwq:IsParentMap(mapID) then
        self:SetScalingLimits(1, parentScale, parentScale + zoomFactor)
    else
        self:SetScalingLimits(1, mapScale, mapScale + zoomFactor)
    end

    -- uniform coloring
    if self:IsSelected() then
        self.NormalTexture:SetAtlas('worldquest-questmarker-epic-supertracked', true)
    else
        self.NormalTexture:SetAtlas('worldquest-questmarker-epic', true)
    end

    -- set reward icon
    local questID = self.questID
    local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID)
    if GetNumQuestLogRewards(questID) > 0 then
        local _, texture, _, _, _, itemID = GetQuestLogRewardInfo(1, questID)
        if C_Item.IsAnimaItemByID(itemID) then
            texture = 3528287 -- from item "Resonating Anima Core"
        end

        self.Reward:SetTexture(texture)
        self.Reward:Show()
    elseif #currencyRewards > 0 then
        self.Reward:SetTexture(currencyRewards[1].texture)
        self.Reward:Show()
    elseif GetQuestLogRewardMoney(questID) > 0 then
        self.Reward:SetTexture([[Interface\Icons\INV_MISC_COIN_01]])
        self.Reward:Show()
    else
        -- if there are no rewards just show the default icon
        self.Display.Icon:Show()
    end

    -- set world quest type indicator
    local questInfo = C_QuestLog.GetQuestTagInfo(questID)
    if questInfo then
        if questInfo.worldQuestType == Enum.QuestTagType.PvP then
            self.Indicator:SetAtlas('Warfronts-BaseMapIcons-Empty-Barracks-Minimap')
            self.Indicator:SetSize(18, 18)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.PetBattle then
            self.Indicator:SetAtlas('WildBattlePetCapturable')
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Profession then
            self.Indicator:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[questInfo.tradeskillLineID])
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Dungeon then
            self.Indicator:SetAtlas('Dungeon')
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Raid then
            self.Indicator:SetAtlas('Raid')
            self.Indicator:SetSize(20, 20)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.Invasion then
            self.Indicator:SetAtlas('worldquest-icon-burninglegion')
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        elseif questInfo.worldQuestType == Enum.QuestTagType.FactionAssault then
            self.Indicator:SetAtlas(FACTION_ASSAULT_ATLAS)
            self.Indicator:SetSize(10, 10)
            self.Indicator:Show()
        end
    end

    -- update bounty icon
    local bountyQuestID = self.dataProvider:GetBountyInfo()
    if bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID) then
        self.Bounty:Show()
    end

    -- highlight reputation
    local _, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
    if factionID then
        local factionInfo = C_Reputation.GetFactionDataByID(factionID)
        if factionInfo and factionInfo.isWatched then
            self.Reputation:Show()
        end
    end
end

function BetterWorldQuestPinMixin:AddIconWidgets()
    -- remove the obnoxious glow behind world bosses
end

function BetterWorldQuestPinMixin:SetPassThroughButtons()
    -- https://github.com/Stanzilla/WoWUIBugs/issues/453
end

----------------------------------
-- storm.lua
----------------------------------

local DRAGON_ISLES_MAPS = {
    [2022] = true, -- The Walking Shores
    [2023] = true, -- Ohn'ahran Plains
    [2024] = true, -- The Azure Span
    [2025] = true, -- Thaldraszus
}

local function updatePOIs(self)
    local map = self:GetMap()
    local mapID = map:GetMapID()
    if mapID == 1978 then -- Dragon Isles
        for childMapID in next, DRAGON_ISLES_MAPS do
            for _, poiID in next, C_AreaPoiInfo.GetAreaPOIForMap(childMapID) do
                local info = C_AreaPoiInfo.GetAreaPOIInfo(childMapID, poiID)
                if info and bwq:startswith(info.atlasName, 'ElementalStorm') then
                    local x, y = info.position:GetXY()
                    info.dataProvider = self
                    info.position:SetXY(hbd:TranslateZoneCoordinates(x, y, childMapID, mapID))
                    map:AcquirePin(self:GetPinTemplate(), info)
                end
            end
        end
    end
end

for dp in next, WorldMapFrame.dataProviders do
    if not dp.GetPinTemplates and type(dp.GetPinTemplate) == 'function' then
        if dp:GetPinTemplate() == 'AreaPOIPinTemplate' then
            hooksecurefunc(dp, 'RefreshAllData', updatePOIs)
            break
        end
    end
end

----------------------------------
-- poi.lua
----------------------------------

local SPECIAL_ASSIGNMENT_WIDGET_SET = 1108

local provider = CreateFromMixins(AreaPOIDataProviderMixin)
function provider:GetPinTemplate()
    return 'BetterWorldQuestPOITemplate'
end

function provider:RefreshAllData()
    self:RemoveAllData()

    local map = self:GetMap()
    local mapID = map:GetMapID()

    if mapID == 947 then
        return
    end

    if bwq:IsParentMap(mapID) then
        for _, mapInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
            if mapInfo.flags == 6 or mapInfo.flags == 4 then -- TODO: do bitwise compare with 0x04
                -- copy from AreaPOIDataProviderMixin
                for _, poiID in next, GetAreaPOIsForPlayerByMapIDCached(mapInfo.mapID) do
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, poiID)
                    if poiInfo and poiInfo.tooltipWidgetSet == SPECIAL_ASSIGNMENT_WIDGET_SET then
                        poiInfo.dataProvider = self

                        -- translate position
                        poiInfo.position = bwq:TranslatePosition(poiInfo.position, mapInfo.mapID, mapID)

                        if poiInfo.position then
                            map:AcquirePin(self:GetPinTemplate(), poiInfo)
                        end
                    end
                end
            end
        end
    end
end

WorldMapFrame:AddDataProvider(provider)

-- hook into changes
local function updateVisuals()
    -- update pins on changes
    if WorldMapFrame:IsShown() then
        provider:RefreshAllData()
    end
end

-- bwq:RegisterOptionCallback('showEvents', updateVisuals)

-- change visibility
-- local modifier
local function toggleVisibility()
    local state = true
    if modifier == 'ALT' then
        state = not IsAltKeyDown()
    elseif modifier == 'SHIFT' then
        state = not IsShiftKeyDown()
    elseif modifier == 'CTRL' then
        state = not IsControlKeyDown()
    end

    for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
        pin:SetShown(state)
    end

    for pin in WorldMapFrame:EnumeratePinsByTemplate('AreaPOIPinTemplate') do
        local poiInfo = pin:GetPoiInfo()
        if poiInfo and poiInfo.tooltipWidgetSet == SPECIAL_ASSIGNMENT_WIDGET_SET then
            pin:SetShown(state)
        end
    end
end

WorldMapFrame:HookScript('OnHide', function()
    toggleVisibility()
end)

-- bwq:RegisterOptionCallback('hideModifier', function(value)
--     if value == 'NEVER' then
--         if bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:UnregisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = nil
--         toggleVisibility()
--     else
--         if not bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:RegisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = value
--     end
-- end)

----------------------------------
-- event.lua
----------------------------------

local provider = CreateFromMixins(AreaPOIEventDataProviderMixin)
function provider:GetPinTemplate()
    return 'BetterWorldQuestEventTemplate'
end

function provider:RefreshAllData()
    self:RemoveAllData()

    if not showEvents then
        return
    end

    local map = self:GetMap()
    local mapID = map:GetMapID()

    if mapID == 947 then
        return
    end

    if bwq:IsParentMap(mapID) then
        for _, mapInfo in next, C_Map.GetMapChildrenInfo(mapID, Enum.UIMapType.Zone, true) do
            if mapInfo.flags == 6 or mapInfo.flags == 4 then -- TODO: do bitwise compare with 0x04
                -- copy from AreaPOIDataProviderMixin
                for _, poiID in next, C_AreaPoiInfo.GetEventsForMap(mapInfo.mapID) do
                    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapInfo.mapID, poiID)
                    if poiInfo then
                        poiInfo.dataProvider = self

                        -- translate position
                        poiInfo.position = bwq:TranslatePosition(poiInfo.position, mapInfo.mapID, mapID)

                        if poiInfo.position then
                            map:AcquirePin(self:GetPinTemplate(), poiInfo)
                        end
                    end
                end
            end
        end
    end
end

WorldMapFrame:AddDataProvider(provider)

-- hook into changes
local function updateVisuals()
    -- update pins on changes
    if WorldMapFrame:IsShown() then
        provider:RefreshAllData()
    end
end

-- bwq:RegisterOptionCallback('showEvents', updateVisuals)

-- change visibility
-- local modifier
local function toggleVisibility()
    local state = true
    if modifier == 'ALT' then
        state = not IsAltKeyDown()
    elseif modifier == 'SHIFT' then
        state = not IsShiftKeyDown()
    elseif modifier == 'CTRL' then
        state = not IsControlKeyDown()
    end

    for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
        pin:SetShown(state)
    end
end

WorldMapFrame:HookScript('OnHide', function()
    toggleVisibility()
end)

-- bwq:RegisterOptionCallback('hideModifier', function(value)
--     if value == 'NEVER' then
--         if bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:UnregisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = nil
--         toggleVisibility()
--     else
--         if not bwq:IsEventRegistered('MODIFIER_STATE_CHANGED', toggleVisibility) then
--             bwq:RegisterEvent('MODIFIER_STATE_CHANGED', toggleVisibility)
--         end

--         modifier = value
--     end
-- end)
