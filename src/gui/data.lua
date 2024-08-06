local F, C, L = unpack(select(2, ...))
local GUI = F:GetModule('GUI')
local LibBase64 = F.Libs.LibBase64

local dataFrame

function GUI:ExportData()
    local text = C.ADDON_TITLE .. 'Settings:' .. C.ADDON_VERSION .. ':' .. C.MY_NAME .. ':' .. C.MY_CLASS
    for KEY, VALUE in pairs(C.DB) do
        if type(VALUE) == 'table' then
            for key, value in pairs(VALUE) do
                if type(value) == 'table' then
                    if value.r then
                        for k, v in pairs(value) do
                            text = text .. ';' .. KEY .. ':' .. key .. ':' .. k .. ':' .. v
                        end
                    elseif KEY == 'UIAnchor' then
                        text = text .. ';' .. KEY .. ':' .. key
                        for _, v in ipairs(value) do
                            text = text .. ':' .. tostring(v)
                        end
                    elseif key == 'favourite_items' then
                        text = text .. ';' .. KEY .. ':' .. key
                        for itemID in pairs(value) do
                            text = text .. ':' .. tostring(itemID)
                        end
                    end
                else
                    if C.DB[KEY][key] ~= C.CharacterSettings[KEY][key] then -- don't export default settings
                        text = text .. ';' .. KEY .. ':' .. key .. ':' .. tostring(value)
                    end
                end
            end
        end
    end

    for KEY, VALUE in pairs(_G.ANDROMEDA_ADB) do
        if KEY == 'ProfileIndex' or KEY == 'ProfileNames' then
            for k, v in pairs(VALUE) do
                text = text .. ';ACCOUNT:' .. KEY .. ':' .. k .. ':' .. v
            end
        end
    end

    dataFrame.editBox:SetText(LibBase64:Encode(text))
    dataFrame.editBox:HighlightText()
end

local function toBoolean(value)
    if value == 'true' then
        return true
    elseif value == 'false' then
        return false
    end
end

local function ReloadDefaultSettings()
    for i, j in pairs(C.CharacterSettings) do
        if type(j) == 'table' then
            if not C.DB[i] then
                C.DB[i] = {}
            end
            for k, v in pairs(j) do
                C.DB[i][k] = v
            end
        else
            C.DB[i] = j
        end
    end
end

function GUI:ImportData()
    local profile = dataFrame.editBox:GetText()
    if LibBase64:IsBase64(profile) then
        profile = LibBase64:Decode(profile)
    end
    local options = { strsplit(';', profile) }
    -- local title, _, _, class = strsplit(':', options[1])
    local title = strsplit(':', options[1])
    if title ~= C.ADDON_TITLE .. 'Settings' then
        _G.UIErrorsFrame:AddMessage(C.RED_COLOR .. L['Import failed, due to data exception.'])
        return
    end

    -- we don't export default settings, so need to reload it
    ReloadDefaultSettings()

    for i = 2, #options do
        local option = options[i]
        local key, value, arg1 = strsplit(':', option)
        if arg1 == 'true' or arg1 == 'false' then
            C.DB[key][value] = toBoolean(arg1)
        elseif arg1 == 'EMPTYTABLE' then
            C.DB[key][value] = {}
        elseif strfind(value, 'Color') and (arg1 == 'r' or arg1 == 'g' or arg1 == 'b') then
            local color = select(4, strsplit(':', option))
            if C.DB[key][value] then
                C.DB[key][value][arg1] = tonumber(color)
            end
        elseif key == 'UIAnchor' then
            local relFrom, parent, relTo, x, y = select(3, strsplit(':', option))
            value = tonumber(value) or value
            x = tonumber(x)
            y = tonumber(y)
            C.DB[key][value] = { relFrom, parent, relTo, x, y }
        elseif key == 'ACCOUNT' then
            if value == 'ProfileIndex' then
                local name, index = select(3, strsplit(':', option))
                _G.ANDROMEDA_ADB[value][name] = tonumber(index)
            elseif value == 'ProfileNames' then
                local index, name = select(3, strsplit(':', option))
                _G.ANDROMEDA_ADB[value][tonumber(index)] = name
            end
        elseif tonumber(arg1) then
            if value == 'countdown' then
                C.DB[key][value] = arg1
            else
                C.DB[key][value] = tonumber(arg1)
            end
        end
    end
