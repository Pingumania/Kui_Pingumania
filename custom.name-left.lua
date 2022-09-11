local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_NameLeft", 101)
if not mod then return end

local function ScaleTextOffset(v)
    return floor(core:Scale(v)) - .5
end

local function UpdateNameTextPosition(plate)
    if plate.IN_NAMEONLY then return end
    plate.NameText:SetJustifyH("LEFT")
	plate.NameText:SetPoint("BOTTOMLEFT", plate.HealthBar, "TOPLEFT", 0, ScaleTextOffset(core.profile.name_vertical_offset))
    plate.NameText:SetPoint("RIGHT", plate.HealthBar, 0, 0)
end

function mod:Create(plate)
    hooksecurefunc(plate, "UpdateNameTextPosition", function(plate)
        UpdateNameTextPosition(plate)
    end)
end

function mod:OnEnable()
    for _, plate in addon:Frames() do
		self:Create(plate)
	end
    self:RegisterMessage("Create")
end