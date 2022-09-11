local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_CastbarText", 101)
if not mod then return end

function mod:CastBarShow(f)
	f.SpellName:SetPoint('TOPLEFT', f.CastBar.bg, 0, 0)
	f.SpellName:SetPoint('BOTTOMRIGHT', f.CastBar.bg, 0, 0)
end

function mod:Initialise()
    self:RegisterMessage("CastBarShow")
end