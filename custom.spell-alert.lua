local _, ns = ...
if not ns.Retail then return end
local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_SpellAlert", 101)
local LCG = LibStub("LibCustomGlow-1.0")
if not mod then return end
local DEBUG = false

local plugin_fading
local currentInstanceID, currentInstanceName
local important_spells = {
	[2162] = { -- Torghast
		{spellID = 330438}, -- Watchers of Death: Fearsome Howl
		{spellID = 294362}, -- Deadsoul Echo: Wave of Suffering
		{spellID = 294517}, -- Deadsoul Scavenger: Phasing Roar
		{spellID = 298844}, -- Deadsoul Shambler: Fearsome Howl
		{spellID = 353769}, -- Karthazel: Shadowbolt Volley
		{spellID = 329975}, -- Empowered Imperial Consular: Shadow Bolt Volley
		{spellID = 329930}, -- Stonewing Ravager: Terrifying Screech
		{spellID = 296523}, -- Mawsworn Seeker: Deafening Howl
		{spellID = 329422}, -- Mawsworn Flametender: Inner Flames
		{spellID = 353721}, -- Sath'zuul: Sanguine Extraction
		{spellID = 242391}, -- Coldheart Agent: Terror
	},
	[2296] = { -- Castle Nathria
		{spellID = 337110}, -- Council: Dreadbolt Volley
	},
	[2450] = { -- Sanctum of Domination
		{spellID = 350286}, -- Nine: Song of Dissolution
		{spellID = 350287}, -- Nine: Song of Dissolution
		{spellID = 350339}, -- Nine: Siphon Vitality
		{spellID = 348428}, -- Kel'Thuzad: Piercing Wail
		{spellID = 355212}, -- Mawsworn Seeker: Fearsome Howl
		{spellID = 357402}, -- Mawsworn Scryer: Soul Bolt Volley
		{spellID = 355540}, -- Sylvanas: Ruin
	},
	[2291] = { -- De Other Side
		-- {spellID = 328707}, -- Risen Cultist: Scribe
		{spellID = 334076}, -- Death Speaker: Shadowcore
		{spellID = 332612, type = "heal"}, -- Atal'ai Hoodoo Hexer: Healing Wave
		{spellID = 332605}, -- Atal'ai Hoodoo Hexer: Hex
		{spellID = 332706, type = "heal"}, -- Atal'ai High Priest: Heal
		{spellID = 332084, type = "heal"}, -- Lubricator: Self-Cleaning Cycle
		{spellID = 331379}, -- Lubricator: Lubricate
		{spellID = 321349}, -- Spriggan Mendbender: Absorbing Haze
		-- {spellID = 320008}, -- Millhouse Manastorm (Boss): Frostbolt
		-- {spellID = 323064}, -- Hakkar (Boss): Blood Barrage
	},
	[2287] = { -- Halls of Atonement
		-- {spellID = 326450}, -- Depraved Houndmaster: Loyal Beasts (ni)
		-- {spellID = 325797}, -- Depraved Houndmaster: Rapid Fire (ni)
		{spellID = 325876}, -- Depraved Obliterator: Curse of Obliteration
		{spellID = 338005}, -- Toiling Groundskeeper: Smack
		{spellID = 325701}, -- Depraved Collector: Siphon Life
		{spellID = 325700}, -- Depraved Collector: Collect Sins
		{spellID = 326607}, -- Stoneborn Reaver: Turn to Stone
		{spellID = 326771}, -- Stoneborn Slasher: Stone Watcher
		-- {spellID = 323538}, -- Aleez (Boss): Bolt of Power
		{spellID = 323552, prio = true}, -- Aleez (Boss): Volley of Power
		{spellID = 326829}, -- Inquisitor Sigar: Wicked Bolt
	},
	[2290] = { -- Mists of Tirna Scithe
		{spellID = 322938}, -- Drust Harvester: Harvest Essence
		{spellID = 322767}, -- Drust Harvester: Spirit Bolt
		{spellID = 323057}, -- Ingra Maloch (Boss): Spirit Bold
		{spellID = 322557}, -- Drust Soulcleaver: Soul Split
		{spellID = 324914, type = "heal"}, -- Mistveil Tender: Nourish the Forest
		{spellID = 326046}, -- Spinemaw Staghorn: Stimulate Resistance
		{spellID = 340544, type = "heal"}, -- Spinemaw Staghorn: Stimulate Regeneration
		-- {spellID = 325418}, -- Spinemaw Acidgullet: Volatile Acid (ni)
		{spellID = 324859, prio = true}, -- Mistveil Shaper: Bramblethorn Entanglement
	},
	[2289] = { -- Plaguefall
		{spellID = 328015}, -- Fungalmancer: Wonder Grow
		{spellID = 327995}, -- Pestilent Harvester: Doom Shroom
		{spellID = 328180}, -- Plaguebinder: Gripping Infection
		{spellID = 328651}, -- Venomous Sniper: Call Venomfang
		{spellID = 328338}, -- Venomous Sniper: Call Venomfang
		{spellID = 328475}, -- Brood Ambusher: Enveloping Webbing
		{spellID = 340635}, -- Fungalmancer: Binding Fungus
		{spellID = 329239}, -- Decaying Flesh Giant: Creepy Crawlers
		{spellID = 321999}, -- Pestilence Slime: Viral Globs
		{spellID = 328094}, -- Virulax Blightweaver: Pestilence Bolt
		{spellID = 322410}, -- Congealed Slime: Withering Filth
	},
	[2284] = { -- Sanguine Depths
		{spellID = 320861}, -- Famished Tick: Drain Essence
		{spellID = 321019}, -- Regal Mistdancer: Sanctified Mists
		{spellID = 334653}, -- Gluttonous Tick: Engorge
		{spellID = 322433}, -- Chamber Sentinel: Stoneskin
		{spellID = 319654}, -- Kryxis: Hungering Drain
		{spellID = 321038}, -- Wicked Oppressor: Wrack Soul
		{spellID = 326836}, -- Wicked Oppressor: Curse of Suppression
		{spellID = 326712}, -- Dark Acolyte: Dark Bolt
		{spellID = 326837}, -- Grand Overseer: Gloom Burst
		{spellID = 335305, prio = true}, -- Depths Warden: Barbed Shackles
		{spellID = 326952}, -- Infused Quill-Feather: Fiery Cantrip
		{spellID = 322262}, -- Vestige of Doubt: Crushing Doubt
		{spellID = 336279}, -- Remnant of Fury: Explosive Anger
	},
	[2285] = { -- Spires of Ascension
		{spellID = 327416}, -- Forsworn Goliath: Rebellious Fist
		{spellID = 317936, type = "heal"}, -- Forsworn Mender/Champion: Forsworn Doctrine
		{spellID = 317661}, -- Etherdiver: Insidious Venom
		{spellID = 328295, type = "heal"}, -- Forsworn Warden: Greater Mending
		{spellID = 317963}, -- Forsworn Castigator: Burden of Knowledge
		{spellID = 317959}, -- Forsworn Castigator/Inquisitor/Justicar: Dark Lash
		{spellID = 328331}, -- Forsworn Justicar: Forced Confession
		{spellID = 327648}, -- Forsworn Inquisitor: Internal Strife
	},
	[2286] = { -- The Necrotic Wake
		{spellID = 334748, prio = true}, -- Corpse Harvester/Corpse Collector/Stitching Assistant: Drain Fluids
		{spellID = 323190}, -- Stitched Vanguard: Meat Shield
		{spellID = 327130, type = "heal"}, -- Flesh Crafter: Repair Flesh
		{spellID = 335143, type = "heal"}, -- Zolramus Bonemender: Bonemend
		{spellID = 320822}, -- Zolramus Bonemender: Final Bargain
		{spellID = 321807}, -- Zolramus Bonecarver: Boneflay
		{spellID = 324293, prio = true}, -- Skeletal Marauder: Rasping Scream
		{spellID = 320462}, -- Nar'zudah: Necrotic Bolt
		{spellID = 333623, prio = true}, -- Mage: Frostbolt Volley
		{spellID = 320170}, -- Amarth (Boss): Necrotic Bolt
		{spellID = 338353, prio = true}, -- Corpse Collector: Goresplatter
	},
	[2293] = { -- Theater of Pain
		{spellID = 342675}, -- Bone Magus: Bone Spear
		{spellID = 330868, prio = true}, -- Maniacal Soulbinder: Necrotic Bolt Volley
		{spellID = 341969}, -- Blighted Sludge-Spewer: Withering Discharge
		{spellID = 341977}, -- Diseased Horror: Meat Shield
		{spellID = 330562}, -- Ancient Captain: Demoralizing Shout
		{spellID = 341902, type = "heal"}, -- Battlefield Ritualist: Unholy Fervor
		{spellID = 333292}, -- Sathel the Accursed (Boss): Searing Death
		{spellID = 330810}, -- Shackled Soul: Bind Soul
		{spellID = 324589}, -- Deathwalker: Death Bolt
	},
	[2441] = { -- Tazavesh
		{spellID = 356031}, -- Interrogation Specialist: Stasis Beam
		{spellID = 355934}, -- Support Officer: Hard Light Barrier
		{spellID = 350922}, -- Speakeasy Security: Menacing Shout
		{spellID = 357188}, -- So'azmi (Boss): Double Technique
		{spellID = 357284, type = "heal"}, -- Devoted Accomplice: Reinvigorate
		{spellID = 357260}, -- Focused Ritualist: Unstable Rift
		{spellID = 351119}, -- So'Cartel Assassin: Shuriken Blitz
	}
}

