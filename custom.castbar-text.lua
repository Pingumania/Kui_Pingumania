local _, ns = ...
if not ns.modules.castbar_text then return end

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_CastbarText", 101)
if not mod then return end

function mod:CastBarShow(f)
    f.SpellName:SetJustifyH("LEFT")
    f.SpellName:SetPoint("TOPLEFT", f.CastBar, 2, 0)
    f.SpellName:SetPoint("BOTTOMRIGHT", f.CastBar, f.SpellTimer and -25 or -2, 0)
end

function mod:Show(f)
    f.UpdateSpellNamePosition = function() end
end

function mod:OnEnable()
    self:RegisterMessage("Show")
    self:RegisterMessage("CastBarShow")
end