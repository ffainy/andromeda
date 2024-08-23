local F, C = unpack(select(2, ...))

local Type_StatusBar = Enum.UIWidgetVisualizationType.StatusBar
local Type_CaptureBar = Enum.UIWidgetVisualizationType.CaptureBar
local Type_SpellDisplay = Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = Enum.UIWidgetVisualizationType.DoubleStatusBar
local Type_ItemDisplay = Enum.UIWidgetVisualizationType.ItemDisplay

local atlasColors = {
    ['UI-Frame-Bar-Fill-Blue'] = { 0.2, 0.6, 1 },
    ['UI-Frame-Bar-Fill-Red'] = { 0.9, 0.2, 0.2 },
    ['UI-Frame-Bar-Fill-Yellow'] = { 1, 0.6, 0 },
    ['objectivewidget-bar-fill-left'] = { 0.2, 0.6, 1 },
    ['objectivewidget-bar-fill-right'] = { 0.9, 0.2, 0.2 },
    ['EmberCourtScenario-Tracker-barfill'] = { 0.9, 0.2, 0.2 },
}

local function replaceWidgetBarTexture(self, atlas)
    if self:IsForbidden() then
        return
    end

    if atlasColors[atlas] then
        self:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
        self:SetStatusBarColor(unpack(atlasColors[atlas]))
    end
end

local function resetLabelColor(text, _, _, _, _, force)
    if not force then
        text:SetTextColor(1, 1, 1, 1, true)
    end
end

local function reskinWidgetStatusBar(bar)
    if not bar or bar:IsForbidden() then
        return
    end

    if bar and not bar.styled then
        if bar.BG then
            bar.BG:SetAlpha(0)
        end

        if bar.BGLeft then
            bar.BGLeft:SetAlpha(0)
        end

        if bar.BGRight then
            bar.BGRight:SetAlpha(0)
        end

        if bar.BGCenter then
            bar.BGCenter:SetAlpha(0)
        end

        if bar.BorderLeft then
            bar.BorderLeft:SetAlpha(0)
        end

        if bar.BorderRight then
            bar.BorderRight:SetAlpha(0)
        end

        if bar.BorderCenter then
            bar.BorderCenter:SetAlpha(0)
        end

        if bar.Spark then
            bar.Spark:SetAlpha(0)
        end

        if bar.SparkGlow then
            bar.SparkGlow:SetAlpha(0)
        end

        if bar.BorderGlow then
            bar.BorderGlow:SetAlpha(0)
        end

        if bar.Label then
            bar.Label:SetPoint('CENTER')
            bar.Label:SetFontObject(Game12Font)
            resetLabelColor(bar.Label)
            hooksecurefunc(bar.Label, 'SetTextColor', resetLabelColor)
        end

        F.SetBD(bar)

        if bar.GetStatusBarTexture then
            replaceWidgetBarTexture(bar, bar:GetStatusBarTexture())
            hooksecurefunc(bar, 'SetStatusBarTexture', replaceWidgetBarTexture)
        end

        bar.styled = true
    end
end

local function reskinDoubleStatusBarWidget(self)
    if self:IsForbidden() then
        return
    end

    if not self.styled then
        reskinWidgetStatusBar(self.LeftBar)
        reskinWidgetStatusBar(self.RightBar)

        self.styled = true
    end
end

local function reskinPVPCaptureBar(self)
    if self:IsForbidden() then
        return
    end

    self.LeftBar:SetTexture(C.Assets.Textures.StatusbarNormal)
    self.NeutralBar:SetTexture(C.Assets.Textures.StatusbarNormal)
    self.RightBar:SetTexture(C.Assets.Textures.StatusbarNormal)

    self.LeftBar:SetVertexColor(0.2, 0.6, 1)
    self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)
    self.RightBar:SetVertexColor(0.9, 0.2, 0.2)

    self.LeftLine:SetAlpha(0)
    self.RightLine:SetAlpha(0)
    self.BarBackground:SetAlpha(0)
    self.Glow1:SetAlpha(0)
    self.Glow2:SetAlpha(0)
    self.Glow3:SetAlpha(0)

    if not self.bg then
        self.bg = F.SetBD(self)
        self.bg:SetPoint('TOPLEFT', self.LeftBar, -2, 2)
        self.bg:SetPoint('BOTTOMRIGHT', self.RightBar, 2, -2)
    end
