local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_NameShort", 101)
if not mod then return end

function mod:Show(plate)
    plate.NameText:SetText(plate.state.name:gsub('(%S+) ', function(t) return t:sub(1,1)..'. ' end))
end

function mod:Initialise()
    self:RegisterMessage("Show")
end