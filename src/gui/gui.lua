local F, C, L = unpack(select(2, ...))
local GUI = F:GetModule('GUI')
local ACTIONBAR = F:GetModule('ActionBar')

GUI.width = 700
GUI.height = 640
GUI.exWidth = 260

local guiTab = {}
local guiPage = {}
GUI.Tab = guiTab
GUI.Page = guiPage
GUI.NeedUIReload = nil

local tabsList = {
    L['General'],
    L['Notification'],
    L['Infobar'],
    L['Chat'],
    L['Actionbar'],
    L['Combat'],
    L['Announcement'],
    L['Backpack'],
    L['Map'],
    L['Tooltip'],
    L['Unitframe'],
    L['Groupframe'],
    L['Nameplate'],
    L['Theme'],
    L['Profile'],
    L['About'],
    L['Credits'],
}

local iconsList = {
    'Interface\\ICONS\\Achievement_Raid_TrialOfValor',
    'Interface\\ICONS\\Ability_Mage_ColdAsIce',
    'Interface\\ICONS\\Ability_Paladin_LightoftheMartyr',
    'Interface\\ICONS\\Spell_Shadow_Seduction',
    'Interface\\ICONS\\Achievement_General_StayClassy',
    'Interface\\ICONS\\Achievement_Garrison_Invasion',
    'Interface\\ICONS\\Ability_Warrior_RallyingCry',
    'Interface\\ICONS\\Achievement_Boss_spoils_of_pandaria',
    'Interface\\ICONS\\Achievement_Ashran_Tourofduty',
    'Interface\\ICONS\\Ability_Priest_BindingPrayers',
    'Interface\\ICONS\\Spell_Priest_Pontifex',
    'Interface\\ICONS\\Ability_Mage_MassInvisibility',
    'Interface\\ICONS\\Ability_Paladin_BeaconsOfLight',
    'Interface\\ICONS\\Ability_Hunter_BeastWithin',
    'Interface\\ICONS\\INV_Misc_Blingtron',
    'Interface\\ICONS\\Achievement_WorldEvent_Brewmaster',
    'Interface\\ICONS\\Achievement_Reputation_06',
}

GUI.TexturesList = {
    [1] = {
        texture = C.Assets.Textures.StatusbarNormal,
        name = L['Default'],
    },
    [2] = {
        texture = C.Assets.Textures.StatusbarGradient,
        name = L['Gradient'],
    },
    [3] = {
        texture = C.Assets.Textures.StatusbarFlat,
        name = L['Flat'],
    },
}

function GUI:FormatTextString(str)
    str = gsub(str, '&ADDON_NAME&', C.COLORFUL_ADDON_TITLE)
    str = gsub(str, '*', C.MY_CLASS_COLOR)
    str = gsub(str, '#', '|cffffeccb')
    str = gsub(str, '@', C.GREY_COLOR)

    return str
end

local function addTextureToOption(parent, index)
    local tex = parent[index]:CreateTexture()
    tex:SetInside(nil, 4, 4)
    tex:SetTexture(GUI.TexturesList[index].texture)
    tex:SetVertexColor(0.6, 0.6, 0.6)
end

local function updateValue(key, value, newValue)
    if key == 'ACCOUNT' then
        if newValue ~= nil then
            _G.ANDROMEDA_ADB[value] = newValue
        else
            return _G.ANDROMEDA_ADB[value]
        end
    else
        if newValue ~= nil then
            C.DB[key][value] = newValue
        else
            return C.DB[key][value]
        end
    end
end

local function gearButtonOnEnter(self)
    local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
    local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

    if classColor then
        self.tex:SetVertexColor(C.r, C.g, C.b)
    else
        self.tex:SetVertexColor(newColor.r, newColor.g, newColor.b)
    end
end

local function gearButtonOnLeave(self)
    self.tex:SetVertexColor(0.4, 0.4, 0.4)
end

