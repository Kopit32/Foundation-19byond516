/obj/item/scp370
	name = "SCP-370"
	desc = "A heavily welded metal box. You feel an inexplicable urge not to open it."
	icon = 'icons/SCP/scp-370.dmi'
	icon_state = "welded_box"
	var/welded = TRUE
	anchored = FALSE

	var/has_been_opened = FALSE
	var/list/infected_people = list()

/obj/item/scp370/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weldingtool))
		if(welded)
			to_chat(user, SPAN_WARNING("You begin cutting through the welds on SCP-370..."))
			addtimer(CALLBACK(src, .proc/open_box, user), 50)
		else
			..()
	else
		return ..()

/obj/item/scp370/proc/open_box(mob/opener)
	if(!welded || has_been_opened)
		return

	welded = FALSE
	has_been_opened = TRUE
	icon_state = "welded_box_open"
	desc = "The box is open. Inside there is only a single handwritten note."
	to_chat(opener, SPAN_USERDANGER("THE BOX OPENS. YOU READ THE NOTE."))

/obj/item/scp370/attack_hand(mob/user)
	if(has_been_opened)
		to_chat(user, SPAN_NOTICE("You read the note inside SCP-370."))
	else
		to_chat(user, SPAN_NOTICE("The box is tightly welded shut."))
