/mob/living/basic/construct
	icon = 'icons/mob/nonhuman-player/cult.dmi'
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	istate = ISTATE_HARM
	mob_biotypes = MOB_MINERAL
	faction = list(FACTION_CULT)
	unsuitable_atmos_damage = 0
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pressure_resistance = 100
	speed = 0
	unique_name = TRUE
	initial_language_holder = /datum/language_holder/construct
	death_message = "collapses in a shattered heap."

	speak_emote = list("hisses")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	melee_attack_cooldown = CLICK_CD_MELEE

	// Vivid red, cause cult theme
	lighting_cutoff_red = 30
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 20

	/// List of spells that this construct can cast
	var/list/construct_spells = list()
	/// Flavor text shown to players when they spawn as this construct
	var/playstyle_string = "You are a generic construct. Your job is to not exist, and you should probably adminhelp this."
	/// The construct's master
	var/master = null
	/// Whether this construct is currently seeking nar nar
	var/seeking = FALSE
	/// Whether this construct can repair other constructs or cult buildings. Gets the healing_touch component if so.
	var/can_repair = FALSE
	/// Whether this construct can repair itself. Works independently of can_repair.
	var/can_repair_self = FALSE
	/// Theme controls color. THEME_CULT is red THEME_WIZARD is purple and THEME_HOLY is blue
	var/theme = THEME_CULT
	/// Can this construct destroy walls?
	var/smashes_walls = FALSE
	/// The different flavors of goop constructs can drop, depending on theme.
	var/static/list/remains_by_theme = list(
		THEME_CULT = list(/obj/item/ectoplasm/construct),
		THEME_HOLY = list(/obj/item/ectoplasm/angelic),
		THEME_WIZARD = list(/obj/item/ectoplasm/mystic),
	)

/mob/living/basic/construct/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	var/list/remains = string_list(remains_by_theme[theme])
	if(length(remains))
		AddElement(/datum/element/death_drops, remains)
	if(smashes_walls)
		AddElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	if(can_repair)
		AddComponent(\
			/datum/component/healing_touch,\
			heal_brute = 5,\
			heal_burn = 0,\
			heal_time = 0,\
			valid_targets_typecache = typecacheof(list(/mob/living/basic/construct, /mob/living/basic/shade)),\
			valid_biotypes = MOB_MINERAL | MOB_SPIRIT,\
			self_targeting = can_repair_self ? HEALING_TOUCH_ANYONE : HEALING_TOUCH_NOT_SELF,\
			action_text = "%SOURCE% begins repairing %TARGET%'s dents.",\
			complete_text = "%TARGET%'s dents are repaired.",\
			show_health = TRUE,\
			heal_color = COLOR_CULT_RED,\
		)
		var/static/list/structure_types = typecacheof(list(/obj/structure/destructible/cult))
		AddElement(\
			/datum/element/structure_repair,\
			structure_types_typecache = structure_types,\
			)
	add_traits(list(TRAIT_HEALS_FROM_CULT_PYLONS, TRAIT_SPACEWALK), INNATE_TRAIT)
	for(var/spell in construct_spells)
		var/datum/action/new_spell = new spell(src)
		new_spell.Grant(src)

	var/spell_count = 1
	for(var/datum/action/spell as anything in actions)
		if(!(spell.type in construct_spells))
			continue

		var/pos = 2 + spell_count * 31
		if(construct_spells.len >= 4)
			pos -= 31 * (construct_spells.len - 4)
		spell.default_button_position = "6:[pos],4:-2" // Set the default position to this random position
		spell_count++
		update_action_buttons()

	if(icon_state)
		add_overlay("glow_[icon_state]_[theme]")

/mob/living/basic/construct/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, span_bold(playstyle_string))

/mob/living/basic/construct/examine(mob/user)
	var/text_span
	switch(theme)
		if(THEME_CULT)
			text_span = "cult"
		if(THEME_WIZARD)
			text_span = "purple"
		if(THEME_HOLY)
			text_span = "blue"
	. = list("<span class='[text_span]'>This is [icon2html(src, user)] \a <b>[src]</b>!\n[desc]")
	if(health < maxHealth)
		if(health >= maxHealth/2)
			. += span_warning("[p_They()] look[p_s()] slightly dented.")
		else
			. += span_warning(span_bold("[p_They()] look[p_s()] severely dented!"))
	. += "</span>"
	return .

/mob/living/basic/construct/narsie_act()
	return

/mob/living/basic/construct/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE

/// Construct ectoplasm. Largely a placeholder, since the death drop element needs a unique list.
/obj/item/ectoplasm/construct
	name = "blood-red ectoplasm"
	desc = "Has a pungent metallic smell."
