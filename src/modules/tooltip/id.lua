local F, C, L = unpack(select(2, ...))
local TOOLTIP = F:GetModule('Tooltip')

local LEARNT_STRING = '|cffff0000' .. _G.ALREADY_LEARNED .. '|r'

local typesList = {
    spell = _G.SPELLS .. 'ID:',
    item = _G.ITEMS .. 'ID:',
    quest = _G.QUESTS_LABEL .. 'ID:',
    talent = _G.TALENT .. 'ID:',
    achievement = _G.ACHIEVEMENTS .. 'ID:',
    currency = _G.CURRENCY .. 'ID:',
    azerite = L['Trait'] .. 'ID:',
}

function TOOLTIP:AddLineForId(id, linkType, noadd)
    if self:IsForbidden() then
        return
    end

    if C.DB.Tooltip.ShowIdByAlt and not IsAltKeyDown() then
        return
    end

    for i = 1, self:NumLines() do
        local line = _G[self:GetName() .. 'TextLeft' .. i]
        if not line then
            break
        end
        local text = line:GetText()
        if text and text == linkType then
            return
        end
    end

    if
        self.__isHoverTip
        and linkType == typesList.spell
        and IsPlayerSpell(id)
        and C_MountJournal.GetMountFromSpell(id)
    then
        self:AddLine(LEARNT_STRING)
    end

    if not noadd then
        self:AddLine(' ')
    end

    self:AddDoubleLine(linkType, format(C.INFO_COLOR .. '%s|r', id), 0.5, 0.8, 1)
    self:Show()
end

function TOOLTIP:SetHyperLinkID(link)
    if self:IsForbidden() then
        return
    end

    local linkType, id = strmatch(link, '^(%a+):(%d+)')
    if not linkType or not id then
        return
    end

    if linkType == 'spell' or linkType == 'enchant' or linkType == 'trade' then
        TOOLTIP.AddLineForId(self, id, typesList.spell)
    elseif linkType == 'talent' then
        TOOLTIP.AddLineForId(self, id, typesList.talent, true)
    elseif linkType == 'quest' then
        TOOLTIP.AddLineForId(self, id, typesList.quest)
    elseif linkType == 'achievement' then
        TOOLTIP.AddLineForId(self, id, typesList.achievement)
    elseif linkType == 'item' then
        TOOLTIP.AddLineForId(self, id, typesList.item)
    elseif linkType == 'currency' then
        TOOLTIP.AddLineForId(self, id, typesList.currency)
    end
end

function TOOLTIP:AddIDs()
    if not C.DB.Tooltip.ShowId then
        return
    end

    local GameTooltip = GameTooltip
    local ItemRefTooltip = _G.ItemRefTooltip
    local TooltipDataProcessor = _G.TooltipDataProcessor

    -- Update all
    hooksecurefunc(GameTooltip, 'SetHyperlink', TOOLTIP.SetHyperLinkID)
    hooksecurefunc(ItemRefTooltip, 'SetHyperlink', TOOLTIP.SetHyperLinkID)

    -- Spells
    hooksecurefunc(GameTooltip, 'SetUnitAura', function(self, ...)
        if self:IsForbidden() then
            return
        end

        local auraData = C_UnitAuras.GetAuraDataByIndex(...)
        if not auraData then
            return
        end
        local caster = auraData.sourceUnit
        local id = auraData.spellId
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.spell)
        end

        if caster then
            self:AddLine(' ')
            local name = GetUnitName(caster, true)
            local hexColor = F:RgbToHex(F:UnitColor(caster))
            self:AddDoubleLine(L['From'] .. ':', hexColor .. name)
            self:Show()
        end
    end)

    local function UpdateAuraTip(self, unit, auraInstanceID)
        local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)

        if not data then
            return
        end

        local id, caster = data.spellId, data.sourceUnit
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.spell)
        end

        if caster then
            self:AddLine(' ')
            local name = GetUnitName(caster, true)
            local hexColor = F:RgbToHex(F:UnitColor(caster))
            self:AddDoubleLine(L['From'] .. ':', hexColor .. name)
            self:Show()
        end
    end

    hooksecurefunc(GameTooltip, 'SetUnitBuffByAuraInstanceID', UpdateAuraTip)
    hooksecurefunc(GameTooltip, 'SetUnitDebuffByAuraInstanceID', UpdateAuraTip)

    hooksecurefunc('SetItemRef', function(link)
        local id = tonumber(strmatch(link, 'spell:(%d+)'))
        if id then
            TOOLTIP.AddLineForId(ItemRefTooltip, id, typesList.spell)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
        if self:IsForbidden() then
            return
        end
        if data.id then
            TOOLTIP.AddLineForId(self, data.id, typesList.spell)
        end
    end)

    local function UpdateActionTooltip(self, data)
        if self:IsForbidden() then
            return
        end

        local lineData = data.lines and data.lines[1]
        local tooltipType = lineData and lineData.tooltipType

        if not tooltipType then
            return
        end

        if tooltipType == 0 then -- item
            TOOLTIP.AddLineForId(self, lineData.tooltipID, typesList.item)
        elseif tooltipType == 1 then -- spell
            TOOLTIP.AddLineForId(self, lineData.tooltipID, typesList.spell)
        end
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, UpdateActionTooltip)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, UpdateActionTooltip)

    -- Items
    local function addItemID(self, data)
        if self:IsForbidden() then
            return
        end
        if data.id then
            TOOLTIP.AddLineForId(self, data.id, typesList.item)
        end
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, addItemID)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, addItemID)

    -- Currencies
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(self, data)
        if self:IsForbidden() then
            return
        end
        if data.id then
            TOOLTIP.AddLineForId(self, data.id, typesList.currency)
        end
    end)

    -- Azerite traits
    hooksecurefunc(GameTooltip, 'SetAzeritePower', function(self, _, _, id)
        if id then
            TOOLTIP.AddLineForId(self, id, typesList.azerite, true)
        end
    end)

    -- Quests
    hooksecurefunc('QuestMapLogTitleButton_OnEnter', function(self)
        if self.questID then
            TOOLTIP.AddLineForId(GameTooltip, self.questID, typesList.quest)
        end
    end)
end
