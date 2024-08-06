local F, C = unpack(select(2, ...))
local BLIZZARD = F:GetModule('Blizzard')

function BLIZZARD:PetTabs_Click(button)
    local activeCount = 0
    for petType in ipairs(_G.PET_TYPE_SUFFIX) do
        local btn = _G['PetJournalQuickFilterButton' .. petType]
        if button == 'LeftButton' then
            if self == btn then
                btn.isActive = not btn.isActive
            elseif not IsShiftKeyDown() then
                btn.isActive = false
            end
        elseif button == 'RightButton' and (self == btn) then
            btn.isActive = not btn.isActive
        end

        if btn.isActive then
            btn.bg:SetBackdropBorderColor(1, 1, 1)
            activeCount = activeCount + 1
        else
            F.SetBorderColor(btn.bg)
        end
        C_PetJournal.SetPetTypeFilter(btn.petType, btn.isActive)
    end

    if activeCount == 0 then
        C_PetJournal.SetAllPetTypesChecked(true)
    end
end

function BLIZZARD:PetTabs_Create()
    _G.PetJournal.ScrollBox:SetPoint('TOPLEFT', _G.PetJournalLeftInset, 3, -60)

    -- Create the pet type buttons, sorted according weakness
    -- Humanoid > Dragonkin > Magic > Flying > Aquatic > Elemental > Mechanical > Beast > Critter > Undead
    local activeCount = 0
    for petIndex, petType in ipairs({ 1, 2, 6, 3, 9, 7, 10, 8, 5, 4 }) do
        local btn = CreateFrame('Button', 'PetJournalQuickFilterButton' .. petIndex, _G.PetJournal, 'BackdropTemplate')
        btn:SetSize(24, 24)
        btn:SetPoint('TOPLEFT', _G.PetJournalLeftInset, 6 + 25 * (petIndex - 1), -33)
        F.PixelIcon(btn, 'Interface\\ICONS\\Pet_Type_' .. _G.PET_TYPE_SUFFIX[petType], true)

        if C_PetJournal.IsPetTypeChecked(petType) then
            btn.isActive = true
            btn.bg:SetBackdropBorderColor(1, 1, 1)
            activeCount = activeCount + 1
        else
            btn.isActive = false
        end
        btn.petType = petType
        btn:SetScript('OnMouseUp', BLIZZARD.PetTabs_Click)
    end

    if activeCount == #_G.PET_TYPE_SUFFIX then
        for petIndex in ipairs(_G.PET_TYPE_SUFFIX) do
            local btn = _G['PetJournalQuickFilterButton' .. petIndex]
            btn.isActive = false
            F.SetBorderColor(btn.bg)
        end
    end
end

function BLIZZARD:PetTabs_Load(addon)
    if addon == 'Blizzard_Collections' then
        BLIZZARD:PetTabs_Create()
        F:UnregisterEvent(self, BLIZZARD.PetTabs_Load)
    end
end

function BLIZZARD:PetTabs_Init()
    if not C.DB.General.PetFilter then
        return
    end

    if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
        BLIZZARD:PetTabs_Create()
    else
        F:RegisterEvent('ADDON_LOADED', BLIZZARD.PetTabs_Load)
    end
end

BLIZZARD:RegisterBlizz('PetFilterTab', BLIZZARD.PetTabs_Init)
