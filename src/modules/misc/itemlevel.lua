local F, C = unpack(select(2, ...))
local IL = F:GetModule('ItemLevel')
local TT = F:GetModule('Tooltip')

local inspectSlots = {
    'Head',
    'Neck',
    'Shoulder',
    'Shirt',
    'Chest',
    'Waist',
    'Legs',
    'Feet',
    'Wrist',
    'Hands',
    'Finger0',
    'Finger1',
    'Trinket0',
    'Trinket1',
    'Back',
    'MainHand',
    'SecondaryHand',
}

function IL:GetSlotAnchor(index)
    if not index then
        return
    end

    if index <= 5 or index == 9 or index == 15 then
        return 'BOTTOMLEFT', 40, 20
    elseif index == 16 then
        return 'BOTTOMRIGHT', -40, 2
    elseif index == 17 then
        return 'BOTTOMLEFT', 40, 2
    else
        return 'BOTTOMRIGHT', -40, 20
    end
end

function IL:CreateItemTexture(slot, relF, x, y)
    local icon = slot:CreateTexture()
    icon:SetPoint(relF, x, y)
    icon:SetSize(14, 14)
    icon:SetTexCoord(unpack(C.TEX_COORD))
    icon.bg = F.ReskinIcon(icon)
    icon.bg:SetFrameLevel(3)
    icon.bg:Hide()

    return icon
end

function IL:ItemString_Expand()
    self:SetWidth(0)
end

function IL:ItemString_Collapse()
    self:SetWidth(100)
end

function IL:CreateItemString(frame, strType)
    if frame.fontCreated then
        return
    end

    local outline = ANDROMEDA_ADB.FontOutline
    for index, slot in pairs(inspectSlots) do
        if index ~= 4 then
            local slotFrame = _G[strType .. slot .. 'Slot']
            slotFrame.iLvlText = F.CreateFS(
                slotFrame,
                C.Assets.Fonts.Condensed, 11, outline or nil,
                '', nil, outline and 'NONE' or 'THICK'
            )
            slotFrame.iLvlText:ClearAllPoints()
            slotFrame.iLvlText:SetPoint('BOTTOMRIGHT', slotFrame, -1, 1)
            local relF, x, y = IL:GetSlotAnchor(index)
            slotFrame.enchantText = F.CreateFS(
                slotFrame,
                C.Assets.Fonts.Condensed, 11, outline or nil,
                '', nil, outline and 'NONE' or 'THICK'
            )
            slotFrame.enchantText:ClearAllPoints()
            slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
            slotFrame.enchantText:SetTextColor(0, 1, 0)

            slotFrame.enchantText:SetJustifyH(strsub(relF, 7))
            slotFrame.enchantText:SetWidth(100)
            slotFrame.enchantText:EnableMouse(true)
            slotFrame.enchantText:HookScript('OnEnter', IL.ItemString_Expand)
            slotFrame.enchantText:HookScript('OnLeave', IL.ItemString_Collapse)
            slotFrame.enchantText:HookScript('OnShow', IL.ItemString_Collapse)

            for i = 1, 10 do
                local offset = (i - 1) * 18 + 5
                local iconX = x > 0 and x + offset or x - offset
                local iconY = index > 15 and 20 or 2
                slotFrame['textureIcon' .. i] = IL:CreateItemTexture(slotFrame, relF, iconX, iconY)
            end
        end
    end

    frame.fontCreated = true
end

local azeriteSlots = {
    [1] = true,
    [3] = true,
    [5] = true,
}

local locationCache = {}
local function GetSlotItemLocation(id)
    if not azeriteSlots[id] then
        return
    end

    local itemLocation = locationCache[id]
    if not itemLocation then
        itemLocation = ItemLocation:CreateFromEquipmentSlot(id)
        locationCache[id] = itemLocation
    end
    return itemLocation
end

function IL:ItemLevel_UpdateTraits(button, id, link)
    local empoweredItemLocation = GetSlotItemLocation(id)
    if not empoweredItemLocation then
        return
    end

    local allTierInfo = TT:Azerite_UpdateTier(link)
    if not allTierInfo then
        return
    end

    for i = 1, 2 do
        local powerIDs = allTierInfo[i] and allTierInfo[i].azeritePowerIDs
        if not powerIDs or powerIDs[1] == 13 then
            break
        end

        for _, powerID in pairs(powerIDs) do
            local selected = C_AzeriteEmpoweredItem.IsPowerSelected(empoweredItemLocation, powerID)
            if selected then
                local spellID = TT:Azerite_PowerToSpell(powerID)
                local name, icon = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
                local texture = button['textureIcon' .. i]
                if name and texture then
                    texture:SetTexture(icon)
                    texture.bg:Show()
                end
            end
        end
    end
