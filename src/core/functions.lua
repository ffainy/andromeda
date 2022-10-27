local F, C, L = unpack(select(2, ...))

-- Functions

do
    function F.HelpInfoAcknowledge(callbackArg)
        _G.ANDROMEDA_ADB['HelpTips'][callbackArg] = true
    end

    function F:MultiCheck(check, ...)
        for i = 1, select('#', ...) do
            if check == select(i, ...) then
                return true
            end
        end
        return false
    end

    local tmp = {}
    local function myPrint(...)
        local prefix = format('[%s]', C.COLORFUL_ADDON_TITLE)
        local n = 0

        n = n + 1
        tmp[n] = prefix

        for i = 1, select('#', ...) do
            n = n + 1
            tmp[n] = tostring(select(i, ...))
        end

        local frame = (_G.SELECTED_CHAT_FRAME or _G.DEFAULT_CHAT_FRAME)
        frame:AddMessage(table.concat(tmp, ' ', 1, n))
    end

    function F:Print(...)
        return myPrint(...)
    end

    function F:Printf(...)
        return myPrint(format(...))
    end

    function F:HookAddOn(addonName, callback)
        self:RegisterEvent('ADDON_LOADED', function(_, name)
            if name == addonName then
                callback()
                return true
            elseif name == C.ADDON_NAME and IsAddOnLoaded(addonName) then
                callback()
                return true
            end
        end)
    end

    function F:RegisterSlashCommand(...)
        local name = C.ADDON_TITLE .. 'Slash' .. random()

        local numArgs = select('#', ...)
        local callback = select(numArgs, ...)
        if type(callback) ~= 'function' or numArgs < 2 then
            error('Syntax: RegisterSlashCommand("/slash1"[, "/slash2"], slashFunction)')
        end

        for index = 1, numArgs - 1 do
            local str = select(index, ...)
            if type(str) ~= 'string' then
                error('Syntax: RegisterSlashCommand("/slash1"[, "/slash2"], slashFunction)')
            end

            _G['SLASH_' .. name .. index] = str
        end

        _G.SlashCmdList[name] = callback
    end

    -- Color
    function F:ClassColor(class)
        local color = C.ClassColors[class]
        if not color then
            return 1, 1, 1
        end
        return color.r, color.g, color.b
    end

    function F:UnitColor(unit)
        local r, g, b = 1, 1, 1
        if UnitIsPlayer(unit) then
            local class = select(2, UnitClass(unit))
            if class then
                r, g, b = F:ClassColor(class)
            end
        elseif UnitIsTapDenied(unit) then
            r, g, b = 0.6, 0.6, 0.6
        else
            local reaction = UnitReaction(unit, 'player')
            if reaction then
                local color = _G.FACTION_BAR_COLORS[reaction]
                r, g, b = color.r, color.g, color.b
            end
        end
        return r, g, b
    end

    -- Table
    function F:CopyTable(source, target)
        for key, value in pairs(source) do
            if type(value) == 'table' then
                if not target[key] then
                    target[key] = {}
                end
                for k in pairs(value) do
                    target[key][k] = value[k]
                end
            else
                target[key] = value
            end
        end
    end

    function F:SplitList(list, variable, cleanup)
        if cleanup then
            wipe(list)
        end

        for word in variable:gmatch('%S+') do
            word = tonumber(word) or word -- use number if exists, needs review
            list[word] = true
        end
    end

    -- Atlas info
    function F:GetTextureStrByAtlas(info, sizeX, sizeY)
        local file = info and info.file
        if not file then
            return
        end

        local width, height, txLeft, txRight, txTop, txBottom = info.width, info.height, info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
        local atlasWidth = width / (txRight - txLeft)
        local atlasHeight = height / (txBottom - txTop)
        local str = '|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t'

        return format(str, file, (sizeX or 0), (sizeY or 0), atlasWidth, atlasHeight, atlasWidth * txLeft, atlasWidth * txRight, atlasHeight * txTop, atlasHeight * txBottom)
    end

    -- GUID to npcID
    function F:GetNpcId(guid)
        local id = tonumber(strmatch((guid or ''), '%-(%d-)%-%x-$'))
        return id
    end

    do
        local t, d = '|T%s%s|t', ''
        function F:TextureString(texture, data)
            return format(t, texture, data or d)
        end
    end
end

-- Scan Tooltip

do
    local iLvlDB = {}
    local itemLevelString = '^' .. gsub(_G.ITEM_LEVEL, '%%d', '')
    local enchantString = gsub(_G.ENCHANTED_TOOLTIP_LINE, '%%s', '(.+)')
    local essenceTextureID = 2975691
    local essenceDescription = GetSpellDescription(277253)

    local tip = CreateFrame('GameTooltip', C.ADDON_TITLE .. 'ScanTooltip', nil, 'GameTooltipTemplate')
    F.ScanTip = tip

    function F:InspectItemTextures()
        if not tip.gems then
            tip.gems = {}
        else
            wipe(tip.gems)
        end

        if not tip.essences then
            tip.essences = {}
        else
            for _, essences in pairs(tip.essences) do
                wipe(essences)
            end
        end

        local step = 1
        for i = 1, 10 do
            local tex = _G[tip:GetName() .. 'Texture' .. i]
            local texture = tex and tex:IsShown() and tex:GetTexture()
            if texture then
                if texture == essenceTextureID then
                    local selected = (tip.gems[i - 1] ~= essenceTextureID and tip.gems[i - 1]) or nil
                    if not tip.essences[step] then
                        tip.essences[step] = {}
                    end
                    tip.essences[step][1] = selected -- essence texture if selected or nil
                    tip.essences[step][2] = tex:GetAtlas() -- atlas place 'tooltip-heartofazerothessence-major' or 'tooltip-heartofazerothessence-minor'
                    tip.essences[step][3] = texture -- border texture placed by the atlas

                    step = step + 1
                    if selected then
                        tip.gems[i - 1] = nil
                    end
                else
                    tip.gems[i] = texture
                end
            end
        end

        return tip.gems, tip.essences
    end

    function F:InspectItemInfo(text, slotInfo)
        local itemLevel = strfind(text, itemLevelString) and strmatch(text, '(%d+)%)?$')
        if itemLevel then
            slotInfo.iLvl = tonumber(itemLevel)
        end

        local enchant = strmatch(text, enchantString)
        if enchant then
            slotInfo.enchantText = enchant
        end
    end

    function F:CollectEssenceInfo(index, lineText, slotInfo)
        local step = 1
        local essence = slotInfo.essences[step]
        if essence and next(essence) and (strfind(lineText, _G.ITEM_SPELL_TRIGGER_ONEQUIP, nil, true) and strfind(lineText, essenceDescription, nil, true)) then
            for i = 5, 2, -1 do
                local line = _G[tip:GetName() .. 'TextLeft' .. index - i]
                local text = line and line:GetText()

                if text and (not strmatch(text, '^[ +]')) and essence and next(essence) then
                    local r, g, b = line:GetTextColor()
                    essence[4] = r
                    essence[5] = g
                    essence[6] = b

                    step = step + 1
                    essence = slotInfo.essences[step]
                end
            end
        end
    end

    function F.GetItemLevel(link, arg1, arg2, fullScan)
        if fullScan then
            tip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
            tip:SetInventoryItem(arg1, arg2)

            if not tip.slotInfo then
                tip.slotInfo = {}
            else
                wipe(tip.slotInfo)
            end

            local slotInfo = tip.slotInfo
            slotInfo.gems, slotInfo.essences = F:InspectItemTextures()

            for i = 1, tip:NumLines() do
                local line = _G[tip:GetName() .. 'TextLeft' .. i]
                if not line then
                    break
                end

                local text = line:GetText()
                if text then
                    if i == 1 and text == _G.RETRIEVING_ITEM_INFO then
                        return 'tooSoon'
                    else
                        F:InspectItemInfo(text, slotInfo)
                        F:CollectEssenceInfo(i, text, slotInfo)
                    end
                end
            end

            return slotInfo
        else
            if iLvlDB[link] then
                return iLvlDB[link]
            end

            tip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
            if arg1 and type(arg1) == 'string' then
                tip:SetInventoryItem(arg1, arg2)
            elseif arg1 and type(arg1) == 'number' then
                tip:SetBagItem(arg1, arg2)
            else
                tip:SetHyperlink(link)
            end

            local firstLine = _G[C.ADDON_TITLE .. 'ScanTooltipTextLeft1']:GetText()
            if firstLine == _G.RETRIEVING_ITEM_INFO then
                return 'tooSoon'
            end

            for i = 2, 5 do
                local line = _G[tip:GetName() .. 'TextLeft' .. i]
                if not line then
                    break
                end

                local text = line:GetText()
                local found = text and strfind(text, itemLevelString)
                if found then
                    local level = strmatch(text, '(%d+)%)?$')
                    iLvlDB[link] = tonumber(level)
                    break
                end
            end

            return iLvlDB[link]
        end
    end

    local pendingNPCs, nameCache, callbacks = {}, {}, {}
    local loadingStr = '...'
    local pendingFrame = CreateFrame('Frame')
    pendingFrame:Hide()
    pendingFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed > 1 then
            if next(pendingNPCs) then
                for npcID, count in pairs(pendingNPCs) do
                    if count > 2 then
                        nameCache[npcID] = _G.UNKNOWN
                        if callbacks[npcID] then
                            callbacks[npcID](_G.UNKNOWN)
                        end
                        pendingNPCs[npcID] = nil
                    else
                        local name = F.GetNPCName(npcID, callbacks[npcID])
                        if name and name ~= loadingStr then
                            pendingNPCs[npcID] = nil
                        else
                            pendingNPCs[npcID] = pendingNPCs[npcID] + 1
                        end
                    end
                end
            else
                self:Hide()
            end

            self.elapsed = 0
        end
    end)

    function F.GetNPCName(npcID, callback)
        local name = nameCache[npcID]
        if not name then
            tip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
            tip:SetHyperlink(format('unit:Creature-0-0-0-0-%d', npcID))
            name = _G[C.ADDON_TITLE .. 'ScanTooltipTextLeft1']:GetText() or loadingStr
            if name == loadingStr then
                if not pendingNPCs[npcID] then
                    pendingNPCs[npcID] = 1
                    pendingFrame:Show()
                end
            else
                nameCache[npcID] = name
            end
        end

        if callback then
            callback(name)
            callbacks[npcID] = callback
        end

        return name
    end
end

-- Widgets

