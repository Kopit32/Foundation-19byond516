/obj/machinery/scp330
	name = "bowl of sweets"
	desc = "A bowl with colorful candies of an unknown brand. Taped to the edge of the bowl is a handwritten note: Dont take more than two, please! "

	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "scp-330"

	anchored = TRUE
	density = FALSE

	//Tracks candy takes per individual user
	var/list/user_takes = list()

/obj/machinery/scp330/Initialize()
	. = ..()
	SCP = new /datum/scp(
		src, // Ref to actual SCP atom
		"bowl of sweets", //Name (Should not be the scp desg, more like what it can be described as to viewers)
		SCP_SAFE, //Obj Class
		"330", //Numerical Designation
	)

/obj/machinery/scp330/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/H = user

	// Initialize counter for this user if not present

	if(!user_takes[H.ckey])
		user_takes[H.ckey] = 0

	user_takes[H.ckey] += 1
	var/user_candies_taken = user_takes[H.ckey]

	var/candy_type
	switch(rand(1,7))
		if(1)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_red
		if(2)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_yellow
		if(3)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_blue
		if(4)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_green
		if(5)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_purple
		if(6)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_rainbow
		if(7)	candy_type = /obj/item/reagent_containers/food/snacks/scp294/candy_pink

	var/obj/item/I = new candy_type
	H.put_in_active_hand(I)
	if(user_candies_taken >= 3)
		amputate(H)

/obj/machinery/scp330/proc/amputate(mob/living/carbon/human/target)
	if(!istype(target) || QDELETED(target) || !target.client)
		return

	var/target_zone
	var/active_hand = target.get_active_hand()

	if(active_hand == target.r_hand)
		target_zone = BP_R_HAND
	else if(active_hand == target.l_hand)
		target_zone = BP_L_HAND
	else
		// Fallback: amputate right hand if active hand detection fails
		target_zone = BP_R_HAND

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	// Check if limb exists and is still attached before proceeding
	if(!istype(affected))
		// If this hand is already gone, try the other one
		target_zone = (target_zone == BP_R_HAND) ? BP_L_HAND : BP_R_HAND
		affected = target.get_organ(target_zone)
		if(!istype(affected))
			// Both hands already gone, do nothing
			return

	// Play sound FIRST before anything else
	playsound(src, "bone_break", 75, TRUE)
	if(istype(target) && !target.incapacitated())
		target.emote("scream")

	target.visible_message(SPAN_WARNING("[target]'s hand fell to the floor with a terrible sound!"), \
	SPAN_WARNING("Your hand fell to the floor with a terrible sound!"))

	// Proper clean amputation with edge cut
	affected.droplimb(TRUE, DROPLIMB_EDGE)
	// Force update body state after amputation
	target.update_body()

	var/shock_level = 3
	if(istype(target))
		target.shock_stage = max(target.shock_stage, shock_level)

// Candy definitions
/obj/item/reagent_containers/food/snacks/scp294/candy_red
	name = "red candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_red"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/bicaridine = 1,
	/datum/reagent/medicine/kelotane = 1,
	/datum/reagent/medicine/ethylredoxrazine = 1,
	/datum/reagent/medicine/imidazoline = 1
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_yellow
	name = "yellow candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_yellow"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/bicaridine = 3,
	/datum/reagent/medicine/kelotane = 3
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_blue
	name = "blue candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_blue"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/imidazoline = 5,
	/datum/reagent/medicine/penicillin/spaceacillin = 5,
	/datum/reagent/medicine/immunobooster = 5
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_green
	name = "green candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_green"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/addiction/amnestics = 5,
	/datum/reagent/medicine/adrenaline = 5
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_purple
	name = "purple candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_purple"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/arithrazine = 5,
	/datum/reagent/medicine/hyronalin = 5
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_rainbow
	name = "rainbow candy"
	desc = "Rainbow candy! Wow!"
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_rainbow"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/ethanol = 10,
	/datum/reagent/medicine/alkysine = 5
	)

/obj/item/reagent_containers/food/snacks/scp294/candy_pink
	name = "pink candy"
	desc = "Just a delicious candy."
	icon = 'icons/SCP/scp-330.dmi'
	icon_state = "candy_pink"
	nutriment_desc = list("candy" = 1)
	nutriment_amt = 2
	bitesize = 10
	food_reagents = list(
	/datum/reagent/nutriment/protein = 2,
	/datum/reagent/medicine/bicaridine = 3,
	/datum/reagent/medicine/painkiller/tramadol = 5
	)
