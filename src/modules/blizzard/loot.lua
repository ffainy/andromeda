-- Credit: Haste
-- https://github.com/haste/Butsu

local F, C, L = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

local lootFrame
local iconSize = 32
local slotWidth = 160
local slotHeight = 64

local coinTextureIDs = {
    [133784] = true,
    [133785] = true,
    [133786] = true,
    [133787] = true,
    [133788] = true,
    [133789] = true,
}

local function onEnter(slot)
    local id = slot:GetID()
    if LootSlotHasItem(id) then
        GameTooltip:SetOwner(slot, 'ANCHOR_RIGHT')
        GameTooltip:SetLootItem(id)

        CursorUpdate(slot)
    end

    slot.drop:Show()
    slot.drop:SetVertexColor(1, 1, 0)
end

local function onLeave(slot)
    if slot.quality and (slot.quality > 1) then
        local color = ITEM_QUALITY_COLORS[slot.quality]
        slot.drop:SetVertexColor(color.r, color.g, color.b)
    else
        slot.drop:Hide()
    end

    GameTooltip:Hide()

    ResetCursor()
end

local function onClick(slot)
    local frame = LootFrame
    frame.selectedQuality = slot.quality
    frame.selectedItemName = slot.name:GetText()
    frame.selectedTexture = slot.icon:GetTexture()
    frame.selectedLootButton = slot:GetName()
    frame.selectedSlot = slot:GetID()

    if IsModifiedClick() then
        HandleModifiedItemClick(GetLootSlotLink(frame.selectedSlot))
    else
        StaticPopup_Hide('CONFIRM_LOOT_DISTRIBUTION')
        LootSlot(frame.selectedSlot)
    end
end

local function onShow(slot)
    if GameTooltip:IsOwned(slot) then
        GameTooltip:SetOwner(slot, 'ANCHOR_RIGHT')
        GameTooltip:SetLootItem(slot:GetID())

        CursorOnUpdate(slot)
    end
end

local function onHide()
    StaticPopup_Hide('CONFIRM_LOOT_DISTRIBUTION')
    CloseLoot()

    if MasterLooterFrame then
        MasterLooterFrame:Hide()
    end
end

local function constructLootSlot(id)
    local size = (iconSize - 2)

    local f = CreateFrame('Button', C.ADDON_TITLE .. 'LootSlot' .. id, lootFrame)
    f:SetPoint('LEFT', 8, 0)
    f:SetPoint('RIGHT', -8, 0)
    f:SetHeight(size)
    f:SetID(id)
    f.bg = F.SetBD(f)

    f:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    f:SetScript('OnEnter', onEnter)
    f:SetScript('OnLeave', onLeave)
    f:SetScript('OnClick', onClick)
    f:SetScript('OnShow', onShow)

    local iconFrame = CreateFrame('Frame', nil, f)
    iconFrame:SetSize(size, size)
    iconFrame:SetPoint('RIGHT', f, 'LEFT', -4, 0)
    iconFrame.bg = F.SetBD(iconFrame)
    f.iconFrame = iconFrame

    local icon = iconFrame:CreateTexture(nil, 'ARTWORK')
    icon:SetTexCoord(unpack(C.TEX_COORD))
    icon:SetInside(iconFrame)
    f.icon = icon

    local outline = ANDROMEDA_ADB.FontOutline

    local count = F.CreateFS(
        iconFrame,
        C.Assets.Fonts.Condensed, 12, outline or nil,
        nil, nil, outline and 'NONE' or 'THICK',
        'TOP', 1, -2
    )
    f.count = count

    local name = F.CreateFS(
        f,
        C.Assets.Fonts.Regular, 12, outline or nil,
        nil, nil, outline and 'NONE' or 'THICK'
    )
    name:SetPoint('RIGHT', f)
    name:SetPoint('LEFT', icon, 'RIGHT', 8, 0)
    name:SetJustifyH('LEFT')
    name:SetNonSpaceWrap(true)
    f.name = name

    local drop = f:CreateTexture(nil, 'ARTWORK')
    drop:SetTexture('Interface\\QuestFrame\\UI-QuestLogTitleHighlight')
    drop:SetPoint('LEFT', icon, 'RIGHT', 0, 0)
    drop:SetPoint('RIGHT', f)
    drop:SetAllPoints(f)
    drop:SetAlpha(0.3)
    f.drop = drop

    local questTexture = iconFrame:CreateTexture(nil, 'OVERLAY')
    questTexture:SetInside()
    questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
    questTexture:SetTexCoord(unpack(C.TEX_COORD))
    f.questTexture = questTexture

    lootFrame.slots[id] = f

    return f
