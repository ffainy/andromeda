local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function updateIconBgAlpha(icon, _, _, _, alpha)
    icon.bg:SetAlpha(alpha)
    if icon.bg.__shadow then
        icon.bg.__shadow:SetAlpha(alpha)
    end
end

local x1, x2, y1, y2 = unpack(C.TEX_COORD)
local function updateIconTexCoord(icon)
    if icon.isCutting then
        return
    end
    icon.isCutting = true

    local width, height = icon:GetSize()
    if width ~= 0 and height ~= 0 then
        local left, right, top, bottom = x1, x2, y1, y2 -- normal icon
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

local function handleIcon(icon)
    updateIconTexCoord(icon)
    hooksecurefunc(icon, 'SetTexCoord', updateIconTexCoord)
    icon.bg = F.SetBD(icon, 0)
    icon.bg:SetBackdropBorderColor(0, 0, 0)
    hooksecurefunc(icon, 'SetVertexColor', updateIconBgAlpha)
end

local function handleBar(f)
    f.bg = F.SetBD(f.bar, 0)
    f.bg:SetFrameLevel(0)
    f.bg:SetBackdropBorderColor(0, 0, 0)
end

local function resetBgLevel(frame)
    if frame.bg then
        frame.bg:SetFrameLevel(0)
    end
end

local function setupIconAndBar(f, fType)
    if fType == 'icon' then
        if not f.styled then
            handleIcon(f.icon)
            hooksecurefunc(f, 'SetFrameStrata', resetBgLevel)

            f.styled = true
        end
    elseif fType == 'aurabar' then
        if not f.styled then
            handleBar(f)
            handleIcon(f.icon)
            hooksecurefunc(f, 'SetFrameStrata', resetBgLevel)

            f.styled = true
        end

        f.icon.bg:SetShown(not not f.iconVisible)
    end
end

local function reskinWeakAuras()
    if not ANDROMEDA_ADB.ReskinWeakAuras then
        return
    end

    local WeakAuras = _G['WeakAuras']
    if not WeakAuras or not WeakAuras.Private then
        return
    end

    if WeakAuras.Private.regionPrototype then
        local function OnPrototypeCreate(region)
            setupIconAndBar(region, region.regionType)
        end

        local function OnPrototypeModifyFinish(_, region)
            setupIconAndBar(region, region.regionType)
        end

        hooksecurefunc(WeakAuras.Private.regionPrototype, 'create', OnPrototypeCreate)
        hooksecurefunc(WeakAuras.Private.regionPrototype, 'modifyFinish', OnPrototypeModifyFinish)
    end
end

THEME:RegisterSkin('WeakAuras', reskinWeakAuras)
