local _, ns = ...
if not ns.Retail then return end

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_RagingIndicator", 101)
if not mod then return end
local HAS_ENABLED

function mod:Show(f)
    if f.IN_NAMEONLY or f.state.level == -1 then
        f.RagingIndicator:Hide()
    else
        f.RagingIndicator:SetSize(2, f.HealthBar:GetHeight()/2)
        f.RagingIndicator:SetPoint("BOTTOMLEFT", f.HealthBar, (f.HealthBar:GetWidth() * 0.3) - 1, 0)
        f.RagingIndicator:Show()
    end
end

function mod:Create(f)
    if f.RagingIndicator then return end
    local line = f:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(1, 0.2, 0.2, 1)
    f.RagingIndicator = line
end

local function EnableAll()
    for _, f in addon:Frames() do
        if not f.RagingIndicator then
            mod:Create(f)
        end
    end
    mod:RegisterMessage("Show")
    mod:RegisterMessage("Create")
    HAS_ENABLED = true
end

local function DisableAll()
    for _, f in addon:Frames() do
        if f.RagingIndicator then
            f.RagingIndicator:Hide()
        end
    end
    mod:UnregisterMessage("Show")
    mod:UnregisterMessage("Create")
end

function mod:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local _, instanceType, difficulty = GetInstanceInfo()
        if instanceType == "party" then
            local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficulty)
            if isChallengeMode then
                local _, activeAffixes = C_ChallengeMode.GetActiveKeystoneInfo()
                for _, id in pairs (activeAffixes) do
                    if id == 6 then
                        EnableAll()
                        return
                    end
                end
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
    -- self:RegisterMessage("Create")
end