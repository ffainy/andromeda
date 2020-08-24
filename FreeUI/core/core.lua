local _, engine = ...
local F = unpack(engine)


_G.BINDING_HEADER_FREEUI = C.Title

F.oUF = engine.oUF
F.cargBags = engine.cargBags

F:RegisterModule('INSTALL')
F:RegisterModule('GUI')
F:RegisterModule('MOVER')
F:RegisterModule('LOGO')
F:RegisterModule('THEME')
F:RegisterModule('BLIZZARD')
F:RegisterModule('MISC')
F:RegisterModule('ACTIONBAR')
F:RegisterModule('COOLDOWN')
F:RegisterModule('AURA')
F:RegisterModule('ANNOUNCEMENT')
F:RegisterModule('CHAT')
F:RegisterModule('COMBAT')
F:RegisterModule('INFOBAR')
F:RegisterModule('INVENTORY')
F:RegisterModule('MAP')
F:RegisterModule('NOTIFICATION')
F:RegisterModule('QUEST')
F:RegisterModule('TOOLTIP')
F:RegisterModule('UNITFRAME')


F.INSTALL = F:GetModule('INSTALL')
F.GUI = F:GetModule('GUI')
F.MOVER = F:GetModule('MOVER')
F.LOGO = F:GetModule('LOGO')
F.THEME = F:GetModule('THEME')
F.BLIZZARD = F:GetModule('BLIZZARD')
F.MISC = F:GetModule('MISC')
F.ACTIONBAR = F:GetModule('ACTIONBAR')
F.COOLDOWN = F:GetModule('COOLDOWN')
F.AURA = F:GetModule('AURA')
F.ANNOUNCEMENT = F:GetModule('ANNOUNCEMENT')
F.CHAT = F:GetModule('CHAT')
F.COMBAT = F:GetModule('COMBAT')
F.INFOBAR = F:GetModule('INFOBAR')
F.INVENTORY = F:GetModule('INVENTORY')
F.MAP = F:GetModule('MAP')
F.NOTIFICATION = F:GetModule('NOTIFICATION')
F.QUEST = F:GetModule('QUEST')
F.TOOLTIP = F:GetModule('TOOLTIP')
F.UNITFRAME = F:GetModule('UNITFRAME')

