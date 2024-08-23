-- Credit: ElvUI teksLoot

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')


local enableDisenchant = true

local cachedRolls = {}
local cachedIndex = {}
local rollBars = {}

local directionUp = true
local barHalfHeight = true
local barWidth = 328
local barHeight = 28
local fontSize = 14
local parentFrame
local generateName = F.NameGenerator(C.ADDON_TITLE .. 'LootRoll')

local rolltypes = {
    [1] = 'need', [2] = 'greed', [3] = 'disenchant', [4] = 'transmog', [0] = 'pass',
}

local iconCoords = {
    [0] = { -0.05, 1.05, -0.05, 1.05 },  -- pass
    [1] = { 0.025, 1.025, -0.05, 0.95 }, -- need
    [2] = { 0, 1, 0.05, 0.95 },          -- greed
    [3] = { 0, 1, 0, 1 },                -- disenchant
    [4] = { 0, 1, 0, 1 },                -- transmog
}

local rollStateToType = {
    [Enum.EncounterLootDropRollState.NeedMainSpec] = 1,
    -- [Enum.EncounterLootDropRollState.NeedOffSpec] = 1,
    [Enum.EncounterLootDropRollState.Transmog] = 4,
    [Enum.EncounterLootDropRollState.Greed] = 2,
    [Enum.EncounterLootDropRollState.Pass] = 0,
}

local function rollButtonOnClick(button)
    RollOnLoot(button.parent.rollID, button.rolltype)
end

local function rollButtonOnEnter(button)
    GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
    GameTooltip:AddLine(button.tiptext)

    local rollID = button.parent.rollID
    local rolls = rollID and cachedRolls[rollID] and cachedRolls[rollID][button.rolltype]
    if rolls then
        for _, rollerInfo in next, rolls do
            local playerName, className = unpack(rollerInfo)
            local r, g, b = F:ClassColor(className)
            GameTooltip:AddLine(playerName, r, g, b)
        end
    end

    GameTooltip:Show()
end

local function rollButtonOnMouseDown(button)
    if button.highlightTex then
        button.highlightTex:SetAlpha(0)
    end
end

local function rollButtonOnMouseUp(button)
    if button.highlightTex then
        button.highlightTex:SetAlpha(1)
    end
end

local function itemButtonOnEnter(self)
    if not self.link then return end

    GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
    GameTooltip:SetHyperlink(self.link)

    self:RegisterEvent('MODIFIER_STATE_CHANGED')
end

local function itemButtonOnLeave(self)
    GameTooltip_Hide()
    self:UnregisterEvent('MODIFIER_STATE_CHANGED')
end

local function itemButtonOnClick(self)
    if self.link and IsModifiedClick() then
        HandleModifiedItemClick(self.link)
    end
end

local function itemButtonOnEvent(self, _, key)
    if (key == 'LSHIFT' or key == 'RSHIFT') and self:IsMouseOver() and GameTooltip:GetOwner() == self then
        GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
        GameTooltip:SetHyperlink(self.link)
    end
end

local function updateStatus(button, elapsed)
    local bar = button.parent
    if not bar.rollID then
        if not bar.isTest then
            bar:Hide()
        end

        return
    end

    if button.elapsed and button.elapsed > 0.1 then
        local timeLeft = GetLootRollTimeLeft(bar.rollID)
        if timeLeft <= 0 then -- workaround for other addons auto-passing loot
            BLIZZARD.LootRoll_Cancel(bar, nil, bar.rollID)
        else
            button:SetValue(timeLeft)
            button.elapsed = 0
        end
    else
        button.elapsed = (button.elapsed or 0) + elapsed
    end
end



local function handleRollTextureCoords(button, icon, minX, maxX, minY, maxY)
    local offset = icon == button.pushedTex and 0.05 or 0
    icon:SetTexCoord(minX - offset, maxX, minY - offset, maxY)

    if icon == button.disabledTex then
        icon:SetDesaturated(true)
        icon:SetAlpha(0.25)
    end
end

