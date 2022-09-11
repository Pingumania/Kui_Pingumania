std = "lua51"
ignore = {
    "211", -- unused local variable / function
    "212/self", -- unused argument self
}
globals = {
    "CreateFrame",
    "GetInstanceInfo",
    "GetQuestDifficultyColor",
    "IsInInstance",
    "KuiNameplates",
    "KuiNameplatesCore",
    "tinsert",
    "tremove",
    "UnitAura",
    "UnitClassification",
    "UnitEffectiveLevel",
    "UnitInParty",
    "UnitIsPlayer",
    "UnitLevel",
    "UnitName",
    "wipe",
}