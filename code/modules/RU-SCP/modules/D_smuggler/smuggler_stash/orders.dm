#define ORDER_RENEWABLE "order_renewable"
#define ORDER_UNIQUE "order_unique"
#define ORDER_CONSTANT "order_constant"

#define ORDER_TYPE_RESOURCES "/datum/order_requirements/stack/resources"
#define ORDER_TYPE_CRAFTABLE "/datum/order_requirements/item/craftable"
#define ORDER_TYPE_ITEM "/datum/order_requirements/item/light"
#define ORDER_TYPE_BOTANY "/datum/order_requirements/item/botany"
#define ORDER_TYPE_ORGAN "/datum/order_requirements/item/organs"
#define ORDER_TYPE_MEDICAL "/datum/order_requirements/item/medical"
#define ORDER_TYPE_WEAPON "/datum/order_requirements/item/weapon"


GLOBAL_LIST_INIT(orders_renewable, list(
    ORDER_TYPE_RESOURCES = 30,
    ORDER_TYPE_CRAFTABLE = 20,
    ORDER_TYPE_BOTANY = 30
	))

GLOBAL_LIST_INIT(orders_unique, list(
    ORDER_TYPE_MEDICAL = 10,
    ORDER_TYPE_ITEM = 25,
    ORDER_TYPE_ORGAN = 15,
    ORDER_TYPE_WEAPON = 15
	))

GLOBAL_LIST_INIT(orders_req, list(
	ORDER_RENEWABLE = orders_renewable,
	ORDER_UNIQUE = orders_unique
))

/datum/smuggler_order
    var/datum/order_requirements/requirements
    var/requirements_type
    var/order_type = ORDER_RENEWABLE

/datum/smuggler_order/New(o_type)
    . = ..()
    if(o_type)
        order_type = o_type
    generate()

/datum/smuggler_order/proc/generate()
	if(order_type == ORDER_CONSTANT)
		requirements = new requirements_type()
	else
		var/req = GLOB.orders_req[order_type]
		var/selected_type = pickweight(req)
		if(selected_type)
			requirements = new selected_type()

/datum/smuggler_order/proc/try_complete(list/items)
    if(!requirements)
        return FALSE
    var/payout = requirements.complete(items)
    if(payout)
        return payout
    return FALSE

/datum/smuggler_order/proc/get_order_info()
	if(!requirements)
		return list()

	return list(
		"name" = requirements.name,
		"items" = requirements.items,
		"reward" = requirements.cost,
		"desc" = requirements.desc,
		)

/datum/order_requirements
	abstract_type = /datum/order_requirements
	var/name
	var/cost
	var/list/items
	var/desc

	var/list/available_requirements = list()

/datum/order_requirements/New()
    . = ..()
    generate_req()

/datum/order_requirements/proc/generate_req()
	if(!length(available_requirements))
		CRASH("Avaiable_requirements is empty")

	var/list/req = pick(available_requirements)
	name = req["name"]
	cost = req["cost"]
	items = req["items"]
	desc = req["desc"]

/datum/order_requirements/proc/complete(list/items)
    return 0

/datum/order_requirements/proc/check_item(obj/item/I, item_type)
    return istype(I, item_type)

/datum/order_requirements/proc/calculate_payout(list/item_groups)
    return cost



/datum/order_requirements/item/complete(list/ex_items)
    var/list/complete_list = get_items_list(ex_items)
    if(!complete_list)
        return 0

    var/payout = calculate_payout(complete_list)

    for(var/list/group in complete_list)
        for(var/obj/item/I in group)
            qdel(I)

    return payout

/datum/order_requirements/item/proc/get_items_list(list/ex_items)
    var/list/final_list = list()
    var/list/item_pool = ex_items.Copy()

    for(var/list/item_list in items)
        var/list/to_complete = list()
        var/amount = item_list["amount"]

        for(var/obj/item/I in item_pool)
            if(check_item(I, item_list["type"]))
                to_complete.Add(I)
                item_pool.Remove(I)
                if(to_complete.len == amount)
                    break

        if(to_complete.len < amount)
            return null

        final_list[++final_list.len] = to_complete

    return final_list



/datum/order_requirements/stack/complete(list/ex_items)
    var/list/stacks_to_deduct = list()

    for(var/list/item_list in items)
        var/needed_amount = item_list["amount"]
        var/stack_type = item_list["type"]
        var/found_amount = 0

        for(var/obj/item/I in ex_items)
            if(!istype(I, stack_type))
                continue

            var/obj/item/stack/S = I
            var/already_claimed = stacks_to_deduct[S] ? stacks_to_deduct[S] : 0
            var/available_amount = S.amount - already_claimed

            if(available_amount <= 0)
                continue

            var/take = min(needed_amount - found_amount, available_amount)
            found_amount += take
            stacks_to_deduct[S] = already_claimed + take

            if(found_amount >= needed_amount)
                break

        if(found_amount < needed_amount)
            return 0

    var/payout = calculate_payout(stacks_to_deduct)

    for(var/obj/item/stack/S in stacks_to_deduct)
        var/deduct_amt = stacks_to_deduct[S]
        if(S.amount == deduct_amt)
            qdel(S)
        else
            S.amount -= deduct_amt

    return payout