local function createGearButton(self, name)
    local bu = CreateFrame('Button', name, self)
    bu:SetSize(16, 16)

    local tex = bu:CreateTexture(nil, 'ARTWORK')
    tex:SetAllPoints()
    tex:SetTexture(C.Assets.Textures.Gear)
    tex:SetVertexColor(0.4, 0.4, 0.4)
    -- bu:SetHighlightTexture(C.Assets.Textures.Gear)

    bu.tex = tex

    bu:HookScript('OnEnter', gearButtonOnEnter)
    bu:HookScript('OnLeave', gearButtonOnLeave)

    return bu
end

local function combatLockdown(event)
    if not _G[C.ADDON_TITLE .. 'GUI'] then
        return
    end

    if event == 'PLAYER_REGEN_DISABLED' then
        if _G[C.ADDON_TITLE .. 'GUI']:IsShown() then
            _G[C.ADDON_TITLE .. 'GUI']:Hide()
            F:RegisterEvent('PLAYER_REGEN_ENABLED', combatLockdown)
        end
    else
        _G[C.ADDON_TITLE .. 'GUI']:Show()
        F:UnregisterEvent(event, combatLockdown)
    end
end

function GUI:CheckCombatStatus()
    F:RegisterEvent('PLAYER_REGEN_DISABLED', combatLockdown)
end

local function checkUIReload(name)
    if name and not strfind(name, '%*') then
        GUI.NeedUIReload = true
    end
end

function GUI:CreateGradientLine(frame, width, x, y, x2, y2)
    local fll = F.SetGradient(frame, 'H', 0.7, 0.7, 0.7, 0, 0.5, width, C.MULT)
    fll:SetPoint('TOP', x, y)
    local flr = F.SetGradient(frame, 'H', 0.7, 0.7, 0.7, 0.5, 0, width, C.MULT)
    flr:SetPoint('TOP', x2, y2)
end

local function selectTab(i)
    local r, g, b = C.r, C.g, C.b
    local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
    local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
    local alpha = _G.ANDROMEDA_ADB.ButtonBackdropAlpha

    local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
    local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

    for num = 1, #tabsList do
        if num == i then
            if gradStyle then
                if classColor then
                    guiTab[num].__gradient:SetGradient(
                        'Vertical',
                        CreateColor(r, g, b, 0.25),
                        CreateColor(0, 0, 0, 0.25)
                    )
                else
                    guiTab[num].__gradient:SetGradient(
                        'Vertical',
                        CreateColor(newColor.r, newColor.g, newColor.b, 0.25),
                        CreateColor(0, 0, 0, 0.25)
                    )
                end
            else
                if classColor then
                    guiTab[num].__gradient:SetVertexColor(r, g, b, 0.25)
                else
                    guiTab[num].__gradient:SetVertexColor(newColor.r, newColor.g, newColor.b, 0.25)
                end
            end
            guiTab[num].checked = true
            guiPage[num]:Show()
        else
            if gradStyle then
                guiTab[num].__gradient:SetGradient(
                    'Vertical',
                    CreateColor(color.r, color.g, color.b, alpha),
                    CreateColor(0, 0, 0, 0.25)
                )
            else
                guiTab[num].__gradient:SetVertexColor(color.r, color.g, color.b, alpha)
            end
            guiTab[num].checked = false
            guiPage[num]:Hide()
        end
    end
end

local function tabOnClick(self)
    PlaySound(_G.SOUNDKIT.GS_TITLE_OPTION_OK)
    selectTab(self.index)
end

local function tabOnEnter(self)
    if self.checked then
        return
    end
end

local function tabOnLeave(self)
    if self.checked then
        return
    end
end

local function createTab(parent, i, name)
    local tab = CreateFrame('Button', nil, parent, 'BackdropTemplate')
    tab:SetSize(140, 26)
    F.ReskinButton(tab)
    tab.index = i
    tab:SetPoint('TOPLEFT', 10, -31 * i - 20)

    tab.icon = tab:CreateTexture(nil, 'OVERLAY')
    tab.icon:SetSize(20, 20)
    tab.icon:SetPoint('LEFT', tab, 3, 0)
    tab.icon:SetTexture(iconsList[i])
    F.ReskinIcon(tab.icon)

    local outline = _G.ANDROMEDA_ADB.FontOutline
    tab.text = F.CreateFS(tab, C.Assets.Fonts.Bold, 13, outline or nil, name, nil, outline and 'NONE' or 'THICK')
    tab.text:SetPoint('LEFT', tab.icon, 'RIGHT', 6, 0)

    tab:HookScript('OnEnter', tabOnEnter)
    tab:HookScript('OnLeave', tabOnLeave)
    tab:HookScript('OnClick', tabOnClick)

    return tab