do
    -- Dropdown menu
    F.EasyMenu = CreateFrame('Frame', C.ADDON_TITLE .. 'EasyMenu', _G.UIParent, 'UIDropDownMenuTemplate')

    -- Font string
    function F:CreateFS(font, size, flag, text, colour, shadow, anchor, x, y)
        local fs = self:CreateFontString(nil, 'OVERLAY')

        if font then
            if type(font) == 'table' then
                fs:SetFont(font[1], font[2], font[3])
            else
                fs:SetFont(font, size, flag and 'OUTLINE')
            end
        else
            fs:SetFont(C.Assets.Fonts.Regular, 12, 'OUTLINE')
        end

        if text then
            fs:SetText(text)
        end

        local r, g, b
        if colour == 'CLASS' then
            r, g, b = F:HexToRgb(C.MY_CLASS_COLOR)
        elseif colour == 'INFO' then
            r, g, b = F:HexToRgb(C.INFO_COLOR)
        elseif colour == 'YELLOW' then
            r, g, b = F:HexToRgb(C.YELLOW_COLOR)
        elseif colour == 'RED' then
            r, g, b = F:HexToRgb(C.RED_COLOR)
        elseif colour == 'GREEN' then
            r, g, b = F:HexToRgb(C.GREEN_COLOR)
        elseif colour == 'BLUE' then
            r, g, b = F:HexToRgb(C.BLUE_COLOR)
        elseif colour == 'GREY' then
            r, g, b = F:HexToRgb(C.GREY_COLOR)
        else
            r, g, b = 255, 255, 255
        end

        if type(colour) == 'table' then
            fs:SetTextColor(colour[1], colour[2], colour[3])
        else
            fs:SetTextColor(r / 255, g / 255, b / 255)
        end

        if type(shadow) == 'boolean' then
            fs:SetShadowColor(0, 0, 0, 1)
            fs:SetShadowOffset(1, -1)
        elseif shadow == 'THICK' then
            fs:SetShadowColor(0, 0, 0, 1)
            fs:SetShadowOffset(2, -2)
        else
            fs:SetShadowColor(0, 0, 0, 0)
        end

        if type(anchor) == 'table' then
            fs:SetPoint(unpack(anchor))
        elseif anchor and x and y then
            fs:SetPoint(anchor, x, y)
        else
            fs:SetPoint('CENTER', 1, 0)
        end

        return fs
    end

    function F:SetFS(object, font, size, flag, text, colour, shadow)
        if type(font) == 'table' then
            object:SetFont(font[1], font[2], font[3] or nil)
        else
            object:SetFont(font, size, flag and 'OUTLINE' or '')
        end

        if text then
            object:SetText(text)
        end

        local r, g, b
        if colour == 'CLASS' then
            r, g, b = F:HexToRgb(C.MY_CLASS_COLOR)
        elseif colour == 'INFO' then
            r, g, b = F:HexToRgb(C.INFO_COLOR)
        elseif colour == 'YELLOW' then
            r, g, b = F:HexToRgb(C.YELLOW_COLOR)
        elseif colour == 'RED' then
            r, g, b = F:HexToRgb(C.RED_COLOR)
        elseif colour == 'GREEN' then
            r, g, b = F:HexToRgb(C.GREEN_COLOR)
        elseif colour == 'BLUE' then
            r, g, b = F:HexToRgb(C.BLUE_COLOR)
        elseif colour == 'GREY' then
            r, g, b = F:HexToRgb(C.GREY_COLOR)
        else
            r, g, b = 255, 255, 255
        end

        if type(colour) == 'table' then
            object:SetTextColor(colour[1], colour[2], colour[3])
        else
            object:SetTextColor(r / 255, g / 255, b / 255)
        end

        if type(shadow) == 'boolean' then
            object:SetShadowColor(0, 0, 0, 1)
            object:SetShadowOffset(1, -1)
        elseif shadow == 'THICK' then
            object:SetShadowColor(0, 0, 0, 1)
            object:SetShadowOffset(2, -2)
        else
            object:SetShadowColor(0, 0, 0, 0)
        end
    end

    function F:CreateColorString(text, color)
        if not text or not type(text) == 'string' then
            return
        end

        if not color or type(color) ~= 'table' then
            return
        end

        local hex = color.r and color.g and color.b and F:RgbToHex(color.r, color.g, color.b) or '|cffffffff'

        return hex .. text .. '|r'
    end

    function F:CreateClassColorString(text, class)
        if not text or not type(text) == 'string' then
            return
        end

        if not class or type(class) ~= 'string' then
            return
        end

        local r, g, b = F:ClassColor(class)
        local hex = r and g and b and F:RgbToHex(r, g, b) or '|cffffffff'

        return hex .. text .. '|r'
    end

    function F.ShortenString(string, i, dots)
        if not string then
            return
        end
        local bytes = string:len()
        if bytes <= i then
            return string
        else
            local len, pos = 0, 1
            while pos <= bytes do
                len = len + 1
                local c = string:byte(pos)
                if c > 0 and c <= 127 then
                    pos = pos + 1
                elseif c >= 192 and c <= 223 then
                    pos = pos + 2
                elseif c >= 224 and c <= 239 then
                    pos = pos + 3
                elseif c >= 240 and c <= 247 then
                    pos = pos + 4
                end
                if len == i then
                    break
                end
            end
            if len == i and pos <= bytes then
                return string:sub(1, pos - 1) .. (dots and '...' or '')
            else
                return string
            end
        end
    end

    -- 'Lady Sylvanas Windrunner' to 'L. S. Windrunner'
    function F.AbbrNameString(string)
        if string then
            return gsub(string, '%s?(.[\128-\191]*)%S+%s', '%1. ')
        else
            return string
        end
    end

    function F:StyleAddonName(msg)
        msg = gsub(msg, '%%ADDONNAME%%', C.COLORFUL_ADDON_TITLE)

        return msg
    end

    -- GameTooltip
    function F:HideTooltip()
        _G.GameTooltip:Hide()
    end

    local function Tooltip_OnEnter(self)
        _G.GameTooltip:SetOwner(self, self.anchor, 0, 4)
        _G.GameTooltip:ClearLines()

        if self.title then
            _G.GameTooltip:AddLine(self.title)
        end

        local r, g, b

        if tonumber(self.text) then
            _G.GameTooltip:SetSpellByID(self.text)
        elseif self.text then
            if self.color == 'CLASS' then
                r, g, b = C.r, C.g, C.b
            elseif self.color == 'SYSTEM' then
                r, g, b = 1, 0.8, 0
            elseif self.color == 'BLUE' then
                r, g, b = 0.6, 0.8, 1
            elseif self.color == 'RED' then
                r, g, b = 0.9, 0.3, 0.3
            end

            if self.blankLine then
                _G.GameTooltip:AddLine(' ')
            end

            _G.GameTooltip:AddLine(self.text, r, g, b, 1)
        end

        _G.GameTooltip:Show()
    end

    function F:AddTooltip(anchor, text, color, blankLine)
        self.anchor = anchor
        self.text = text
        self.color = color
        self.blankLine = blankLine
        self:HookScript('OnEnter', Tooltip_OnEnter)
        self:HookScript('OnLeave', F.HideTooltip)
    end

    -- Glow parent
    function F:CreateGlowFrame(size)
        local frame = CreateFrame('Frame', nil, self)
        frame:SetPoint('CENTER')
        frame:SetSize(size + 8, size + 8)

        return frame
    end

    -- Gradient Frame
    local orientationAbbr = { ['V'] = 'Vertical', ['H'] = 'Horizontal' }
    function F:SetGradient(orientation, r, g, b, a1, a2, width, height)
        orientation = orientationAbbr[orientation]
        if not orientation then
            return
        end

        local tex = self:CreateTexture(nil, 'BACKGROUND')
        tex:SetTexture(C.Assets.Textures.Backdrop)

        if C.IS_NEW_PATCH then
            tex:SetGradient(orientation, CreateColor(r, g, b, a1), CreateColor(r, g, b, a2))
        else
            tex:SetGradientAlpha(orientation, r, g, b, a1, r, g, b, a2)
        end

        if width then
            tex:SetWidth(width)
        end
        if height then
            tex:SetHeight(height)
        end

        return tex
    end

    -- Background texture
    function F:CreateTex()
        if self.__bgTex then
            return
        end

        local frame = self
        if self:IsObjectType('Texture') then
            frame = self:GetParent()
        end

        local tex = frame:CreateTexture(nil, 'BACKGROUND', nil, 1)
        tex:SetAllPoints(self)
        tex:SetTexture(C.Assets.Textures.BackdropStripes, true, true)
        tex:SetHorizTile(true)
        tex:SetVertTile(true)
        tex:SetBlendMode('ADD')

        self.__bgTex = tex
    end

    function F:CreateSD(a, m, s, override)
        if not override and not _G.ANDROMEDA_ADB.ShadowOutline then
            return
        end

        if self.__shadow then
            return
        end

        local frame = self
        if self:IsObjectType('Texture') then
            frame = self:GetParent()
        end

        local shadow = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
        shadow:SetOutside(self, m or 5, m or 5)
        shadow:SetBackdrop({ edgeFile = C.Assets.Textures.Shadow, edgeSize = s or 5 })
        shadow:SetBackdropBorderColor(0, 0, 0, a or 0.25)
        -- shadow:SetFrameLevel(1)
        shadow:SetFrameStrata(frame:GetFrameStrata())
        self.__shadow = shadow

        return self.__shadow
    end

    function F:CreateGradient()
        local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
        local normTex = C.Assets.Textures.Backdrop

        local tex = self:CreateTexture(nil, 'BORDER')
        tex:SetAllPoints(self)
        tex:SetTexture(normTex)

        local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
        if gradStyle then
            if C.IS_NEW_PATCH then
                tex:SetGradient('Vertical', CreateColor(color.r, color.g, color.b, 0.65), CreateColor(0, 0, 0, 0.25))
            else
                tex:SetGradientAlpha('Vertical', color.r, color.g, color.b, 0.65, 0, 0, 0, 0.25)
            end
        else
            tex:SetVertexColor(color.r, color.g, color.b, 0)
        end

        return tex
    end

    -- Setup backdrop
    function F:SetBorderColor()
        local borderColor = _G.ANDROMEDA_ADB.BorderColor
        self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)
    end

    C.Frames = {}
    function F:CreateBD(alpha)
        local backdropColor = _G.ANDROMEDA_ADB.BackdropColor
        local backdropAlpha = _G.ANDROMEDA_ADB.BackdropAlpha

        self:SetBackdrop({
            bgFile = C.Assets.Textures.Backdrop,
            edgeFile = C.Assets.Textures.Backdrop,
            edgeSize = C.MULT,
        })
        self:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, alpha or backdropAlpha)

        F.SetBorderColor(self)

        if not alpha then
            tinsert(C.Frames, self)
        end
    end

    function F:CreateBDFrame(a, gradient)
        local frame = self
        if self:IsObjectType('Texture') then
            frame = self:GetParent()
        end
        local lvl = frame:GetFrameLevel()

        self.__bg = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
        self.__bg:SetOutside(self)
        self.__bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)

        F.CreateBD(self.__bg, a)

        if gradient then
            self.__gradient = F.CreateGradient(self.__bg)
        end

        return self.__bg
    end

    function F:SetBD(a, x, y, x2, y2)
        local bg = F.CreateBDFrame(self, a)
        if x then
            bg:SetPoint('TOPLEFT', self, x, y)
            bg:SetPoint('BOTTOMRIGHT', self, x2, y2)
        end
        F.CreateSD(bg)
        F.CreateTex(bg)

        return bg
    end

    -- GUI
    function F:CreateHelpInfo(tooltip)
        local bu = CreateFrame('Button', nil, self)
        bu:SetSize(40, 40)
        bu.Icon = bu:CreateTexture(nil, 'ARTWORK')
        bu.Icon:SetAllPoints()
        bu.Icon:SetTexture(616343)
        bu:SetHighlightTexture(616343)
        if tooltip then
            bu.title = L['Hint']
            F.AddTooltip(bu, 'ANCHOR_BOTTOMLEFT', tooltip, 'BLUE')
        end

        return bu
    end

    local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
    function F:ClassIconTexCoord(class)
        local tcoords = CLASS_ICON_TCOORDS[class]
        self:SetTexCoord(tcoords[1] + 0.022, tcoords[2] - 0.025, tcoords[3] + 0.022, tcoords[4] - 0.025)
    end

    function F:CreateSB(spark, r, g, b)
        self:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        if r and g and b then
            self:SetStatusBarColor(r, g, b)
        else
            self:SetStatusBarColor(C.r, C.g, C.b)
        end

        local bg = F.SetBD(self)
        self.__shadow = bg.__shadow

        if spark then
            self.Spark = self:CreateTexture(nil, 'OVERLAY')
            self.Spark:SetTexture(C.Assets.Textures.Spark)
            self.Spark:SetBlendMode('ADD')
            self.Spark:SetAlpha(0.8)
            self.Spark:SetPoint('TOPLEFT', self:GetStatusBarTexture(), 'TOPRIGHT', -10, 10)
            self.Spark:SetPoint('BOTTOMRIGHT', self:GetStatusBarTexture(), 'BOTTOMRIGHT', 10, -10)
        end
    end

    function F:CreateAndUpdateBarTicks(bar, ticks, numTicks)
        for i = 1, #ticks do
            ticks[i]:Hide()
        end

        if numTicks and numTicks > 0 then
            local width, height = bar:GetSize()
            local delta = width / numTicks
            for i = 1, numTicks - 1 do
                if not ticks[i] then
                    ticks[i] = bar:CreateTexture(nil, 'OVERLAY')
                    ticks[i]:SetTexture(C.Assets.Textures.StatusbarFlat)
                    ticks[i]:SetVertexColor(0, 0, 0)
                    ticks[i]:SetWidth(C.MULT)
                    ticks[i]:SetHeight(height)
                end
                ticks[i]:ClearAllPoints()
                ticks[i]:SetPoint('RIGHT', bar, 'LEFT', delta * i, 0)
                ticks[i]:Show()
            end
        end
    end

    function F:CreateButton(width, height, text, fontSize)
        local bu = CreateFrame('Button', nil, self, 'BackdropTemplate')
        bu:SetSize(width, height)
        if type(text) == 'boolean' then
            F.PixelIcon(bu, fontSize, true)
        else
            F.Reskin(bu)
            bu.text = F.CreateFS(bu, C.Assets.Fonts.Regular, fontSize or 12, nil, text, nil, true)
        end

        return bu
    end

    function F:CreateCheckbox(flat)
        local cb = CreateFrame('CheckButton', nil, self, 'InterfaceOptionsBaseCheckButtonTemplate')
        cb:SetScript('OnClick', nil) -- reset onclick handler
        F.ReskinCheckbox(cb, flat, true)

        cb.Type = 'CheckBox'
        return cb
    end

    local function EditBoxClearFocus(self)
        self:ClearFocus()
    end

    function F:CreateEditBox(width, height)
        local eb = CreateFrame('EditBox', nil, self)
        eb:SetSize(width, height)
        eb:SetAutoFocus(false)
        eb:SetTextInsets(5, 5, 5, 5)
        eb:SetFont(C.Assets.Fonts.Regular, 11, '')
        eb.bg = F.CreateBDFrame(eb, 0.25, true)
        eb.bg:SetAllPoints()
        F.SetBorderColor(eb.bg)
        F.CreateSD(eb.bg, 0.25)
        F.CreateTex(eb)

        eb:SetScript('OnEscapePressed', EditBoxClearFocus)
        eb:SetScript('OnEnterPressed', EditBoxClearFocus)

        eb.Type = 'EditBox'
        return eb
    end

    local function Option_OnClick(self)
        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        PlaySound(_G.SOUNDKIT.GS_TITLE_OPTION_OK)
        local opt = self.__owner.options
        for i = 1, #opt do
            if self == opt[i] then
                if classColor then
                    opt[i]:SetBackdropColor(C.r, C.g, C.b, 0.25)
                else
                    opt[i]:SetBackdropColor(newColor.r, newColor.g, newColor.b, 0.25)
                end
                opt[i].selected = true
            else
                opt[i]:SetBackdropColor(0.1, 0.1, 0.1, 0.25)
                opt[i].selected = false
            end
        end
        self.__owner.Text:SetText(self.text)
        self:GetParent():Hide()
    end

    local function Option_OnEnter(self)
        if self.selected then
            return
        end
        self:SetBackdropColor(1, 1, 1, 0.25)
    end

    local function Option_OnLeave(self)
        if self.selected then
            return
        end
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.25)
    end

    local function DD_OnShow(self)
        self.__list:Hide()
    end

    local function DD_OnClick(self)
        PlaySound(_G.SOUNDKIT.GS_TITLE_OPTION_OK)
        F:TogglePanel(self.__list)
    end

    local function DD_OnEnter(self)
        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        if classColor then
            self.arrow:SetVertexColor(C.r, C.g, C.b)
        else
            self.arrow:SetVertexColor(newColor.r, newColor.g, newColor.b)
        end
    end

    local function DD_OnLeave(self)
        self.arrow:SetVertexColor(1, 1, 1)
    end

    function F:CreateDropDown(width, height, data)
        local outline = _G.ANDROMEDA_ADB.FontOutline

        local dd = CreateFrame('Frame', nil, self, 'BackdropTemplate')
        dd:SetSize(width, height)
        dd.bg = F.CreateBDFrame(dd, 0.25, true)
        F.SetBorderColor(dd.bg)
        F.CreateSD(dd.bg, 0.25)
        F.CreateTex(dd)

        dd.Text = F.CreateFS(dd, C.Assets.Fonts.Regular, 11, outline, '', nil, outline or 'THICK', 'LEFT', 5, 0)
        dd.Text:SetPoint('RIGHT', -5, 0)
        dd.options = {}

        local bu = CreateFrame('Button', nil, dd)
        bu:SetPoint('RIGHT', -5, 0)
        bu:SetSize(18, 18)
        dd.button = bu

        local tex = bu:CreateTexture(nil, 'ARTWORK')
        tex:SetVertexColor(1, 1, 1)
        tex:SetAllPoints()
        F.SetupArrow(tex, 'down')
        bu.arrow = tex

        local list = CreateFrame('Frame', nil, dd, 'BackdropTemplate')
        list:SetPoint('TOP', dd, 'BOTTOM', 0, -2)
        RaiseFrameLevel(list)
        F.CreateBD(list, 0.75)
        F.CreateTex(list)
        list:Hide()
        bu.__list = list

        bu:SetScript('OnShow', DD_OnShow)
        bu:SetScript('OnClick', DD_OnClick)

        bu:HookScript('OnEnter', DD_OnEnter)
        bu:HookScript('OnLeave', DD_OnLeave)

        local opt, index = {}, 0
        for i, j in pairs(data) do
            opt[i] = CreateFrame('Button', nil, list, 'BackdropTemplate')
            opt[i]:SetPoint('TOPLEFT', 4, -4 - (i - 1) * (height + 2))
            opt[i]:SetSize(width - 8, height)
            F.CreateBD(opt[i])

            local text = F.CreateFS(opt[i], C.Assets.Fonts.Regular, 11, nil, j, nil, true, 'LEFT', 5, 0)
            text:SetPoint('RIGHT', -5, 0)
            opt[i].text = j
            opt[i].index = i
            opt[i].__owner = dd
            opt[i]:SetScript('OnClick', Option_OnClick)
            opt[i]:SetScript('OnEnter', Option_OnEnter)
            opt[i]:SetScript('OnLeave', Option_OnLeave)

            dd.options[i] = opt[i]
            index = index + 1
        end
        list:SetSize(width, index * (height + 2) + 6)

        dd.Type = 'DropDown'
        return dd
    end

    local function UpdatePicker()
        local swatch = _G.ColorPickerFrame.__swatch
        local r, g, b = _G.ColorPickerFrame:GetColorRGB()
        r = F:Round(r, 2)
        g = F:Round(g, 2)
        b = F:Round(b, 2)
        swatch.tex:SetVertexColor(r, g, b)
        swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
        F.UpdateCustomClassColors()
    end

    local function CancelPicker()
        local swatch = _G.ColorPickerFrame.__swatch
        local r, g, b = _G.ColorPicker_GetPreviousValues()
        swatch.tex:SetVertexColor(r, g, b)
        swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
    end

    local function OpenColorPicker(self)
        local r, g, b = self.color.r, self.color.g, self.color.b
        _G.ColorPickerFrame.__swatch = self
        _G.ColorPickerFrame.func = UpdatePicker
        _G.ColorPickerFrame.previousValues = { r = r, g = g, b = b }
        _G.ColorPickerFrame.cancelFunc = CancelPicker
        _G.ColorPickerFrame:SetColorRGB(r, g, b)
        _G.ColorPickerFrame:Show()
    end

    local function GetSwatchTexColor(tex)
        local r, g, b = tex:GetVertexColor()
        r = F:Round(r, 2)
        g = F:Round(g, 2)
        b = F:Round(b, 2)
        return r, g, b
    end

    local function ResetColorPicker(swatch)
        local defaultColor = swatch.__default
        if defaultColor then
            _G.ColorPickerFrame:SetColorRGB(defaultColor.r, defaultColor.g, defaultColor.b)
        end
    end

    local whiteColor = { r = 1, g = 1, b = 1 }
    function F:CreateColorSwatch(name, color)
        color = color or whiteColor

        local swatch = CreateFrame('Button', nil, self, 'BackdropTemplate')
        swatch:SetSize(20, 12)
        swatch.bg = F.CreateBDFrame(swatch, 1)
        F.SetBorderColor(swatch.bg)
        F.CreateSD(swatch.bg, 0.25)

        if name then
            swatch.text = F.CreateFS(swatch, C.Assets.Fonts.Regular, 12, nil, name, nil, true)
            swatch.text:SetPoint('LEFT', swatch, 'RIGHT', 6, 0)
        end

        local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
        local normTex = C.Assets.Textures.StatusbarFlat
        local gradTex = C.Assets.Textures.StatusbarGradient

        local tex = swatch:CreateTexture()
        tex:SetInside(swatch, 2, 2)
        tex:SetTexture(gradStyle and gradTex or normTex)
        tex:SetVertexColor(color.r, color.g, color.b)
        tex.GetColor = GetSwatchTexColor

        swatch.tex = tex
        swatch.color = color
        swatch:SetScript('OnClick', OpenColorPicker)
        swatch:SetScript('OnDoubleClick', ResetColorPicker)

        return swatch
    end

    local function UpdateSliderEditBox(self)
        local slider = self.__owner
        local minValue, maxValue = slider:GetMinMaxValues()
        local text = tonumber(self:GetText())
        if not text then
            return
        end
        text = min(maxValue, text)
        text = max(minValue, text)
        slider:SetValue(text)
        self:SetText(text)
        self:ClearFocus()
    end

    local function ResetSliderValue(self)
        local slider = self.__owner
        if slider.__default then
            slider:SetValue(slider.__default)
        end
    end

    function F:CreateSlider(name, minValue, maxValue, step, x, y, width)
        local slider = CreateFrame('Slider', nil, self, 'OptionsSliderTemplate')
        slider:SetPoint('TOPLEFT', x, y)
        slider:SetWidth(width or 140)
        slider:SetMinMaxValues(minValue, maxValue)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetHitRectInsets(0, 0, 0, 0)
        F.ReskinSlider(slider)

        slider.Low:SetText(minValue)
        slider.Low:SetFontObject(_G.Game11Font)
        slider.Low:SetPoint('TOPLEFT', slider, 'BOTTOMLEFT', 10, -2)

        slider.High:SetText(maxValue)
        slider.High:SetFontObject(_G.Game11Font)
        slider.High:SetPoint('TOPRIGHT', slider, 'BOTTOMRIGHT', -10, -2)

        slider.Text:SetText(name)
        slider.Text:SetFontObject(_G.Game11Font)
        slider.Text:ClearAllPoints()
        slider.Text:SetPoint('CENTER', 0, 16)

        slider.value = F.CreateEditBox(slider, 50, 20)
        slider.value:SetPoint('TOP', slider, 'BOTTOM', 0, -2)
        slider.value:SetJustifyH('CENTER')
        slider.value:SetFont(C.Assets.Fonts.Regular, 11, '')
        slider.value.__owner = slider
        slider.value:SetScript('OnEnterPressed', UpdateSliderEditBox)

        slider.clicker = CreateFrame('Button', nil, slider)
        slider.clicker:SetAllPoints(slider.Text)
        slider.clicker.__owner = slider
        slider.clicker:SetScript('OnDoubleClick', ResetSliderValue)

        return slider
    end

    function F:TogglePanel(frame)
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end

