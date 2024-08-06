local F, C = unpack(select(2, ...))

local function updateGuildRanks()
    for i = 1, GuildControlGetNumRanks() do
        local rank = _G['GuildControlUIRankOrderFrameRank' .. i]
        if not rank.styled then
            rank.upButton.icon:Hide()
            rank.downButton.icon:Hide()
            rank.deleteButton.icon:Hide()

            F.ReskinArrow(rank.upButton, 'up')
            F.ReskinArrow(rank.downButton, 'down')
            F.ReskinClose(rank.deleteButton)
            F.ReskinEditbox(rank.nameBox, 20)

            rank.styled = true
        end
    end
end

C.Themes['Blizzard_GuildControlUI'] = function()
    local r, g, b = C.r, C.g, C.b

    F.SetBD(_G.GuildControlUI)

    for i = 1, 9 do
        select(i, _G.GuildControlUI:GetRegions()):Hide()
    end

    for i = 1, 8 do
        select(i, _G.GuildControlUIRankBankFrameInset:GetRegions()):Hide()
    end

    _G.GuildControlUIRankSettingsFrameOfficerBg:SetAlpha(0)
    _G.GuildControlUIRankSettingsFrameRosterBg:SetAlpha(0)
    _G.GuildControlUIRankSettingsFrameBankBg:SetAlpha(0)
    _G.GuildControlUITopBg:Hide()
    _G.GuildControlUIHbar:Hide()

    -- Guild ranks
    F:RegisterEvent('GUILD_RANKS_UPDATE', updateGuildRanks)
    hooksecurefunc('GuildControlUI_RankOrder_Update', updateGuildRanks)

    -- Guild tabs
    local checkboxes = { 'viewCB', 'depositCB' }
    hooksecurefunc('GuildControlUI_BankTabPermissions_Update', function()
        for i = 1, GetNumGuildBankTabs() + 1 do
            local tab = 'GuildControlBankTab' .. i
            local bu = _G[tab]
            if bu and not bu.styled then
                local ownedTab = bu.owned

                _G[tab .. 'Bg']:Hide()
                F.ReskinIcon(ownedTab.tabIcon)
                F.CreateBDFrame(bu, 0.25)
                F.ReskinButton(bu.buy.button)
                F.ReskinEditbox(ownedTab.editBox)

                for _, name in pairs(checkboxes) do
                    local box = ownedTab[name]
                    box:SetNormalTexture(0)
                    box:SetPushedTexture(0)
                    box:SetHighlightTexture(C.Assets.Textures.Backdrop)

                    local check = box:GetCheckedTexture()
                    check:SetDesaturated(true)
                    check:SetVertexColor(r, g, b)

                    local bg = F.CreateBDFrame(box, 0, true)
                    bg:SetInside(box, 4, 4)

                    local hl = box:GetHighlightTexture()
                    hl:SetInside(bg)
                    hl:SetVertexColor(r, g, b, 0.25)
                end

                bu.styled = true
            end
        end
    end)

    F.ReskinCheckbox(_G.GuildControlUIRankSettingsFrameOfficerCheckbox)
    for i = 1, 20 do
        local checbox = _G['GuildControlUIRankSettingsFrameCheckbox' .. i]
        if checbox then
            F.ReskinCheckbox(checbox)
        end
    end

    F.ReskinButton(_G.GuildControlUIRankOrderFrameNewButton)
    F.ReskinClose(_G.GuildControlUICloseButton)
    F.ReskinTrimScroll(_G.GuildControlUIRankBankFrameInsetScrollFrame.ScrollBar)
    F.ReskinDropdown(_G.GuildControlUINavigationDropdown)
    F.ReskinDropdown(_G.GuildControlUIRankSettingsFrameRankDropdown)
    F.ReskinDropdown(_G.GuildControlUIRankBankFrameRankDropdown)
    F.ReskinEditbox(_G.GuildControlUIRankSettingsFrameGoldBox, 20)
end
