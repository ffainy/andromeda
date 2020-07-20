local addonName, engine = ...

engine[1] = {} -- F, Functions
engine[2] = {} -- C, Constants/Config
engine[3] = {} -- L, Localisation

_G[addonName] = engine

FreeUIGlobalConfig, FreeUIConfig = {}, {}


local F, C, L = unpack(engine)

local pairs, next, tinsert = pairs, next, table.insert
local min, max = math.min, math.max
local CombatLogGetCurrentEventInfo, GetPhysicalScreenSize = CombatLogGetCurrentEventInfo, GetPhysicalScreenSize


-- Events
local events = {}

local host = CreateFrame("Frame")
host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function F:RegisterEvent(event, func, unit1, unit2)
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function F:UnregisterEvent(event, func)
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end


-- Modules
local modules, initQueue = {}, {}

function F:RegisterModule(name)
	if modules[name] then print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function F:GetModule(name)
	if not modules[name] then print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

F.oUF = engine.oUF
F.cargBags = engine.cargBags
F.Install = F:RegisterModule('Install')
F.Mover = F:RegisterModule('Mover')
F.Animation = F:RegisterModule('Logo')
F.Theme = F:RegisterModule('Theme')
F.Misc = F:RegisterModule('Misc')
F.Actionbar = F:RegisterModule('Actionbar')
F.Cooldown = F:RegisterModule('Cooldown')
F.Aura = F:RegisterModule('Aura')
F.Announcement = F:RegisterModule('Announcement')
F.Chat = F:RegisterModule('Chat')
F.Combat = F:RegisterModule('Combat')
F.Infobar = F:RegisterModule('Infobar')
F.Inventory = F:RegisterModule('Inventory')
F.Map = F:RegisterModule('Map')
F.Notification = F:RegisterModule('Notification')
F.Quest = F:RegisterModule('Quest')
F.Tooltip = F:RegisterModule('Tooltip')
F.Unitframe = F:RegisterModule('Unitframe')
F.Automation = F:RegisterModule('Automation')
L.QUEST = {}


-- UI scale
local function GetBestScale()
	local scale = max(.4, min(1.15, 768 / C.ScreenHeight))
	return F:Round(scale, 2)
end

function F:SetupUIScale(init)
	local scale = GetBestScale() * C.General.uiScale

	if init then
		local pixel = 1
		local ratio = 768 / C.ScreenHeight
		C.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

local isScaling = false
local function UpdatePixelScale(event)
	if isScaling then return end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		C.ScreenWidth, C.ScreenHeight = GetPhysicalScreenSize()
	end
	F:SetupUIScale(true)
	F:SetupUIScale()

	isScaling = false
end


-- Init
F:RegisterEvent('PLAYER_LOGIN', function()

	if FreeUIConfig['installComplete'] then

		F:SetupUIScale()
		F:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)

		F.HideOption(Advanced_UseUIScale)
		F.HideOption(Advanced_UIScaleSlider)
	else
		F:SetupUIScale(true)
	end

	for _, module in next, initQueue do
		if module.OnLogin then
			module:OnLogin()
		else
			print('Module <'..module.name..'> does not loaded.')
		end
	end

	F.Modules = modules
end)