end

function IL:ItemLevel_UpdateInfo(slotFrame, info, quality)
    local infoType = type(info)
    local level
    if infoType == 'table' then
        level = info.iLvl
    else
        level = info
    end

    if level and level > 1 and quality and quality > 1 then
        local color = C.QualityColors[quality]
        slotFrame.iLvlText:SetText(level)
        slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
    end

    if infoType == 'table' then
        local enchant = info.enchantText
        if enchant then
            slotFrame.enchantText:SetText(enchant)
        end

        local gemStep, essenceStep = 1, 1
        for i = 1, 10 do
            local texture = slotFrame['textureIcon' .. i]
            local bg = texture.bg
            local gem = info.gems and info.gems[gemStep]
            local color = info.gemsColor and info.gemsColor[gemStep]
            local essence = not gem and (info.essences and info.essences[essenceStep])
            if gem then
                texture:SetTexture(gem)
                if color then
                    bg:SetBackdropBorderColor(color.r, color.g, color.b)
                else
                    bg:SetBackdropBorderColor(0, 0, 0)
                end
                bg:Show()

                gemStep = gemStep + 1
            elseif essence and next(essence) then
                local r = essence[4]
                local g = essence[5]
                local b = essence[6]
                if r and g and b then
                    bg:SetBackdropBorderColor(r, g, b)
                else
                    bg:SetBackdropBorderColor(0, 0, 0)
                end

                local selected = essence[1]
                texture:SetTexture(selected)
                bg:Show()

                essenceStep = essenceStep + 1
            end
        end
    end
end

function IL:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
    C_Timer.After(0.1, function()
        local quality = select(3, C_Item.GetItemInfo(link))
        local info = F.GetItemLevel(link, unit, index, C.DB.General.GemEnchant)
        if info == 'tooSoon' then
            return
        end
        IL:ItemLevel_UpdateInfo(slotFrame, info, quality)
    end)
end

function IL:ItemLevel_SetupLevel(frame, strType, unit)
    if not UnitExists(unit) then
        return
    end

    IL:CreateItemString(frame, strType)

    for index, slot in pairs(inspectSlots) do
        if index ~= 4 then
            local slotFrame = _G[strType .. slot .. 'Slot']
            slotFrame.iLvlText:SetText('')
            slotFrame.enchantText:SetText('')
            for i = 1, 10 do
                local texture = slotFrame['textureIcon' .. i]
                texture:SetTexture(nil)
                texture.bg:Hide()
            end

            local link = GetInventoryItemLink(unit, index)
            if link then
                local quality = select(3, C_Item.GetItemInfo(link))
                local info = F.GetItemLevel(link, unit, index, C.DB.General.GemEnchant)
                if info == 'tooSoon' then
                    IL:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
                else
                    IL:ItemLevel_UpdateInfo(slotFrame, info, quality)
                end

                if strType == 'Character' then
                    IL:ItemLevel_UpdateTraits(slotFrame, index, link)
                end
            end
        end
    end
end

function IL:ItemLevel_UpdatePlayer()
    IL:ItemLevel_SetupLevel(CharacterFrame, 'Character', 'player')
end

function IL:ItemLevel_UpdateInspect(...)
    local guid = ...
    if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
        IL:ItemLevel_SetupLevel(InspectFrame, 'Inspect', InspectFrame.unit)
    end
end

function IL:ItemLevel_FlyoutUpdate(bag, slot, quality)
    if not self.iLvl then
        local outline = ANDROMEDA_ADB.FontOutline
        self.iLvl = F.CreateFS(
            self,
            C.Assets.Fonts.Condensed, 11, outline or nil,
            '', nil, outline and 'NONE' or 'THICK',
            { 'BOTTOMRIGHT', -1, 1 }
        )
    end

    if quality and quality <= 1 then
        return
    end

    local link, level
    if bag then
        link = C_Container.GetContainerItemLink(bag, slot)
        level = F.GetItemLevel(link, bag, slot)
    else
        link = GetInventoryItemLink('player', slot)
        level = F.GetItemLevel(link, 'player', slot)
    end

    local color = C.QualityColors[quality or 0]
    self.iLvl:SetText(level)
    self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function IL:ItemLevel_FlyoutSetup()
    if self.iLvl then
        self.iLvl:SetText('')
    end

    local location = self.location
    if not location then
        return
    end

    if tonumber(location) then
        if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
            return
        end

        local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
        if voidStorage then
            return
        end
        local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
        if bags then
            IL.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
        else
            IL.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
        end
    else
        local itemLocation = self:GetItemLocation()
        local quality = itemLocation and C_Item.GetItemQuality(itemLocation)
        if itemLocation:IsBagAndSlot() then
            local bag, slot = itemLocation:GetBagAndSlot()
            IL.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
        elseif itemLocation:IsEquipmentSlot() then
            local slot = itemLocation:GetEquipmentSlot()
            IL.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
        end
    end
