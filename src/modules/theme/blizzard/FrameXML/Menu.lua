local F, C = unpack(select(2, ...))

tinsert(C.BlizzThemes, function()
    if not _G.ANDROMEDA_ADB.ReskinBlizz then
        return
    end

    if not Menu then
        return
    end

    local menuManagerProxy = Menu.GetManager()

    local backdrops = {}

    local function skinMenu(menuFrame)
        F.StripTextures(menuFrame)

        if backdrops[menuFrame] then
            menuFrame.bg = backdrops[menuFrame]
        else
            menuFrame.bg = F.SetBD(menuFrame)
            backdrops[menuFrame] = menuFrame.bg
        end

        if not menuFrame.ScrollBar.styled then
            F.ReskinTrimScroll(menuFrame.ScrollBar)
            menuFrame.ScrollBar.styled = true
        end

        for i = 1, menuFrame:GetNumChildren() do
            local child = select(i, menuFrame:GetChildren())

            local minLevel = child.MinLevel
            if minLevel and not minLevel.styled then
                F.ReskinEditbox(minLevel)
                minLevel.styled = true
            end

            local maxLevel = child.MaxLevel
            if maxLevel and not maxLevel.styled then
                F.ReskinEditbox(maxLevel)
                maxLevel.styled = true
            end
        end
    end

    local function setupMenu()
        local menuFrame = menuManagerProxy:GetOpenMenu()
        if menuFrame then
            skinMenu(menuFrame)
        end
    end

    hooksecurefunc(menuManagerProxy, 'OpenMenu', setupMenu)
    hooksecurefunc(menuManagerProxy, 'OpenContextMenu', setupMenu)
end)
