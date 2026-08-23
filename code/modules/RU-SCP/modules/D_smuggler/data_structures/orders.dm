#define ORDER_RENEWABLE "order_renewable"
#define ORDER_UNIQUE "order_unique"
#define ORDER_CONSTANT "order_constant"

#define ORDER_TYPE_RESOURCES "/datum/order_requirements/stack/resources"
#define ORDER_TYPE_COOKING "/datum/order_requirements/item/cooking"
#define ORDER_TYPE_ITEM "/datum/order_requirements/item/light"
#define ORDER_TYPE_BOTANY "/datum/order_requirements/item/botany"
#define ORDER_TYPE_ORGAN "/datum/order_requirements/item/organs"
#define ORDER_TYPE_WEAPON "/datum/order_requirements/item/weapon"


GLOBAL_LIST_INIT(orders_renewable, list(
	ORDER_TYPE_RESOURCES = 30,
	ORDER_TYPE_COOKING = 20,
	ORDER_TYPE_BOTANY = 30
	))

GLOBAL_LIST_INIT(orders_unique, list(
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

/datum/smuggler_order/New(o_type, req_type)
	. = ..()
	if(o_type)
		order_type = o_type
	generate(req_type)

/datum/smuggler_order/proc/generate(req_type)
	if(order_type == ORDER_CONSTANT)
		requirements = new requirements_type()
	else
		var/selected_type
		if(req_type && order_type == ORDER_RENEWABLE)
			selected_type = req_type
		else
			var/req = GLOB.orders_req[order_type]
			selected_type = pickweight(req)
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
	var/list/checked_items = check_items(ex_items)
	if(!checked_items)
		return 0

	var/payout = calculate_payout(checked_items)

	clear_checked(checked_items, ex_items)

	return payout

/datum/order_requirements/item/proc/clear_checked(list/checked_items, list/ex_items)
	PRIVATE_PROC(TRUE)
	for(var/list/group in checked_items)
		for(var/obj/item/I in group)
			ex_items.Remove(I)
			qdel(I)

/datum/order_requirements/item/proc/check_items(list/ex_items)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/list)
	var/list/return_list = list()

	for(var/list/group in items)
		var/list/items_group = get_items_group(group, ex_items)
		if(!items_group || length(items_group) <= 0)
			return FALSE

		return_list[++return_list.len] = items_group

	return return_list

//group format: list("type" = ... , "amount" = ...)
/datum/order_requirements/item/proc/get_items_group(list/group, list/ex_items)
	PRIVATE_PROC(TRUE)
	var/list/return_list = list()
	var/amount = group["amount"]

	for(var/obj/item/I in ex_items)
		if(check_item(I, group["type"]))

			return_list.Add(I)
			group.Remove(I)

			if(return_list.len == amount)
				break

	if(return_list.len < amount)
		return null

	return return_list

/datum/order_requirements/item/botany/check_item(obj/item, item_type)
	if(istype(item, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/G = item
		if(G.plantname == GROWN_TOBACO)
			if(G.dry)
				return TRUE
		return is_grown(item, list(item_type))
	if(istype(item, /obj/item/reagent_containers/food/snacks/meat))
		return TRUE

/datum/order_requirements/item/organs/check_item(obj/item/I, item_type)
	. = ..()
	if(istype(I, item_type))
		var/obj/item/organ/internal/O = I
		if(O.status & ORGAN_DEAD)
			return FALSE
		else
			return TRUE


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
			ex_items.Remove(S)
			qdel(S)
		else
			S.amount -= deduct_amt

	return payout


/datum/order_requirements/item/constant/id_cards
	var/list/tier_bonuses = list(50, 70, 100, 200, 400)

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
	for(var/list/department in GLOB.ID_access)
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
			for(var/list/department in GLOB.ID_access)
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
				list("name" = "Steel", "type" = /obj/item/stack/material/steel, "amount" = 30)
			),
			"cost" = 100,
			"desc" = "30 листов стали"
		),
				list(
			"name" = "gold",
			"items" = list(
				list("name" = "Gold", "type" = /obj/item/stack/material/gold, "amount" = 10)
			),
			"cost" = 60,
			"desc" = "10 слитков золота"
		),
				list(
			"name" = "Plasteel",
			"items" = list(
				list("name" = "Plasteel", "type" = /obj/item/stack/material/plasteel, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 листов пластали"
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
			"name" = "Самокрутки",
			"items" = list(
				list("name" = "Blunt", "type" = /obj/item/clothing/mask/smokable/cigarette/blunt, "amount" = 2)
			),
			"cost" = 8
		)
	)

/datum/order_requirements/item/botany
	available_requirements = list(
		list(
			"name" = "Картошка",
			"items" = list(
				list("name" = "Potato", "type" = GROWN_POTATO, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 картофелин"
		),
		list(
			"name" = "Морковь",
			"items" = list(
				list("name" = "Carrot", "type" = GROWN_CARROT, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 морковок"
		),
		list(
			"name" = "Капуста",
			"items" = list(
				list("name" = "Cabbage", "type" = GROWN_CABAGGE, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 кочанов капусты"
		),
		list(
			"name" = "Томаты",
			"items" = list(
				list("name" = "Tomato", "type" = GROWN_TOMATO, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 томатов"
		),
		list(
			"name" = "Баклажаны",
			"items" = list(
				list("name" = "Eggplant", "type" = GROWN_EGGPLANT, "amount" = 20)
			),
			"cost" = 100,
			"desc" = "20 баклажанов"
		),
		list(
			"name" = "Табак сушеный",
			"items" = list(
				list("name" = "Tobaco", "type" = GROWN_TOBACO, "amount" = 15)
			),
			"cost" = 100,
			"desc" = "15 сушеного табака"
		),
		list(
			"name" = "Мясо",
			"items" = list(
				list("name" = "Meat", "type" = /obj/item/reagent_containers/food/snacks/meat, "amount" = 5)
			),
			"cost" = 90,
			"desc" = "5 кусков мяса"
		)
	)

/datum/order_requirements/item/cooking
	available_requirements = list(
		list(
			"name" = "Баклажаны с сыром",
			"items" = list(
				list("name" = "Eggplant with cheese", "type" = /obj/item/reagent_containers/food/snacks/eggplantparm, "amount" = 3)
			),
			"cost" = 70
		),
		list(
			"name" = "Суп",
			"items" = list(
				list("name" = "Meatball soup", "type" = /obj/item/reagent_containers/food/snacks/meatballsoup, "amount" = 2)
			),
			"cost" = 70
		),
		list(
			"name" = "Омлет",
			"items" = list(
				list("name" = "Omelette", "type" = /obj/item/reagent_containers/food/snacks/omelette, "amount" = 3)
			),
			"cost" = 70
		),
		list(
			"name" = "Печенья",
			"items" = list(
				list("name" = "Cookie", "type" = /obj/item/reagent_containers/food/snacks/cookie, "amount" = 10)
			),
			"cost" = 100
		),
		list(
			"name" = "Мясной хлеб",
			"items" = list(
				list("name" = "Meatbread", "type" = /obj/item/reagent_containers/food/snacks/sliceable/meatbread, "amount" = 1)
			),
			"cost" = 70
		),
		list(
			"name" = "Пицца",
			"items" = list(
				list("name" = "Pizza", "type" = /obj/item/reagent_containers/food/snacks/sliceable/pizza, "amount" = 2)
			),
			"cost" = 70
		),
		list(
			"name" = "Сэндвич",
			"items" = list(
				list("name" = "Sandwich", "type" = /obj/item/reagent_containers/food/snacks/sandwich, "amount" = 2)
			),
			"cost" = 70
		),
		list(
			"name" = "Рагу",
			"items" = list(
				list("name" = "Stew", "type" = /obj/item/reagent_containers/food/snacks/stew, "amount" = 1)
			),
			"cost" = 70
		)
	)

/datum/order_requirements/item/organs
	available_requirements = list(
		list(
			"name" = "Легкие",
			"items" = list(
				list("name" = "Lungs", "type" = /obj/item/organ/internal/lungs, "amount" = 1)
			),
			"cost" = 110,
			"desc" = "Гнилое не принимаем"
		),
		list(
			"name" = "Печень",
			"items" = list(
				list("name" = "Liver", "type" = /obj/item/organ/internal/liver, "amount" = 1)
			),
			"cost" = 110,
			"desc" = "Гнилое не принимаем"
		),
		list(
			"name" = "Сердце",
			"items" = list(
				list("name" = "Heart", "type" = /obj/item/organ/internal/heart, "amount" = 1)
			),
			"cost" = 140,
			"desc" = "Гнилое не принимаем"
		),
		list(
			"name" = "Глаза",
			"items" = list(
				list("name" = "Eyes", "type" = /obj/item/organ/internal/eyes, "amount" = 1)
			),
			"cost" = 100,
			"desc" = "Гнилое не принимаем"
		),
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
			"desc" = "Если есть больший доступ, то цены повышаются"
		)
	)

/datum/smuggler_order/constant/blunts
	order_type = ORDER_CONSTANT
	requirements_type = /datum/order_requirements/item/constant/blunts

/datum/smuggler_order/constant/id_cards
	order_type = ORDER_CONSTANT
	requirements_type = /datum/order_requirements/item/constant/id_cards