end

local function checkboxOnClick(self)
    updateValue(self.__key, self.__value, self:GetChecked())
    checkUIReload(self.__name)
    if self.__callback then
        self:__callback()
    end
end

local function editboxOnEscapePressed(self)
    self:SetText(updateValue(self.__key, self.__value))
end

local function editboxOnEnterPressed(self)
    updateValue(self.__key, self.__value, self:GetText())
    checkUIReload(self.__name)
    if self.__callback then
        self:__callback()
    end
end

local function sliderOnValueChanged(self, v)
    local current = F:Round(tonumber(v), 2)
    updateValue(self.__key, self.__value, current)
    checkUIReload(self.__name)
    self.value:SetText(current)
    if self.__callback then
        self:__callback()
    end
end

local function updateDropdownSelection(self)
    local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
    local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor
    local dd = self.__owner
    for i = 1, #dd.__options do
        local option = dd.options[i]
        if i == updateValue(dd.__key, dd.__value) then
            if classColor then
                option:SetBackdropColor(C.r, C.g, C.b, 0.25)
            else
                option:SetBackdropColor(newColor.r, newColor.g, newColor.b, 0.25)
            end
            option.selected = true
        else
            option:SetBackdropColor(0.1, 0.1, 0.1, 0.25)
            option.selected = false
        end
    end
end

local abPreStr = {
    [1] =
    'AAB:34:12:12:12:34:12:12:12:34:12:0:12:30:12:12:1:30:12:12:1:32:12:12:12:32:12:12:12:32:12:12:12:26:12:10:30:12:10:   0B33:0B70:  -278B33:278B33:  0R0:-33R0:  0B500:0B536:0B572:  0B112:-202B100',
    [2] =
    'AAB:34:12:12:12:34:12:12:12:34:12:12:12:30:12:12:1:30:12:12:1:32:12:10:10:32:12:10:12:32:12:12:12:26:12:10:30:12:10:  0B33:0B70:  0B106:278B33:    0R0:-33R0:  0B500:0B536:0B572:  0B148:-202B100',
    [3] =
    'AAB:34:12:12:12:34:12:12:12:34:12:12:6:34:12:12:6:30:12:12:1:32:12:10:10:32:12:10:12:32:12:12:12:26:12:10:30:12:10:  0B33:0B70:  -334B33:334B33:  334B33:0R0:  0B500:0B536:0B572:  0B112:-202B100',
}

local function updateBarLayout(self)
    local str = abPreStr[self.index]

    if not str then
        return
    end

    ACTIONBAR:ImportBarLayout(str)
end

local function updateDropdownClick(self)
    local dd = self.__owner
    updateValue(dd.__key, dd.__value, self.index)
    checkUIReload(dd.__name)
    if dd.__callback then
        dd:__callback()
    end

    if dd.__value == 'BarPreset' then
        updateBarLayout(self)
    end
end

