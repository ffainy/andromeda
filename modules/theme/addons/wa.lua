local _G = _G
local select = select
local unpack = unpack
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local F, C = unpack(select(2, ...))
local THEME = F.THEME

local function iconBgOnUpdate(self)
    self:SetAlpha(self.__icon:GetAlpha())
    if self.__shadow then
        self.__shadow:SetAlpha(self.__icon:GetAlpha())
    end
end

local function updateIconTexCoord(icon)
    if icon.isCutting then
        return
    end
    icon.isCutting = true

    local width, height = icon:GetSize()
    if width ~= 0 and height ~= 0 then
        local left, right, top, bottom = unpack(C.TexCoord) -- normal icon
        local ratio = width / height
        if ratio > 1 then -- fat icon
            local offset = (1 - 1 / ratio) / 2
            top = top + offset
            bottom = bottom - offset
        elseif ratio < 1 then -- thin icon
            local offset = (1 - ratio) / 2
            left = left + offset
            bottom = bottom - offset
        end
        icon:SetTexCoord(left, right, top, bottom)
    end

    icon.isCutting = nil
end

local function reskinObject(f, fType)
    if fType == 'icon' then
        if not f.styled then
            updateIconTexCoord(f.icon)
            hooksecurefunc(f.icon, 'SetTexCoord', updateIconTexCoord)
            f.bg = F.SetBD(f, 0)
            -- f.bg:SetFrameStrata('BACKGROUND')
            -- f.bg:SetFrameLevel(0)
            f.bg.__icon = f.icon
            f.bg:HookScript('OnUpdate', iconBgOnUpdate)

            f.styled = true
        end
    elseif fType == 'aurabar' then
        if not f.styled then
            f.bg = F.SetBD(f.bar)
            -- f.bg:SetFrameLevel(0)
            updateIconTexCoord(f.icon)
            hooksecurefunc(f.icon, 'SetTexCoord', updateIconTexCoord)
            f.iconFrame:SetAllPoints(f.icon)
            F.SetBD(f.iconFrame)

            f.styled = true
        end
    end
end

local function reskinWA()
    local regionTypes = _G.WeakAuras.regionTypes
    local Create_Icon, Modify_Icon = regionTypes.icon.create, regionTypes.icon.modify
    local Create_AuraBar, Modify_AuraBar = regionTypes.aurabar.create, regionTypes.aurabar.modify

    regionTypes.icon.create = function(parent, data)
        local region = Create_Icon(parent, data)
        reskinObject(region, 'icon')
        return region
    end

    regionTypes.aurabar.create = function(parent)
        local region = Create_AuraBar(parent)
        reskinObject(region, 'aurabar')
        return region
    end

    regionTypes.icon.modify = function(parent, region, data)
        Modify_Icon(parent, region, data)
        reskinObject(region, 'icon')
    end

    regionTypes.aurabar.modify = function(parent, region, data)
        Modify_AuraBar(parent, region, data)
        reskinObject(region, 'aurabar')
    end

    for weakAura in pairs(_G.WeakAuras.regions) do
        local regions = _G.WeakAuras.regions[weakAura]
        if regions.regionType == 'icon' or regions.regionType == 'aurabar' then
            reskinObject(regions.region, regions.regionType)
        end
    end
end

THEME:LoadWithAddOn('WeakAuras', 'reskin_wa', reskinWA)
