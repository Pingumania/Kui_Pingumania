local _, ns = ...

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_NameShort", 101)
if not mod then return end

function mod:Show(f)
    if f.IN_NAMEONLY then return end
    if f.state then
        f.NameText:SetText(gsub(f.state.name, "(%S+) ", function(t) return t:sub(1, 1) .. "." end))
    end
end

function mod:Enable()
    for _, f in addon:Frames() do
        self:Show(f)
    end
    self:RegisterMessage("Show")
end