local function createOptions(i)
    local outline = _G.ANDROMEDA_ADB.FontOutline
    local parent, offset = guiPage[i].child, 20

    for _, option in pairs(GUI.OptionsList[i]) do
        local optType, key, value, name, horizon, data, callback, tip = unpack(option)
        if optType == 1 then -- checkbox
            local cb = F.CreateCheckbox(parent, true, nil, true)
            cb:SetSize(14, 14)
            cb:SetHitRectInsets(-5, -5, -5, -5)

            if horizon then
                cb:SetPoint('TOPLEFT', 250, -offset + 35)
            else
                cb:SetPoint('TOPLEFT', 20, -offset)
                offset = offset + 35
            end

            cb.__key = key
            cb.__value = value
            cb.__name = name
            cb.__callback = callback

            cb.label =
                F.CreateFS(cb, C.Assets.Fonts.Regular, 12, outline or nil, name, nil, outline and 'NONE' or 'THICK')
            cb.label:SetPoint('LEFT', cb, 'RIGHT', 4, 0)

            cb:SetChecked(updateValue(key, value))
            cb:SetScript('OnClick', checkboxOnClick)

            if data and type(data) == 'function' then
                local bu = createGearButton(parent)
                bu:SetPoint('LEFT', cb.label, 'RIGHT', 2, 0)
                bu:SetScript('OnClick', data)
            end

            if tip then
                cb.tipHeader = name
                F.AddTooltip(cb, 'ANCHOR_TOPLEFT', tip, 'BLUE')
            end
        elseif optType == 2 then -- editbox
            local eb = F.CreateEditbox(parent, 170, 22)
            eb:SetMaxLetters(999)

            if horizon then
                eb:SetPoint('TOPLEFT', 260, -offset + 55)
            else
                eb:SetPoint('TOPLEFT', 20, -offset - 15)
                offset = offset + 70
            end

            eb.__key = key
            eb.__value = value
            eb.__name = name
            eb.__callback = callback
            eb.__default = (key == 'ACCOUNT' and C.AccountSettings[value]) or C.CharacterSettings[key][value]

            eb.label = F.CreateFS(
                eb,
                C.Assets.Fonts.Condensed,
                11,
                outline or nil,
                name,
                nil,
                outline and 'NONE' or 'THICK',
                'CENTER',
                0,
                20
            )
            eb:SetText(updateValue(key, value))

            eb:HookScript('OnEscapePressed', editboxOnEscapePressed)
            eb:HookScript('OnEnterPressed', editboxOnEnterPressed)

            if tip then
                eb.tipHeader = name
                F.AddTooltip(eb, 'ANCHOR_TOPLEFT', tip, 'BLUE')
            end
        elseif optType == 3 then -- slider
            local min, max, step = unpack(data)

            local x, y
            if horizon then
                x, y = 250, -offset + 55
            else
                x, y = 15, -offset - 15
                offset = offset + 70
            end

            local s = F.CreateSlider(parent, name, min, max, step, x, y, 190)
            s.__key = key
            s.__value = value
            s.__name = name
            s.__callback = callback
            s.__default = (key == 'ACCOUNT' and C.AccountSettings[value]) or C.CharacterSettings[key][value]

            s:SetValue(updateValue(key, value))
            s:SetScript('OnValueChanged', sliderOnValueChanged)

            s.value:SetText(F:Round(updateValue(key, value), 2))

            if tip then
                s.tipHeader = name
                F.AddTooltip(s, 'ANCHOR_TOPLEFT', tip, 'BLUE')
            end
        elseif optType == 4 then -- dropdown
            if value == 'UnitframeTextureIndex' or value == 'NameplateTextureIndex' then
                for _, v in ipairs(GUI.TexturesList) do
                    tinsert(data, v.name)
                end
            end

            local dd = F.CreateDropdown(parent, 170, 20, data)
            if horizon then
                dd:SetPoint('TOPLEFT', 260, -offset + 55)
            else
                dd:SetPoint('TOPLEFT', 26, -offset - 15)
                offset = offset + 70
            end

            dd.Text:SetText(data[updateValue(key, value)])

            dd.__key = key
            dd.__value = value
            dd.__name = name
            dd.__options = data
            dd.__callback = callback
            dd.button.__owner = dd
            dd.button:HookScript('OnClick', updateDropdownSelection)

            for j = 1, #data do
                dd.options[j]:HookScript('OnClick', updateDropdownClick)
                if value == 'UnitframeTextureIndex' or value == 'NameplateTextureIndex' then
                    addTextureToOption(dd.options, j) -- texture preview
                end
            end

            dd.label =
                F.CreateFS(dd, C.Assets.Fonts.Condensed, 11, outline or nil, name, nil, outline and 'NONE' or 'THICK')
            dd.label:SetPoint('BOTTOM', dd, 'TOP', 0, 4)
            if tip then
                dd.tipHeader = name
                F.AddTooltip(dd, 'ANCHOR_RIGHT', tip, 'BLUE')
            end
        elseif optType == 5 then -- colorswatch
            local swatch = F.CreateColorSwatch(parent, name, updateValue(key, value))
            swatch:SetSize(22, 14)
            local width = 25 + (horizon or 0) * 115
            if horizon then
                swatch:SetPoint('TOPLEFT', width, -offset + 30)
            else
                swatch:SetPoint('TOPLEFT', width, -offset - 5)
                offset = offset + 35
            end

            swatch.__default = (key == 'ACCOUNT' and C.AccountSettings[value]) or C.CharacterSettings[key][value]
        else -- blank, no optType
            if not key then
                GUI:CreateGradientLine(parent, 230, -115, -offset - 12, 115, -offset - 12)
            end
            offset = offset + 35
        end
    end

    local footer = CreateFrame('Frame', nil, parent) -- Fix bottom space
    footer:SetSize(20, 20)
    footer:SetPoint('TOPLEFT', 25, -offset)
