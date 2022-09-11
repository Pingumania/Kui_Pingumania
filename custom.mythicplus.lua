local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_MythicPlus", 101)
if not mod then return end
local HAS_ENABLED

local function GetBolsterCount(unit)
	local c = 0
	AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(...)
		local name = ...
		if name == "Bolster" then
			c = c + 1
		end
	end)
	return c
end

local function PostCreateAuraButton(plate, button)
	if plate.id ~= "Custom_MythicBolster" then return end
	button.count:ClearAllPoints()
	button.count:SetPoint("Center", button)
	local font, size, flag = button.cd:GetFont()
	button.count.fontobject_size = size + 10
end

local function PostDisplayAuraButton(plate, button)
	if plate.id ~= "Custom_MythicBolster" then return end
	button.count:SetText(GetBolsterCount(plate.parent.unit) > 1 or "")
	button.count:Show()
end

local function PostUpdateAuraFrame(plate)
	if plate.id ~= "Custom_MythicBolster" then return end
	local c = GetBolsterCount(plate.parent.unit)
	if c > 1 then
		for _, button in ipairs(plate.buttons) do
			if button.spellid == 209859 then
				button.count:SetText(c)
				button.count:Show()
				break
			end
		end
	end
end

local function EnableAll()
	for _, plate in addon:Frames() do
		if not plate.MythicAuras then
			mod:Create(plate)
		else
			plate.MythicAuras:Enable()
			plate.MythicBolster:Enable()
		end
	end
	mod:RegisterMessage("Create")
	HAS_ENABLED = true
end

local function DisableAll()
	for _, plate in addon:Frames() do
		if plate.MythicAuras then
			plate.MythicAuras:Disable()
			plate.MythicBolster:Disable()
		end
	end
	mod:UnregisterMessage("Create")
end

function mod:Create(plate)
	local size = 28
	assert(not plate.MythicAuras)
	local custom = plate.handler:CreateAuraFrame({
		id = "Custom_MythicAuras",
		max = 2,
		size = core:Scale(core.profile.auras_icon_normal_size),
		squareness = core.profile.auras_icon_squareness,
		point = {"BOTTOMLEFT", "LEFT", "RIGHT"},
		rows = 1,
		filter = "HELPFUL",
		whitelist = {
			[226510] = true, -- Mythic Plus Affix: Sanguine
			[228318] = true, -- Mythic Plus Affix: Raging
			[343502] = true, -- Mythic Plus Affix: Inspiring
		},
	})
	custom:SetFrameLevel(0)
	custom:SetWidth(size)
	custom:SetHeight(size)
	custom:SetPoint("BOTTOMLEFT", plate.bg, "TOPLEFT", 0, 42)
	plate.MythicAuras = custom

	assert(not plate.MythicBolster)
	local bolster = plate.handler:CreateAuraFrame({
		id = "Custom_MythicBolster",
		max = 1,
		size = core:Scale(core.profile.auras_icon_normal_size),
		squareness = core.profile.auras_icon_squareness,
		point = {"BOTTOMRIGHT", "RIGHT", "LEFT"},
		rows = 1,
		filter = "HELPFUL",
		whitelist = {
			[209859] = true -- Mythic Plus Affix: Bolstering
		}
	})
	bolster:SetFrameLevel(0)
	bolster:SetWidth(size)
	bolster:SetHeight(size)
	bolster:SetPoint("BOTTOMRIGHT", plate.bg, "TOPRIGHT", 0, 42)
	plate.MythicBolster = bolster
end

function mod:PLAYER_ENTERING_WORLD()
	if IsInInstance() then
		local _, instanceType, difficulty = GetInstanceInfo()
		if instanceType == "party" then
			local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficulty)
			if isChallengeMode then
				EnableAll()
				return
			end
		end
	end
	if HAS_ENABLED then
		DisableAll()
	end
end

function mod:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_INSTANCE_INFO", "PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHALLENGE_MODE_START", "PLAYER_ENTERING_WORLD")
	self:AddCallback("Auras", "PostCreateAuraButton", PostCreateAuraButton)
	self:AddCallback("Auras", "PostDisplayAuraButton", PostDisplayAuraButton)
	self:AddCallback("Auras", "PostUpdateAuraFrame", PostUpdateAuraFrame)
end