local F, C = unpack(select(2, ...))

local NORMAL = C.Assets.Fonts.Regular
local BOLD = C.Assets.Fonts.Bold
local COMBAT = C.Assets.Fonts.Combat
local HEADER = C.Assets.Fonts.Header

local function ReplaceFont(obj, font, size, flag, shadow)
    if not font then
        F:Debug('ReplaceFont: Unknown font object.')
        return
    end

    local outline = _G.ANDROMEDA_ADB.FontOutline
    local origFont, origSize = obj:GetFont()
    font = font or origFont
    size = size or origSize

    if outline then
        obj:SetFont(font, size, 'OUTLINE')
    else
        obj:SetFont(font, size, flag and 'OUTLINE' or '')
    end

    if shadow then
        obj:SetShadowColor(0, 0, 0, 1)
        obj:SetShadowOffset(2, -2)
    else
        obj:SetShadowColor(0, 0, 0, 1)
        obj:SetShadowOffset(1, -1)
    end
end

local function SetupBlizFonts()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    _G.STANDARD_TEXT_FONT = NORMAL
    _G.UNIT_NAME_FONT = HEADER
    _G.DAMAGE_TEXT_FONT = COMBAT

    ReplaceFont(_G.SystemFont_Outline_Small, NORMAL, 12)
    ReplaceFont(_G.SystemFont_Outline, NORMAL, 13)
    ReplaceFont(_G.SystemFont_InverseShadow_Small, NORMAL, 10)
    ReplaceFont(_G.SystemFont_Huge1, HEADER, 20)
    ReplaceFont(_G.SystemFont_Huge1_Outline, HEADER, 20)
    ReplaceFont(_G.SystemFont_OutlineThick_Huge2, HEADER, 22)
    ReplaceFont(_G.SystemFont_OutlineThick_Huge4, HEADER, 26)
    ReplaceFont(_G.SystemFont_OutlineThick_WTF, HEADER, 32)
    ReplaceFont(_G.SystemFont_Tiny2, NORMAL, 8)
    ReplaceFont(_G.SystemFont_Tiny, NORMAL, 9)
    ReplaceFont(_G.SystemFont_Shadow_Small, NORMAL, 12)
    ReplaceFont(_G.SystemFont_Small, NORMAL, 12)
    ReplaceFont(_G.SystemFont_Small2, NORMAL, 13)
    ReplaceFont(_G.SystemFont_Shadow_Small2, NORMAL, 13)
    ReplaceFont(_G.SystemFont_Shadow_Med1_Outline, NORMAL, 12)
    ReplaceFont(_G.SystemFont_Shadow_Med1, NORMAL, 12)
    ReplaceFont(_G.SystemFont_Med2, NORMAL, 13)
    ReplaceFont(_G.SystemFont_Med3, NORMAL, 14)
    ReplaceFont(_G.SystemFont_Shadow_Med3, NORMAL, 14)
    ReplaceFont(_G.SystemFont_Shadow_Med3_Outline, NORMAL, 14)
    ReplaceFont(_G.SystemFont_Large, NORMAL, 14)
    ReplaceFont(_G.SystemFont_Shadow_Large_Outline, NORMAL, 17)
    ReplaceFont(_G.SystemFont_Shadow_Med2, NORMAL, 16)
    ReplaceFont(_G.SystemFont_Shadow_Med2_Outline, NORMAL, 16)
    ReplaceFont(_G.SystemFont_Shadow_Large, NORMAL, 17)
    ReplaceFont(_G.SystemFont_Shadow_Large2, NORMAL, 19)
    ReplaceFont(_G.SystemFont_Shadow_Huge1, HEADER, 20)
    ReplaceFont(_G.SystemFont_Huge2, HEADER, 24)
    ReplaceFont(_G.SystemFont_Shadow_Huge2, HEADER, 24)
    ReplaceFont(_G.SystemFont_Shadow_Huge2_Outline, HEADER, 24)
    ReplaceFont(_G.SystemFont_Shadow_Huge3, HEADER, 25)
    ReplaceFont(_G.SystemFont_Shadow_Outline_Huge3, HEADER, 25)
    ReplaceFont(_G.SystemFont_Huge4, HEADER, 27)
    ReplaceFont(_G.SystemFont_Shadow_Huge4, HEADER, 27)
    ReplaceFont(_G.SystemFont_Shadow_Huge4_Outline, HEADER, 27)
    ReplaceFont(_G.SystemFont_World, HEADER, 64)
    ReplaceFont(_G.SystemFont_World_ThickOutline, HEADER, 64)
    ReplaceFont(_G.SystemFont22_Outline, HEADER, 22)
    ReplaceFont(_G.SystemFont22_Shadow_Outline, HEADER, 22)
    ReplaceFont(_G.SystemFont_Med1, NORMAL, 13)
    ReplaceFont(_G.SystemFont_WTF2, HEADER, 64)
    ReplaceFont(_G.SystemFont_Outline_WTF2, HEADER, 64)
    ReplaceFont(_G.System15Font, NORMAL, 15)

    ReplaceFont(_G.Game11Font, NORMAL, 11)
    ReplaceFont(_G.Game12Font, NORMAL, 12)
    ReplaceFont(_G.Game13Font, NORMAL, 13)
    ReplaceFont(_G.Game13FontShadow, NORMAL, 13)
    ReplaceFont(_G.Game15Font, NORMAL, 15)
    ReplaceFont(_G.Game16Font, NORMAL, 16)
    ReplaceFont(_G.Game17Font_Shadow, NORMAL, 17)
    ReplaceFont(_G.Game18Font, NORMAL, 18)
    ReplaceFont(_G.Game20Font, HEADER, 20)
    ReplaceFont(_G.Game24Font, HEADER, 24)
    ReplaceFont(_G.Game27Font, HEADER, 27)
    ReplaceFont(_G.Game30Font, HEADER, 30)
    ReplaceFont(_G.Game32Font, HEADER, 32)
    ReplaceFont(_G.Game36Font, HEADER, 36)
    ReplaceFont(_G.Game40Font, HEADER, 40)
    ReplaceFont(_G.Game40Font_Shadow2, HEADER, 40)
    ReplaceFont(_G.Game42Font, HEADER, 42)
    ReplaceFont(_G.Game46Font, HEADER, 46)
    ReplaceFont(_G.Game48Font, HEADER, 48)
    ReplaceFont(_G.Game48FontShadow, HEADER, 48)
    ReplaceFont(_G.Game52Font_Shadow2, HEADER, 52)
    ReplaceFont(_G.Game58Font_Shadow2, HEADER, 58)
    ReplaceFont(_G.Game60Font, HEADER, 60)
    ReplaceFont(_G.Game69Font_Shadow2, HEADER, 69)
    ReplaceFont(_G.Game72Font, HEADER, 72)
    ReplaceFont(_G.Game72Font_Shadow, HEADER, 72)
    ReplaceFont(_G.Game120Font, HEADER, 120)
    ReplaceFont(_G.Game10Font_o1, NORMAL, 10)
    ReplaceFont(_G.Game11Font_o1, NORMAL, 11)
    ReplaceFont(_G.Game12Font_o1, NORMAL, 12)
    ReplaceFont(_G.Game13Font_o1, NORMAL, 13)
    ReplaceFont(_G.Game15Font_o1, NORMAL, 15)

    ReplaceFont(_G.Fancy12Font, NORMAL, 12)
    ReplaceFont(_G.Fancy14Font, NORMAL, 14)
    ReplaceFont(_G.Fancy16Font, NORMAL, 16)
    ReplaceFont(_G.Fancy18Font, NORMAL, 18)
    ReplaceFont(_G.Fancy20Font, HEADER, 20)
    ReplaceFont(_G.Fancy22Font, HEADER, 22)
    ReplaceFont(_G.Fancy24Font, HEADER, 24)
    ReplaceFont(_G.Fancy27Font, HEADER, 27)
    ReplaceFont(_G.Fancy30Font, HEADER, 30)
    ReplaceFont(_G.Fancy32Font, HEADER, 32)
    ReplaceFont(_G.Fancy48Font, HEADER, 48)

    ReplaceFont(_G.NumberFont_GameNormal, NORMAL, 12, true)
    ReplaceFont(_G.NumberFont_OutlineThick_Mono_Small, NORMAL, 11, true)
    ReplaceFont(_G.Number12Font_o1, NORMAL, 11, true)
    ReplaceFont(_G.NumberFont_Small, NORMAL, 11, true)
    ReplaceFont(_G.Number11Font, NORMAL, 10, true)
    ReplaceFont(_G.Number12Font, NORMAL, 11, true)
    ReplaceFont(_G.Number13Font, NORMAL, 12, true)
    ReplaceFont(_G.Number15Font, NORMAL, 14, true)
    ReplaceFont(_G.Number16Font, NORMAL, 15, true)
    ReplaceFont(_G.Number18Font, NORMAL, 17, true)
    ReplaceFont(_G.NumberFont_Normal_Med, NORMAL, 13, true)
    ReplaceFont(_G.NumberFont_Outline_Med, NORMAL, 13, true)
    ReplaceFont(_G.NumberFont_Outline_Large, NORMAL, 16, true)
    ReplaceFont(_G.NumberFont_Outline_Huge, HEADER, 20, true)
    ReplaceFont(_G.NumberFont_Shadow_Tiny, NORMAL, 10, true)
    ReplaceFont(_G.NumberFont_Shadow_Small, NORMAL, 12, true)
    ReplaceFont(_G.NumberFont_Shadow_Med, NORMAL, 14, true)
    ReplaceFont(_G.NumberFont_Shadow_Large, HEADER, 20, true)
    ReplaceFont(_G.PriceFont, NORMAL, 14, true)
    ReplaceFont(_G.NumberFontNormalLargeRight, NORMAL, 14, true)

    ReplaceFont(_G.SplashHeaderFont, HEADER, 24)

    ReplaceFont(_G.QuestFont_Outline_Huge, NORMAL, 14)
    ReplaceFont(_G.QuestFont_Super_Huge, HEADER, 22)
    ReplaceFont(_G.QuestFont_Super_Huge_Outline, HEADER, 22)
    ReplaceFont(_G.QuestFont_Large, NORMAL, 15)
    ReplaceFont(_G.QuestFont_Huge, NORMAL, 17)
    ReplaceFont(_G.QuestFont_30, HEADER, 29)
    ReplaceFont(_G.QuestFont_39, HEADER, 38)
    ReplaceFont(_G.QuestFont_Enormous, HEADER, 30)
    ReplaceFont(_G.QuestFont_Shadow_Small, NORMAL, 12)

    -- QuestFont_Shadow_Huge
    -- QuestFont_Shadow_Super_Huge
    -- QuestFont_Shadow_Enormous

    ReplaceFont(_G.GameFont_Gigantic, HEADER, 28)

    ReplaceFont(_G.DestinyFontMed, NORMAL, 14)
    ReplaceFont(_G.DestinyFontLarge, NORMAL, 18)
    ReplaceFont(_G.CoreAbilityFont, HEADER, 28)
    ReplaceFont(_G.DestinyFontHuge, HEADER, 28)

    ReplaceFont(_G.SpellFont_Small, NORMAL, 12)

    ReplaceFont(_G.MailFont_Large, NORMAL, 15)

    ReplaceFont(_G.InvoiceFont_Med, NORMAL, 12)
    ReplaceFont(_G.InvoiceFont_Small, NORMAL, 10)

    ReplaceFont(_G.AchievementFont_Small, NORMAL, 10)
    ReplaceFont(_G.ReputationDetailFont, NORMAL, 12)

    ReplaceFont(_G.FriendsFont_Normal, NORMAL, 13)
    ReplaceFont(_G.FriendsFont_11, NORMAL, 12)
    ReplaceFont(_G.FriendsFont_Small, NORMAL, 12)
    ReplaceFont(_G.FriendsFont_Large, NORMAL, 15)
    ReplaceFont(_G.FriendsFont_UserText, NORMAL, 11)

    ReplaceFont(_G.ChatBubbleFont, BOLD, 14)
    -- ChatFontNormal
    -- ChatFontSmall

    ReplaceFont(GameTooltipHeader, BOLD, 16)
    ReplaceFont(_G.Tooltip_Med, NORMAL, 14)
    ReplaceFont(_G.Tooltip_Small, NORMAL, 12)

    ReplaceFont(_G.System_IME, BOLD, 16)

    ReplaceFont(_G.SystemFont_NamePlateFixed, HEADER, 9, nil, true)
    ReplaceFont(_G.SystemFont_LargeNamePlateFixed, HEADER, 9, nil, true)
    ReplaceFont(_G.SystemFont_NamePlate, HEADER, 9, nil, true)
    ReplaceFont(_G.SystemFont_LargeNamePlate, HEADER, 9, nil, true)
    ReplaceFont(_G.SystemFont_NamePlateCastBar, HEADER, 9, nil, true)

    ReplaceFont(_G.ErrorFont, BOLD, 14)
    ReplaceFont(_G.CombatTextFont, COMBAT, 200) -- improved text quality at high resolution ???

    ReplaceFont(_G.RaidWarningFrame.slot1, BOLD, 20)
    ReplaceFont(_G.RaidWarningFrame.slot2, BOLD, 20)
    ReplaceFont(_G.RaidBossEmoteFrame.slot1, BOLD)
    ReplaceFont(_G.RaidBossEmoteFrame.slot2, BOLD, 20)

    ReplaceFont(_G.GameFontNormal, NORMAL, 13)
    ReplaceFont(_G.QuestFont, NORMAL, 15)

    -- force to whiten some fonts
    _G.GameFontBlack:SetTextColor(1, 1, 1)
    _G.GameFontBlackMedium:SetTextColor(1, 1, 1)
    _G.CoreAbilityFont:SetTextColor(1, 1, 1)

    F:UnregisterEvent('ADDON_LOADED', SetupBlizFonts)
end

F:RegisterEvent('ADDON_LOADED', SetupBlizFonts)