local function debug(plate)
	local db = KuiNameplatesManiaDB
	local _, name, spellID, instance

	if currentInstanceID == 2162 then
		local zone = GetMinimapZoneText()
		instance = tostring(currentInstanceID.." - "..currentInstanceName.." - "..zone)
	else
		instance = tostring(currentInstanceID.." - "..currentInstanceName)
	end

	if plate.cast_state.channel then
		name, _, _, _, _, _, _, _, spellID = UnitChannelInfo(plate.unit)
	else
		name, _, _, _, _, _, _, _, spellID = UnitCastingInfo(plate.unit)
	end

	local unit = GetUnitName(plate.unit)
	local interruptible = tostring(plate.cast_state.interruptible)

	if not name or not spellID or not unit or not interruptible then return end

	local match = false
	local entry = tostring(spellID.." | "..name.." | "..interruptible)

	if not db[instance] then
		db[instance] = {}
	end

	if not db[instance][unit] then
		db[instance][unit] = {}
	end

	if #db[instance][unit] == 0 then
		tinsert(db[instance][unit], entry)
	else
		for i = 1, #db[instance][unit] do
			if db[instance][unit][i] == entry then
				match = true
			end
		end
		if match == false then
			tinsert(db[instance][unit], entry)
		end
	end
end

function mod:CastBarShow(plate)
	if not important_spells[currentInstanceID] then return end
	if DEBUG then debug(plate) end

	for _, spell in pairs(important_spells[currentInstanceID]) do
		local name = GetSpellInfo(spell.spellID)
		if plate.cast_state.name == name and plate.cast_state.interruptible then
			local color
			if spell.type and spell.type == "heal" then
				color = {0.32, 0.95, 0.32, 1}
			elseif spell.prio then
				color = {1.00, 0.11, 0.11, 1}
			end
			-- plate:SetAlpha(1)
			LCG.PixelGlow_Start(plate.CastBar, color or nil, nil, nil, nil, 1)
		end
	end