end

local function scrollBarOnMouseWheel(self, delta)
    local scrollBar = self.ScrollBar
    scrollBar:SetValue(scrollBar:GetValue() - delta * 35)
end

local function createGUI(tabIndex)
    if _G[C.ADDON_TITLE .. 'GUI'] then
        _G[C.ADDON_TITLE .. 'GUI']:Show()
        return
    end

    local guiFrame = CreateFrame('Frame', C.ADDON_TITLE .. 'GUI', UIParent)
    tinsert(_G.UISpecialFrames, C.ADDON_TITLE .. 'GUI')
    guiFrame:SetSize(GUI.width, GUI.height)
    guiFrame:SetPoint('CENTER')
    guiFrame:SetFrameStrata('HIGH')
    guiFrame:EnableMouse(true)
    F.CreateMF(guiFrame)
    F.SetBD(guiFrame)

    local verticalLine = F.SetGradient(guiFrame, 'V', 0.5, 0.5, 0.5, 0.25, 0.25, C.MULT, 540)
    verticalLine:SetPoint('TOPLEFT', 160, -50)

    local outline = _G.ANDROMEDA_ADB.FontOutline
    local verStr = format('%s: %s', L['Version'], C.ADDON_VERSION)
    F.CreateFS(
        guiFrame,
        C.ASSET_PATH .. 'fonts\\suez-one.ttf',
        22,
        outline or nil,
        C.COLORFUL_ADDON_TITLE,
        nil,
        outline and 'NONE' or 'THICK',
        'TOP',
        0,
        -4
    )
    F.CreateFS(
        guiFrame,
        C.Assets.Fonts.Condensed,
        10,
        outline or nil,
        verStr,
        { 0.7, 0.7, 0.7 },
        outline and 'NONE' or 'THICK',
        'TOP',
        0,
        -30
    )

    GUI:CreateGradientLine(guiFrame, 140, -70, -26, 70, -26)

    local btnClose = CreateFrame('Button', nil, guiFrame, 'UIPanelButtonTemplate')
    btnClose:SetPoint('BOTTOMRIGHT', -6, 6)
    btnClose:SetSize(80, 24)
    btnClose:SetText(_G.CLOSE)
    btnClose:SetScript('OnClick', function()
        PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
        guiFrame:Hide()
    end)
    F.ReskinButton(btnClose)

    local btnApply = CreateFrame('Button', nil, guiFrame, 'UIPanelButtonTemplate')
    btnApply:SetPoint('RIGHT', btnClose, 'LEFT', -6, 0)
    btnApply:SetSize(80, 24)
    btnApply:SetText(_G.APPLY)
    -- btnApply:Disable()
    btnApply:SetScript('OnClick', function()
        guiFrame:Hide()
        if GUI.NeedUIReload then
            _G.StaticPopup_Show('ANDROMEDA_RELOADUI')
            GUI.NeedUIReload = nil
        end
    end)
    F.ReskinButton(btnApply)

    for i, name in pairs(tabsList) do
        guiTab[i] = createTab(guiFrame, i, name)

        guiPage[i] = CreateFrame('ScrollFrame', nil, guiFrame, 'UIPanelScrollFrameTemplate')
        guiPage[i]:SetPoint('TOPLEFT', 170, -50)
        guiPage[i]:SetSize(500, 540)
        guiPage[i].__bg = F.CreateBDFrame(guiPage[i], 0.25)
        guiPage[i]:Hide()

        guiPage[i].child = CreateFrame('Frame', nil, guiPage[i])
        guiPage[i].child:SetSize(500, 1)
        guiPage[i]:SetScrollChild(guiPage[i].child)
        F.ReskinScroll(guiPage[i].ScrollBar)
        guiPage[i]:SetScript('OnMouseWheel', scrollBarOnMouseWheel)

        createOptions(i)
    end

    GUI:CreateProfileFrame(guiPage[15])
    GUI:CreateAboutFrame(guiPage[16])
    GUI:CreateCreditsFrame(guiPage[17])

    if tabIndex then
        selectTab(tabIndex)
    else
        selectTab(1)
    end
