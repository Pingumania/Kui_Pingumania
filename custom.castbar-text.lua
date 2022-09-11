local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_CastbarText", 101)
if not mod then return end

function mod:CastBarShow(plate)
	plate.SpellName:SetJustifyH("LEFT")
	plate.SpellName:SetPoint("TOPLEFT", plate.CastBar, 2, 0)
	plate.SpellName:SetPoint("BOTTOMRIGHT", plate.CastBar, plate.SpellTimer and -25 or -2, 0)
end

function mod:Show(plate)
	plate.UpdateSpellNamePosition = function() end
end

function mod:OnEnable()
	self:RegisterMessage("Show")
	self:RegisterMessage("CastBarShow")
end