local F, C = unpack(select(2, ...))

C.Themes['Blizzard_ChallengesUI'] = function()
    _G.ChallengesFrameInset:Hide()
    for i = 1, 2 do
        select(i, _G.ChallengesFrame:GetRegions()):Hide()
    end

    local angryStyle
    local function UpdateIcons(self)
        for i = 1, #self.maps do
            local bu = self.DungeonIcons[i]
            if bu and not bu.styled then
                bu:GetRegions():SetAlpha(0)
                bu.Icon:SetTexCoord(unpack(C.TEX_COORD))
                bu.Icon:SetInside()
                F.CreateBDFrame(bu.Icon, 0)

                bu.styled = true
            end
            if i == 1 then
                self.WeeklyInfo.Child.SeasonBest:ClearAllPoints()
                self.WeeklyInfo.Child.SeasonBest:SetPoint('BOTTOMLEFT', self.DungeonIcons[i], 'TOPLEFT', 0, 2)
            end
        end

        if C_AddOns.IsAddOnLoaded('AngryKeystones') and not angryStyle then
            local mod = _G.AngryKeystones.Modules.Schedule
            local scheduel = mod.AffixFrame
            if scheduel then
                F.StripTextures(scheduel)
                F.CreateBDFrame(scheduel, 0.25)

                if scheduel.Entries then
                    for i = 1, 3 do
                        F.AffixesSetup(scheduel.Entries[i])
                    end
                end

                local party = mod.PartyFrame
                F.StripTextures(party)
                F.CreateBDFrame(party, 0.25)
            end

            angryStyle = true
        end
    end

    hooksecurefunc(_G.ChallengesFrame, 'Update', UpdateIcons)
    hooksecurefunc(_G.ChallengesFrame.WeeklyInfo, 'SetUp', function(self)
        local affixes = C_MythicPlus.GetCurrentAffixes()
        if affixes then
            F.AffixesSetup(self.Child)
        end
    end)

    local keystone = _G.ChallengesKeystoneFrame
    F.SetBD(keystone)
    F.ReskinClose(keystone.CloseButton)
    F.ReskinButton(keystone.StartButton)

    hooksecurefunc(keystone, 'Reset', function(self)
        self:GetRegions():SetAlpha(0)
        self.InstructionBackground:SetAlpha(0)
    end)

    hooksecurefunc(keystone, 'OnKeystoneSlotted', F.AffixesSetup)

    -- New season
    local noticeFrame = _G.ChallengesFrame.SeasonChangeNoticeFrame
    F.ReskinButton(noticeFrame.Leave)
    noticeFrame.Leave.__bg:SetFrameLevel(noticeFrame:GetFrameLevel() + 1)
    noticeFrame.NewSeason:SetTextColor(1, 0.8, 0)
    noticeFrame.SeasonDescription:SetTextColor(1, 1, 1)
    noticeFrame.SeasonDescription2:SetTextColor(1, 1, 1)
    noticeFrame.SeasonDescription3:SetTextColor(1, 0.8, 0)

    local affix = noticeFrame.Affix
    F.StripTextures(affix)
    local bg = F.ReskinIcon(affix.Portrait)
    bg:SetFrameLevel(3)

    hooksecurefunc(affix, 'SetUp', function(_, affixID)
        local _, _, texture = C_ChallengeMode.GetAffixInfo(affixID)
        if texture then
            affix.Portrait:SetTexture(texture)
        end
    end)
end