end

function F.ToggleGUI(index)
    if _G[C.ADDON_TITLE .. 'GUI'] then
        if _G[C.ADDON_TITLE .. 'GUI']:IsShown() then
            _G[C.ADDON_TITLE .. 'GUI']:Hide()
        else
            _G[C.ADDON_TITLE .. 'GUI']:Show()
        end
    else
        if index then
            createGUI(index)
        else
            createGUI()
        end
    end
    PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
end

-- insert my button into GameMenuFrame
-- also resize the GameMenuFrame, since tww it's been ridiculously large

do
    -- PlaySound(850) --IG_MAINMENU_OPEN
    -- PlaySound(854) --IG_MAINMENU_QUIT

    local StoreEnabled = C_StorePublic.IsEnabled
    local gameMenuLastButtons = {
        [GAMEMENU_OPTIONS] = 1,
        [BLIZZARD_STORE] = 2,
    }

    local function replaceEditModeButton()
        for button in GameMenuFrame.buttonPool:EnumerateActive() do
            local text = button:GetText()
            if text and text == HUD_EDIT_MODE_MENU then
                button:SetScript('OnClick', function()
                    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
                    F:MoverConsole()
                    HideUIPanel(GameMenuFrame)
                end)
            end
        end
    end

    local function insertButton()
        GameMenuFrame.Header.Text:SetTextColor(C.r, C.g, C.b)

        local anchorIndex = (StoreEnabled and StoreEnabled() and 2) or 1
        for button in GameMenuFrame.buttonPool:EnumerateActive() do
            local text = button:GetText()

            GameMenuFrame.MenuButtons[text] = button -- export these

            local lastIndex = gameMenuLastButtons[text]
            if lastIndex == anchorIndex and GameMenuFrame.AndromedaUI then
                GameMenuFrame.AndromedaUI:SetPoint('TOPLEFT', button, 'BOTTOMLEFT', 0, -10)
            elseif not lastIndex then
                local point, anchor, point2, x, y = button:GetPoint()
                button:SetPoint(point, anchor, point2, x, y - 35)
            end
        end

        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 35)
    end

    local function onClick()
        if InCombatLockdown() then
            UIErrorsFrame:AddMessage(C.RED_COLOR .. ERR_NOT_IN_COMBAT)
            return
        end
        createGUI()
        HideUIPanel(GameMenuFrame)
        PlaySound(850)
    end

    function GUI:CreateAndromedaUIButton()
        if GameMenuFrame.AndromedaUI then return end

        local button = CreateFrame('Button',
            C.ADDON_TITLE .. 'GameMenuButton', GameMenuFrame, 'MainMenuFrameButtonTemplate')
        button:SetScript('OnClick', onClick)
        button:SetSize(144, 21)
        button:SetText(C.COLORFUL_ADDON_TITLE)
        button:SetNormalFontObject('GameFontHighlight')
        button:SetHighlightFontObject('GameFontHighlight')
        button:SetDisabledFontObject('GameFontDisable')
        F.ReskinButton(button)

        GameMenuFrame.AndromedaUI = button
        GameMenuFrame.MenuButtons = {}

        hooksecurefunc(GameMenuFrame, 'Layout', insertButton)
        replaceEditModeButton()
    end
end


function GUI:OnLogin()
    GUI:CreateAndromedaUIButton()
    GUI:CreateCheatSheet()
    GUI:CheckCombatStatus()
end
