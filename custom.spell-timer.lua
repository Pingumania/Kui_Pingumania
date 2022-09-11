local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_SpellTimer", 101)
if not mod then return end

local format = format

function mod:CastBarShow(plate)
	plate.SpellTimer:Show()
	plate.CastBarUpdateFrame:HookScript("OnUpdate", function(self, elapsed)
		local value
		if plate.cast_state.channel then
			value = plate.CastBar:GetValue()
		else
			value = (plate.cast_state.end_time - plate.cast_state.start_time) - (GetTime() - plate.cast_state.start_time)
		end
		if value < 99 and value >= 0 then
			plate.SpellTimer:SetText(format("%.1f", value))
		elseif value >= 99 then
			plate.SpellTimer:SetText("~")
		end
	end)
end

function mod:CastBarHide(plate)
	plate.SpellTimer:Hide()
end

function mod:Create(plate)
	if plate.SpellTimer then return end
	local timer = plate:CreateFontString(nil, "OVERLAY")
	local font, _, flags = plate.NameText:GetFont()
	timer:SetFont(font, core.profile.font_size_small, flags)
	timer:SetPoint("RIGHT", plate.CastBar.bg, "RIGHT", -2, 0)
	plate.SpellTimer = timer
end

function mod:OnEnable()
	for _, plate in addon:Frames() do
		self:Create(plate)
	end
	self:RegisterMessage("CastBarShow")
	self:RegisterMessage("CastBarHide")
	self:RegisterMessage("Create")
end
