local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_SpellTimer", 101)
if not mod then return end

function mod:CastBarShow(f)
	f.SpellTimer:Show()

	f.CastBarUpdateFrame:HookScript("OnUpdate", function(self, elapsed)
		local value
		if f.cast_state.channel then
			value = f.CastBar:GetValue()
		else
			value = (f.cast_state.end_time - f.cast_state.start_time) - (GetTime() - f.cast_state.start_time)
		end		
		if value < 99 and value >= 0 then
			f.SpellTimer:SetText(string.format("%.1f", value))
		end
	end)
end

function mod:CastBarHide(f)
	f.SpellTimer:Hide()
end

function mod:Show(f)
	local font, _, flags = f.NameText:GetFont()
	f.SpellTimer:SetFont(font, core.profile.font_size_small, flags)
	f.SpellTimer:SetPoint("RIGHT", f.CastBar.bg, "RIGHT", -2, 0)
end

function mod:Create(f)
	if f.SpellTimer then return end
	local timer = f:CreateFontString(nil, "OVERLAY")
	f.SpellTimer = timer
end

function mod:OnEnable()
	self:RegisterMessage("CastBarShow")
	self:RegisterMessage("CastBarHide")
	self:RegisterMessage("Create")
	self:RegisterMessage("Show")
end