end

local function reskinSpellDisplayWidget(spell)
    if not spell or spell:IsForbidden() then
        return
    end

    if not spell.bg then
        spell.Border:SetAlpha(0)
        spell.DebuffBorder:SetAlpha(0)
        spell.bg = F.ReskinIcon(spell.Icon)
    end

    spell.IconMask:Hide()
end

local function reskinPowerBarWidget(self)
    if not self.widgetFrames then
        return
    end

    for _, widgetFrame in pairs(self.widgetFrames) do
        if widgetFrame.widgetType == Type_StatusBar then
            if not widgetFrame:IsForbidden() then
                reskinWidgetStatusBar(widgetFrame.Bar)
            end
        end
    end
end

local function reskinWidgetItemDisplay(item)
    if not item.bg then
        item.bg = F.ReskinIcon(item.Icon)
        F.ReskinIconBorder(item.IconBorder, true)
    end

    item.IconMask:Hide()
end

local function reskinWidgetGroups(self)
    if not self.widgetFrames then
        return
    end

    for _, widgetFrame in pairs(self.widgetFrames) do
        if not widgetFrame:IsForbidden() then
            local widgetType = widgetFrame.widgetType
            if widgetType == Type_DoubleStatusBar then
                reskinDoubleStatusBarWidget(widgetFrame)
            elseif widgetType == Type_SpellDisplay then
                reskinSpellDisplayWidget(widgetFrame.Spell)
            elseif widgetType == Type_StatusBar then
                reskinWidgetStatusBar(widgetFrame.Bar)
            elseif widgetType == Type_ItemDisplay then
                reskinWidgetItemDisplay(widgetFrame.Item)
            end
        end
    end
end

tinsert(C.BlizzThemes, function()
    hooksecurefunc(UIWidgetTopCenterContainerFrame, 'UpdateWidgetLayout', reskinWidgetGroups)
    reskinWidgetGroups(UIWidgetTopCenterContainerFrame)

    hooksecurefunc(UIWidgetBelowMinimapContainerFrame, 'UpdateWidgetLayout', function(self)
        if not self.widgetFrames then
            return
        end

        for _, widgetFrame in pairs(self.widgetFrames) do
            if widgetFrame.widgetType == Type_CaptureBar then
                if not widgetFrame:IsForbidden() then
                    reskinPVPCaptureBar(widgetFrame)
                end
            end
        end
    end)

    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'UpdateWidgetLayout', reskinPowerBarWidget)
    reskinPowerBarWidget(UIWidgetPowerBarContainerFrame)

    hooksecurefunc(ObjectiveTrackerUIWidgetContainer, 'UpdateWidgetLayout', reskinPowerBarWidget)
    reskinPowerBarWidget(ObjectiveTrackerUIWidgetContainer)

    -- if font outline enabled in tooltip, fix text shows in two lines on Torghast info
    hooksecurefunc(UIWidgetTemplateTextWithStateMixin, 'Setup', function(self)
        self.Text:SetWidth(self.Text:GetStringWidth() + 2)
    end)

    -- needs review, might remove this in the future
    hooksecurefunc(UIWidgetTemplateStatusBarMixin, 'Setup', function(self)
        if self:IsForbidden() then
            return
        end

        reskinWidgetStatusBar(self.Bar)
    end)

    F.ReskinButton(UIWidgetCenterDisplayFrame.CloseButton)
end)
