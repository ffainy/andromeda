-- Better World Quests
-- Credit: p3lim
-- https://github.com/p3lim-wow/BetterWorldQuests


local mapScale = 1
local parentScale = 1
local zoomFactor = 0.5

local PARENT_MAPS = {
    -- list of all continents and their sub-zones that have world quests
    [2274] = {         -- Khaz Algar
        [2248] = true, -- Isle of Dorn
        [2215] = true, -- Hallowfall
        [2214] = true, -- The Ringing Deeps
        [2255] = true, -- Azj-Kahet
        [2256] = true, -- Azj-Kahet - Lower (don't know how this works yet)
        [2213] = true, -- City of Threads (not really representable on Algar, TBD)
        [2216] = true, -- City of Threads - Lower (again, don't know how this works)
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
    },
}

local function IsParentMap(mapID)
    return not not PARENT_MAPS[mapID]
end

local provider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin)
provider:SetMatchWorldMapFilters(true)
provider:SetUsesSpellEffect(true)
provider:SetCheckBounties(true)

-- override GetPinTemplate to use our custom pin
function provider:GetPinTemplate()
    return 'BetterWorldQuestPinTemplate'
end

-- override ShouldShowQuest method to also show on parent maps
function provider:ShouldOverrideShowQuest(mapID) --, questInfo)
    local mapInfo = C_Map.GetMapInfo(mapID)
    return mapInfo.mapType == Enum.UIMapType.Continent
end

WorldMapFrame:AddDataProvider(provider)

-- remove the default provider
for dp in next, WorldMapFrame.dataProviders do
    if dp.GetPinTemplate and dp.GetPinTemplate() == 'WorldMap_WorldQuestPinTemplate' then
        WorldMapFrame:RemoveDataProvider(dp)
    end
end

-- change visibility
local modifier
local function toggleVisibility()
    local state = true
    if not WorldMapFrame:IsShown() then
        state = false
    else
        if modifier == 'ALT' then
            state = not IsAltKeyDown()
        elseif modifier == 'SHIFT' then
            state = not IsShiftKeyDown()
        elseif modifier == 'CTRL' then
            state = not IsControlKeyDown()
        end
    end

    for pin in WorldMapFrame:EnumeratePinsByTemplate(provider:GetPinTemplate()) do
        pin:SetShown(state)
    end
end

WorldMapFrame:HookScript('OnHide', function()
    toggleVisibility()
end)







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
    if IsParentMap(self:GetMap():GetMapID()) then
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

local HBD = LibStub('HereBeDragons-2.0')

local DRAGON_ISLES_MAPS = {
    [2022] = true, -- The Walking Shores
    [2023] = true, -- Ohn'ahran Plains
    [2024] = true, -- The Azure Span
    [2025] = true, -- Thaldraszus
}

local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function updatePOIs(self)
    local map = self:GetMap()
    local mapID = map:GetMapID()
    if mapID == 1978 then -- Dragon Isles
        for childMapID in next, DRAGON_ISLES_MAPS do
            for _, poiID in next, C_AreaPoiInfo.GetAreaPOIForMap(childMapID) do
                local info = C_AreaPoiInfo.GetAreaPOIInfo(childMapID, poiID)
                if info and startsWith(info.atlasName, 'ElementalStorm') then
                    local x, y = info.position:GetXY()
                    info.dataProvider = self
                    info.position:SetXY(HBD:TranslateZoneCoordinates(x, y, childMapID, mapID))
                    map:AcquirePin(self:GetPinTemplate(), info)
                end
            end
        end
    end
end

for provider in next, WorldMapFrame.dataProviders do
    if provider.GetPinTemplate and provider:GetPinTemplate() == 'AreaPOIPinTemplate' then
        hooksecurefunc(provider, 'RefreshAllData', updatePOIs)
    end
end