/datum/order_requirements/item/constant/id_cards
    var/list/tier_bonuses = list(50, 70, 100, 200, 400)
    var/list/access_groups = list(
        list("ACCESS_SECURITY_LVL1", "ACCESS_SECURITY_LVL2", "ACCESS_SECURITY_LVL3", "ACCESS_SECURITY_LVL4", "ACCESS_SECURITY_LVL5"),
        list("ACCESS_SCIENCE_LVL1", "ACCESS_SCIENCE_LVL2", "ACCESS_SCIENCE_LVL3", "ACCESS_SCIENCE_LVL4", "ACCESS_SCIENCE_LVL5"),
        list("ACCESS_MEDICAL_LVL1", "ACCESS_MEDICAL_LVL2", "ACCESS_MEDICAL_LVL3", "ACCESS_MEDICAL_LVL4", "ACCESS_MEDICAL_LVL5"),
        list("ACCESS_ENGINEERING_LVL1", "ACCESS_ENGINEERING_LVL2", "ACCESS_ENGINEERING_LVL3", "ACCESS_ENGINEERING_LVL4", "ACCESS_ENGINEERING_LVL5"),
        list("ACCESS_ADMIN_LVL1", "ACCESS_ADMIN_LVL2", "ACCESS_ADMIN_LVL3", "ACCESS_ADMIN_LVL4", "ACCESS_ADMIN_LVL5")
    )

/datum/order_requirements/item/constant/id_cards
	available_requirements = list(
        "Command IDs" = list(
            "items" = list(/obj/item/card/id = 1),
            "cost" = 50
        )
    )

/datum/order_requirements/item/constant/id_cards/check_item(obj/item/I, item_type)
    if(!..())
        return FALSE

    var/obj/item/card/id/ID = I
    for(var/list/department in access_groups)
        for(var/access in department)
            if(access in ID.access)
                return TRUE
    return FALSE

/datum/order_requirements/item/constant/id_cards/calculate_payout(list/item_groups)
    var/base = cost
    var/bonus = 0

    for(var/list/group in item_groups)
        for(var/obj/item/card/id/ID in group)
            var/max_tier = 0
            for(var/list/department in access_groups)
                for(var/tier = 5 to 1 step -1)
                    if(department[tier] in ID.access)
                        if(tier > max_tier)
                            max_tier = tier
                        break
            if(max_tier)
                bonus += tier_bonuses[max_tier]

    return base + bonus


/datum/order_requirements/stack/resources
	available_requirements = list(
		list(
			"name" = "Steel",
			"items" = list(
				list("name" = "Steel", "type" = /obj/item/stack/material/steel, "amount" = 20)
			),
			"cost" = 30,
			"desc" = "20 листов стали"
		)
	)

/datum/order_requirements/item/craftable
	available_requirements = list(
		list(
			"name" = "Pickaxes",
			"items" = list(
				list("name" = "Pickaxe", "type" = /obj/item/pickaxe, "amount" = 2)
			),
			"cost" = 30,
			"desc" = "Две кирки"
		)
	)

/datum/order_requirements/item/weapon
	available_requirements = list(
		list(
			"name" = "Gun",
			"items" = list(
				list("name" = "Makarov", "type" = /obj/item/gun/projectile/pistol/makarov, "amount" = 1)
			),
			"cost" = 150,
			"desc" = "Пистолет Макарова"
		)
	)

/datum/order_requirements/item/constant/blunts
	available_requirements = list(
		list(
			"name" = "Blunts",
			"items" = list(
				list("name" = "Cigarette", "type" = /obj/item/clothing/mask/smokable/cigarette, "amount" = 2)
			),
			"cost" = 5,
			"desc" = "Две сигареты"
		)
	)

/datum/order_requirements/item/botany
	available_requirements = list(
		list(
			"name" = "Potatoes",
			"items" = list(
				list("name" = "Potato", "type" = /obj/item/reagent_containers/food/snacks/grown/potato, "amount" = 10)
			),
			"cost" = 20,
			"desc" = "10 картофелин"
		)
	)

/datum/order_requirements/item/organs
	available_requirements = list(
		list(
			"name" = "Lungs",
			"items" = list(
				list("name" = "Lungs", "type" = /obj/item/organ/internal/lungs, "amount" = 1)
			),
			"cost" = 150,
			"desc" = "Пара лёгких"
		)
	)

/datum/order_requirements/item/medical
	available_requirements = list(
		list(
			"name" = "Scalpel",
			"items" = list(
				list("name" = "Scalpel", "type" = /obj/item/scalpel, "amount" = 1)
			),
			"cost" = 60,
			"desc" = "Хирургический скальпель"
		)
	)

/datum/order_requirements/item/light
	available_requirements = list(
		list(
			"name" = "Baton",
			"items" = list(
				list("name" = "Baton", "type" = /obj/item/melee/baton, "amount" = 1)
			),
			"cost" = 150,
			"desc" = "Полицейская дубинка"
		)
	)

/datum/order_requirements/item/constant/id_cards
	available_requirements = list(
		list(
			"name" = "Command IDs",
			"items" = list(
				list("name" = "ID Card", "type" = /obj/item/card/id, "amount" = 1)
			),
			"cost" = 50,
			"desc" = "ID-карта командования"
		)
	)

/datum/smuggler_order/constant/blunts
    order_type = ORDER_CONSTANT
    requirements_type = /datum/order_requirements/item/constant/blunts

/datum/smuggler_order/constant/id_cards
    order_type = ORDER_CONSTANT
    requirements_type = /datum/order_requirements/item/constant/id_cards
