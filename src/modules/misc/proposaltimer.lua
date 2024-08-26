local F, C = unpack(select(2, ...))
local MISC = F:GetModule('Misc')

LFGDungeonReadyDialog.nextUpdate = 0
PVPReadyDialog.nextUpdate = 0

local function consturctBars()
    local lfgBar = CreateFrame('Frame', nil, LFGDungeonReadyDialog)
    lfgBar:SetPoint('BOTTOMLEFT')
    lfgBar:SetPoint('BOTTOMRIGHT')
    lfgBar:SetHeight(3)

    lfgBar.bar = CreateFrame('StatusBar', nil, lfgBar)
    lfgBar.bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    lfgBar.bar:SetPoint('TOPLEFT', C.MULT, -C.MULT)
    lfgBar.bar:SetPoint('BOTTOMLEFT', -C.MULT, C.MULT)
    lfgBar.bar:SetFrameLevel(LFGDungeonReadyDialog:GetFrameLevel() + 1)
    lfgBar.bar:SetStatusBarColor(C.r, C.g, C.b)

    MISC.LfgTimerBar = lfgBar

    local pvpBar = CreateFrame('Frame', nil, PVPReadyDialog)
    pvpBar:SetPoint('BOTTOMLEFT')
    pvpBar:SetPoint('BOTTOMRIGHT')
    pvpBar:SetHeight(3)

    pvpBar.bar = CreateFrame('StatusBar', nil, pvpBar)
    pvpBar.bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    pvpBar.bar:SetPoint('TOPLEFT', C.MULT, -C.MULT)
    pvpBar.bar:SetPoint('BOTTOMLEFT', -C.MULT, C.MULT)
    pvpBar.bar:SetFrameLevel(PVPReadyDialog:GetFrameLevel() + 1)
    pvpBar.bar:SetStatusBarColor(C.r, C.g, C.b)

    MISC.PvpTimerBar = pvpBar
end

local function updateLfgTimer()
    local lfgBar = MISC.LfgTimerBar
    local obj = LFGDungeonReadyDialog
    local oldTime = GetTime()
    local flag = 0
    local duration = 40
    local interval = 0.1
    obj:SetScript('OnUpdate', function(self, elapsed)
        lfgBar.bar:SetStatusBarColor(C.r, C.g, C.b)
        obj.nextUpdate = obj.nextUpdate + elapsed
        if obj.nextUpdate > interval then
            local newTime = GetTime()
            if (newTime - oldTime) < duration then
                local width = lfgBar:GetWidth() * (newTime - oldTime) / duration
                lfgBar.bar:SetPoint('BOTTOMRIGHT', lfgBar, 0 - width, 0)
                flag = flag + 1
                if flag >= 10 then
                    flag = 0
                end
            else
                obj:SetScript('OnUpdate', nil)
            end

            obj.nextUpdate = 0
        end
    end)
end

local function updatePvpTimer()
    local pvpBar = MISC.PvpTimerBar
    local obj = PVPReadyDialog
    local oldTime = GetTime()
    local flag = 0
    local duration = 90
    local interval = 0.1
    obj:SetScript('OnUpdate', function(self, elapsed)
        obj.nextUpdate = obj.nextUpdate + elapsed
        if obj.nextUpdate > interval then
            local newTime = GetTime()
            if (newTime - oldTime) < duration then
                local width = pvpBar:GetWidth() * (newTime - oldTime) / duration
                pvpBar.bar:SetPoint('BOTTOMRIGHT', pvpBar, 0 - width, 0)
                flag = flag + 1
                if flag >= 10 then
                    flag = 0
                end
            else
                obj:SetScript('OnUpdate', nil)
            end

            obj.nextUpdate = 0
        end
    end)
end

local function lfgOnEvent()
    if LFGDungeonReadyDialog:IsShown() then
        updateLfgTimer()
    end
end

local function pvpOnEvent()
    if PVPReadyDialog:IsShown() then
        updatePvpTimer()
    end
end

function MISC:ProposalTimerBar()
    if C_AddOns.IsAddOnLoaded('BigWigs') then
        return
    end

    if not C.DB.General.ProposalTimer then
        return
    end

    local lfgBar = CreateFrame('Frame', nil, LFGDungeonReadyDialog)
    lfgBar:SetPoint('BOTTOMLEFT')
    lfgBar:SetPoint('BOTTOMRIGHT')
    lfgBar:SetHeight(3)

    lfgBar.bar = CreateFrame('StatusBar', nil, lfgBar)
    lfgBar.bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    lfgBar.bar:SetPoint('TOPLEFT', C.MULT, -C.MULT)
    lfgBar.bar:SetPoint('BOTTOMLEFT', -C.MULT, C.MULT)
    lfgBar.bar:SetFrameLevel(LFGDungeonReadyDialog:GetFrameLevel() + 1)
    lfgBar.bar:SetStatusBarColor(C.r, C.g, C.b)

    MISC.LfgTimerBar = lfgBar

    local pvpBar = CreateFrame('Frame', nil, PVPReadyDialog)
    pvpBar:SetPoint('BOTTOMLEFT')
    pvpBar:SetPoint('BOTTOMRIGHT')
    pvpBar:SetHeight(3)

    pvpBar.bar = CreateFrame('StatusBar', nil, pvpBar)
    pvpBar.bar:SetStatusBarTexture(C.Assets.Textures.StatusbarNormal)
    pvpBar.bar:SetPoint('TOPLEFT', C.MULT, -C.MULT)
    pvpBar.bar:SetPoint('BOTTOMLEFT', -C.MULT, C.MULT)
    pvpBar.bar:SetFrameLevel(PVPReadyDialog:GetFrameLevel() + 1)
    pvpBar.bar:SetStatusBarColor(C.r, C.g, C.b)

    MISC.PvpTimerBar = pvpBar

    MISC.LfgTimerBar:RegisterEvent('LFG_PROPOSAL_SHOW')
    MISC.LfgTimerBar:SetScript('OnEvent', lfgOnEvent)

    MISC.PvpTimerBar:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
    MISC.PvpTimerBar:SetScript('OnEvent', pvpOnEvent)
end