local function handleRollButtonTexture(button, texture, rolltype, atlas)
    if atlas then
        button:SetNormalAtlas(texture)
        button:SetPushedAtlas(texture)
        button:SetDisabledAtlas(texture)
        button:SetHighlightAtlas(texture)
    else
        button:SetNormalTexture(texture)
        button:SetPushedTexture(texture)
        button:SetDisabledTexture(texture)
        button:SetHighlightTexture(texture)
    end

    button.normalTex = button:GetNormalTexture()
    button.disabledTex = button:GetDisabledTexture()
    button.pushedTex = button:GetPushedTexture()
    button.highlightTex = button:GetHighlightTexture()

    local minX, maxX, minY, maxY = unpack(iconCoords[rolltype])
    handleRollTextureCoords(button, button.normalTex, minX, maxX, minY, maxY)
    handleRollTextureCoords(button, button.disabledTex, minX, maxX, minY, maxY)
    handleRollTextureCoords(button, button.pushedTex, minX, maxX, minY, maxY)
    handleRollTextureCoords(button, button.highlightTex, minX, maxX, minY, maxY)
end

local function createRollButton(parent, texture, rolltype, tiptext, points, atlas)
    local button = CreateFrame('Button', nil, parent)
    button:SetPoint(unpack(points))
    button:SetWidth(barHeight - 4)
    button:SetHeight(barHeight - 4)
    button:SetScript('OnMouseDown', rollButtonOnMouseDown)
    button:SetScript('OnMouseUp', rollButtonOnMouseUp)
    button:SetScript('OnClick', rollButtonOnClick)
    button:SetScript('OnEnter', rollButtonOnEnter)
    button:SetScript('OnLeave', GameTooltip_Hide)
    button:SetMotionScriptsWhileDisabled(true)
    button:SetHitRectInsets(3, 3, 3, 3)

    handleRollButtonTexture(button, texture .. '-Up', rolltype, atlas)

    button.parent = parent
    button.rolltype = rolltype
    button.tiptext = tiptext

    local outline = ANDROMEDA_ADB.FontOutline
    button.text = button:CreateFontString(nil, nil)
    button.text:SetFont(C.Assets.Fonts.Bold, fontSize, outline or '')
    button.text:SetPoint('CENTER', 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0)

    return button
end

local function createRollBar(name)
    local bar = CreateFrame('Frame', name or generateName(), UIParent)
    bar:SetSize(barWidth, barHeight)
    bar:SetFrameStrata('MEDIUM')
    bar:SetFrameLevel(10)
    bar:SetScript('OnEvent', BLIZZARD.LootRoll_Cancel)
    bar:RegisterEvent('CANCEL_LOOT_ROLL')
    bar:Hide()

    local button = CreateFrame('Button', nil, bar)
    button:SetPoint('RIGHT', bar, 'LEFT', -(C.MULT * 2), 0)
    button:SetSize(bar:GetHeight() - (C.MULT * 2), bar:GetHeight() - (C.MULT * 2))
    button:SetScript('OnEnter', itemButtonOnEnter)
    button:SetScript('OnLeave', itemButtonOnLeave)
    button:SetScript('OnClick', itemButtonOnClick)
    button:SetScript('OnEvent', itemButtonOnEvent)
    bar.button = button

    button.icon = button:CreateTexture(nil, 'OVERLAY')
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(unpack(C.TEX_COORD))
    button.bg = F.SetBD(button.icon)

    local outline = ANDROMEDA_ADB.FontOutline

    button.stack = F.CreateFS(
        button, C.Assets.Fonts.Condensed, 11, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'TOP', 1, -2 }
    )

    button.ilvl = F.CreateFS(
        button, C.Assets.Fonts.Condensed, 11, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'BOTTOMLEFT', 1, 1 }
    )

    local status = CreateFrame('StatusBar', nil, bar)
    status:SetPoint('TOPLEFT', C.MULT, -(barHalfHeight and bar:GetHeight() / 1.6 or C.MULT))
    status:SetPoint('BOTTOMRIGHT', -C.MULT, C.MULT)
    status:SetScript('OnUpdate', updateStatus)
    status:SetFrameLevel(status:GetFrameLevel() - 1)
    F.CreateStatusbar(status, true)
    status:SetStatusBarColor(.8, .8, .8, .9)
    status.parent = bar
    bar.status = status

    bar.need = createRollButton(
        bar, [[lootroll-toast-icon-need]], 1, NEED,
        { 'LEFT', bar.button, 'RIGHT', 6, 0 }, true
    )
    bar.transmog = createRollButton(
        bar, [[lootroll-toast-icon-transmog]], 4, TRANSMOGRIFICATION,
        { 'LEFT', bar.need, 'RIGHT', 3, 0 }, true
    )
    bar.greed = createRollButton(
        bar, [[lootroll-toast-icon-greed]], 2, GREED,
        { 'LEFT', bar.need, 'RIGHT', 3, 0 }, true
    )
    bar.disenchant = enableDisenchant and
        createRollButton(
            bar, [[lootroll-toast-icon-disenchant]], 3, ROLL_DISENCHANT,
            { 'LEFT', bar.greed, 'RIGHT', 3, 0 }, true
        )
    bar.pass = createRollButton(
        bar, [[lootroll-toast-icon-pass]], 0, PASS,
        { 'LEFT', bar.disenchant or bar.greed, 'RIGHT', 3, 0 }, true
    )

    bar.fsbind = F.CreateFS(
        bar, C.Assets.Fonts.Bold, 12, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'LEFT', bar.pass, 'RIGHT', 5, 0 }
    )


    bar.fsloot = F.CreateFS(
        bar, C.Assets.Fonts.Bold, 12, outline or nil,
        '', nil, outline and 'NONE' or 'THICK'
    )
    bar.fsloot:SetPoint('LEFT', bar.fsbind, 'RIGHT', 5, 0)
    bar.fsloot:SetPoint('RIGHT', bar, 'RIGHT', -5, 0)
    bar.fsloot:SetSize(200, 10)
    bar.fsloot:SetJustifyH('LEFT')

    return bar
