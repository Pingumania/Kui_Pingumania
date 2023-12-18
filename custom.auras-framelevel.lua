local _, ns = ...

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_AurasFrameLevel", 101)
if not mod then return end

function mod:Create(f)
    if f.IN_NAMEONLY then return end
    f:SetFrameLevel(1)
    for _, frame in pairs(f.Auras.frames) do
        frame:SetFrameLevel(f:GetFrameLevel() - 1)
    end
end

function mod:Enable()
    for _, f in addon:Frames() do
        self:Create(f)
    end
    self:RegisterMessage("Create")
end