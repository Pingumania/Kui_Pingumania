local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_TargetArrows", 101)
if not mod then return end

local ELVUI_TARGET_ARROWS = true
local ARROWS_INSET = -3
local TARGET_ARROW = [[Interface\AddOns\Kui_Nameplates_Custom\media\ArrowUp.tga]]

local function Arrows_UpdatePosition(self)
	local inset = ARROWS_INSET + (self.l:GetHeight() * .12)
	self.l:SetPoint("RIGHT", self.parent.bg, "LEFT", inset, -1)
	self.r:SetPoint("LEFT", self.parent.bg, "RIGHT", -inset, -1)
end

local function Arrows_SetVertexColor(self)
	self.l:SetVertexColor(1, 1, 1)
	self.r:SetVertexColor(1, 1, 1)
end

local function UpdateTargetArrows(f)
	if not ELVUI_TARGET_ARROWS or f.IN_NAMEONLY then
		f.TargetArrows:Hide()
		return
	end

	if f.state.target then
		f.TargetArrows.l:SetTexture(TARGET_ARROW)
		f.TargetArrows.r:SetTexture(TARGET_ARROW)
		f.TargetArrows:SetVertexColor(1, 1, 1)
		f.TargetArrows:SetSize(32)

		f.TargetArrows:Show()
		f.TargetArrows:UpdatePosition()
	else
		f.TargetArrows:Hide()
	end
end

function mod:Show(f)
	if ELVUI_TARGET_ARROWS and f.TargetArrows then
		if not f.TargetArrows._elvui_textures then
			f.TargetArrows.l:SetBlendMode("BLEND")
			f.TargetArrows.l:SetRotation(-1.57)

			f.TargetArrows.r:SetBlendMode("BLEND")
			f.TargetArrows.r:SetRotation(1.57)

			f.TargetArrows.UpdatePosition = Arrows_UpdatePosition
			f.TargetArrows.SetVertexColor = Arrows_SetVertexColor
			f.UpdateTargetArrows = UpdateTargetArrows
			f.TargetArrows._elvui_textures = true
		end

		f.TargetArrows.l:SetWidth(f.TargetArrows.l:GetHeight()*.72)
		f.TargetArrows.r:SetWidth(f.TargetArrows.r:GetHeight()*.72)
	end
end

function mod:Initialise()
	self:RegisterMessage("Show")
end