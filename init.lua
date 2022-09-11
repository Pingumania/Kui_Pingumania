local _, ns = ...

ns.Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.BCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
ns.Retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

ns.modules = {
    castbar_text = true,
    classpower_pos = true,
    elite_indicator = true,
    enemy_auras = true,
    explosives = true,
    mythicplus = true,
    name_left = true,
    name_short = true,
    objectives = true,
    spell_alert = true,
    spell_timer = true,
    target_helper = true,
}