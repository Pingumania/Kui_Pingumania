local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_SpellTarget", 101)
if not mod then return end

function mod:CastBarShow(f)
	-- if not f.NameText then return end
	local target = UnitName(f.unit.."target")
	if UnitIsUnit(f.unit.."target", "player") then
		f.SpellTarget:SetText("You")
		f.SpellTarget:SetTextColor(1, .1, .1)
		f.SpellTarget:Show()
	elseif UnitIsUnit(f.unit.."target", "party1") or UnitIsUnit(f.unit.."target", "party2") or UnitIsUnit(f.unit.."target", "party3") or UnitIsUnit(f.unit.."target", "party4") or UnitIsUnit(f.unit.."target", "party5") then
		f.SpellTarget:SetText(target or "")
		f.SpellTarget:SetTextColor(kui.GetUnitColour(f.unit.."target", 2))
		f.SpellTarget:Show()
	end
end

function mod:CastBarHide(f)
	f.SpellTarget:Hide()
end

function mod:Show(f)
	-- if not f.NameText then return end
	local font, _, flags = f.NameText:GetFont()
	f.SpellTarget:SetFont(font, core.profile.font_size_small - 1, flags)
	f.SpellTarget:SetPoint("CENTER", f.CastBar.bg, "BOTTOM", 0, -5)
end

function mod:Create(f)
	if f.SpellTarget then return end
	local target = f:CreateFontString(nil, "OVERLAY")
	f.SpellTarget = target
end

function mod:OnEnable()
	self:RegisterMessage("CastBarShow")
	self:RegisterMessage("CastBarHide")
	self:RegisterMessage("Create")
	self:RegisterMessage("Show")
end
