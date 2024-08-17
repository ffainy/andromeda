local F, C, L = unpack(select(2, ...))
local BR = F:RegisterModule('BuffReminder')

local buffsList = {
    ITEMS = {
        {
            itemID = 190384, -- 9.0永久属性符文
            spells = {
                [393438] = true, -- 巨龙强化符文 itemID 201325
                [367405] = true, -- 永久符文buff
            },
            instance = true,
            disable = true, -- 禁用直到出了新符文
        },
        {
            itemID = 194307, -- 巢穴守护者的诺言
            spells = {
                [394457] = true,
            },
            equip = true,
            instance = true,
            inGroup = true,
        },
    },
    MAGE = {
        {
            spells = {
                -- 奥术魔宠
                [210126] = true,
            },
            depend = 205022,
            spec = 1,
            combat = true,
            instance = true,
            pvp = true,
        },
        {
            spells = {
                -- 奥术智慧
                [1459] = true,
            },
            depend = 1459,
            instance = true,
        },
    },
    PRIEST = {
        {
            spells = {
                -- 真言术耐
                [21562] = true,
            },
            depend = 21562,
            instance = true,
        },
    },
    WARRIOR = {
        {
            spells = {
                -- 战斗怒吼
                [6673] = true,
            },
            depend = 6673,
            instance = true,
        },
    },
    SHAMAN = {
        {
            spells = {
                [192106] = true, -- 闪电之盾
                [974] = true, -- 大地之盾
                [52127] = true, -- 水之护盾
            },
            depend = 192106,
            combat = true,
            instance = true,
            pvp = true,
        },
        {
            spells = {
                [33757] = true, -- 风怒武器
            },
            depend = 33757,
            combat = true,
            instance = true,
            pvp = true,
            weaponIndex = 1,
            spec = 2,
        },
        {
            spells = {
                [318038] = true, -- 火舌武器
            },
            depend = 318038,
            combat = true,
            instance = true,
            pvp = true,
            weaponIndex = 2,
            spec = 2,
        },
        {
            spells = { -- 天怒
                [462854] = true,
            },
            depend = 462854,
            instance = true,
        },
    },
    ROGUE = {
        {
            spells = {
                -- 伤害类毒药
                [2823] = true, -- 致命药膏
                [8679] = true, -- 致伤药膏
                [315584] = true, -- 速效药膏
                [381664] = true, -- 增效药膏
            },
            texture = 132273,
            depend = 315584,
            combat = true,
            instance = true,
            pvp = true,
        },
        {
            spells = {
                -- 效果类毒药
                [3408] = true, -- 减速药膏
                [5761] = true, -- 迟钝药膏
                [381637] = true, -- 萎缩药膏
            },
            depend = 3408,
            pvp = true,
        },
    },
    EVOKER = {
        {
            spells = { -- 青铜龙的祝福
                [381748] = true,
            },
            depend = 364342,
            instance = true,
        },
    },
    DRUID = {
        {
            spells = { -- 野性印记
                [1126] = true,
            },
            depend = 1126,
            instance = true,
        },
    },
}

local groups = buffsList[C.MY_CLASS]
local iconSize = 36
local frames, parentFrame = {}

function BR:Reminder_Update(cfg)
    local frame = cfg.frame
    local depend = cfg.depend
    local spec = cfg.spec
    local combat = cfg.combat
    local instance = cfg.instance
    local pvp = cfg.pvp
    local itemID = cfg.itemID
    local equip = cfg.equip
    local inGroup = cfg.inGroup
    local isPlayerSpell, isRightSpec, isEquipped, isGrouped, isInCombat, isInInst, isInPVP = true, true, true, true
    local inInst, instType = IsInInstance()
    local weaponIndex = cfg.weaponIndex

    if itemID then
        if inGroup and GetNumGroupMembers() < 2 then
            isGrouped = false
        end
        if equip and not IsEquippedItem(itemID) then
            isEquipped = false
        end
        if GetItemCount(itemID) == 0 or not isEquipped or not isGrouped or GetItemCooldown(itemID) > 0 then
            frame:Hide()
            return
        end
    end

    if depend and not IsPlayerSpell(depend) then
        isPlayerSpell = false
    end
    if spec and spec ~= GetSpecialization() then
        isRightSpec = false
    end
    if combat and InCombatLockdown() then
        isInCombat = true
    end
    if instance and inInst and (instType == 'scenario' or instType == 'party' or instType == 'raid') then
        isInInst = true
    end
    if pvp and (instType == 'arena' or instType == 'pvp' or GetZonePVPInfo() == 'combat') then
        isInPVP = true
    end
    if not combat and not instance and not pvp then
        isInCombat, isInInst, isInPVP = true, true, true
    end

    frame:Hide()
    if
        isPlayerSpell
        and isRightSpec
        and (isInCombat or isInInst or isInPVP)
        and not UnitInVehicle('player')
        and not UnitIsDeadOrGhost('player')
    then
        if weaponIndex then
            local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
            if (hasMainHandEnchant and weaponIndex == 1) or (hasOffHandEnchant and weaponIndex == 2) then
                frame:Hide()
                return
            end
        else
            for i = 1, 40 do
                local auraData = C_UnitAuras.GetBuffDataByIndex('player', i, 'HELPFUL')
                if not auraData then
                    break
                end
                if auraData.spellId and cfg.spells[auraData.spellId] then
                    frame:Hide()
                    return
                end
            end
        end
        frame:Show()
    end
