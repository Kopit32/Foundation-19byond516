

#define ORDERS "orders"
#define PURSHASE "purshase"
#define GOALS "goals"



/datum/smuggler_tgui
	var/obj/structure/smuggler_stash/connected_smuggler_stash
	var/datum/component/smuggler/owner_component

	var/active_tab = PURCHASE_SECTION_LIGHT
	var/left_tab = ORDERS
	var/list/cached_data = list(
		ORDERS = list(ORDER_RENEWABLE = list(), ORDER_UNIQUE = list(), ORDER_CONSTANT = list()),
		PURSHASE = list(PURCHASE_SECTION_LIGHT = list(), PURCHASE_SECTION_MEDIUM = list(), PURCHASE_SECTION_HIGH = list()),
		GOALS = list())
	var/shop_need_update = TRUE
	var/goals_need_update = TRUE

	var/next_reroll_time = 0


/datum/smuggler_tgui/New(datum/component/smuggler/comp)
	. = ..()
	src.owner_component = comp
	refresh_cash()



/datum/smuggler_tgui/tgui_interact(mob/user, datum/tgui/ui, stash)
	if(!user.GetComponent(/datum/component/smuggler))
		return
	if(stash)
		connected_smuggler_stash = stash
	connected_smuggler_stash.state = OPEN
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smuggler", "stash", connected_smuggler_stash.name)
		ui.open()



/datum/smuggler_tgui/tgui_close(mob/user)
	. = ..()
	connected_smuggler_stash.state = CLOSED
	connected_smuggler_stash.update_icon()
	connected_smuggler_stash = null



/datum/smuggler_tgui/tgui_host()
	return connected_smuggler_stash



/datum/smuggler_tgui/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return FALSE
	if(!H.GetComponent(/datum/component/smuggler))
		return FALSE

	var/result

	switch(action)
		if("select_tab")
			var/tab = params["tab"]
			if(tab in list(PURCHASE_SECTION_LIGHT, PURCHASE_SECTION_MEDIUM, PURCHASE_SECTION_HIGH))
				active_tab = tab
				return TRUE

		if("withdraw")
			var/amount = tgui_input_number(usr, "Введите количество денег", "Вывод средств", max_value = owner_component.cash_amount)
			if(!amount || amount <= 0)
				return FALSE
			result = money_withdraw(amount, get_turf(connected_smuggler_stash))

		if("fulfill")
			result = fulfill_orders(get_turf(connected_smuggler_stash))

		if("buy")
			result = buy_items(params, H)
		if("deposit")
			result = money_deposit(get_turf(connected_smuggler_stash))
		if("fulfill_goal")
			result = try_fulfill_goal(get_turf(connected_smuggler_stash), params["chosen_goal"])
			if(result)
				goals_need_update = TRUE
				shop_need_update = TRUE
				refresh_cash()
		if("reroll")
			result = reroll_order(params["id"])
		if("select_left_tab")
			var/tab = params["tab"]
			if(tab in list(ORDERS, GOALS))
				left_tab = tab
				return TRUE
		if("unlock_tier")
			result = unlock_tier(params["tier"])
	return result



/datum/smuggler_tgui/tgui_data(mob/user)

	if(!user.GetComponent(/datum/component/smuggler))
		return
	var/list/data = list()
	data["credits"] = owner_component.cash_amount
	data["active_tab"] = active_tab

	data["constant_contracts"] = cached_data[ORDERS][ORDER_CONSTANT]
	data["unique_contracts"] = cached_data[ORDERS][ORDER_UNIQUE]
	data["renewable_contracts"] = cached_data[ORDERS][ORDER_RENEWABLE]

	var/list/shop = list()
	shop["light"] = cached_data[PURSHASE][PURCHASE_SECTION_LIGHT]
	shop["medium"] = cached_data[PURSHASE][PURCHASE_SECTION_MEDIUM]
	shop["high"] = cached_data[PURSHASE][PURCHASE_SECTION_HIGH]
	data["shop_items"] = shop
	data["reroll_cooldown"] = max(0, round((next_reroll_time - world.time) / 10))
	data["unlocked_tiers"] = owner_component.unlocked_tiers
	data["tier_unlock_costs"] = owner_component.tier_unlock_costs

	shop["goals"] = cached_data[GOALS]
	data["left_tab"] = left_tab
	return data





/datum/smuggler_tgui/proc/refresh_cash()
	if(shop_need_update)
		refresh_shop()
	if(goals_need_update)
		refresh_goals()
	refresh_orders()