end

local function UpdateTooltip()
    local profile = dataFrame.editBox:GetText()
    if LibBase64:IsBase64(profile) then
        profile = LibBase64:Decode(profile)
    end
    local option = strsplit(';', profile)
    local title, version, name, class = strsplit(':', option)
    if title == C.ADDON_TITLE .. 'Settings' then
        dataFrame.version = version
        dataFrame.name = name
        dataFrame.class = class
    else
        dataFrame.version = nil
    end
end

function GUI:CreateDataFrame()
    if dataFrame then
        dataFrame:Show()
        return
    end

    dataFrame = CreateFrame('Frame', C.ADDON_TITLE .. 'ProfileData', UIParent)
    dataFrame:SetPoint('CENTER')
    dataFrame:SetSize(500, 500)
    dataFrame:SetFrameStrata('DIALOG')
    F.CreateMF(dataFrame)
    F.SetBD(dataFrame)

    local outline = _G.ANDROMEDA_ADB.FontOutline
    dataFrame.Header = F.CreateFS(
        dataFrame,
        C.Assets.Fonts.Regular,
        14,
        outline or nil,
        L['Export settings'],
        'YELLOW',
        outline and 'NONE' or 'THICK',
        'TOP',
        0,
        -5
    )

    local scrollArea = CreateFrame('ScrollFrame', nil, dataFrame, 'UIPanelScrollFrameTemplate')
    scrollArea:SetPoint('TOPLEFT', 10, -30)
    scrollArea:SetPoint('BOTTOMRIGHT', -28, 40)
    F.CreateBDFrame(scrollArea, 0.25)
    F.ReskinScroll(scrollArea.ScrollBar)

    local editBox = CreateFrame('EditBox', nil, dataFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(99999)
    editBox:EnableMouse(true)
    editBox:SetAutoFocus(true)
    editBox:SetTextInsets(5, 5, 5, 5)
    editBox:SetFont(C.Assets.Fonts.Regular, 12, '')
    editBox:SetWidth(scrollArea:GetWidth())
    editBox:SetHeight(scrollArea:GetHeight())
    editBox:SetScript('OnEscapePressed', function()
        dataFrame:Hide()
    end)
    scrollArea:SetScrollChild(editBox)
    dataFrame.editBox = editBox

    local accept = F.CreateButton(dataFrame, 100, 20, _G.OKAY)
    accept:SetPoint('BOTTOM', 0, 10)
    accept:SetScript('OnClick', function(self)
        if self.text:GetText() ~= _G.OKAY and dataFrame.editBox:GetText() ~= '' then
            _G.StaticPopup_Show('ANDROMEDA_IMPORT_PROFILE')
        end
        dataFrame:Hide()
    end)

    accept:HookScript('OnEnter', function(self)
        if dataFrame.editBox:GetText() == '' then
            return
        end
        UpdateTooltip()

        GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 10)
        GameTooltip:ClearLines()

        if dataFrame.version then
            GameTooltip:AddLine(L['Data info'])
            GameTooltip:AddDoubleLine(L['Version'], dataFrame.version, 0.6, 0.8, 1, 1, 1, 1)
            GameTooltip:AddDoubleLine(L['Character'], dataFrame.name, 0.6, 0.8, 1, F:ClassColor(dataFrame.class))
        else
            GameTooltip:AddLine(L['Data exception'], 1, 0, 0)
        end

        GameTooltip:Show()
    end)

    accept:HookScript('OnLeave', F.HideTooltip)
    dataFrame.text = accept.text

    GUI.ProfileDataFrame = dataFrame
end