end

function BR:Reminder_Create(cfg)
    local outline = _G.ANDROMEDA_ADB.FontOutline
    local frame = CreateFrame('Frame', nil, parentFrame)
    frame:SetSize(iconSize, iconSize)
    F.PixelIcon(frame)
    F.CreateSD(frame)
    local texture = cfg.texture
    if not texture then
        for spellID in pairs(cfg.spells) do
            texture = C_Spell.GetSpellTexture(spellID)
            break
        end
    end
    frame.Icon:SetTexture(texture)
    frame.text = F.CreateFS(
        frame,
        C.Assets.Fonts.Regular,
        12,
        outline or nil,
        L['lacking'],
        'RED',
        outline and 'NONE' or 'THICK',
        'TOP',
        1,
        15
    )
    frame:Hide()
    cfg.frame = frame

    tinsert(frames, frame)
end

function BR:Reminder_UpdateAnchor()
    local index = 0
    local offset = iconSize + 5
    for _, frame in next, frames do
        if frame:IsShown() then
            frame:SetPoint('LEFT', offset * index, 0)
            index = index + 1
        end
    end
    parentFrame:SetWidth(offset * index)
end

function BR:Reminder_OnEvent()
    for _, cfg in pairs(groups) do
        if not cfg.frame then
            BR:Reminder_Create(cfg)
        end
        BR:Reminder_Update(cfg)
    end
    BR:Reminder_UpdateAnchor()
end

function BR:Reminder_AddItemGroup()
    for _, value in pairs(buffsList['ITEMS']) do
        if not value.disable and C_Item.GetItemCount(value.itemID) > 0 then
            if not value.texture then
                value.texture = C_Item.GetItemIconByID(value.itemID)
            end
            if not groups then
                groups = {}
            end
            tinsert(groups, value)
        end
    end
end

function BR:OnLogin()
    BR:Reminder_AddItemGroup()

    if not groups or not next(groups) then
        return
    end

    if C.DB.Combat.BuffReminder then
        if not parentFrame then
            parentFrame = CreateFrame('Frame', nil, UIParent)
            parentFrame:SetPoint('TOP', 0, -100)
            parentFrame:SetSize(iconSize, iconSize)
        end
        parentFrame:Show()

        BR:Reminder_OnEvent()
        F:RegisterEvent('UNIT_AURA', BR.Reminder_OnEvent, 'player')
        F:RegisterEvent('UNIT_EXITED_VEHICLE', BR.Reminder_OnEvent)
        F:RegisterEvent('UNIT_ENTERED_VEHICLE', BR.Reminder_OnEvent)
        F:RegisterEvent('PLAYER_REGEN_ENABLED', BR.Reminder_OnEvent)
        F:RegisterEvent('PLAYER_REGEN_DISABLED', BR.Reminder_OnEvent)
        F:RegisterEvent('ZONE_CHANGED_NEW_AREA', BR.Reminder_OnEvent)
        F:RegisterEvent('PLAYER_ENTERING_WORLD', BR.Reminder_OnEvent)
        F:RegisterEvent('WEAPON_ENCHANT_CHANGED', BR.Reminder_OnEvent)
    else
        if parentFrame then
            parentFrame:Hide()
            F:UnregisterEvent('UNIT_AURA', BR.Reminder_OnEvent)
            F:UnregisterEvent('UNIT_EXITED_VEHICLE', BR.Reminder_OnEvent)
            F:UnregisterEvent('UNIT_ENTERED_VEHICLE', BR.Reminder_OnEvent)
            F:UnregisterEvent('PLAYER_REGEN_ENABLED', BR.Reminder_OnEvent)
            F:UnregisterEvent('PLAYER_REGEN_DISABLED', BR.Reminder_OnEvent)
            F:UnregisterEvent('ZONE_CHANGED_NEW_AREA', BR.Reminder_OnEvent)
            F:UnregisterEvent('PLAYER_ENTERING_WORLD', BR.Reminder_OnEvent)
            F:UnregisterEvent('WEAPON_ENCHANT_CHANGED', BR.Reminder_OnEvent)
        end
    end
end
