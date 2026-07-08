#define OPEN 1
#define CLOSED 0

#define MAX_ORDERS 3

/obj/structure/smuggler_stash
	name = "Smuggler's Stash"
	desc = ""
	icon = 'icons/obj/structures.dmi'
	icon_state = "stash_closed"

	var/state = CLOSED

	var/datum/smuggler_tgui

/obj/structure/smuggler_stash/Initialize()
	. = ..()
	smuggler_tgui = new(src)

/obj/structure/smuggler_stash/attack_hand(mob/user)
	. = ..()
	if(user.GetComponent(/datum/component/smuggler))
		smuggler_tgui.tgui_interact(user)
		update_icon()

/obj/structure/smuggler_stash/update_icon()
	. = ..()
	if(state == CLOSED)
		icon_state = "stash_closed"
	else
		icon_state = "stash_open"