-- UI Skins

do
    -- Kill regions
    F.HiddenFrame = CreateFrame('Frame')
    F.HiddenFrame:Hide()

    function F:HideObject()
        if self.UnregisterAllEvents then
            self:UnregisterAllEvents()
            self:SetParent(F.HiddenFrame)
        else
            self.Show = self.Hide
        end
        self:Hide()
    end

    function F:HideOption()
        if not self then
            return
        end -- isNewPatch
        self:SetAlpha(0)
        self:SetScale(0.0001)
    end

    local blizzTextures = {
        'Inset',
        'inset',
        'InsetFrame',
        'LeftInset',
        'RightInset',
        'NineSlice',
        'BG',
        'Bg',
        'border',
        'Border',
        'Background',
        'BorderFrame',
        'bottomInset',
        'BottomInset',
        'bgLeft',
        'bgRight',
        'FilligreeOverlay',
        'PortraitOverlay',
        'ArtOverlayFrame',
        'Portrait',
        'portrait',
        'ScrollFrameBorder',
        'ScrollUpBorder',
        'ScrollDownBorder',
    }

    function F:StripTextures(kill)
        local frameName = self.GetName and self:GetName()
        for _, texture in pairs(blizzTextures) do
            local blizzFrame = self[texture] or (frameName and _G[frameName .. texture])
            if blizzFrame then
                F.StripTextures(blizzFrame, kill)
            end
        end

        if self.GetNumRegions then
            for i = 1, self:GetNumRegions() do
                local region = select(i, self:GetRegions())
                if region and region.IsObjectType and region:IsObjectType('Texture') then
                    if kill and type(kill) == 'boolean' then
                        F.HideObject(region)
                    elseif tonumber(kill) then
                        if kill == 0 then
                            region:SetAlpha(0)
                        elseif i ~= kill then
                            region:SetTexture('')
                            region:SetAtlas('')
                        end
                    else
                        region:SetTexture('')
                    end
                end
            end
        end
    end

    -- Handle icons
    local x1, x2, y1, y2 = unpack(C.TEX_COORD)
    function F:ReskinIcon(shadow)
        self:SetTexCoord(x1, x2, y1, y2)
        local bg = F.CreateBDFrame(self, 0.25) -- exclude from opacity control
        bg:SetBackdropBorderColor(0, 0, 0)
        if shadow then
            F.CreateSD(bg)
        end
        return bg
    end

    function F:PixelIcon(texture, highlight)
        self.bg = F.CreateBDFrame(self)
        self.bg:SetBackdropBorderColor(0, 0, 0)
        self.bg:SetAllPoints()
        self.Icon = self:CreateTexture(nil, 'ARTWORK')
        self.Icon:SetInside()
        self.Icon:SetTexCoord(x1, x2, y1, y2)
        if texture then
            local atlas = strmatch(texture, 'Atlas:(.+)$')
            if atlas then
                self.Icon:SetAtlas(atlas)
            else
                self.Icon:SetTexture(texture)
            end
        end
        if highlight and type(highlight) == 'boolean' then
            self:EnableMouse(true)
            self.HL = self:CreateTexture(nil, 'HIGHLIGHT')
            self.HL:SetColorTexture(1, 1, 1, 0.25)
            self.HL:SetInside()
        end
    end

    function F:AuraIcon(highlight)
        self.CD = CreateFrame('Cooldown', nil, self, 'CooldownFrameTemplate')
        self.CD:SetInside()
        self.CD:SetReverse(true)
        F.PixelIcon(self, nil, highlight)
        F.CreateSD(self)
    end

    local atlasToQuality = {
        ['error'] = 99,
        ['uncollected'] = Enum.ItemQuality.Poor,
        ['gray'] = Enum.ItemQuality.Poor,
        ['white'] = Enum.ItemQuality.Common,
        ['green'] = Enum.ItemQuality.Uncommon,
        ['blue'] = Enum.ItemQuality.Rare,
        ['purple'] = Enum.ItemQuality.Epic,
        ['orange'] = Enum.ItemQuality.Legendary,
        ['artifact'] = Enum.ItemQuality.Artifact,
        ['account'] = Enum.ItemQuality.Heirloom,
    }

    local function UpdateIconBorderColorByAtlas(self, atlas)
        local atlasAbbr = atlas and strmatch(atlas, '%-(%w+)$')
        local quality = atlasAbbr and atlasToQuality[atlasAbbr]
        local color = C.QualityColors[quality or 1]
        self.__owner.bg:SetBackdropBorderColor(color.r, color.g, color.b)
    end

    local greyRGB = C.QualityColors[0].r
    local function UpdateIconBorderColor(self, r, g, b)
        if not r or r == greyRGB or (r > 0.99 and g > 0.99 and b > 0.99) then
            r, g, b = 0, 0, 0
        end
        self.__owner.bg:SetBackdropBorderColor(r, g, b)
    end

    local function ResetIconBorderColor(self, texture)
        if not texture then
            self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
        end
    end

    local function resetIconBorder(button, quality)
        if not quality then
            button.IconBorder:Hide()
        end
    end

    function F:ReskinIconBorder(needInit, useAtlas)
        self:SetAlpha(0)
        self.__owner = self:GetParent()
        if not self.__owner.bg then
            return
        end
        if useAtlas or self.__owner.useCircularIconBorder then -- for auction item display
            hooksecurefunc(self, 'SetAtlas', UpdateIconBorderColorByAtlas)
            hooksecurefunc(self, 'SetTexture', ResetIconBorderColor)
            if needInit then
                self:SetAtlas(self:GetAtlas()) -- for border with color before hook
            end
        else
            hooksecurefunc(self, 'SetVertexColor', UpdateIconBorderColor)
            if needInit then
                self:SetVertexColor(self:GetVertexColor()) -- for border with color before hook
            end
        end
        hooksecurefunc(self, 'Hide', ResetIconBorderColor)

        if self.__owner.SetItemButtonQuality then
            hooksecurefunc(self.__owner, 'SetItemButtonQuality', resetIconBorder)
        end
    end

    -- Handle button
    local function UpdateGlow(frame, stop)
        local speed = 0.05
        local mult = 1
        local alpha = 1
        local last = 0

        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        frame:SetScript('OnUpdate', function(self, elapsed)
            if not stop then
                if classColor then
                    self:SetBackdropBorderColor(C.r, C.g, C.b)
                else
                    self:SetBackdropBorderColor(newColor.r, newColor.g, newColor.b)
                end

                last = last + elapsed
                if last > speed then
                    last = 0
                    self:SetAlpha(alpha)
                end

                alpha = alpha - elapsed * mult
                if alpha < 0 and mult > 0 then
                    mult = mult * -1
                    alpha = 0
                elseif alpha > 1 and mult < 0 then
                    mult = mult * -1
                end
            else
                self:SetBackdropBorderColor(0, 0, 0)
                self:SetAlpha(0.25)
            end
        end)
    end

    local function StartGlow(self)
        if not self:IsEnabled() then
            return
        end

        if not self.__shadow then
            return
        end

        UpdateGlow(self.__shadow)
    end

    local function StopGlow(self)
        if not self.__shadow then
            return
        end

        UpdateGlow(self.__shadow, true)
    end

    local function Button_OnEnter(self)
        if not self:IsEnabled() then
            return
        end

        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        if classColor then
            self.__bg:SetBackdropColor(C.r, C.g, C.b, 0.45)
            self.__bg:SetBackdropBorderColor(C.r, C.g, C.b)
        else
            self.__bg:SetBackdropColor(newColor.r, newColor.g, newColor.b, 0.25)
            self.__bg:SetBackdropBorderColor(newColor.r, newColor.g, newColor.b)
        end
    end

    local function Button_OnLeave(self)
        self.__bg:SetBackdropColor(0, 0, 0, 0.25)
        F.SetBorderColor(self.__bg)

        -- if gradStyle then
        --     self.__gradient:SetGradientAlpha('Vertical', color.r, color.g, color.b, alpha, 0, 0, 0, 0.25)
        -- else
        --     self.__gradient:SetVertexColor(color.r, color.g, color.b, alpha)
        -- end
    end

    local blizzRegions = {
        'Left',
        'Middle',
        'Right',
        'Mid',
        'LeftDisabled',
        'MiddleDisabled',
        'RightDisabled',
        'TopLeft',
        'TopRight',
        'BottomLeft',
        'BottomRight',
        'TopMiddle',
        'MiddleLeft',
        'MiddleRight',
        'BottomMiddle',
        'MiddleMiddle',
        'TabSpacer',
        'TabSpacer1',
        'TabSpacer2',
        '_RightSeparator',
        '_LeftSeparator',
        'Cover',
        'Border',
        'Background',
        'TopTex',
        'TopLeftTex',
        'TopRightTex',
        'LeftTex',
        'BottomTex',
        'BottomLeftTex',
        'BottomRightTex',
        'RightTex',
        'MiddleTex',
        'Center',
    }

    function F:Reskin(noGlow, override)
        if self.SetNormalTexture and not override then
            self:SetNormalTexture(C.Assets.Textures.Blank)
        end
        if self.SetHighlightTexture then
            self:SetHighlightTexture(C.Assets.Textures.Blank)
        end
        if self.SetPushedTexture then
            self:SetPushedTexture(C.Assets.Textures.Blank)
        end
        if self.SetDisabledTexture then
            self:SetDisabledTexture(C.Assets.Textures.Blank)
        end

        local buttonName = self.GetName and self:GetName()
        for _, region in pairs(blizzRegions) do
            region = buttonName and _G[buttonName .. region] or self[region]
            if region then
                region:SetAlpha(0)
                region:Hide()
            end
        end

        F.CreateTex(self)
        self.__bg = F.CreateBDFrame(self, 0, true)

        local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
        local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
        local alpha = _G.ANDROMEDA_ADB.ButtonBackdropAlpha

        self.__bg:SetBackdropColor(0, 0, 0, 0.25)
        F.SetBorderColor(self.__bg)

        if gradStyle then
            if C.IS_NEW_PATCH then
                self.__gradient:SetGradient('Vertical', CreateColor(color.r, color.g, color.b, alpha), CreateColor(0, 0, 0, 0.25))
            else
                self.__gradient:SetGradientAlpha('Vertical', color.r, color.g, color.b, alpha, 0, 0, 0, 0.25)
            end
        else
            self.__gradient:SetVertexColor(color.r, color.g, color.b, alpha)
        end

        self:HookScript('OnEnter', Button_OnEnter)
        self:HookScript('OnLeave', Button_OnLeave)

        local buttonAnima = _G.ANDROMEDA_ADB.ButtonHoverAnimation
        if not noGlow and buttonAnima then
            self.__shadow = F.CreateSD(self.__bg, 0.25)

            self:HookScript('OnEnter', StartGlow)
            self:HookScript('OnLeave', StopGlow)
        end
    end

    -- Handle tabs
    function F:ReskinTab()
        self:DisableDrawLayer('BACKGROUND')
        if C.IS_NEW_PATCH then
            if self.LeftHighlight then
                self.LeftHighlight:SetAlpha(0)
            end
            if self.RightHighlight then
                self.RightHighlight:SetAlpha(0)
            end
            if self.MiddleHighlight then
                self.MiddleHighlight:SetAlpha(0)
            end
        end

        local bg = F.CreateBDFrame(self)
        bg:SetPoint('TOPLEFT', 10, -3)
        bg:SetPoint('BOTTOMRIGHT', -10, 0)
        F.CreateSD(bg)
        self.bg = bg

        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        self:SetHighlightTexture(C.Assets.Textures.Backdrop)
        local hl = self:GetHighlightTexture()
        hl:ClearAllPoints()
        hl:SetInside(bg)

        if classColor then
            hl:SetVertexColor(C.r, C.g, C.b, 0.25)
        else
            hl:SetVertexColor(newColor.r, newColor.g, newColor.b, 0.25)
        end
    end

    function F:ResetTabAnchor()
        local text = self.Text or (self.GetName and _G[self:GetName() .. 'Text'])
        if text then
            text:SetPoint('CENTER', self)
        end
    end
    hooksecurefunc('PanelTemplates_SelectTab', F.ResetTabAnchor)
    hooksecurefunc('PanelTemplates_DeselectTab', F.ResetTabAnchor)

    -- Handle scrollframe
    --[[ local function Scroll_OnEnter(self)
        local thumb = self.thumb
        if not thumb then
            return
        end

        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        if classColor then
            thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.65)
            thumb.bg:SetBackdropBorderColor(C.r, C.g, C.b)
        else
            thumb.bg:SetBackdropColor(newColor.r, newColor.g, newColor.b, 0.65)
            thumb.bg:SetBackdropBorderColor(newColor.r, newColor.g, newColor.b)
        end
    end

    local function Scroll_OnLeave(self)
        local thumb = self.thumb
        if not thumb then
            return
        end

        local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
        thumb.bg:SetBackdropColor(color.r, color.g, color.b, 0.25)
        F.SetBorderColor(thumb.bg)
    end

    local function GrabScrollBarElement(frame, element)
        local frameName = frame:GetDebugName()
        return frame[element] or frameName and (_G[frameName .. element] or strfind(frameName, element)) or nil
    end

    function F:ReskinScroll()
        F.StripTextures(self:GetParent())
        F.StripTextures(self)

        local thumb = GrabScrollBarElement(self, 'ThumbTexture') or GrabScrollBarElement(self, 'thumbTexture') or self.GetThumbTexture and self:GetThumbTexture()
        if thumb then
            thumb:SetAlpha(0)
            thumb:SetWidth(16)
            self.thumb = thumb

            local color = _G.ANDROMEDA_ADB.ButtonBackdropColor
            local bg = F.CreateBDFrame(self, 0.25, true)
            bg:SetPoint('TOPLEFT', thumb, 0, -2)
            bg:SetPoint('BOTTOMRIGHT', thumb, 0, 4)
            bg:SetBackdropColor(color.r, color.g, color.b, 0.25)
            bg:SetBackdropBorderColor(0, 0, 0)
            thumb.bg = bg
        end

        local up, down = self:GetChildren()
        F.ReskinArrow(up, 'up')
        F.ReskinArrow(down, 'down')

        self:HookScript('OnEnter', Scroll_OnEnter)
        self:HookScript('OnLeave', Scroll_OnLeave)
    end

    -- WowTrimScrollBar
    local function updateTrimScrollArrow(self, atlas)
        local arrow = self.__owner
        if not arrow.__texture then
            return
        end

        if atlas == arrow.disabledTexture then
            arrow.__texture:SetVertexColor(0.5, 0.5, 0.5)
        else
            arrow.__texture:SetVertexColor(1, 1, 1)
        end
    end

    local function reskinTrimScrollArrow(self, direction)
        if not self then
            return
        end

        if not self.Texture then
            return
        end -- CovenantMissonFrame, isNewPatch

        self.Texture:SetAlpha(0)
        self.Overlay:SetAlpha(0)
        local tex = self:CreateTexture(nil, 'ARTWORK')
        tex:SetAllPoints()
        F.CreateBDFrame(tex, 0.25)
        F.SetupArrow(tex, direction)
        self.__texture = tex

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)
        self.Texture.__owner = self
        hooksecurefunc(self.Texture, 'SetAtlas', updateTrimScrollArrow)
        self.Texture:SetAtlas(self.Texture:GetAtlas())
    end --]]

    local function Thumb_OnEnter(self)
        local thumb = self.thumb or self
        thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.75)
    end

    local function Thumb_OnLeave(self)
        local thumb = self.thumb or self
        if thumb.__isActive then
            return
        end
        thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
    end

    local function Thumb_OnMouseDown(self)
        local thumb = self.thumb or self
        thumb.__isActive = true
        thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.75)
    end

    local function Thumb_OnMouseUp(self)
        local thumb = self.thumb or self
        thumb.__isActive = nil
        thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
    end

    local function updateScrollArrow(arrow)
        if not arrow.__texture then
            return
        end

        if arrow:IsEnabled() then
            arrow.__texture:SetVertexColor(1, 1, 1)
        else
            arrow.__texture:SetVertexColor(0.5, 0.5, 0.5)
        end
    end

    local function updateTrimScrollArrow(self, atlas)
        local arrow = self.__owner
        if not arrow.__texture then
            return
        end

        if atlas == arrow.disabledTexture then
            arrow.__texture:SetVertexColor(0.5, 0.5, 0.5)
        else
            arrow.__texture:SetVertexColor(1, 1, 1)
        end
    end

    local function reskinScrollArrow(self, direction, minimal)
        if not self then
            return
        end

        if self.Texture then
            self.Texture:SetAlpha(0)
            if self.Overlay then
                self.Overlay:SetAlpha(0)
            end
            if minimal then
                self:SetHeight(17)
            end
        else
            F.StripTextures(self)
        end

        local tex = self:CreateTexture(nil, 'ARTWORK')
        tex:SetAllPoints()
        F.SetupArrow(tex, direction)
        self.__texture = tex

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)

        if self.Texture then
            if minimal then
                return
            end
            self.Texture.__owner = self
            hooksecurefunc(self.Texture, 'SetAtlas', updateTrimScrollArrow)
            updateTrimScrollArrow(self.Texture, self.Texture:GetAtlas())
        else
            hooksecurefunc(self, 'Enable', updateScrollArrow)
            hooksecurefunc(self, 'Disable', updateScrollArrow)
        end
    end

    function F:ReskinScroll()
        F.StripTextures(self:GetParent())
        F.StripTextures(self)

        local thumb = self:GetThumbTexture()
        if thumb then
            thumb:SetAlpha(0)
            thumb.bg = F.CreateBDFrame(thumb, 0.25)
            thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
            thumb.bg:SetPoint('TOPLEFT', thumb, 4, -1)
            thumb.bg:SetPoint('BOTTOMRIGHT', thumb, -4, 1)
            self.thumb = thumb

            self:HookScript('OnEnter', Thumb_OnEnter)
            self:HookScript('OnLeave', Thumb_OnLeave)
            self:HookScript('OnMouseDown', Thumb_OnMouseDown)
            self:HookScript('OnMouseUp', Thumb_OnMouseUp)
        end

        local up, down = self:GetChildren()
        reskinScrollArrow(up, 'up')
        reskinScrollArrow(down, 'down')
    end

    -- WowTrimScrollBar
    function F:ReskinTrimScroll(minimal)
        F.StripTextures(self)
        reskinScrollArrow(self.Back, 'up', minimal)
        reskinScrollArrow(self.Forward, 'down', minimal)
        if self.Track then
            self.Track:DisableDrawLayer('ARTWORK')
        end

        local thumb = self:GetThumb()
        if thumb then
            thumb:DisableDrawLayer('BACKGROUND')
            thumb.bg = F.CreateBDFrame(thumb, 0.25)
            thumb.bg:SetBackdropColor(C.r, C.g, C.b, 0.25)
            if not minimal then
                thumb.bg:SetPoint('TOPLEFT', 4, -1)
                thumb.bg:SetPoint('BOTTOMRIGHT', -4, 1)
            end
            self.thumb = thumb

            thumb:HookScript('OnEnter', Thumb_OnEnter)
            thumb:HookScript('OnLeave', Thumb_OnLeave)
            thumb:HookScript('OnMouseDown', Thumb_OnMouseDown)
            thumb:HookScript('OnMouseUp', Thumb_OnMouseUp)
        end
    end

    -- Handle dropdown
    function F:ReskinDropDown()
        F.StripTextures(self)

        local frameName = self.GetName and self:GetName()
        local down = self.Button or frameName and (_G[frameName .. 'Button'] or _G[frameName .. '_Button'])

        local bg = F.CreateBDFrame(self, 0.45)
        bg:SetPoint('TOPLEFT', 16, -4)
        bg:SetPoint('BOTTOMRIGHT', -18, 8)
        F.CreateSD(bg, 0.25)

        down:ClearAllPoints()
        down:SetPoint('RIGHT', bg, -2, 0)
        F.ReskinArrow(down, 'down')
    end

    -- Handle close button
    function F:Texture_OnEnter()
        if self:IsEnabled() then
            if self.__texture then
                local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
                local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

                if classColor then
                    self.__texture:SetVertexColor(C.r, C.g, C.b)
                else
                    self.__texture:SetVertexColor(newColor.r, newColor.g, newColor.b)
                end
            end
        end
    end

    function F:Texture_OnLeave()
        if self.__texture then
            self.__texture:SetVertexColor(1, 1, 1)
        end
    end

    function F:ReskinClose(parent, xOffset, yOffset)
        parent = parent or self:GetParent()
        xOffset = xOffset or -6
        yOffset = yOffset or -6

        self:SetSize(16, 16)
        self:ClearAllPoints()
        self:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', xOffset, yOffset)

        F.StripTextures(self)
        if self.Border then
            self.Border:SetAlpha(0)
        end
        local bg = F.CreateBDFrame(self, 0, true)
        bg:SetAllPoints()

        self:SetDisabledTexture(C.Assets.Textures.Backdrop)
        local dis = self:GetDisabledTexture()
        dis:SetVertexColor(0, 0, 0, 0.4)
        dis:SetDrawLayer('OVERLAY')
        dis:SetAllPoints()

        local tex = self:CreateTexture()
        tex:SetTexture(C.Assets.Textures.Close)
        tex:SetVertexColor(1, 1, 1)
        tex:SetAllPoints()

        self.__texture = tex

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)
    end

    -- Handle editbox
    function F:ReskinEditBox(height, width)
        local frameName = self.GetName and self:GetName()
        for _, region in pairs(blizzRegions) do
            region = frameName and _G[frameName .. region] or self[region]
            if region then
                region:SetAlpha(0)
            end
        end

        local bg = F.CreateBDFrame(self)
        bg:SetPoint('TOPLEFT', -2, 0)
        bg:SetPoint('BOTTOMRIGHT')
        F.CreateSD(bg, 0.25)
        self.__bg = bg

        if height then
            self:SetHeight(height)
        end
        if width then
            self:SetWidth(width)
        end
    end
    F.ReskinInput = F.ReskinEditBox -- Deprecated

    -- Handle arrows
    local arrowDegree = { ['up'] = 0, ['down'] = 180, ['left'] = 90, ['right'] = -90 }

    function F:SetupArrow(direction)
        self:SetTexture(C.Assets.Textures.Arrow)
        self:SetRotation(rad(arrowDegree[direction]))
    end

    function F:ReskinArrow(direction)
        F.StripTextures(self)
        self:SetSize(16, 16)
        -- self:SetDisabledTexture(C.Assets.Textures.Backdrop)

        -- local dis = self:GetDisabledTexture()
        -- dis:SetVertexColor(0, 0, 0, .3)
        -- dis:SetDrawLayer('OVERLAY')
        -- dis:SetAllPoints()

        F.CreateBDFrame(self, 0.25)

        local tex = self:CreateTexture(nil, 'ARTWORK')
        tex:SetVertexColor(1, 1, 1)
        tex:SetAllPoints()
        F.SetupArrow(tex, direction)
        self.__texture = tex

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)
    end

    function F:ReskinFilterReset()
        F.StripTextures(self)
        self:ClearAllPoints()
        self:SetPoint('TOPRIGHT', -5, 10)

        local tex = self:CreateTexture(nil, 'ARTWORK')
        tex:SetInside(nil, 2, 2)
        tex:SetTexture(C.Assets.Textures.Close)
        tex:SetVertexColor(1, 0, 0)
    end

    function F:ReskinFilterButton()
        F.StripTextures(self)
        F.Reskin(self)

        if self.Text then
            self.Text:SetPoint('CENTER')
        end

        if self.Icon then
            F.SetupArrow(self.Icon, 'right')
            self.Icon:SetPoint('RIGHT')
            self.Icon:SetSize(14, 14)
        end
        if self.ResetButton then
            F.ReskinFilterReset(self.ResetButton)
        end
    end

    function F:ReskinNavBar()
        if self.navBarStyled then
            return
        end

        local homeButton = self.homeButton
        local overflowButton = self.overflowButton

        self:GetRegions():Hide()
        self:DisableDrawLayer('BORDER')
        self.overlay:Hide()
        homeButton:GetRegions():Hide()
        F.Reskin(homeButton)
        F.Reskin(overflowButton, true)

        local tex = overflowButton:CreateTexture(nil, 'ARTWORK')
        tex:SetTexture(C.Assets.Textures.Arrow)
        tex:SetSize(8, 8)
        tex:SetPoint('CENTER')
        overflowButton.__texture = tex

        overflowButton:HookScript('OnEnter', F.Texture_OnEnter)
        overflowButton:HookScript('OnLeave', F.Texture_OnLeave)

        self.navBarStyled = true
    end

    -- Handle checkbox and radio
    function F:ReskinCheckbox(flat, forceSaturation)
        self:SetNormalTexture(C.Assets.Textures.Blank)
        self:SetPushedTexture(C.Assets.Textures.Blank)

        self.bg = F.CreateBDFrame(self, 0.25, true)
        F.SetBorderColor(self.bg)
        self.bg:SetInside(self)
        self.shadow = F.CreateSD(self.bg, 0.25)

        if self.SetHighlightTexture then
            local highligh = self:CreateTexture(nil, 'HIGHLIGHT')
            highligh:SetColorTexture(1, 1, 1, 0.25)
            -- highligh:SetPoint('TOPLEFT', self, 6, -6)
            -- highligh:SetPoint('BOTTOMRIGHT', self, -6, 6)
            highligh:SetInside(self.bg, 1, 1)
            self:SetHighlightTexture(highligh)
        end

        if flat then
            local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
            local normTex = C.Assets.Textures.StatusbarFlat
            local gradTex = C.Assets.Textures.StatusbarGradient
            local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
            local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

            if self.SetCheckedTexture then
                local checked = self:CreateTexture()
                checked:SetTexture(gradStyle and gradTex or normTex)
                checked:SetInside(self.bg, 1, 1)
                checked:SetDesaturated(true)

                if classColor then
                    checked:SetVertexColor(C.r, C.g, C.b)
                else
                    checked:SetVertexColor(newColor.r, newColor.g, newColor.b)
                end

                self:SetCheckedTexture(checked)
            end

            if self.SetDisabledCheckedTexture then
                local disabled = self:CreateTexture()
                disabled:SetTexture(gradStyle and gradTex or normTex)
                disabled:SetInside(self.bg, 1, 1)
                self:SetDisabledCheckedTexture(disabled)
            end
        else
            self:SetCheckedTexture(C.Assets.Textures.Tick)
            self:SetDisabledCheckedTexture(C.Assets.Textures.Tick)

            if self.SetCheckedTexture then
                local checked = self:GetCheckedTexture()
                checked:SetVertexColor(C.r, C.g, C.b)
                checked:SetInside(self.bg, 1, 1)
                checked:SetDesaturated(true)
            end

            if self.SetDisabledCheckedTexture then
                local disabled = self:GetDisabledCheckedTexture()
                disabled:SetVertexColor(0.3, 0.3, 0.3)
                disabled:SetInside(self.bg, 1, 1)
            end
        end

        self.forceSaturation = forceSaturation
    end

    function F:ReskinRadio()
        self:GetNormalTexture():SetAlpha(0)
        self:GetHighlightTexture():SetAlpha(0)
        self:SetCheckedTexture(C.Assets.Textures.Backdrop)

        local ch = self:GetCheckedTexture()
        ch:SetPoint('TOPLEFT', 4, -4)
        ch:SetPoint('BOTTOMRIGHT', -4, 4)
        ch:SetVertexColor(C.r, C.g, C.b, 0.6)

        local bd = F.CreateBDFrame(self, 0)
        bd:SetPoint('TOPLEFT', 3, -3)
        bd:SetPoint('BOTTOMRIGHT', -3, 3)
        F.CreateGradient(bd)
        self.bd = bd

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)
    end

    -- Color swatch
    function F:ReskinColorSwatch()
        local frameName = self.GetName and self:GetName()
        local swatchBg = frameName and _G[frameName .. 'SwatchBg']
        if swatchBg then
            swatchBg:SetColorTexture(0, 0, 0)
            swatchBg:SetInside(nil, 2, 2)
        end

        self:SetNormalTexture(C.Assets.Textures.Backdrop)
        self:GetNormalTexture():SetInside(self, 3, 3)
    end

    -- Handle slider
    function F:ReskinSlider(vertical)
        if self.SetBackdrop then
            self:SetBackdrop(nil)
        end -- isNewPatch
        F.StripTextures(self)

        local bg = F.CreateBDFrame(self, 0.25, true)
        bg:SetPoint('TOPLEFT', 14, -2)
        bg:SetPoint('BOTTOMRIGHT', -15, 3)
        F.SetBorderColor(bg)
        F.CreateSD(bg, 0.25)
        F.CreateTex(bg)

        local thumb = self:GetThumbTexture()
        thumb:SetTexture(C.Assets.Textures.Spark)
        thumb:SetSize(20, 20)
        thumb:SetBlendMode('ADD')

        if vertical then
            thumb:SetRotation(rad(90))
        end

        local gradStyle = _G.ANDROMEDA_ADB.GradientStyle
        local normTex = C.Assets.Textures.StatusbarFlat
        local gradTex = C.Assets.Textures.StatusbarGradient
        local classColor = _G.ANDROMEDA_ADB.WidgetHighlightClassColor
        local newColor = _G.ANDROMEDA_ADB.WidgetHighlightColor

        local bar = CreateFrame('StatusBar', nil, bg)
        bar:SetStatusBarTexture(gradStyle and gradTex or normTex)

        if classColor then
            bar:SetStatusBarColor(C.r, C.g, C.b, 0.85)
        else
            bar:SetStatusBarColor(newColor.r, newColor.g, newColor.b, 0.85)
        end

        if vertical then
            bar:SetPoint('BOTTOMLEFT', bg, C.MULT, C.MULT)
            bar:SetPoint('BOTTOMRIGHT', bg, -C.MULT, C.MULT)
            bar:SetPoint('TOP', thumb, 'CENTER')
            bar:SetOrientation('VERTICAL')
        else
            bar:SetPoint('TOPLEFT', bg, C.MULT, -C.MULT)
            bar:SetPoint('BOTTOMLEFT', bg, C.MULT, C.MULT)
            bar:SetPoint('RIGHT', thumb, 'CENTER')
        end
    end

    local function reskinStepper(stepper, direction)
        F.StripTextures(stepper)
        stepper:SetWidth(19)

        local tex = stepper:CreateTexture(nil, 'ARTWORK')
        tex:SetAllPoints()
        F.SetupArrow(tex, direction)
        stepper.__texture = tex

        stepper:HookScript('OnEnter', F.Texture_OnEnter)
        stepper:HookScript('OnLeave', F.Texture_OnLeave)
    end

    function F:ReskinStepperSlider(minimal)
        F.StripTextures(self)
        reskinStepper(self.Back, 'left')
        reskinStepper(self.Forward, 'right')
        self.Slider:DisableDrawLayer('ARTWORK')

        local thumb = self.Slider.Thumb
        thumb:SetTexture(C.Assets.Textures.Spark)
        thumb:SetBlendMode('ADD')
        thumb:SetSize(20, 30)

        local bg = F.CreateBDFrame(self.Slider, 0, true)
        local offset = minimal and 10 or 13
        bg:SetPoint('TOPLEFT', 10, -offset)
        bg:SetPoint('BOTTOMRIGHT', -10, offset)

        local bar = CreateFrame('StatusBar', nil, bg)
        bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        bar:SetStatusBarColor(1, 0.8, 0, 0.5)
        bar:SetPoint('TOPLEFT', bg, C.MULT, -C.MULT)
        bar:SetPoint('BOTTOMLEFT', bg, C.MULT, C.MULT)
        bar:SetPoint('RIGHT', thumb, 'CENTER')
    end

    -- Handle collapse
    local function UpdateCollapseTexture(texture, collapsed)
        local atlas = collapsed and 'Soulbinds_Collection_CategoryHeader_Expand' or 'Soulbinds_Collection_CategoryHeader_Collapse'
        texture:SetAtlas(atlas, true)
    end

    local function ResetCollapseTexture(self, texture)
        if self.settingTexture then
            return
        end
        self.settingTexture = true
        self:SetNormalTexture('')

        if texture and texture ~= '' then
            if strfind(texture, 'Plus') or strfind(texture, '[Cc]losed') then
                self.__texture:DoCollapse(true)
            elseif strfind(texture, 'Minus') or strfind(texture, '[Oo]pen') then
                self.__texture:DoCollapse(false)
            end
            self.bg:Show()
        else
            self.bg:Hide()
        end
        self.settingTexture = nil
    end

    function F:ReskinCollapse(isAtlas)
        self:SetNormalTexture(C.Assets.Textures.Blank)
        self:SetHighlightTexture(C.Assets.Textures.Blank)
        self:SetPushedTexture(C.Assets.Textures.Blank)

        local bg = F.CreateBDFrame(self)
        bg:ClearAllPoints()
        bg:SetSize(13, 13)
        bg:SetPoint('TOPLEFT', self:GetNormalTexture())
        F.CreateSD(bg, 0.25)
        self.bg = bg

        self.__texture = bg:CreateTexture(nil, 'OVERLAY')
        self.__texture:SetPoint('CENTER')
        self.__texture.DoCollapse = UpdateCollapseTexture

        self:HookScript('OnEnter', F.Texture_OnEnter)
        self:HookScript('OnLeave', F.Texture_OnLeave)
        if isAtlas then
            hooksecurefunc(self, 'SetNormalAtlas', ResetCollapseTexture)
        else
            hooksecurefunc(self, 'SetNormalTexture', ResetCollapseTexture)
        end
    end

    local buttonNames = { 'MaximizeButton', 'MinimizeButton' }
    function F:ReskinMinMax()
        for _, name in next, buttonNames do
            local button = self[name]
            if button then
                button:SetSize(16, 16)
                button:ClearAllPoints()
                button:SetPoint('CENTER', -3, 0)
                button:SetHitRectInsets(1, 1, 1, 1)
                F.Reskin(button)

                local tex = button:CreateTexture()
                tex:SetAllPoints()
                if name == 'MaximizeButton' then
                    F.SetupArrow(tex, 'up')
                else
                    F.SetupArrow(tex, 'down')
                end
                button.__texture = tex

                button:SetScript('OnEnter', F.Texture_OnEnter)
                button:SetScript('OnLeave', F.Texture_OnLeave)
            end
        end
    end

    -- UI templates
    function F:ReskinPortraitFrame()
        F.StripTextures(self)
        local bg = F.SetBD(self)
        bg:SetAllPoints(self)
        local frameName = self.GetName and self:GetName()
        local portrait = self.PortraitTexture or self.portrait or (frameName and _G[frameName .. 'Portrait'])
        if portrait then
            portrait:SetAlpha(0)
        end
        local closeButton = self.CloseButton or (frameName and _G[frameName .. 'CloseButton'])
        if closeButton then
            F.ReskinClose(closeButton)
        end
        return bg
    end

    local replacedRoleTex = {
        ['Adventures-Tank'] = 'Soulbinds_Tree_Conduit_Icon_Protect',
        ['Adventures-Healer'] = 'ui_adv_health',
        ['Adventures-DPS'] = 'ui_adv_atk',
        ['Adventures-DPS-Ranged'] = 'Soulbinds_Tree_Conduit_Icon_Utility',
    }

    local function ReplaceFollowerRole(roleIcon, atlas)
        local newAtlas = replacedRoleTex[atlas]
        if newAtlas then
            roleIcon:SetAtlas(newAtlas)
        end
    end

    function F:ReskinGarrisonPortrait()
        self.squareBG = F.CreateBDFrame(self.Portrait, 1)

        local level = self.Level or self.LevelText
        if level then
            level:ClearAllPoints()
            level:SetPoint('BOTTOM', self.squareBG)
            if self.LevelCircle then
                self.LevelCircle:Hide()
            end
            if self.LevelBorder then
                self.LevelBorder:SetScale(0.0001)
            end
        end

        if self.PortraitRing then
            self.PortraitRing:Hide()
            self.PortraitRingQuality:SetTexture('')
            self.PortraitRingCover:SetColorTexture(0, 0, 0)
            self.PortraitRingCover:SetAllPoints(self.squareBG)
        end

        if self.Empty then
            self.Empty:SetColorTexture(0, 0, 0)
            self.Empty:SetAllPoints(self.Portrait)
        end
        if self.Highlight then
            self.Highlight:Hide()
        end
        if self.PuckBorder then
            self.PuckBorder:SetAlpha(0)
        end
        if self.TroopStackBorder1 then
            self.TroopStackBorder1:SetAlpha(0)
        end
        if self.TroopStackBorder2 then
            self.TroopStackBorder2:SetAlpha(0)
        end

        if self.HealthBar then
            self.HealthBar.Border:Hide()

            local roleIcon = self.HealthBar.RoleIcon
            roleIcon:ClearAllPoints()
            roleIcon:SetPoint('CENTER', self.squareBG, 'TOPRIGHT', -2, -2)
            ReplaceFollowerRole(roleIcon, roleIcon:GetAtlas())
            hooksecurefunc(roleIcon, 'SetAtlas', ReplaceFollowerRole)

            local background = self.HealthBar.Background
            background:SetAlpha(0)
            background:ClearAllPoints()
            background:SetPoint('TOPLEFT', self.squareBG, 'BOTTOMLEFT', 0, -2)
            background:SetPoint('TOPRIGHT', self.squareBG, 'BOTTOMRIGHT', -2, -2)
            background:SetHeight(2)
            self.HealthBar.Health:SetTexture(C.Assets.Textures.StatusbarNormal)
        end
    end

    function F:StyleSearchButton()
        F.StripTextures(self)
        F.CreateBDFrame(self, 0.25)

        local icon = self.icon or self.Icon
        if icon then
            F.ReskinIcon(icon)
        end

        self:SetHighlightTexture(C.Assets.Textures.Backdrop)
        local hl = self:GetHighlightTexture()
        hl:SetVertexColor(C.r, C.g, C.b, 0.25)
        hl:SetInside()
    end

    function F:AffixesSetup()
        for _, frame in ipairs(self.Affixes) do
            frame.Border:SetTexture(nil)
            frame.Portrait:SetTexture(nil)
            if not frame.bg then
                frame.bg = F.ReskinIcon(frame.Portrait)
            end

            if frame.info then
                frame.Portrait:SetTexture(_G.CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
            elseif frame.affixID then
                local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
                frame.Portrait:SetTexture(filedataid)
            end
        end
    end

    -- Role Icons
    function F:GetRoleTexCoord()
        if self == 'TANK' then
            return 0.34 / 9.03, 2.85 / 9.03, 3.16 / 9.03, 5.67 / 9.03
        elseif self == 'DPS' or self == 'DAMAGER' then
            return 3.27 / 9.03, 5.78 / 9.03, 3.16 / 9.03, 5.67 / 9.03
        elseif self == 'HEALER' then
            return 3.27 / 9.03, 5.78 / 9.03, 0.27 / 9.03, 2.78 / 9.03
        elseif self == 'LEADER' then
            return 0.34 / 9.03, 2.85 / 9.03, 0.27 / 9.03, 2.78 / 9.03
        elseif self == 'READY' then
            return 6.17 / 9.03, 8.68 / 9.03, 0.27 / 9.03, 2.78 / 9.03
        elseif self == 'PENDING' then
            return 6.17 / 9.03, 8.68 / 9.03, 3.16 / 9.03, 5.67 / 9.03
        elseif self == 'REFUSE' then
            return 3.27 / 9.03, 5.78 / 9.03, 6.04 / 9.03, 8.55 / 9.03
        end
    end

    function F:GetRoleTex()
        if self == 'TANK' then
            return C.Assets.Textures.RoleTank
        elseif self == 'DPS' or self == 'DAMAGER' then
            return C.Assets.Textures.RoleDamager
        elseif self == 'HEALER' then
            return C.Assets.Textures.RoleHealer
        end
    end

    function F:ReskinSmallRole(role)
        self:SetTexture(F.GetRoleTex(role))
        self:SetTexCoord(0, 1, 0, 1)
        self:SetSize(32, 32)
    end

    function F:ReskinRole(role)
        if self.background then
            self.background:SetTexture('')
        end

        local cover = self.cover or self.Cover
        if cover then
            cover:SetTexture('')
        end

        local texture = self.GetNormalTexture and self:GetNormalTexture() or self.texture or self.Texture or (self.SetTexture and self) or self.Icon
        if texture then
            texture:SetTexture(C.Assets.Textures.RoleLfgIcons)
            texture:SetTexCoord(F.GetRoleTexCoord(role))
        end
        self.bg = F.CreateBDFrame(self)

        local checkButton = self.checkButton or self.CheckButton or self.CheckBox
        if checkButton then
            checkButton:SetFrameLevel(self:GetFrameLevel() + 2)
            checkButton:SetPoint('BOTTOMLEFT', -2, -2)
            checkButton:SetSize(20, 20)
            F.ReskinCheckbox(checkButton, true)
        end

        local shortageBorder = self.shortageBorder
        if shortageBorder then
            shortageBorder:SetTexture('')
            local icon = self.incentiveIcon
            icon:SetPoint('BOTTOMRIGHT')
            icon:SetSize(14, 14)
            icon.texture:SetSize(14, 14)
            F.ReskinIcon(icon.texture)
            icon.border:SetTexture('')
        end
    end
end

-- Add APIs

do
    function F:SetPointsRestricted(frame)
        if frame and not pcall(frame.GetPoint, frame) then
            return true
        end
    end

    function F:SafeGetPoint(frame)
        if frame and frame.GetPoint and not F:SetPointsRestricted(frame) then
            return frame:GetPoint()
        end
    end

    local function WatchPixelSnap(frame, snap)
        if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and snap then
            frame.PixelSnapDisabled = nil
        end
    end

    local function DisablePixelSnap(frame)
        if (frame and not frame:IsForbidden()) and not frame.PixelSnapDisabled then
            if frame.SetSnapToPixelGrid then
                frame:SetSnapToPixelGrid(false)
                frame:SetTexelSnappingBias(0)
            elseif frame.GetStatusBarTexture then
                local texture = frame:GetStatusBarTexture()
                if texture and texture.SetSnapToPixelGrid then
                    texture:SetSnapToPixelGrid(false)
                    texture:SetTexelSnappingBias(0)
                end
            end

            frame.PixelSnapDisabled = true
        end
    end

    local function SetOutside(obj, anchor, xOffset, yOffset, anchor2, noScale)
        if not anchor then
            anchor = obj:GetParent()
        end

        if not xOffset then
            xOffset = C.MULT
        end
        if not yOffset then
            yOffset = C.MULT
        end
        local x = (noScale and xOffset) or xOffset
        local y = (noScale and yOffset) or yOffset

        if F:SetPointsRestricted(obj) or obj:GetPoint() then
            obj:ClearAllPoints()
        end

        DisablePixelSnap(obj)
        obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', -x, y)
        obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', x, -y)
    end

    local function SetInside(obj, anchor, xOffset, yOffset, anchor2, noScale)
        if not anchor then
            anchor = obj:GetParent()
        end

        if not xOffset then
            xOffset = C.MULT
        end
        if not yOffset then
            yOffset = C.MULT
        end
        local x = (noScale and xOffset) or xOffset
        local y = (noScale and yOffset) or yOffset

        if F:SetPointsRestricted(obj) or obj:GetPoint() then
            obj:ClearAllPoints()
        end

        DisablePixelSnap(obj)
        obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', x, -y)
        obj:SetPoint('BOTTOMRIGHT', anchor2 or anchor, 'BOTTOMRIGHT', -x, y)
    end

    local function Kill(object)
        if object.UnregisterAllEvents then
            object:UnregisterAllEvents()
            object:SetParent(F.HiddenFrame)
        else
            object.Show = object.Hide
        end

        object:Hide()
    end

    local StripTexturesBlizzFrames = {
        'Inset',
        'inset',
        'InsetFrame',
        'LeftInset',
        'RightInset',
        'NineSlice',
        'BG',
        'border',
        'Border',
        'BorderFrame',
        'bottomInset',
        'BottomInset',
        'bgLeft',
        'bgRight',
        'FilligreeOverlay',
        'PortraitOverlay',
        'ArtOverlayFrame',
        'Portrait',
        'portrait',
        'ScrollFrameBorder',
        'ScrollUpBorder',
        'ScrollDownBorder',
    }

    local STRIP_TEX = 'Texture'
    local STRIP_FONT = 'FontString'
    local function StripRegion(which, object, kill, alpha)
        if kill then
            object:Kill()
        elseif which == STRIP_TEX then
            object:SetTexture('')
            object:SetAtlas('')
        elseif which == STRIP_FONT then
            object:SetText('')
        end

        if alpha then
            object:SetAlpha(0)
        end
    end

    local function StripType(which, object, kill, alpha)
        if object:IsObjectType(which) then
            StripRegion(which, object, kill, alpha)
        else
            if which == STRIP_TEX then
                local FrameName = object.GetName and object:GetName()
                for _, Blizzard in pairs(StripTexturesBlizzFrames) do
                    local BlizzFrame = object[Blizzard] or (FrameName and _G[FrameName .. Blizzard])
                    if BlizzFrame and BlizzFrame.StripTextures then
                        BlizzFrame:StripTextures(kill, alpha)
                    end
                end
            end

            if object.GetNumRegions then
                for i = 1, object:GetNumRegions() do
                    local region = select(i, object:GetRegions())
                    if region and region.IsObjectType and region:IsObjectType(which) then
                        StripRegion(which, region, kill, alpha)
                    end
                end
            end
        end
    end

    local function StripTextures(object, kill, alpha)
        StripType(STRIP_TEX, object, kill, alpha)
    end

    local function StripTexts(object, kill, alpha)
        StripType(STRIP_FONT, object, kill, alpha)
    end

    local function GetNamedChild(frame, childName, index)
        local name = frame and frame.GetName and frame:GetName()
        if not name or not childName then
            return nil
        end
        return _G[name .. childName .. (index or '')]
    end

    local function HideBackdrop(frame)
        if frame.NineSlice then
            frame.NineSlice:SetAlpha(0)
        end
        if frame.SetBackdrop then
            frame:SetBackdrop(nil)
        end
    end

    local function AddAPI(object)
        local mt = getmetatable(object).__index
        if not object.Kill then
            mt.Kill = Kill
        end
        if not object.SetInside then
            mt.SetInside = SetInside
        end
        if not object.SetOutside then
            mt.SetOutside = SetOutside
        end

        if not object.HideBackdrop then
            mt.HideBackdrop = HideBackdrop
        end

        if not object.StripTextures then
            mt.StripTextures = StripTextures
        end
        if not object.StripTexts then
            mt.StripTexts = StripTexts
        end

        if not object.GetNamedChild then
            mt.GetNamedChild = GetNamedChild
        end

        if not object.DisabledPixelSnap then
            if mt.SetTexture then
                hooksecurefunc(mt, 'SetTexture', DisablePixelSnap)
            end
            if mt.SetTexCoord then
                hooksecurefunc(mt, 'SetTexCoord', DisablePixelSnap)
            end
            if mt.CreateTexture then
                hooksecurefunc(mt, 'CreateTexture', DisablePixelSnap)
            end
            if mt.SetVertexColor then
                hooksecurefunc(mt, 'SetVertexColor', DisablePixelSnap)
            end
            if mt.SetColorTexture then
                hooksecurefunc(mt, 'SetColorTexture', DisablePixelSnap)
            end
            if mt.SetSnapToPixelGrid then
                hooksecurefunc(mt, 'SetSnapToPixelGrid', WatchPixelSnap)
            end
            if mt.SetStatusBarTexture then
                hooksecurefunc(mt, 'SetStatusBarTexture', DisablePixelSnap)
            end
            mt.DisabledPixelSnap = true
        end
    end

    local handled = { ['Frame'] = true }
    local object = CreateFrame('Frame')
    AddAPI(object)
    AddAPI(object:CreateTexture())
    AddAPI(object:CreateMaskTexture())

    object = _G.EnumerateFrames()
    while object do
        if not object:IsForbidden() and not handled[object:GetObjectType()] then
            AddAPI(object)
            handled[object:GetObjectType()] = true
        end

        object = _G.EnumerateFrames(object)
    end
end