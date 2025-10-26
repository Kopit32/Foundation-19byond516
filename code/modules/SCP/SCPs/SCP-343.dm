/mob/living/carbon/human/scp343
	name = "strange elderly man"
	desc = "A mysterious powerful man. He looks a lot like what you would imagine god to look like."
	icon = 'icons/SCP/scp-343.dmi'
	icon_state = null

	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 7

	status_flags = CANPUSH|GODMODE

	roundstart_traits = list(TRAIT_ADVANCED_TOOL_USER)

	//Config

	var/cookie_cooldown = 30 SECONDS
	var/cookie_cooldown_track = 0 SECONDS
	var/heal_cooldown = 15 MINUTE
	var/heal_cooldown_track = -15 MINUTE

	///Cooldown for our phasing ability
	var/phase_cooldown = 5 SECONDS
	///How long it takes us to phase
	var/phase_time = 2 SECONDS
	var/move_delay = 3.0
	//Mechanical
/mob/living/carbon/human/scp343/verb/object_phase()
	phase_time = 1 SECOND

	var/obj/target_object = null
	for(var/obj/O in get_step(src, dir))
		// Things that we will ignore
		if(!isstructure(O) && !ismachinery(O))
			continue

		if(!O.density)
			continue

		// Things that will block our phasing
		if(istype(O, /obj/machinery/shieldwall) || istype(O, /obj/machinery/shieldwallgen))
			to_chat(src, SPAN_WARNING("You cannot phase through [O]."))
			return

		// There can be more than one available dense object, but that doesn't matter
		target_object = O

	if(!istype(target_object))
		to_chat(src, SPAN_WARNING("There's nothing to phase through in that direction."))
		return

	var/turf/target_turf = get_step(target_object, dir)
	if(target_turf.density)
		to_chat(src, SPAN_WARNING("\The [target_turf] is preventing us from phasing in that direction."))
		return

	// Mob effects
	var/old_layer = layer
	var/anim_x = 0
	var/anim_y = 0
	layer = OBSERVER_LAYER

	if(dir in list(NORTH, NORTHEAST, NORTHWEST))
		anim_y = 32
	if(dir in list(SOUTH, SOUTHEAST, SOUTHWEST))
		anim_y = -32
	if(dir in list(EAST, NORTHEAST, SOUTHEAST))
		anim_x = 32
	if(dir in list(WEST, NORTHWEST, SOUTHWEST))
		anim_x = -32
	animate(src, pixel_x = anim_x, pixel_y = anim_y, time = phase_time)

	//if(do_after(src, phase_time, target_object))
	forceMove(get_step(src, dir))
	visible_message(SPAN_NOTICE("[src] silently phases through [target_object]"))

	layer = old_layer
	pixel_x = 0
	pixel_y = 0
	///Cooldow tracker for our phasing ability
/mob/living/carbon/human/scp343/Initialize(mapload, new_species = "SCP-343")
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"strange elderly man", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"343", //Numerical Designation
		SCP_PLAYABLE|SCP_ROLEPLAY
	)

	add_language(LANGUAGE_ENGLISH)
	add_language(LANGUAGE_HUMAN_FRENCH)
	add_language(LANGUAGE_HUMAN_GERMAN)
	add_language(LANGUAGE_HUMAN_SPANISH)
	if(!(MUTATION_XRAY in mutations))
		mutations.Add(MUTATION_XRAY)
		update_mutations()
		update_sight()

	add_verb(src, /mob/living/carbon/human/scp343/verb/object_phase)

	SCP.min_time = 15 MINUTES
	SCP.min_playercount = 20

//Mechanics

//Overrides

/mob/living/carbon/human/scp343/UnarmedAttack(atom/A, proximity)
	if((a_intent == I_HURT) && iscarbon(A))
		to_chat(src, SPAN_WARNING("You know better than to hurt one of your own children."))
		return

	if((a_intent == I_HELP) && ismob(A))
		if((world.time - heal_cooldown_track) < heal_cooldown)
			to_chat(src, SPAN_WARNING("You can't cure your children yet!"))
			return
		heal_cooldown_track = world.time + heal_cooldown
		var/mob/living/target = A
		to_chat(src, SPAN_WARNING("You start to heal [target]'s wounds"))
		visible_message(SPAN_NOTICE("\The [src] starts to heal [target]'s wounds"))
		if(!do_after(src, 12 SECONDS, A, bonus_percentage = 25))
			return
		target.revive()
		visible_message(SPAN_NOTICE("\The [src] has fully healed [target]!"))
		return

	return ..()

