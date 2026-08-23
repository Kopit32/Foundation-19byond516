#define MAX_ORDERS 3
#define REROLL_COOLDOWN 2 MINUTES
#define STASH_COOLDOWN 5 MINUTES

#define PURCHASE_SECTION_LIGHT "light"
#define PURCHASE_SECTION_MEDIUM "medium"
#define PURCHASE_SECTION_HIGH "high"

/datum/component/smuggler
	var/smuggler_stash
	var/last_help_message
	var/cash_amount = 150

	var/list/goals = list()
	var/list/orders = list(ORDER_RENEWABLE = list(), ORDER_UNIQUE = list(), ORDER_CONSTANT = list())

	var/datum/smuggler_tgui/smuggler_window_controller

	var/busy = FALSE

	var/last_stash = 0

	var/list/unlocked_tiers = list(
	PURCHASE_SECTION_LIGHT = TRUE,
	PURCHASE_SECTION_MEDIUM = FALSE,
	PURCHASE_SECTION_HIGH = FALSE,
	)
	var/list/tier_unlock_costs = list(
		PURCHASE_SECTION_MEDIUM = 200,
		PURCHASE_SECTION_HIGH = 400,
	)

/datum/component/smuggler/Initialize()
	. = ..()
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	last_help_message = world.time
	RegisterSignal(parent, COMSIG_ATTACK_ITEM, PROC_REF(try_make_stash))
	goals = init_goals()

	for(var/I = 1 to MAX_ORDERS)
		orders[ORDER_UNIQUE] += new /datum/smuggler_order(ORDER_UNIQUE)
	orders[ORDER_RENEWABLE] += new /datum/smuggler_order(ORDER_RENEWABLE, ORDER_TYPE_BOTANY)
	orders[ORDER_RENEWABLE] += new /datum/smuggler_order(ORDER_RENEWABLE, ORDER_TYPE_RESOURCES)
	orders[ORDER_RENEWABLE] += new /datum/smuggler_order(ORDER_RENEWABLE, ORDER_TYPE_COOKING)
	orders[ORDER_CONSTANT] += new /datum/smuggler_order/constant/blunts()
	orders[ORDER_CONSTANT] += new /datum/smuggler_order/constant/id_cards()

	smuggler_window_controller = new(src)

/datum/component/smuggler/Destroy()
	. = ..()
	qdel(smuggler_stash)
	UnregisterSignal(parent, COMSIG_ATTACK_ITEM)

/datum/component/smuggler/proc/init_goals()
	var/list/raw_data = GLOB.global_shop_items

	var/list/add_list = list()
	for(var/list/purshase_list in raw_data)
		if(purshase_list["goal_type"])
			if(locate(purshase_list["goal_type"]) in add_list)
				continue
			var/goal_path_string = purshase_list["goal_type"]
			var/goal_path = text2path(goal_path_string)
			var/datum/goal/new_goal = new goal_path()
			add_list.Add(list("[goal_path_string]" = new_goal))
	return add_list

/datum/component/smuggler/proc/try_make_stash(mob/user, obj/item/using_item, atom/attacked_atom)
	if(!user)
		return
	if(!istype(using_item, /obj/item/material/kitchen/utensil/spoon))
		return
	if(!istype(attacked_atom, /turf/simulated/floor))
		return
	if(busy)
		return
	var/mob/living/carbon/human/H = parent

	if(H.a_intent != I_GRAB)
		if(last_help_message <= world.time)
			to_chat(H, SPAN_INFO("Change your intent to grab to make a hole"))
			last_help_message = world.time + 5 MINUTES
		return

	if(smuggler_stash)
		to_chat(H, SPAN_WARNING("You already have a smuggler stash! Destroy it before making another one"))
		return
	if(!(world.time - last_stash > 0))
		to_chat(H, SPAN_WARNING("You already have stash! Destroy it before making another one"))
		return
	busy = TRUE
	if(do_after(H, 10 SECONDS, attacked_atom))
		var/obj/structure/smuggler_stash/S = new(get_turf(attacked_atom), src)
		RegisterSignal(S, COMSIG_PARENT_QDELETING, PROC_REF(remove_stash))
		smuggler_stash = S
		last_stash = world.time + STASH_COOLDOWN
	busy = FALSE

/datum/component/smuggler/proc/remove_stash(stash)
	smuggler_stash = null

/datum/component/smuggler/proc/withdraw_money(amount, turf/place)
	if(amount <= 0)
		return
	if(amount > cash_amount)
		amount = cash_amount
	var/obj/item/smuggler_cash/S = new(place, amount)
	cash_amount -= amount

/datum/component/smuggler/proc/deposit_money(atom/place)
	if(!place)
		return
	var/deposit_amount
	for(var/obj/item/smuggler_cash/B in place.contents)
		deposit_amount += B.worth
		qdel(B)
	cash_amount += deposit_amount
	return FALSE