end

local function anchorLootSlots(frame)
    local shownSlots = 0

    for _, slot in next, frame.slots do
        if slot:IsShown() then
            shownSlots = shownSlots + 1

            slot:SetPoint('TOP', lootFrame, 4, (-8 + iconSize) - (shownSlots * (iconSize + 4)))
        end
    end

    frame:SetHeight(max(shownSlots * iconSize + 16, 20))
end

function BLIZZARD.LOOT_CLOSED()
    StaticPopup_Hide('LOOT_BIND')
    lootFrame:Hide()

    for _, slot in next, lootFrame.slots do
        slot:Hide()
    end
end

function BLIZZARD.LOOT_OPENED(_, autoloot)
    lootFrame:Show()

    if not lootFrame:IsShown() then
        CloseLoot(not autoloot)
    end

    if IsFishingLoot() then
        lootFrame.title:SetText(L['Fishy Loot'])
    elseif not UnitIsFriend('player', 'target') and UnitIsDead('target') then
        lootFrame.title:SetText(UnitName('target'))
    else
        lootFrame.title:SetText(LOOT)
    end

    local x, y = GetCursorPosition()
    x = x / lootFrame:GetEffectiveScale()
    y = y / lootFrame:GetEffectiveScale()

    lootFrame:ClearAllPoints()
    lootFrame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x - 40, y + 20)
    lootFrame:Raise()

    local maxQuality = 0
    local maxWidth = 0
    local numItems = GetNumLootItems()

    if numItems > 0 then
        for i = 1, numItems do
            local slot = lootFrame.slots[i] or constructLootSlot(i)
            local lootIcon, lootName, lootQuantity, _, lootQuality, _, isQuestItem, questID, isActive = GetLootSlotInfo(
                i)
            local color = ITEM_QUALITY_COLORS[lootQuality or 0]

            if coinTextureIDs[lootIcon] then
                lootName = lootName:gsub('\n', ', ')
            end

            if lootIcon then
                if GetLootSlotType(i) == LOOT_SLOT_MONEY then
                    lootName = lootName:gsub('\n', ', ')
                end

                if lootQuantity and lootQuantity > 1 then
                    slot.count:SetText(lootQuantity)
                    slot.count:Show()
                else
                    slot.count:Hide()
                end

                if lootQuality and (lootQuality > 1) then
                    slot.iconFrame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
                    if slot.iconFrame.bg.__shadow then
                        slot.iconFrame.bg.__shadow:SetBackdropBorderColor(color.r, color.g, color.b, 0.25)
                    end

                    slot.drop:SetVertexColor(color.r, color.g, color.b)
                    slot.drop:Show()
                else
                    slot.iconFrame.bg:SetBackdropBorderColor(0, 0, 0)
                    if slot.iconFrame.bg.__shadow then
                        slot.iconFrame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, 0.25)
                    end

                    slot.drop:Hide()
                end

                slot.quality = lootQuality
                slot.name:SetTextColor(color.r, color.g, color.b)
                slot.icon:SetTexture(lootIcon)
                -- slot.name:SetWordWrap(false)

                if lootQuantity > 1 then
                    slot.name:SetText(lootName .. ' (' .. lootQuantity .. ')')
                else
                    slot.name:SetText(lootName)
                end

                maxWidth = max(maxWidth, slot.name:GetStringWidth())

                if lootQuality then
                    maxQuality = max(maxQuality, lootQuality)
                end

                local questTexture = slot.questTexture
                if questID and not isActive then
                    questTexture:Show()
                    F.ShowOverlayGlow(slot.iconFrame)
                elseif questID or isQuestItem then
                    questTexture:Hide()
                    F.ShowOverlayGlow(slot.iconFrame)
                else
                    questTexture:Hide()
                    F.HideOverlayGlow(slot.iconFrame)
                end

                if lootIcon then
                    slot:Enable()
                    slot:Show()
                end
            end
        end
    else
        local slot = lootFrame.slots[1] or constructLootSlot(1)
        local color = ITEM_QUALITY_COLORS[0]

        slot.name:SetText(L['No Loot'])
        slot.name:SetTextColor(color.r, color.g, color.b)
        slot.icon:SetTexture()

        maxWidth = max(maxWidth, slot.name:GetStringWidth())

        slot.count:Hide()
        slot.drop:Hide()
        slot:Disable()
        slot:Show()
    end

    anchorLootSlots(lootFrame)

    lootFrame:SetWidth(max(maxWidth + 60, lootFrame.title:GetStringWidth() + 5))