/mob/living/carbon/human/scp343/get_pressure_weakness()
	return 0

/mob/living/carbon/human/scp343/handle_breath()
	return 1

/mob/living/carbon/human/scp343/movement_delay(decl/move_intent/using_intent = move_intent)
	return 3.0

//TODO: Change pathing of SCPs to no longer be humans so that we dont have to do this bullshit.
/mob/living/carbon/human/scp343/update_icons()
	return

/mob/living/carbon/human/scp343/on_update_icon()
	if(lying || resting)
		var/matrix/M =  matrix()
		transform = M.Turn(90)
	else
		transform = null
	return


/mob/living/carbon/human/scp343/verb/change_shell()
	set name = "Change shell"
	set category = "SCP-343"
	set desc = "Become unreal"

	// Invisible
	if (alpha < 255)
		alpha = 255
		move_delay = 3.0 // Default speed
	else if (alpha == 255)
		alpha = 0
		move_delay = 1.5 // Max speed
	to_chat(src, SPAN_WARNING("You change your visibility."))


/mob/living/carbon/human/scp343/verb/summon_cookie()
	set name = "Summon cookie"
	set category = "SCP-343"
	set desc = "Create cookies out of air"

	if((world.time - cookie_cooldown_track) < cookie_cooldown)
		to_chat(src, SPAN_WARNING("You can't create cookies yet!"))
		return

	var/mob/living/carbon/human/scp343/H = src

	H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), slot_l_hand )
	if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
		H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), slot_r_hand )
		if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
			to_chat(src, SPAN_WARNING("You need free hands to create cookies!"))
			return
		else
			H.update_inv_r_hand()
			visible_message(SPAN_WARNING("A cookie appears in the [name] right hand!"))
	else
		H.update_inv_l_hand()
		visible_message(SPAN_WARNING("A cookie appears in the [name] left hand!"))

	cookie_cooldown_track = world.time + cookie_cooldown // To avoid cookie spam

/mob/living/carbon/human/scp343/verb/return_scp_back() // Soo sussy verb
	set name = "Return SCP back \[CAUTION\]"
	set category = "SCP-343"
	set desc = "Get your child back."

	if(alert("Using this ability will incapacitate you for the rest of the round. Are you sure?",,"Yes","No") != "Yes")
		return

	var/list/A = list("049", "066", "082", "096", "106", "173", "247", "280", "457", "2427-3")

	var/Target = tgui_input_list(src, "Choose a SCP to return", "SCP return", A)

	// There's a bit of long code here, but it gets the job done.
	if(Target == "049")
		for(var/mob/living/carbon/human/scp049/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your doctor child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "066")
		for(var/mob/living/simple_animal/friendly/retaliate/scp066/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your toy child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "082")
		for(var/mob/living/carbon/human/scp082/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your french child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "096")
		for(var/mob/living/scp096/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your shy child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "106")
		for(var/mob/living/carbon/human/scp106/T in GLOB.SCP_list)
			T.forceMove(T.spawn_turf)
			to_chat(src, SPAN_WARNING("Your old child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "173")
		for(var/mob/living/scp173/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your waiting child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "247")
		for(var/mob/living/simple_animal/hostile/scp247/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your shaggy child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "280")
		for(var/mob/living/simple_animal/hostile/scp280/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your dark child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "457")
		for(var/mob/living/simple_animal/hostile/scp457/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your fiery child has returned home. It's time to rest."))
			usr.gib()
			return
	else if(Target == "2427-3")
		for(var/mob/living/simple_animal/hostile/scp2427_3/T in GLOB.SCP_list)
			T.forceMove(T.start_turf)
			to_chat(src, SPAN_WARNING("Your steel child has returned home. It's time to rest."))
			usr.gib()
			return
	else
		to_chat(src, SPAN_WARNING("You cannot affect this SCP!"))
		return
	to_chat(src, SPAN_WARNING("Something went wrong."))



/mob/living/carbon/human/scp343/movement_delay()
	return move_delay


/mob/living/carbon/human/scp343/verb/scp_say(message as text)
	set category = "SCP-343"
	set name = "SCP say"

	for(var/mob/A in GLOB.SCP_list)
		if(A.client)
			to_chat(A, SPAN_DANGER("[icon2html(src, usr)] <B><strong>SCP-[SCP.designation] [src]:</strong></B> <span class='message linkify'>[message]</span>"))
