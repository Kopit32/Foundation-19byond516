/datum/component/smuggler
	var/list/smuggler_stashes = list()
	var/last_help_message
	var/cash_amount = 300
	var/list/done_goals = list()

/datum/component/smuggler/Initialize()
	. = ..()
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	last_help_message = world.time
	RegisterSignal(parent, COMSIG_ATTACK_ITEM, PROC_REF(try_make_stash))

/datum/component/smuggler/Destroy()
	. = ..()
	QDEL_LIST(smuggler_stashes)
	UnregisterSignal(parent, COMSIG_ATTACK_ITEM)

/datum/component/smuggler/proc/try_make_stash(mob/user, obj/item/using_item, atom/attacked_atom)
	if(!user)
		return
	if(!istype(using_item, /obj/item/material/kitchen/utensil/spoon))
		return
	if(!istype(attacked_atom, /turf/simulated/floor))
		return
	var/mob/living/carbon/human/H = parent
	if(H.a_intent != I_GRAB)
		if(last_help_message <= world.time)
			to_chat(H, SPAN_INFO("Change your intent to grab to make a hole"))
			last_help_message = world.time + 5 MINUTES
		return

	if(smuggler_stashes.len >= 1)
		to_chat(H, SPAN_WARNING("You already have a smuggler stash! Destroy it before making another one"))
		return
	if(do_after(H, 10 SECONDS, attacked_atom))
		var/obj/structure/smuggler_stash/S = new(get_turf(attacked_atom))
		RegisterSignal(S, COMSIG_SMUGGLER_STASH_DESTROYED, PROC_REF(update_smuggler_stash))
		smuggler_stashes.Add(S)

/datum/component/smuggler/proc/update_smuggler_stash(stash)
	smuggler_stashes.Remove(stash)