/datum/smuggler_tgui/proc/refresh_shop()
	var/list/raw_data = GLOB.global_shop_items

	cached_data[PURSHASE] = list(PURCHASE_SECTION_LIGHT = list(), PURCHASE_SECTION_MEDIUM = list(), PURCHASE_SECTION_HIGH = list())
	for(var/list/item_data in raw_data)
		var/item_tier = item_data["tier"]
		var/item_name = item_data["name"]
		var/goal_type = item_data["goal_type"]
		var/locked = FALSE
		if(goal_type)
			var/datum/goal/G = owner_component.goals[goal_type]
			if(G && !G.done)
				locked = TRUE

		cached_data[PURSHASE][item_tier] += list(
		list(
			"id" = "s_[item_tier]_[item_name]",
			"name" = item_name,
			"tier" = item_tier,
			"cost" = item_data["cost"],
			"items" = get_formatted_items(item_data),
			"goal_type" = goal_type,
			"locked" = locked
			)
		)
	shop_need_update = FALSE


/datum/smuggler_tgui/proc/get_formatted_items(shop_data)
	PRIVATE_PROC(TRUE)
	var/list/raw_items = shop_data["items"]

	var/list/spawn_items = list()
	for(var/type_path in raw_items)
		var/amount = raw_items[type_path]
		spawn_items += list(list(
			"type" = type_path,
			"amount" = amount
		))
	return spawn_items



/datum/smuggler_tgui/proc/refresh_orders()

	for(var/order_type in list(ORDER_RENEWABLE, ORDER_UNIQUE, ORDER_CONSTANT))
		var/list/order_formatted = list()

		for(var/datum/smuggler_order/O in owner_component.orders[order_type])
			var/list/info = O.get_order_info()
			if(!info)
				continue
			var/order_name = info["name"]

			if(info)
				order_formatted += list(
				list(
					"order_type" = O.order_type,
					"id" = "[O.order_type]_[order_name]",
					"name" = order_name,
					"reward" = info["reward"],
					"req" = get_requirements_formatted(info["items"]),
					"desc" = info["desc"]
				))
		cached_data[ORDERS][order_type] = order_formatted


/datum/smuggler_tgui/proc/get_requirements_formatted(list/items_list)
	PRIVATE_PROC(TRUE)
	var/list/parts = list()
	for(var/list/item1 in items_list)
		parts += "[item1["amount"]]x [item1["name"]]"
	return parts

/datum/smuggler_tgui/proc/refresh_goals()

	var/list/goals = owner_component.goals
	var/list/goals_formatted = list()
	for(var/goal_type in goals)
		var/datum/goal/G = goals[goal_type]
		goals_formatted += list(list(
			"goal_type" = goal_type,
			"name" = G.goal_name,
			"done" = G.done,
			"desc" = G.desc,
			"reward" = G.reward
		))
	cached_data[GOALS] = goals_formatted
	goals_need_update = FALSE





/datum/smuggler_tgui/proc/buy_items(list/tgui_params, mob/user)
	var/list/found = find_item_by_id(tgui_params["id"])

	if(!length(found))
		to_chat(user, SPAN_WARNING("Товар не найден."))
		return FALSE
	if(owner_component.cash_amount < found["cost"])
		to_chat(user, SPAN_WARNING("Недостаточно валюты."))
		return FALSE
	if(!owner_component.unlocked_tiers[found["tier"]])
		to_chat(user, SPAN_WARNING("Эта категория не разблокирована."))
		return FALSE

	var/goal_type = found["goal_type"]
	if(goal_type)
		var/datum/goal/G = owner_component.goals[goal_type]
		if(G && !G.done)
			return FALSE

	owner_component.cash_amount -= found["cost"]
	spawn_purshase_items(found["items"])

	to_chat(user, SPAN_NOTICE("Вы купили '[found["name"]]' за [found["cost"]] валюты."))
	return TRUE


/datum/smuggler_tgui/proc/find_item_by_id(id)
	PRIVATE_PROC(TRUE)
	for(var/purshase_tab in list(PURCHASE_SECTION_LIGHT, PURCHASE_SECTION_MEDIUM, PURCHASE_SECTION_HIGH))

		for(var/list/I in cached_data[PURSHASE][purshase_tab])

			if(I["id"] == id)
				return I