end

function BLIZZARD.LOOT_SLOT_CLEARED(_, id)
    if not lootFrame:IsShown() then
        return
    end

    local slot = lootFrame.slots[id]
    if slot then
        slot:Hide()
    end

    anchorLootSlots(lootFrame)
end

function BLIZZARD.OPEN_MASTER_LOOT_LIST()
    MasterLooterFrame_Show(LootFrame.selectedLootButton)
end

function BLIZZARD.UPDATE_MASTER_LOOT_LIST()
    if LootFrame.selectedLootButton then
        MasterLooterFrame_UpdatePlayers()
    end
end

local function constructLootFrame()
    lootFrame = CreateFrame('Button', C.ADDON_TITLE .. 'LootFrame', UIParent)
    lootFrame:SetFrameStrata('HIGH')
    lootFrame:SetClampedToScreen(true)
    lootFrame:SetSize(slotWidth, slotHeight)
    lootFrame:SetClampedToScreen(true)
    lootFrame:SetFrameStrata(LootFrame:GetFrameStrata())
    lootFrame:SetToplevel(true)
    lootFrame:Hide()
    lootFrame:SetScript('OnHide', onHide)

    local outline = ANDROMEDA_ADB.FontOutline
    lootFrame.title = F.CreateFS(
        lootFrame, C.Assets.Fonts.Bold, 12, outline or nil,
        '', nil, outline and 'NONE' or 'THICK'
    )
    lootFrame.title:SetPoint('BOTTOM', lootFrame, 'TOP')

    lootFrame.slots = {}

    LootFrame:UnregisterAllEvents()
    tinsert(UISpecialFrames, C.ADDON_TITLE .. 'LootFrame')
end

function BLIZZARD:EnhancedLoot()
    if not C.DB.General.EnhancedLoot then
        return
    end

    constructLootFrame()

    -- fix blizzard setpoint connection
    hooksecurefunc(MasterLooterFrame, 'Hide', MasterLooterFrame.ClearAllPoints)

    F:RegisterEvent('LOOT_OPENED', BLIZZARD.LOOT_OPENED)
    F:RegisterEvent('LOOT_SLOT_CLEARED', BLIZZARD.LOOT_SLOT_CLEARED)
    F:RegisterEvent('LOOT_CLOSED', BLIZZARD.LOOT_CLOSED)
    F:RegisterEvent('OPEN_MASTER_LOOT_LIST', BLIZZARD.OPEN_MASTER_LOOT_LIST)
    F:RegisterEvent('UPDATE_MASTER_LOOT_LIST', BLIZZARD.UPDATE_MASTER_LOOT_LIST)
end

-- Faster auto loot
local tDelay = 0
local lootDelay = 0.3

function BLIZZARD.LOOT_READY()
    if GetCVarBool('autoLootDefault') ~= IsModifiedClick('AUTOLOOTTOGGLE') then
        if (GetTime() - tDelay) >= lootDelay then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end

            tDelay = GetTime()
        end
    end
end

function BLIZZARD:FasterLoot()
    if C.DB.General.FasterLoot then
        F:RegisterEvent('LOOT_READY', BLIZZARD.LOOT_READY)
    else
        F:UnregisterEvent('LOOT_READY', BLIZZARD.LOOT_READY)
    end
end
