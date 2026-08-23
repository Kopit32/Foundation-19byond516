#define CASH_STATE_SINGLE "cash_single"
#define CASH_STATE_FEW    "cash_few"
#define CASH_STATE_BUNDLE "cash_bundle"
#define CASH_NAME "pounds"
#define CASH_SHORT_NAME "£"

#define CASH_LIMIT_SINGLE 20
#define CASH_LIMIT_FEW    100

/obj/item/smuggler_cash
	name = "contraband cash"
	desc = "It's worth 0."
	icon = 'code/modules/RU-SCP/icons/new_cash.dmi'
	icon_state = CASH_STATE_SINGLE
	opacity = 0
	density = FALSE
	anchored = FALSE
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = ITEM_SIZE_TINY
	var/worth = 0

/obj/item/smuggler_cash/Initialize(mapload, worth)
	. = ..()
	if(worth)
		src.worth = worth
	update_icon()

/obj/item/smuggler_cash/on_update_icon()
	icon_state = get_cash_state()
	SetName(get_cash_name())
	desc = "It's worth [worth] [currency_short()]."
	w_class = worth > CASH_LIMIT_FEW ? ITEM_SIZE_SMALL : ITEM_SIZE_TINY

/obj/item/smuggler_cash/proc/get_cash_state()
	if(worth <= CASH_LIMIT_SINGLE)
		return CASH_STATE_SINGLE
	if(worth <= CASH_LIMIT_FEW)
		return CASH_STATE_FEW
	return CASH_STATE_BUNDLE

/obj/item/smuggler_cash/proc/get_cash_name()
	if(worth > CASH_LIMIT_FEW)
		return "pile of [CASH_NAME] ([worth])"
	return "[worth] [currency()]"

/obj/item/smuggler_cash/proc/currency()
	return CASH_NAME

/obj/item/smuggler_cash/proc/currency_short()
	return CASH_SHORT_NAME

/obj/item/smuggler_cash/attackby(obj/item/W, mob/user)

	if(!istype(W, /obj/item/smuggler_cash))
		return ..()

	var/obj/item/smuggler_cash/other = W
	other.worth += worth
	other.update_icon()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.drop_from_inventory(other)
		H.put_in_hands(other)

	to_chat(user, SPAN_NOTICE("You add [worth] [currency()] to the pile. It holds [other.worth] [currency()] now."))
	qdel(src)

/obj/item/smuggler_cash/attack_hand(mob/user)
	if(user.get_inactive_hand() != src)
		return ..()

	var/amount = input(user, "How many [currency()] do you want to take? (0 to [worth])", "Take Money", 1) as num
	amount = round(Clamp(amount, 0, worth))
	if(!amount)
		return

	worth -= amount
	update_icon()

	var/obj/item/smuggler_cash/taken = new(get_turf(user))
	taken.worth = amount
	taken.update_icon()
	user.put_in_hands(taken)

	if(!worth)
		qdel(src)

#undef CASH_STATE_SINGLE
#undef CASH_STATE_FEW
#undef CASH_STATE_BUNDLE
#undef CASH_NAME
#undef CASH_SHORT_NAME

#undef CASH_LIMIT_SINGLE
#undef CASH_LIMIT_FEW
