local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_MythicAuras", 101)
if not mod then return end
local HAS_ENABLED

local function GetBolsterCount(unit)
    local c = 0
    for i = 1, 40 do
        local name = UnitAura(unit, i)
        if name and name == "Bolster" then
            c = c + 1
        end
    end
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
    button.count:SetText(GetBolsterCount(f.parent.unit))
    button.count:Show()
end

local function PostUpdateAuraFrame(f)
    if f.id ~= "Custom_MythicAuras" then return end
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
        end
    end
    mod:RegisterMessage("Create")
    HAS_ENABLED = true
    -- print("Custom_MythicAuras enabled.")
end

local function DisableAll()
    for _,f in addon:Frames() do
        if f.MythicAuras then
            f.MythicAuras:Disable()
        end
    end
    mod:UnregisterMessage("Create")
    -- print("Custom_MythicAuras disabled.")
end

function mod:Create(f)
    -- assert(not f.MythicAuras)
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
            [260805] = true, -- Waycrest Manor: Focusing Iris
            [263246] = true, -- Temple of Sethralis: Lightning Shield
            [257597] = true, -- MOTHERLODE: Azerite Infusion
        },
    })
    custom:SetFrameLevel(0)
    custom:SetWidth(42)
    custom:SetHeight(42)
    custom:SetPoint("BOTTOM", f.bg, "TOP", 0, 42)
    f.MythicAuras = custom

    local bolster = f.handler:CreateAuraFrame({
        id = "Custom_MythicBolster",
        max = 1,
        size = 24,
        squareness = 1,
        timer_threshold = 10,
        pulsate = false,
        point = {"BOTTOMRIGHT", "RIGHT", "LEFT"},
        rows = 1,
        filter = "HELPFUL",
        whitelist = { [209859] = true -- Mythic Plus Affix: Bolstering
        }
    })
    bolster:SetFrameLevel(0)
    bolster:SetWidth(24)
    bolster:SetHeight(24)
    bolster:SetPoint("BOTTOMLEFT", custom, "BOTTOMRIGHT", 1, 0)
    f.MythicBolster = bolster
end

function mod:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local instance_type, difficulty = select(2, GetInstanceInfo())
        if instance_type == "party" then
            if difficulty == 8 then
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
    -- self:AddCallback("Auras", "PostUpdateAuraFrame", PostUpdateAuraFrame)
end