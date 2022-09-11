local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_EnemyAuras", 101)
if not mod then return end

function mod:Create(plate)
	local custom = plate.handler:CreateAuraFrame({
		id = "Custom_EnemyAuras",
		max = 2,
		size = 42,
		squareness = 1,
		point = {"CENTER", "LEFT", "RIGHT"},
		rows = 1,
		filter = "HELPFUL",
		centred = true,
		whitelist = {
			[45438]  = true, -- Mage: Ice Block
			[186265] = true, -- Hunter: Ascpect of the Turtle
			[642]    = true, -- Paladin: Divine Shield
			[1022]   = true, -- Paladin: Blessing of Protection
			[196555] = true, -- Demon Hunter: Netherwalk
			[198589] = true, -- Demon Hunter: Blur
			[31224]  = true, -- Rogue: Cloak of Shadows
			[31230]  = true, -- Rogue: Cheat Death
			[5277]   = true, -- Rogue: Evasion
			[199754] = true, -- Rogue: Riposte
			[871]    = true, -- Warrior: Shield Wall
			[118038] = true, -- Warrior: Die by the Sword
		},
	})
	custom:SetFrameLevel(0)
	custom:SetWidth(42)
	custom:SetHeight(42)
	custom:SetPoint("BOTTOM", plate.bg, "TOP", 0, 42)
	plate.EnemyAuras = custom
end

function mod:OnEnable()
	for _, plate in addon:Frames() do
		self:Create(plate)
	end
	mod:RegisterMessage("Create")
end