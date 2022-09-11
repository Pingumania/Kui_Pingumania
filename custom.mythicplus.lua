local addon = KuiNameplates
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

local function PostCreateAuraButton(f, button)
    if f.id ~= "Custom_MythicBolster" then return end
    button.count:ClearAllPoints()
    button.count:SetPoint("Center", button)
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
    -- print("Custom_MythicPlus enabled.")
end

local function DisableAll()
    for _, f in addon:Frames() do
        if f.MythicAuras then
            f.MythicAuras:Disable()
            f.MythicBolster:Disable()
        end
    end
    mod:UnregisterMessage("Create")
    -- print("Custom_MythicPlus disabled.")
end

function mod:Create(f)
    local size = 28
    assert(not f.MythicAuras)
    local custom = f.handler:CreateAuraFrame({
        id = "Custom_MythicAuras",
        max = 2,
        size = 42,
        squareness = 1,
        point = {"CENTER", "LEFT", "RIGHT"},
        rows = 1,
        filter = "HELPFUL",
        centred = true,
        whitelist = {
            [226510] = true, -- Mythic Plus Affix: Sanguine
            [228318] = true, -- Mythic Plus Affix: Raging
            [343502] = true, -- Mythic Plus Affix: Inspiring
            -- [260805] = true, -- Waycrest Manor: Focusing Iris
            -- [263246] = true, -- Temple of Sethralis: Lightning Shield
            -- [257597] = true, -- MOTHERLODE: Azerite Infusion
        },
    })
    custom:SetFrameLevel(0)
    custom:SetWidth(size)
    custom:SetHeight(size)
    custom.icon_height = floor(size * .7)
    custom.icon_ratio = (1 - (custom.icon_height / size)) / 2.5
    custom:SetPoint("BOTTOM", f.bg, "TOP", 0, 42)
    f.MythicAuras = custom

    assert(not f.MythicBolster)
    local bolster = f.handler:CreateAuraFrame({
        id = "Custom_MythicBolster",
        max = 1,
        size = 42,
        squareness = 1,
        timer_threshold = 10,
        pulsate = false,
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
    bolster.icon_height = floor(size * .7)
    bolster.icon_ratio = (1 - (bolster.icon_height / size)) / 2.5
    bolster:SetPoint("BOTTOMLEFT", f.bg, "TOPLEFT", 1, 42)
    f.MythicBolster = bolster
end

function mod:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local _, instanceType, difficulty = GetInstanceInfo()
        if instanceType == "party" then
            local isChallengeMode = select (4, GetDifficultyInfo(difficulty))
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

function mod:Initialise()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_INSTANCE_INFO", "PLAYER_ENTERING_WORLD")
    self:AddCallback("Auras", "PostCreateAuraButton", PostCreateAuraButton)
    self:AddCallback("Auras", "PostDisplayAuraButton", PostDisplayAuraButton)
    self:AddCallback("Auras", "PostUpdateAuraFrame", PostUpdateAuraFrame)
end