end

function IL:ItemLevel_ScrappingUpdate()
    if not self.iLvl then
        local outline = ANDROMEDA_ADB.FontOutline
        self.iLvl = F.CreateFS(
            self,
            C.Assets.Fonts.Condensed, 11, outline or nil,
            '', nil, outline and 'NONE' or 'THICK',
            { 'BOTTOMRIGHT', -1, 1 }
        )
    end
    if not self.itemLink then
        self.iLvl:SetText('')
        return
    end

    local quality = 1
    if self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
        quality = self.item:GetItemQuality()
    end
    local level = F.GetItemLevel(self.itemLink)
    local color = C.QualityColors[quality]
    self.iLvl:SetText(level)
    self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function IL:ItemLevel_ScrappingSetup()
    for button in self.ItemSlots.scrapButtons:EnumerateActive() do
        if button and not button.iLvl then
            hooksecurefunc(button, 'RefreshIcon', IL.ItemLevel_ScrappingUpdate)
        end
    end
end

function IL.ItemLevel_ScrappingShow(event, addon)
    if addon == 'Blizzard_ScrappingMachineUI' then
        hooksecurefunc(ScrappingMachineFrame, 'SetupScrapButtonPool', IL.ItemLevel_ScrappingSetup)

        F:UnregisterEvent(event, IL.ItemLevel_ScrappingShow)
    end
end

function IL:ItemLevel_UpdateMerchant(link)
    if not self.iLvl then
        local outline = ANDROMEDA_ADB.FontOutline
        self.iLvl = F.CreateFS(
            _G[self:GetName() .. 'ItemButton'],
            C.Assets.Fonts.Condensed, 11, outline or nil,
            '', nil, outline and 'NONE' or 'THICK',
            { 'BOTTOMRIGHT', -1, 1 }
        )
    end
    local quality = link and select(3, C_Item.GetItemInfo(link)) or nil
    if quality and quality > 1 then
        local level = F.GetItemLevel(link)
        local color = C.QualityColors[quality]
        self.iLvl:SetText(level)
        self.iLvl:SetTextColor(color.r, color.g, color.b)
    else
        self.iLvl:SetText('')
    end
end

function IL.ItemLevel_UpdateTradePlayer(index)
    local button = _G['TradePlayerItem' .. index]
    local link = GetTradePlayerItemLink(index)
    IL.ItemLevel_UpdateMerchant(button, link)
end

function IL.ItemLevel_UpdateTradeTarget(index)
    local button = _G['TradeRecipientItem' .. index]
    local link = GetTradeTargetItemLink(index)
    IL.ItemLevel_UpdateMerchant(button, link)
end

local itemCache = {}

function IL.ItemLevel_ReplaceItemLink(link, name)
    if not link then
        return
    end

    local modLink = itemCache[link]
    if not modLink then
        local itemLevel = F.GetItemLevel(link)
        if itemLevel then
            modLink = gsub(link, '|h%[(.-)%]|h', '|h(' .. itemLevel .. F.IsItemHasGem(link) .. ')' .. name .. '|h')
            itemCache[link] = modLink
        end
    end
    return modLink
end

function IL:GuildNewsButtonOnClick(btn)
    if self.isEvent or not self.playerName then
        return
    end
    if btn == 'LeftButton' and IsShiftKeyDown() then
        if MailFrame:IsShown() then
            MailFrameTab_OnClick(nil, 2)
            SendMailNameEditBox:SetText(self.playerName)
            SendMailNameEditBox:HighlightText()
        else
            local editBox = ChatEdit_ChooseBoxForSend()
            local hasText = (editBox:GetText() ~= '')
            ChatEdit_ActivateChat(editBox)
            editBox:Insert(self.playerName)
            if not hasText then
                editBox:HighlightText()
            end
        end
    end
end

function IL:ItemLevel_ReplaceGuildNews(_, _, playerName)
    self.playerName = playerName

    local newText = gsub(self.text:GetText(), '(|Hitem:%d+:.-|h%[(.-)%]|h)', IL.ItemLevel_ReplaceItemLink)
    if newText then
        self.text:SetText(newText)
    end

    if not self.hooked then
        self.text:SetFontObject(Game13Font)
        self:HookScript('OnClick', IL.GuildNewsButtonOnClick) -- copy name by key shift
        self.hooked = true
    end