end

local function getFrame()
    for _, bar in next, rollBars do
        if not bar.rollID then
            return bar
        end
    end

    local bar = createRollBar()
    if next(rollBars) then
        if directionUp then
            bar:SetPoint('BOTTOM', rollBars[#rollBars], 'TOP', 0, 4)
        else
            bar:SetPoint('TOP', rollBars[#rollBars], 'BOTTOM', 0, -4)
        end
    else
        bar:SetPoint('TOP', parentFrame, 'TOP')
    end

    tinsert(rollBars, bar)
    return bar
end

function BLIZZARD:LootRoll_Start(rollID, rollTime)
    local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired, canTransmog =
        GetLootRollItemInfo(rollID)

    if not name then
        for _, rollBar in next, rollBars do
            if rollBar.rollID == rollID then
                BLIZZARD.LootRoll_Cancel(rollBar, nil, rollID)
            end
        end

        return
    end

    if BLIZZARD.EncounterID and not cachedIndex[BLIZZARD.EncounterID] then
        cachedIndex[BLIZZARD.EncounterID] = rollID
    end

    local link = GetLootRollItemLink(rollID)
    local level = F.GetItemLevel(link)
    local color = ITEM_QUALITY_COLORS[quality]

    local bar = getFrame()
    if not bar then return end

    bar.rollID = rollID
    bar.time = rollTime

    bar.button.icon:SetTexture(texture)
    bar.button.stack:SetText(count > 1 and count or '')
    bar.button.ilvl:SetText(level or '')
    bar.button.ilvl:SetTextColor(color.r, color.g, color.b)
    bar.button.link = link
    bar.button.bg:SetBackdropBorderColor(color.r, color.g, color.b)


    bar.need.text:SetText('')
    bar.need:SetEnabled(canNeed)
    bar.need.tiptext = canNeed and NEED or _G['LOOT_ROLL_INELIGIBLE_REASON' .. reasonNeed]

    bar.transmog.text:SetText('')
    bar.transmog:SetShown(not not canTransmog)
    bar.transmog:SetEnabled(canTransmog)

    bar.greed.text:SetText('')
    bar.greed:SetShown(not canTransmog)
    bar.greed:SetEnabled(canGreed)
    bar.greed.tiptext = canGreed and GREED or _G['LOOT_ROLL_INELIGIBLE_REASON' .. reasonGreed]

    if bar.disenchant then
        bar.disenchant.text:SetText('')
        bar.disenchant:SetEnabled(canDisenchant)
        bar.disenchant.tiptext = canDisenchant and ROLL_DISENCHANT or
            format(_G['LOOT_ROLL_INELIGIBLE_REASON' .. reasonDisenchant], deSkillRequired)
    end

    bar.pass.text:SetText('')

    bar.fsbind:SetText(bop and 'BoP' or 'BoE')
    bar.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)
    bar.fsloot:SetText(name)
    bar.status.elapsed = 1
    bar.status:SetStatusBarColor(color.r, color.g, color.b, .7)
    bar.status:SetMinMaxValues(0, rollTime)
    bar.status:SetValue(rollTime)

    bar:Show()

    local cachedInfo = cachedRolls[rollID]
    if cachedInfo then
        for rollType in pairs(cachedInfo) do
            bar[rolltypes[rollType]].text:SetText(#cachedInfo[rollType])
        end
    end

    F:Debug('RollID: %d %s', rollID, link)
end

local function getRollBarByID(rollID)
    for _, bar in next, rollBars do
        if bar.rollID == rollID then
            return bar
        end
    end
end

function BLIZZARD:LootRoll_GetRollID(encounterID, lootListID)
    local index = cachedIndex[encounterID]
    return index and (index + lootListID - 1)
end

function BLIZZARD:LootRoll_UpdateDrops(encounterID, lootListID)
    local dropInfo = C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID)
    local rollID = BLIZZARD:LootRoll_GetRollID(encounterID, lootListID)
    if rollID then
        cachedRolls[rollID] = {}
        if not dropInfo.allPassed then
            for _, roll in ipairs(dropInfo.rollInfos) do
                local rollType = rollStateToType[roll.state]
                if rollType then
                    cachedRolls[rollID][rollType] = cachedRolls[rollID][rollType] or {}
                    tinsert(cachedRolls[rollID][rollType], { roll.playerName, roll.playerClass })
                end
            end
        end

        local bar = getRollBarByID(rollID)
        if bar then
            for rollType in pairs(cachedRolls[rollID]) do
                bar[rolltypes[rollType]].text:SetText(#cachedRolls[rollID][rollType])
            end
        end
    end
end

function BLIZZARD:LootRoll_EncounterEnd(id, _, _, _, status)
    if status == 1 then
        BLIZZARD.EncounterID = id
    end
end

function BLIZZARD:LootRoll_Cancel(_, rollID)
    if self.rollID == rollID then
        self.rollID = nil
        self.time = nil

        if cachedRolls[rollID] then wipe(cachedRolls[rollID]) end
    end
end

function BLIZZARD:EnhancedLootRoll()
    if not C.DB.General.EnhancedLootRoll then return end

    parentFrame = CreateFrame('Frame', nil, UIParent)
    parentFrame:SetSize(barWidth, barHeight)
    F.Mover(parentFrame, L['Loot Roll'], 'LootRoll', { 'TOP', UIParent, 0, -300 })
    fontSize = barHeight / 2

    -- F:RegisterEvent("LOOT_HISTORY_UPDATE_DROP", self.LootRoll_UpdateDrops)
    F:RegisterEvent('ENCOUNTER_END', self.LootRoll_EncounterEnd)
    F:RegisterEvent('START_LOOT_ROLL', self.LootRoll_Start)

    UIParent:UnregisterEvent('START_LOOT_ROLL')
    UIParent:UnregisterEvent('CANCEL_LOOT_ROLL')
end

local testFrame
local function OnClick_Hide(self)
    self:GetParent():Hide()
end

function BLIZZARD:LootRollTest()
    if not parentFrame then return end

    if testFrame then
        if testFrame:IsShown() then
            testFrame:Hide()
        else
            testFrame:Show()
        end
        return
    end

    testFrame = createRollBar('AndromedaUILootRoll')
    testFrame.isTest = true
    testFrame:Show()
    testFrame:SetPoint('TOP', parentFrame, 'TOP')
    testFrame.need:SetScript('OnClick', OnClick_Hide)
    testFrame.transmog:SetScript('OnClick', OnClick_Hide)
    testFrame.greed:SetScript('OnClick', OnClick_Hide)
    testFrame.greed:Hide()
    if testFrame.disenchant then
        testFrame.disenchant:SetScript('OnClick', OnClick_Hide)
    end
    testFrame.pass:SetScript('OnClick', OnClick_Hide)

    local itemID = 17103
    local bop = 1
    local canTransmog = true
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local name, link, quality, itemLevel, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        local color = ITEM_QUALITY_COLORS[quality]
        testFrame.button.icon:SetTexture(icon)
        testFrame.button.link = link
        testFrame.fsloot:SetText(name)
        testFrame.fsbind:SetText(bop and 'BoP' or 'BoE')
        testFrame.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

        testFrame.transmog:SetShown(not not canTransmog)
        testFrame.greed:SetShown(not canTransmog)

        testFrame.status:SetStatusBarColor(color.r, color.g, color.b, .7)
        testFrame.status:SetMinMaxValues(0, 100)
        testFrame.status:SetValue(80)

        testFrame.button.itemLevel = itemLevel
        testFrame.button.color = color
        testFrame.button.ilvl:SetText(itemLevel or '')
        testFrame.button.ilvl:SetTextColor(color.r, color.g, color.b)
        testFrame.button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    end)
end

F:RegisterSlashCommand('/lootrolltest', function()
    BLIZZARD:LootRollTest()
end)
