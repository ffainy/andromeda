local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')
local COOLDOWN = F:GetModule('Cooldown')

local textures = {
    mask = C.Assets.Textures.opie.mask,
    border = C.Assets.Textures.opie.border,
    highlight = C.Assets.Textures.opie.highlight,
}

local methods = {
    SetIcon = nop,                   -- (texture, aspect)
    SetIconAtlas = nop,              -- (atlas, aspect)
    SetIconTexCoord = nop,           -- (a,b,c,d, e,f,g,h)
    SetIconVertexColor = nop,        -- (r,g,b)
    SetUsable = nop,                 -- (usable, _usableCharge, _cd, nomana, norange)
    SetDominantColor = nop,          -- (r,g,b)
    SetOverlayIcon = nop,            -- (texture, w, h, ...)
    SetOverlayIconVertexColor = nop, -- (...)
    SetCount = nop,                  -- (count)
    SetBinding = nop,                -- (binding)
    SetCooldown = nop,               -- (remain, duration, usable)
    SetCooldownTextShown = nop,      -- (cooldownShown, rechargeShown)
    SetHighlighted = nop,            -- (highlight)
    SetActive = nop,                 -- (active)
    SetOuterGlow = nop,              -- (shown)
    SetEquipState = nop,             -- (isInContainer, isInInventory)
    SetShortLabel = nop,             -- (text)
    SetQualityOverlay = nop,         -- (qual)
}

function methods:SetIconVertexColor(r, g, b)
    self.Texture:SetVertexColor(r, g, b)
end

function methods:SetDominantColor(r, g, b)
    self.Border:SetVertexColor(r, g, b)
end

function methods:SetIcon(texture)
    self.Texture:SetTexture(texture)
end

function methods:SetHighlighted(highlight)
    self.Highlight:SetShown(highlight)
end

function methods:SetActive(state)
    self:SetAlpha(state and 0.2 or 1)
end

function methods:SetCooldown(remaining, duration)
    if (duration or 0) <= 0 or (remaining or 0) <= 0 then
        self.Texture:SetAlpha(1)
        self.Border:SetAlpha(1)
        self.Cooldown:SetText('')
    else
        self.Texture:SetAlpha(0.6)
        self.Border:SetAlpha(0.6)
        self.Cooldown:SetText(COOLDOWN.FormattedTimer(remaining, 1))
    end
end

local function constructor(name, parent, size)
    local button = CreateFrame('CheckButton', name, parent)
    button:SetSize(size, size)

    local texture = button:CreateTexture('$parentIcon', 'BACKGROUND')
    texture:SetAllPoints()
    texture:SetMask(textures.mask)
    button.Texture = texture

    local border = button:CreateTexture('$parentBorder', 'OVERLAY')
    border:ClearAllPoints()
    border:SetPoint('TOPLEFT', texture, -1, 1)
    border:SetPoint('BOTTOMRIGHT', texture, 1, -1)
    border:SetTexture(textures.border)
    button.Border = border

    local highlight = button:CreateTexture(nil, 'OVERLAY')
    highlight:SetAllPoints()
    highlight:SetTexture(textures.highlight)
    highlight:SetVertexColor(1, 1, 1, 1)
    button.Highlight = highlight

    local outline = ANDROMEDA_ADB.FontOutline
    local cdText = F.CreateFS(
        button, C.Assets.Fonts.Heavy, 20, outline or nil,
        '', nil, outline and 'NONE' or 'THICK',
        { 'CENTER' }
    )
    button.Cooldown = cdText

    return Mixin(button, methods)
end

F:HookAddOn('OPie', function()
    if not _G.ANDROMEDA_ADB.ReskinOpie then
        return
    end

    _G['OPie'].UI:RegisterIndicatorConstructor(C.ADDON_TITLE, {
        name = C.ADDON_TITLE,
        apiLevel = 3,
        CreateIndicator = constructor,
    })
end)