end

function IL:ItemLevel_UpdateLoot()
    local outline = ANDROMEDA_ADB.FontOutline
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local button = select(i, self.ScrollTarget:GetChildren())
        if button and button.Item and button.GetElementData then
            if not button.iLvl then
                button.iLvl = F.CreateFS(
                    button.Item,
                    C.Assets.Fonts.Condensed, 11, outline or nil,
                    '', nil, outline and 'NONE' or 'THICK',
                    { 'BOTTOMLEFT', 1, 1 }
                )
            end

            local slotIndex = button:GetSlotIndex()
            local quality = select(5, GetLootSlotInfo(slotIndex))
            if quality and quality > 1 then
                local level = F.GetItemLevel(GetLootSlotLink(slotIndex))
                local color = C.QualityColors[quality]
                button.iLvl:SetText(level)
                button.iLvl:SetTextColor(color.r, color.g, color.b)
            else
                button.iLvl:SetText('')
            end
        end
    end
end

function IL:ItemLevel_UpdateBag()
    local button = self.__owner

    if not button.iLvl then
        local outline = ANDROMEDA_ADB.FontOutline
        button.iLvl = F.CreateFS(
            button,
            C.Assets.Fonts.Condensed, 11, outline or nil,
            '', nil, outline and 'NONE' or 'THICK',
            { 'BOTTOMLEFT', 1, 1 }
        )
    end

    local bagID = button.GetBankTabID and button:GetBankTabID() or button:GetBagID()
    local slotID = button.GetContainerSlotID and button:GetContainerSlotID() or button:GetID()
    local info = C_Container.GetContainerItemInfo(bagID, slotID)
    local link = info and info.hyperlink
    local quality = info and info.quality

    if quality and quality > 1 then
        local level = F.GetItemLevel(link, bagID, slotID)
        local color = C.QualityColors[quality]
        button.iLvl:SetText(level)
        button.iLvl:SetTextColor(color.r, color.g, color.b)
    else
        button.iLvl:SetText('')
    end
end

function IL:ItemLevel_HandleSlots()
    for button in self.itemButtonPool:EnumerateActive() do
        if not button.hooked then
            button.IconBorder.__owner = button
            hooksecurefunc(button.IconBorder, 'SetShown', IL.ItemLevel_UpdateBag)
            button.hooked = true
        end
    end
end

function IL:ItemLevel_Containers()
    if C.DB['Inventory']['Enable'] then
        return
    end

    for i = 1, 13 do
        local frame = _G['ContainerFrame' .. i]
        if frame then
            hooksecurefunc(frame, 'UpdateItemSlots', IL.ItemLevel_HandleSlots)
        end
    end

    hooksecurefunc(ContainerFrameCombinedBags, 'UpdateItemSlots', IL.ItemLevel_HandleSlots)
    hooksecurefunc(AccountBankPanel, 'GenerateItemSlotsForSelectedTab', IL.ItemLevel_HandleSlots)
end

function IL:OnLogin()
    if not C.DB.General.ItemLevel then
        return
    end

    -- iLvl on CharacterFrame
    CharacterFrame:HookScript('OnShow', IL.ItemLevel_UpdatePlayer)
    F:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', IL.ItemLevel_UpdatePlayer)

    -- iLvl on InspectFrame
    F:RegisterEvent('INSPECT_READY', IL.ItemLevel_UpdateInspect)

    -- iLvl on FlyoutButtons
    hooksecurefunc('EquipmentFlyout_UpdateItems', function()
        for _, button in pairs(EquipmentFlyoutFrame.buttons) do
            if button:IsShown() then
                IL.ItemLevel_FlyoutSetup(button)
            end
        end
    end)

    -- iLvl on ScrappingMachineFrame
    F:RegisterEvent('ADDON_LOADED', IL.ItemLevel_ScrappingShow)

    -- iLvl on MerchantFrame
    hooksecurefunc('MerchantFrameItem_UpdateQuality', IL.ItemLevel_UpdateMerchant)

    -- iLvl on TradeFrame
    hooksecurefunc('TradeFrame_UpdatePlayerItem', IL.ItemLevel_UpdateTradePlayer)
    hooksecurefunc('TradeFrame_UpdateTargetItem', IL.ItemLevel_UpdateTradeTarget)

    -- iLvl on GuildNews
    hooksecurefunc('GuildNewsButton_SetText', IL.ItemLevel_ReplaceGuildNews)

    -- iLvl on LootFrame
    hooksecurefunc(LootFrame.ScrollBox, 'Update', IL.ItemLevel_UpdateLoot)

    -- iLvl on default Container
    IL:ItemLevel_Containers()
end
