local F, C, L = unpack(select(2, ...))
local ACTIONBAR = F:GetModule('ActionBar')

function ACTIONBAR:CreateExtraBar()
    local padding = C.DB['Actionbar']['BarPadding']
    local buttonList = {}
    local size = C.DB['Actionbar']['BarExtraButtonSize']

    -- ExtraActionButton
    local frame = CreateFrame('Frame', C.ADDON_TITLE .. 'ActionBarExtra', UIParent, 'SecureHandlerStateTemplate')
    frame:SetWidth(size + 2 * padding)
    frame:SetHeight(size + 2 * padding)
    frame.mover = F.Mover(frame, L['ExtraButton'], 'ExtraButton', { 'CENTER', UIParent, 'CENTER', 0, 250 })

    local ExtraActionBarFrame = ExtraActionBarFrame
    ExtraActionBarFrame:EnableMouse(false)
    ExtraActionBarFrame:ClearAllPoints()
    ExtraActionBarFrame:SetPoint('CENTER', frame)
    ExtraActionBarFrame.ignoreFramePositionManager = true

    hooksecurefunc(ExtraActionBarFrame, 'SetParent', function(self, parent)
        if parent == ExtraAbilityContainer then
            self:SetParent(frame)
        end
    end)

    local button = ExtraActionButton1
    tinsert(buttonList, button)
    tinsert(ACTIONBAR.buttons, button)
    button:SetSize(size, size)

    if ExtraActionButton1HotKey then
        ExtraActionButton1HotKey:SetFont(C.Assets.Fonts.Condensed, 11, 'OUTLINE')
        ExtraActionButton1HotKey:ClearAllPoints()
        ExtraActionButton1HotKey:SetPoint('TOPLEFT', button, 'TOPLEFT', 2, -2)
        ExtraActionButton1HotKey:SetJustifyH('LEFT')
    end
    if ExtraActionButton1Count then
        ExtraActionButton1Count:SetFont(C.Assets.Fonts.Condensed, 11, 'OUTLINE')
        ExtraActionButton1Count:ClearAllPoints()
        ExtraActionButton1Count:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -2, 2)
        ExtraActionButton1Count:SetJustifyH('RIGHT')
    end

    frame.frameVisibility = '[extrabar] show; hide'
    RegisterStateDriver(frame, 'visibility', frame.frameVisibility)

    -- ZoneAbility
    local zoneFrame = CreateFrame('Frame', C.ADDON_TITLE .. 'ActionBarZone', UIParent)
    zoneFrame:SetWidth(size + 2 * padding)
    zoneFrame:SetHeight(size + 2 * padding)
    zoneFrame.mover = F.Mover(zoneFrame, L['ZoneAbilityButton'], 'ZoneAbilityButton', { 'CENTER', UIParent, 'CENTER', 0, 200 })

    local ZoneAbilityFrame = ZoneAbilityFrame
    ZoneAbilityFrame:SetParent(zoneFrame)
    ZoneAbilityFrame:ClearAllPoints()
    ZoneAbilityFrame:SetPoint('CENTER', zoneFrame)
    ZoneAbilityFrame.ignoreFramePositionManager = true
    ZoneAbilityFrame.Style:SetAlpha(0)

    hooksecurefunc(ZoneAbilityFrame, 'UpdateDisplayedZoneAbilities', function(self)
        for spellButton in self.SpellButtonContainer:EnumerateActive() do
            if spellButton and not spellButton.styled then
                spellButton.NormalTexture:SetAlpha(0)
                spellButton:SetPushedTexture(C.Assets.Textures.ButtonPushed) --force it to gain a texture
                spellButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                spellButton:GetHighlightTexture():SetInside()
                spellButton.Icon:SetInside()
                F.ReskinIcon(spellButton.Icon, true)
                spellButton.styled = true
            end
        end
    end)

    -- Fix button visibility
    hooksecurefunc(ZoneAbilityFrame, 'SetParent', function(self, parent)
        if parent == ExtraAbilityContainer then
            self:SetParent(zoneFrame)
        end
    end)
end
