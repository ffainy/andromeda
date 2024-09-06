local F, C = unpack(select(2, ...))

local NORMAL = C.Assets.Fonts.Regular
local BOLD = C.Assets.Fonts.Bold
local CONDENSED = C.Assets.Fonts.Condensed
local COMBAT = C.Assets.Fonts.Combat
local HEADER = C.Assets.Fonts.Header

local function replaceFont(obj, font, size)
    if not font then
        F:Debug('ReplaceFont: Unknown font object.')
        return
    end

    local outline = ANDROMEDA_ADB.FontOutline
    local origFont, origSize = obj:GetFont()
    font = font or origFont
    size = size or origSize

    if outline then
        obj:SetFont(font, size, 'OUTLINE')
        obj:SetShadowColor(0, 0, 0, 1)
        obj:SetShadowOffset(1, -1)
    else
        obj:SetFont(font, size, '')
        obj:SetShadowColor(0, 0, 0, 1)
        obj:SetShadowOffset(2, -2)
    end
end

local function reskinBlizzFonts()
    if not ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    STANDARD_TEXT_FONT = NORMAL
    UNIT_NAME_FONT = HEADER
    DAMAGE_TEXT_FONT = COMBAT

    replaceFont(SystemFont_Outline_Small, NORMAL, 12)
    replaceFont(SystemFont_Outline, NORMAL, 13)
    replaceFont(SystemFont_InverseShadow_Small, NORMAL, 10)
    replaceFont(SystemFont_Huge1, HEADER, 20)
    replaceFont(SystemFont_Huge1_Outline, HEADER, 20)
    replaceFont(SystemFont_OutlineThick_Huge2, HEADER, 22)
    replaceFont(SystemFont_OutlineThick_Huge4, HEADER, 26)
    replaceFont(SystemFont_OutlineThick_WTF, HEADER, 32)
    replaceFont(SystemFont_Tiny2, NORMAL, 8)
    replaceFont(SystemFont_Tiny, NORMAL, 9)
    replaceFont(SystemFont_Shadow_Small, NORMAL, 12)
    replaceFont(SystemFont_Small, NORMAL, 12)
    replaceFont(SystemFont_Small2, NORMAL, 13)
    replaceFont(SystemFont_Shadow_Small2, NORMAL, 13)
    replaceFont(SystemFont_Shadow_Med1_Outline, NORMAL, 12)
    replaceFont(SystemFont_Shadow_Med1, NORMAL, 12)
    replaceFont(SystemFont_Med2, NORMAL, 13)
    replaceFont(SystemFont_Med3, NORMAL, 14)
    replaceFont(SystemFont_Shadow_Med3, NORMAL, 14)
    replaceFont(SystemFont_Shadow_Med3_Outline, NORMAL, 14)
    replaceFont(SystemFont_Large, NORMAL, 14)
    replaceFont(SystemFont_Shadow_Large_Outline, NORMAL, 17)
    replaceFont(SystemFont_Shadow_Med2, NORMAL, 16)
    replaceFont(SystemFont_Shadow_Med2_Outline, NORMAL, 16)
    replaceFont(SystemFont_Shadow_Large, NORMAL, 17)
    replaceFont(SystemFont_Shadow_Large2, NORMAL, 19)
    replaceFont(SystemFont_Shadow_Huge1, HEADER, 20)
    replaceFont(SystemFont_Huge2, HEADER, 24)
    replaceFont(SystemFont_Shadow_Huge2, HEADER, 24)
    replaceFont(SystemFont_Shadow_Huge2_Outline, HEADER, 24)
    replaceFont(SystemFont_Shadow_Huge3, HEADER, 25)
    replaceFont(SystemFont_Shadow_Outline_Huge3, HEADER, 25)
    replaceFont(SystemFont_Huge4, HEADER, 27)
    replaceFont(SystemFont_Shadow_Huge4, HEADER, 27)
    replaceFont(SystemFont_Shadow_Huge4_Outline, HEADER, 27)
    replaceFont(SystemFont_World, HEADER, 64)
    replaceFont(SystemFont_World_ThickOutline, HEADER, 64)
    replaceFont(SystemFont22_Outline, HEADER, 22)
    replaceFont(SystemFont22_Shadow_Outline, HEADER, 22)
    replaceFont(SystemFont_Med1, NORMAL, 13)
    replaceFont(SystemFont_WTF2, HEADER, 64)
    replaceFont(SystemFont_Outline_WTF2, HEADER, 64)
    replaceFont(System15Font, NORMAL, 15)

    replaceFont(Game11Font, NORMAL, 11)
    replaceFont(Game12Font, NORMAL, 12)
    replaceFont(Game13Font, NORMAL, 13)
    replaceFont(Game13FontShadow, NORMAL, 13)
    replaceFont(Game15Font, NORMAL, 15)
    replaceFont(Game16Font, NORMAL, 16)
    replaceFont(Game17Font_Shadow, NORMAL, 17)
    replaceFont(Game18Font, NORMAL, 18)
    replaceFont(Game20Font, HEADER, 20)
    replaceFont(Game24Font, HEADER, 24)
    replaceFont(Game27Font, HEADER, 27)
    replaceFont(Game30Font, HEADER, 30)
    replaceFont(Game32Font, HEADER, 32)
    replaceFont(Game36Font, HEADER, 36)
    replaceFont(Game40Font, HEADER, 40)
    replaceFont(Game40Font_Shadow2, HEADER, 40)
    replaceFont(Game42Font, HEADER, 42)
    replaceFont(Game46Font, HEADER, 46)
    replaceFont(Game48Font, HEADER, 48)
    replaceFont(Game48FontShadow, HEADER, 48)
    replaceFont(Game52Font_Shadow2, HEADER, 52)
    replaceFont(Game58Font_Shadow2, HEADER, 58)
    replaceFont(Game60Font, HEADER, 60)
    replaceFont(Game69Font_Shadow2, HEADER, 69)
    replaceFont(Game72Font, HEADER, 72)
    replaceFont(Game72Font_Shadow, HEADER, 72)
    replaceFont(Game120Font, HEADER, 120)
    replaceFont(Game10Font_o1, NORMAL, 10)
    replaceFont(Game11Font_o1, NORMAL, 11)
    replaceFont(Game12Font_o1, NORMAL, 12)
    replaceFont(Game13Font_o1, NORMAL, 13)
    replaceFont(Game15Font_o1, NORMAL, 15)

    replaceFont(Fancy12Font, NORMAL, 12)
    replaceFont(Fancy14Font, NORMAL, 14)
    replaceFont(Fancy16Font, NORMAL, 16)
    replaceFont(Fancy18Font, NORMAL, 18)
    replaceFont(Fancy20Font, HEADER, 20)
    replaceFont(Fancy22Font, HEADER, 22)
    replaceFont(Fancy24Font, HEADER, 24)
    replaceFont(Fancy27Font, HEADER, 27)
    replaceFont(Fancy30Font, HEADER, 30)
    replaceFont(Fancy32Font, HEADER, 32)
    replaceFont(Fancy48Font, HEADER, 48)

    replaceFont(NumberFont_GameNormal, CONDENSED, 12)
    replaceFont(NumberFont_OutlineThick_Mono_Small, CONDENSED, 11)
    replaceFont(Number12Font_o1, CONDENSED, 11)
    replaceFont(NumberFont_Small, CONDENSED, 11)
    replaceFont(Number11Font, CONDENSED, 10)
    replaceFont(Number12Font, CONDENSED, 11)
    replaceFont(Number13Font, CONDENSED, 12)
    replaceFont(Number15Font, CONDENSED, 14)
    replaceFont(Number16Font, CONDENSED, 15)
    replaceFont(Number18Font, CONDENSED, 17)
    replaceFont(NumberFont_Normal_Med, CONDENSED, 13)
    replaceFont(NumberFont_Outline_Med, CONDENSED, 13)
    replaceFont(NumberFont_Outline_Large, CONDENSED, 16)
    replaceFont(NumberFont_Outline_Huge, HEADER, 20)
    replaceFont(NumberFont_Shadow_Tiny, CONDENSED, 10)
    replaceFont(NumberFont_Shadow_Small, CONDENSED, 12)
    replaceFont(NumberFont_Shadow_Med, CONDENSED, 14)
    replaceFont(NumberFont_Shadow_Large, HEADER, 20)
    replaceFont(PriceFont, CONDENSED, 14)
    replaceFont(NumberFontNormalLargeRight, CONDENSED, 14)

    replaceFont(SplashHeaderFont, HEADER, 24)

    replaceFont(QuestFont_Outline_Huge, NORMAL, 14)
    replaceFont(QuestFont_Super_Huge, HEADER, 22)
    replaceFont(QuestFont_Super_Huge_Outline, HEADER, 22)
    replaceFont(QuestFont_Large, NORMAL, 15)
    replaceFont(QuestFont_Huge, NORMAL, 17)
    replaceFont(QuestFont_30, HEADER, 29)
    replaceFont(QuestFont_39, HEADER, 38)
    replaceFont(QuestFont_Enormous, HEADER, 30)
    replaceFont(QuestFont_Shadow_Small, NORMAL, 12)

    -- QuestFont_Shadow_Huge
    -- QuestFont_Shadow_Super_Huge
    -- QuestFont_Shadow_Enormous

    replaceFont(GameFont_Gigantic, HEADER, 28)

    replaceFont(DestinyFontMed, NORMAL, 14)
    replaceFont(DestinyFontLarge, NORMAL, 18)
    replaceFont(CoreAbilityFont, HEADER, 28)
    replaceFont(DestinyFontHuge, HEADER, 28)

    replaceFont(SpellFont_Small, NORMAL, 12)

    replaceFont(MailFont_Large, NORMAL, 15)

    replaceFont(InvoiceFont_Med, NORMAL, 12)
    replaceFont(InvoiceFont_Small, NORMAL, 10)

    replaceFont(AchievementFont_Small, NORMAL, 10)
    replaceFont(ReputationDetailFont, NORMAL, 12)

    replaceFont(FriendsFont_Normal, NORMAL, 13)
    replaceFont(FriendsFont_11, NORMAL, 12)
    replaceFont(FriendsFont_Small, NORMAL, 12)
    replaceFont(FriendsFont_Large, NORMAL, 15)
    replaceFont(FriendsFont_UserText, NORMAL, 11)

    replaceFont(ChatBubbleFont, BOLD, 14)
    -- ChatFontNormal
    -- ChatFontSmall

    replaceFont(GameTooltipHeader, BOLD, 16)
    replaceFont(Tooltip_Med, NORMAL, 14)
    replaceFont(Tooltip_Small, NORMAL, 12)

    replaceFont(System_IME, BOLD, 16)

    replaceFont(SystemFont_NamePlateFixed, HEADER, 9)
    replaceFont(SystemFont_LargeNamePlateFixed, HEADER, 9)
    replaceFont(SystemFont_NamePlate, HEADER, 9)
    replaceFont(SystemFont_LargeNamePlate, HEADER, 9)
    replaceFont(SystemFont_NamePlateCastBar, HEADER, 9)

    replaceFont(ErrorFont, BOLD, 14)
    replaceFont(CombatTextFont, COMBAT, 200) -- improved text quality at high resolution ???

    replaceFont(RaidWarningFrame.slot1, BOLD, 20)
    replaceFont(RaidWarningFrame.slot2, BOLD, 20)
    replaceFont(RaidBossEmoteFrame.slot1, BOLD)
    replaceFont(RaidBossEmoteFrame.slot2, BOLD, 20)

    replaceFont(GameFontNormal, NORMAL, 13)
    replaceFont(QuestFont, NORMAL, 15)

    -- new font family in 11.0.2
    for i = 12, 22 do
        local font = _G['ObjectiveTrackerFont' .. i]
        if font then
            replaceFont(font, NORMAL, 13)
        end
    end
    replaceFont(ObjectiveTrackerHeaderFont, HEADER, 13)
    replaceFont(ObjectiveTrackerLineFont, NORMAL, 13)

    F:UnregisterEvent('ADDON_LOADED', reskinBlizzFonts)
end

F:RegisterEvent('ADDON_LOADED', reskinBlizzFonts)
