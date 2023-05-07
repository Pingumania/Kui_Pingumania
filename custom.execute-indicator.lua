local _, ns = ...
if not ns.Retail then return end

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_ExecuteIndicator", 101)
if not mod then return end

local class, execute_range

local talents = {
    ["HUNTER"] = {
        [273887] = 35, -- Beast Mastery Killer Instinct
        [53351] = 20, -- Kill Shot
    },
    ["MAGE"] = {
        [269644] = 30, -- Fire Searing Touch
    },
    ["PRIEST"] = {
        [390972] = 35 -- Shadow Twist of Fate
    },
    ["ROGUE"] = {
        [328085] = 30 -- Assassination Blindside
    },
    ["WARRIOR"] = {
        [281001] = 35, -- Arms Massacre
        [206315] = 35, -- Fury Massacre
    },
}
local pvp_talents = {

}

local function IsTalentKnown(id, pvp)
    return pvp and select(10, GetPvpTalentInfoByID(id)) or IsSpellKnown(id)
end

local function GetExecuteRange()
    -- return execute range depending on class/spec/talents
    local r

    if talents[class] then
        for id, v in pairs(talents[class]) do
            if IsTalentKnown(id) then
                r = v
            end
        end
    end

    if UnitIsPVP("player") and pvp_talents[class] then
        for id, v in pairs(pvp_talents[class]) do
            if IsTalentKnown(id, true) then
                r = v
            end
        end
    end

    return (not r or r < 0) and 0 or r
end

function mod:PLAYER_SPECIALIZATION_CHANGED()
    execute_range = GetExecuteRange()
end

function mod:Show(f)
    if f.IN_NAMEONLY or execute_range <= 0 then
        f.ExecuteLine:Hide()
    else
        f.ExecuteLine:SetSize(2, f.HealthBar:GetHeight()/2)
        f.ExecuteLine:SetPoint("BOTTOMLEFT", f.HealthBar, f.HealthBar:GetWidth() * (execute_range/100) - 1, 0)
        f.ExecuteLine:Show()
    end
end

function mod:Create(f)
    if f.ExecuteLine then return end
    local line = f:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(1, 1, 1, 1)
    f.ExecuteLine = line
end

function mod:OnEnable()
    for _, f in addon:Frames() do
        self:Create(f)
    end
    self:RegisterMessage("Create")
    self:RegisterMessage("Show")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("SPELLS_CHANGED", "PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED", "PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "PLAYER_SPECIALIZATION_CHANGED")
    self:PLAYER_SPECIALIZATION_CHANGED()
end

function mod:Initialise()
    class = select(2, UnitClass("player"))
end