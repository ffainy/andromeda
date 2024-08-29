local F, C = unpack(select(2, ...))
local THEME = F:GetModule('Theme')

local function handleItemsList(frame, template)
    if template == 'SimpleAddonManagerAddonItem' or template == 'SimpleAddonManagerCategoryItem' then
        for _, btn in pairs(frame.buttons) do
            if not btn.styled then
                F.ReskinCheckbox(btn.EnabledButton)

                if btn.ExpandOrCollapseButton then
                    F.ReskinCollapse(btn.ExpandOrCollapseButton)
                end

                btn.styled = true
            end
        end
    end
end

local function handleSizer(frame)
    if not frame then
        return
    end

    frame:SetPoint('BOTTOMRIGHT')
end

local function handleDropdown(frame)
    if not frame then
        return
    end

    frame:SetWidth(180)
    frame:SetHeight(32)
    F.ReskinDropdown(frame)
    frame.Button:SetSize(20, 20)
    frame.Text:ClearAllPoints()
    frame.Text:SetPoint('RIGHT', frame.Button, 'LEFT', -2, 0)
end

local function handleModules(frame)
    -- MainFrame

    F.ReskinButton(frame.OkButton)
    F.ReskinButton(frame.CancelButton)
    F.ReskinButton(frame.EnableAllButton)
    F.ReskinButton(frame.DisableAllButton)
    handleDropdown(frame.CharacterDropDown)

    frame.OkButton:ClearAllPoints()
    frame.OkButton:SetPoint('RIGHT', frame.CancelButton, 'LEFT', -2, 0)
    frame.DisableAllButton:ClearAllPoints()
    frame.DisableAllButton:SetPoint('LEFT', frame.EnableAllButton, 'RIGHT', 2, 0)
    handleSizer(frame.Sizer)

    -- SearchBox
    F.ReskinEditbox(frame.SearchBox)
    F.ReskinArrow(frame.ResultOptionsButton, 'down')

    -- AddonListFrame
    F.ReskinScroll(frame.ScrollFrame.ScrollBar)

    -- CategoryFrame
    F.ReskinButton(frame.CategoryFrame.NewButton)
    F.ReskinButton(frame.CategoryFrame.SelectAllButton)
    F.ReskinButton(frame.CategoryFrame.ClearSelectionButton)
    F.ReskinButton(frame.CategoryButton)
    F.ReskinScroll(frame.CategoryFrame.ScrollFrame.ScrollBar)

    frame.CategoryFrame.NewButton:ClearAllPoints()
    frame.CategoryFrame.NewButton:SetHeight(20)
    frame.CategoryFrame.NewButton:SetPoint('BOTTOMLEFT', frame.CategoryFrame.SelectAllButton, 'TOPLEFT', 0, 2)
    frame.CategoryFrame.NewButton:SetPoint('BOTTOMRIGHT', frame.CategoryFrame.ClearSelectionButton, 'TOPRIGHT', 0, 2)

    -- Profile
    F.ReskinButton(frame.SetsButton)
    F.ReskinButton(frame.ConfigButton)

    -- Misc
    hooksecurefunc('HybridScrollFrame_CreateButtons', handleItemsList)
    handleItemsList(frame.ScrollFrame, 'SimpleAddonManagerAddonItem')
    handleItemsList(frame.CategoryFrame.ScrollFrame, 'SimpleAddonManagerCategoryItem')
end

function THEME:ReskinSam()
    if not ANDROMEDA_ADB.ReskinSimpleAddonManager then
        return
    end

    local SimpleAddonManager = _G['SimpleAddonManager']
    if not SimpleAddonManager then return end

    F.StripTextures(SimpleAddonManager)
    F.SetBD(SimpleAddonManager)
    F.ReskinClose(SimpleAddonManager.CloseButton)
    hooksecurefunc(SimpleAddonManager, 'Initialize', handleModules)
end

THEME:RegisterSkin('SimpleAddonManager', THEME.ReskinSam)