/datum/smuggler_tgui/proc/spawn_purshase_items(list/items)
	PRIVATE_PROC(TRUE)
	for(var/list/spawn_item in items)

		var/spawn_type = text2path(spawn_item["type"])
		var/amount = spawn_item["amount"]
		if(!spawn_type)
			log_debug("Smuggler shop: unknown item type [spawn_item["type"]]")
			continue
		for(var/i = 1 to amount)
			new spawn_type(get_turf(connected_smuggler_stash))



/datum/smuggler_tgui/proc/fulfill_orders(turf/T)
	var/list/items_to_check = get_items_on_stash(owner_component, T)
	var/mob/living/carbon/human/H = owner_component.parent
	if(!items_to_check)
		return FALSE

	var/total_amount = 0
	for(var/order_type in list(ORDER_RENEWABLE, ORDER_UNIQUE, ORDER_CONSTANT))

		for(var/datum/smuggler_order/O in owner_component.orders[order_type])

			var/payout = O.try_complete(items_to_check)
			if(payout > 0)
				total_amount += payout

				to_chat(H, SPAN_NOTICE("Заказ '[O.requirements.name]' выполнен! Получено [payout] валюты."))
				switch(order_type)
					if(ORDER_RENEWABLE)
						replace_order(O, TRUE)
					if(ORDER_UNIQUE)
						replace_order(O, FALSE)

	owner_component.cash_amount += total_amount

	if(total_amount <= 0)
		to_chat(H, SPAN_INFO("Ни один заказ не может быть выполнен с текущими предметами."))

	refresh_cash()
	return TRUE


/datum/smuggler_tgui/proc/replace_order(datum/smuggler_order/O, same_type_replace)
	if(!O)
		return
	var/req_type
	if(same_type_replace)
		req_type = O.requirements.type
	owner_component.orders[O.order_type] += new /datum/smuggler_order(O.order_type, req_type)
	owner_component.orders[O.order_type] -= O
	qdel(O)


/datum/smuggler_tgui/proc/money_withdraw(amount, turf/T)
	owner_component.withdraw_money(amount, T)
	return TRUE



/datum/smuggler_tgui/proc/money_deposit(turf/T)
	owner_component.deposit_money(T)
	return TRUE

/datum/smuggler_tgui/proc/try_fulfill_goal(turf/T, goal_type)
	if(!goal_type)
		return FALSE
	var/datum/goal/goal_to_check = owner_component.goals[goal_type]
	if(!goal_to_check || goal_to_check.done)
		return FALSE
	var/list/items_to_check = get_items_on_stash(owner_component, T)
	if(!items_to_check)
		return FALSE
	if(!goal_to_check.check_condition(items_to_check))
		return FALSE
	owner_component.cash_amount += goal_to_check.reward
	to_chat(owner_component.parent, SPAN_NOTICE("Цель '[goal_to_check.goal_name]' выполнена! Получено [goal_to_check.reward] валюты."))
	return TRUE


/datum/smuggler_tgui/proc/reroll_order(id)
	if(world.time < next_reroll_time)
		to_chat(usr, SPAN_WARNING("Замена доступна через [round((next_reroll_time - world.time) / 10)] сек."))
		return FALSE

	for(var/order_type in list(ORDER_RENEWABLE, ORDER_UNIQUE))
		var/list/orders_list = owner_component.orders[order_type]
		for(var/i in 1 to length(orders_list))
			var/datum/smuggler_order/O = orders_list[i]
			var/list/info = O.get_order_info()
			if(!length(info) || "[O.order_type]_[info["name"]]" != id)
				continue

			var/same_order_type = FALSE
			if(order_type == ORDER_RENEWABLE)
				same_order_type = TRUE
			replace_order(O, same_order_type)
			next_reroll_time = world.time + REROLL_COOLDOWN
			refresh_cash()
			return TRUE

	return FALSE

/datum/smuggler_tgui/proc/unlock_tier(tier)
	var/cost = owner_component.tier_unlock_costs[tier]
	if(!cost || owner_component.unlocked_tiers[tier])
		return FALSE
	if(owner_component.cash_amount < cost)
		to_chat(usr, SPAN_WARNING("Недостаточно валюты для разблокировки."))
		return FALSE
	owner_component.cash_amount -= cost
	owner_component.unlocked_tiers[tier] = TRUE
	return TRUE

/datum/smuggler_tgui/proc/get_items_on_stash(datum/component/smuggler/S, turf/T)
	var/list/items_to_check = T.contents - connected_smuggler_stash
	var/mob/living/carbon/human/H = S.parent
	if(!length(items_to_check))
		to_chat(H, SPAN_WARNING("На схроне нет предметов"))
		return FALSE
	return items_to_check
