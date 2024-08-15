local F, C = unpack(select(2, ...))

local methods = {
    SetIcon = nop,                -- (texture, aspect)
    SetIconAtlas = nop,           -- (atlas, aspect)
    SetIconTexCoord = nop,        -- (a,b,c,d, e,f,g,h)
    SetIconVertexColor = nop,     -- (r,g,b)
    SetUsable = nop,              -- (usable, _usableCharge, _cd, nomana, norange)
    SetDominantColor = nop,       -- (r,g,b)
    SetOverlayIcon = nop,         -- (texture, w, h, ...)
    SetOverlayIconVertexColor = nop, -- (...)
    SetCount = nop,               -- (count)
    SetBinding = nop,             -- (binding)
    SetCooldown = nop,            -- (remain, duration, usable)
    SetCooldownTextShown = nop,   -- (cooldownShown, rechargeShown)
    SetHighlighted = nop,         -- (highlight)
    SetActive = nop,              -- (active)
    SetOuterGlow = nop,           -- (shown)
    SetEquipState = nop,          -- (isInContainer, isInInventory)
    SetShortLabel = nop,          -- (text)
    SetQualityOverlay = nop,      -- (qual)
}

function methods:SetIconVertexColor(r, g, b)
    self.icon:SetVertexColor(r, g, b)
end

function methods:SetDominantColor(r, g, b)
    self.NormalTexture:SetVertexColor(r, g, b)
end

function methods:SetIcon(texture)
    self.icon:SetTexture(texture)
end

function methods:SetHighlighted(highlight)
    self.highlight:SetShown(highlight)
end

function methods:SetActive(state)
    self:SetAlpha(state and 0.2 or 1)
end

local function constructor(name, parent, size)
    if not _G.ANDROMEDA_ADB.ReskinOpie then
        return
    end

    local button = CreateFrame('CheckButton', name, parent, 'ActionButtonTemplate')
    button:SetSize(size, size)
    button:EnableMouse(false)

    local icon = button.icon
    icon:SetMask(C.Assets.Textures.ButtonCircleMask)

    local texture = button.NormalTexture
    texture:ClearAllPoints()
    texture:SetPoint('TOPLEFT', icon, -6, 6)
    texture:SetPoint('BOTTOMRIGHT', icon, 6, -6)
    texture:SetTexture(C.Assets.Textures.ButtonCircleBorder)

    local highlight = button:CreateTexture(nil, 'OVERLAY')
    highlight:SetAllPoints()
    highlight:SetTexture(C.Assets.Textures.ButtonCircleHighlight)
    highlight:SetVertexColor(1, 1, 1, 0.3)
    button.highlight = highlight

    return Mixin(button, methods)
end

F:HookAddOn('OPie', function()
    _G['OPie'].UI:RegisterIndicatorConstructor(C.ADDON_TITLE, {
        name = C.ADDON_TITLE,
        apiLevel = 3,
        CreateIndicator = constructor,
    })
end)