end

function mod:CastBarHide(plate)
	-- plugin_fading:UpdateFrame(plate)
	LCG.PixelGlow_Stop(plate.CastBar)
end

function mod:PLAYER_ENTERING_WORLD()
	if IsInInstance() then
		local instanceName, instanceType, difficulty, _, _, _, _, instanceID = GetInstanceInfo()
		if instanceType == "raid" or instanceType == "party" or instanceType == "scenario" then
			currentInstanceName, currentInstanceID = instanceName, instanceID
			self:RegisterMessage("CastBarShow")
			self:RegisterMessage("CastBarHide")
			return
		end
	end
	self:UnregisterMessage("CastBarShow")
	self:UnregisterMessage("CastBarHide")
end

function mod:OnEnable()
	KuiNameplatesManiaDB = KuiNameplatesManiaDB or {}
	plugin_fading = addon:GetPlugin("Fading")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_INSTANCE_INFO", "PLAYER_ENTERING_WORLD")
end

local function SlashHandler(cmd)
	if (cmd == "wipe") then
		KuiNameplatesManiaDB = {}
		print("Kui_Nameplates_Mania wiped.")
	end
end

SLASH_KUIMANIA1 = "/kuimania"
SlashCmdList["KUIMANIA"] = function(cmd) SlashHandler(cmd) end