/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"
	plural_form = "Shadowpeople"
	id = SPECIES_SHADOW
	sexes = 0
	meat = /obj/item/food/meat/slab/human/mutant/shadow
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED
	)
	inherent_factions = list(FACTION_FAITHLESS)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC

	mutantbrain = /obj/item/organ/internal/brain/shadow
	mutanteyes = /obj/item/organ/internal/eyes/shadow
	mutantheart = null
	mutantlungs = null

	species_language_holder = /datum/language_holder/shadowpeople

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

/datum/species/shadow/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/shadow/get_species_description()
	return "Victims of a long extinct space alien. Their flesh is a sickly \
		seethrough filament, their tangled insides in clear view. Their form \
		is a mockery of life, leaving them mostly unable to work with others under \
		normal circumstances."

/datum/species/shadow/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "moon",
			SPECIES_PERK_NAME = "Shadowborn",
			SPECIES_PERK_DESC = "Their skin blooms in the darkness. All kinds of damage, \
				no matter how extreme, will heal over time as long as there is no light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Nightvision",
			SPECIES_PERK_DESC = "Their eyes are adapted to the night, and can see in the dark with no problems.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Lightburn",
			SPECIES_PERK_DESC = "Their flesh withers in the light. Any exposure to light is \
				incredibly painful for the shadowperson, charring their skin.",
		),
	)

	return to_add

/// the key to some of their powers
/obj/item/organ/internal/brain/shadow
	name = "shadowling tumor"
	desc = "Something that was once a brain, before being remolded by a shadowling. It has adapted to the dark, irreversibly."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'

/obj/item/organ/internal/brain/shadow/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return
	var/light_amount = owner_turf.get_lumcount()

	if(light_amount >= SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying -minor monke edit
		owner.take_overall_damage(brute = 0.5 * seconds_per_tick, burn = 0.5 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
	else //heal in the dark -minor monke edit
		owner.heal_overall_damage(brute = 0.5 * seconds_per_tick, burn = 0.5 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)

/obj/item/organ/internal/eyes/shadow
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon = 'icons/obj/medical/organs/shadow_organs.dmi'
	color_cutoffs = list(20, 10, 40)
	pepperspray_protect = TRUE
