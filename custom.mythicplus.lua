local _, ns = ...
if not ns.Retail then return end
if not ns.modules.mythicplus then return end

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_MythicPlus", 101)
if not mod then return end
local HAS_ENABLED

local function UpdateBolsterAnchor(f, hidden)
    f:ClearAllPoints()
    if hidden then
        f:SetPoint("BOTTOMRIGHT", f.parent.bg, "TOPRIGHT", 0, core:Scale(core.profile.auras_offset))
    else
        f:SetPoint("BOTTOM", f.sibling, "TOP", 0, 3)
    end
end

local function OnHide(f)
    UpdateBolsterAnchor(f.sibling, true)
end

local function OnShow(f)
    UpdateBolsterAnchor(f.sibling)
end

local function GetBolsterCount(unit)
    local c = 0
    AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(...)
        local _, _, _, _, _, _, _, _, _, spellID = ...
        if spellID == 209859 then
            c = c + 1
        end
    end)
    return c
end

local function PostCreateAuraButton(f, button)
    if f.id ~= "Custom_MythicBolster" then return end
    button.count:ClearAllPoints()
    button.count:SetPoint("BOTTOMRIGHT", 4, -2)
    local font, size, flag = button.cd:GetFont()
    button.count.fontobject_size = size + 10
end

local function PostDisplayAuraButton(f, button)
    if f.id ~= "Custom_MythicBolster" then return end
    button.count:SetText(GetBolsterCount(f.parent.unit) > 1 or "")
    button.count:Show()
end

local function PostUpdateAuraFrame(f)
    if f.id ~= "Custom_MythicBolster" then return end
    local c = GetBolsterCount(f.parent.unit)
    if c > 1 then
        for _, button in ipairs(f.buttons) do
            if button.spellid == 209859 then
                button.count:SetText(c)
                button.count:Show()
                break
            end
        end
    end
end

local function EnableAll()
    for _, f in addon:Frames() do
        if not f.MythicAuras then
            mod:Create(f)
        else
            f.MythicAuras:Enable()
            f.MythicBolster:Enable()
        end
    end
    mod:RegisterMessage("Create")
    HAS_ENABLED = true
end

local function DisableAll()
    for _, f in addon:Frames() do
        if f.MythicAuras then
            f.MythicAuras:Disable()
            f.MythicBolster:Disable()
        end
    end
    mod:UnregisterMessage("Create")
end

function mod:Create(f)
    local size = 28
    assert(not f.MythicAuras)
    local custom = f.handler:CreateAuraFrame({
        id = "Custom_MythicAuras",
        max = 2,
        size = core:Scale(core.profile.auras_icon_normal_size),
        squareness = core.profile.auras_icon_squareness,
        point = {"BOTTOMRIGHT", "RIGHT", "LEFT"},
        rows = 1,
        filter = "HELPFUL",
        whitelist = {
            [226510] = true, -- Mythic Plus Affix: Sanguine
            [228318] = true, -- Mythic Plus Affix: Raging
            [343502] = true -- Mythic Plus Affix: Inspiring
        },
    })
    custom:SetFrameLevel(0)
    custom:SetWidth(size)
    custom:SetHeight(size)
    custom:SetPoint("BOTTOMRIGHT", f.bg, "TOPRIGHT", 0, core:Scale(core.profile.auras_offset))
    custom:HookScript("OnShow", OnShow)
    custom:HookScript("OnHide", OnHide)
    
    assert(not f.MythicBolster)
    local bolster = f.handler:CreateAuraFrame({
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
    bolster:SetPoint("BOTTOMRIGHT", f.bg, "TOPRIGHT", 0, core:Scale(core.profile.auras_offset))

    custom.sibling = bolster
    bolster.sibling = custom

    f.MythicAuras = custom
    f.MythicBolster = bolster
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