local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local style = {
    name = 'AndromedaUI',
    border = {
        color = { 0, 0, 0 },
        offset = 0,
        size = 1,
        texture = { 1, 1, 1, 1 },
    },
    title = {
        flags = '',
        shadow = true,
    },
    text = {
        flags = '',
        shadow = true,
    },
    icon = {
        tex_coords = C.TEX_COORD,
    },
    icon_border = {
        color = { 0, 0, 0 },
        offset = 0,
        size = 1,
        texture = { 1, 1, 1, 1 },
    },
    icon_text_1 = {
        flags = '',
    },
    icon_text_2 = {
        flags = '',
    },
    slot = {
        tex_coords = C.TEX_COORD,
    },
    slot_border = {
        color = { 0, 0, 0 },
        offset = 0,
        size = 1,
        texture = { 1, 1, 1, 1 },
    },
    glow = {
        texture = { 1, 1, 1, 1 },
        size = { 226, 50 },
    },
    shine = {
        tex_coords = { 403 / 512, 465 / 512, 15 / 256, 61 / 256 },
        size = { 67, 50 },
        point = {
            y = -1,
        },
    },
    text_bg = {
        hidden = true,
    },
    leaves = {
        hidden = true,
    },
    dragon = {
        hidden = true,
    },
    icon_highlight = {
        hidden = true,
    },
    bg = {
        default = {
            texture = '',
        },
    },
}

local function addBackdrop(event, toast)
    F.SetBD(toast)
end

function THEME:ReskinlsToasts()
    if not ANDROMEDA_ADB.ReskinlsToasts then
        return
    end

    _G['ls_Toasts'][1]:RegisterSkin('AndromedaUI', style)
    _G['ls_Toasts'][1]:RegisterCallback('ToastCreated', addBackdrop)
    _G['ls_Toasts'][2].db.profile.skin = 'AndromedaUI'
end

THEME:RegisterSkin('ls_Toasts', THEME.ReskinlsToasts)
