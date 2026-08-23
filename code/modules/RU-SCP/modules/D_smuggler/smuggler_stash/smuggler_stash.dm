#define OPEN 1
#define CLOSED 0

/obj/structure/smuggler_stash
	name = "Smuggler's Stash"
	desc = ""
	icon = 'icons/obj/structures.dmi'
	icon_state = "stash_closed"
	anchored = TRUE
	breakable = TRUE
	health_max = 100

	var/state = CLOSED

	var/datum/component/smuggler/owner_component

/obj/structure/smuggler_stash/Initialize(mapload, datum/component/smuggler/owner_component)
	. = ..()
	src.owner_component = owner_component//Посмотри почему не создается схрон

/obj/structure/smuggler_stash/attack_hand(mob/user)
	. = ..()
	var/datum/component/smuggler/S = user.GetComponent(/datum/component/smuggler)
	if(S)
		owner_component.smuggler_window_controller.tgui_interact(user, null, src)
		update_icon()

/obj/structure/smuggler_stash/attackby(obj/item/O, mob/user)
	. = ..()
	if(istype(O, /obj/item/material/kitchen/utensil/spoon))
		if(user.a_intent == I_HURT)
			if(do_after(user, 10 SECONDS, src))
				remove_stash(TRUE)


/obj/structure/smuggler_stash/handle_death_change(new_death_state)
	remove_stash(FALSE)

/obj/structure/smuggler_stash/proc/remove_stash(is_spoon)
	if(!is_spoon)
		owner_component.withdraw_money(owner_component.cash_amount * 0.5, get_turf(src))
	qdel(src)

/obj/structure/smuggler_stash/update_icon()
	. = ..()
	if(state == CLOSED)
		icon_state = "stash_closed"
	else
		icon_state = "stash_open"
