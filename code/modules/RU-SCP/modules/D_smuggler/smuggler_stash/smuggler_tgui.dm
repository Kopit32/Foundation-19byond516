#define PURCHASE_SECTION_LIGHT "light"
#define PURCHASE_SECTION_MEDIUM "medium"
#define PURCHASE_SECTION_HIGH "high"

/datum/smuggler_tgui
	var/obj/structure/smuggler_stash/connected_smuggler_stash
	var/list/orders = list(ORDER_RENEWABLE = list(), ORDER_UNIQUE = list(), ORDER_CONSTANT = list())

	var/active_tab = "light"
	var/list/shop_items_by_tab = list()
	var/shop_json_path = "items_info.json"

	var/list/cached_orders = list()


/datum/smuggler_tgui/New(stash)
	. = ..()

	connected_smuggler_stash = stash

	for(var/I = 1 to MAX_ORDERS)
		orders[ORDER_RENEWABLE] += new /datum/smuggler_order(ORDER_RENEWABLE)
		orders[ORDER_UNIQUE] += new /datum/smuggler_order(ORDER_UNIQUE)
	orders[ORDER_CONSTANT] += new /datum/smuggler_order/constant/blunts()
	orders[ORDER_CONSTANT] += new /datum/smuggler_order/constant/id_cards()
	//load_shop()
	//refresh_order_cache()

/datum/smuggler_tgui/tgui_interact(mob/user, datum/tgui/ui)
	connected_smuggler_stash.state = OPEN
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smuggler", connected_smuggler_stash.name)
		ui.open()

/datum/smuggler_tgui/tgui_close(mob/user)
	. = ..()
	connected_smuggler_stash.state = CLOSED
	connected_smuggler_stash.update_icon()

/datum/smuggler_tgui/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return TRUE

	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return FALSE
	var/datum/component/smuggler/S = H.GetComponent(/datum/component/smuggler)
	if(!S)
		return FALSE

	switch(action)
		if("select_tab")
			var/tab = params["tab"]
			if(tab in list(PURCHASE_SECTION_LIGHT, PURCHASE_SECTION_MEDIUM, PURCHASE_SECTION_HIGH))
				active_tab = tab
				return TRUE

		if("withdraw")
			var/amount = tgui_input_number(usr, "Введите количество денег", "Вывод средств", max_value = S.cash_amount)
			if(!amount || amount <= 0)
				return FALSE
			if(S.cash_amount < amount)
				return FALSE
			var/turf/T = get_turf(connected_smuggler_stash)
			var/obj/item/spacecash/bundle/B = new(T)
			B.worth = amount
			S.cash_amount -= amount
			return TRUE

		if("fulfill")
			var/turf/T = get_turf(connected_smuggler_stash)
			var/list/items_to_check = T.contents - connected_smuggler_stash
			if(!length(items_to_check))
				to_chat(H, SPAN_WARNING("Рядом со схроном нет предметов для сдачи."))
				return FALSE

			var/total_earned = 0
			for(var/otype in list(ORDER_RENEWABLE, ORDER_UNIQUE, ORDER_CONSTANT))
				for(var/datum/smuggler_order/O in orders[otype])
					var/payout = O.try_complete(items_to_check)
					if(payout > 0)
						total_earned += payout
						S.cash_amount += payout
						to_chat(H, SPAN_NOTICE("Заказ '[O.requirements.name]' выполнен! Получено [payout] кредитов."))
						if(otype == ORDER_UNIQUE)
							orders[ORDER_UNIQUE] -= O
							qdel(O)
							orders[ORDER_UNIQUE] += new /datum/smuggler_order(ORDER_UNIQUE)
						if(otype == ORDER_RENEWABLE)
							orders[ORDER_RENEWABLE] -= O
							qdel(O)
							orders[ORDER_RENEWABLE] += new /datum/smuggler_order(ORDER_RENEWABLE)

			if(total_earned > 0)
				to_chat(H, SPAN_NOTICE("Итого заработано: [total_earned] кредитов."))
			else
				to_chat(H, SPAN_INFO("Ни один заказ не может быть выполнен с текущими предметами."))
			refresh_order_cache()
			return TRUE

		if("buy")
			var/item_id = params["id"]
			var/list/found = null
			for(var/tab in list(PURCHASE_SECTION_LIGHT, PURCHASE_SECTION_MEDIUM, PURCHASE_SECTION_HIGH))
				for(var/list/I in shop_items_by_tab[tab])
					if(I["id"] == item_id)
						found = I
						break
				if(found) break

			if(!found)
				to_chat(H, SPAN_WARNING("Товар не найден."))
				return FALSE
			if(S.cash_amount < found["cost"])
				to_chat(H, SPAN_WARNING("Недостаточно кредитов."))
				return FALSE

			S.cash_amount -= found["cost"]
			for(var/list/spawn_item in found["items"])
				var/spawn_type = text2path(spawn_item["type"])
				var/amount = spawn_item["amount"]
				if(!spawn_type)
					log_debug("Smuggler shop: unknown item type [spawn_item["type"]]")
					continue
				for(var/i = 1 to amount)
					new spawn_type(get_turf(src))
			to_chat(H, SPAN_NOTICE("Вы купили '[found["name"]]' за [found["cost"]] кредитов."))
			return TRUE

	return FALSE

/datum/smuggler_tgui/proc/refresh_order_cache()
	cached_orders = list()
	for(var/order_type in list(ORDER_RENEWABLE, ORDER_UNIQUE, ORDER_CONSTANT))
		var/list/contracts = list()
		var/prefix
		switch(order_type)
			if(ORDER_CONSTANT)
				prefix = "c_"
			if(ORDER_UNIQUE)
				prefix = "u_"
			if(ORDER_RENEWABLE)
				prefix = "r_"
			else
				prefix = "o_"
		for(var/i = 1 to length(orders[order_type]))
			var/datum/smuggler_order/O = orders[order_type][i]
			var/list/info = O.get_order_info()
			if(length(info))
				contracts += list(list(
					"id" = "[prefix][i]",
					"name" = info["name"],
					"reward" = info["reward"],
					"req" = 0,//format_req_string(info["items"]),
					"desc" = info["desc"]
				))
		cached_orders[order_type] = contracts

/datum/smuggler_tgui/proc/format_req_string()
	//var/list/parts = list()
	//for(var/list/item1 in items_list)
	//	parts += "[item1["amount"]]x [item1["name"]]"
	return


/datum/smuggler_tgui/tgui_data(mob/user)
	return list()
/*
	var/datum/component/smuggler/S = user.GetComponent(/datum/component/smuggler)
	if(!S)
		return
	. = list()
	.["credits"] = S.cash_amount
	.["active_tab"] = active_tab

	.["constant_contracts"] = cached_orders[ORDER_CONSTANT]
	.["unique_contracts"] = cached_orders[ORDER_UNIQUE]
	.["renewable_contracts"] = cached_orders[ORDER_RENEWABLE]

	var/list/shop = list()
	shop["light"] = 0//shop_items_by_tab[PURCHASE_SECTION_LIGHT]
	shop["medium"] = 0//shop_items_by_tab[PURCHASE_SECTION_MEDIUM]
	shop["high"] = 0//shop_items_by_tab[PURCHASE_SECTION_HIGH]
	.["shop_items"] = shop*/
/*
/datum/smuggler_tgui/proc/load_shop()
	var/list/source_data = GLOB.global_shop_items

	if(!islist(source_data))
		log_world("Smuggler shop: global list 'global_shop_items' not found or invalid!")
		source_data = list()

	shop_items_by_tab = list(
		"[PURCHASE_SECTION_LIGHT]" = list(),
		"[PURCHASE_SECTION_MEDIUM]" = list(),
		"[PURCHASE_SECTION_HIGH]" = list()
	)

	for(var/list/item_data in source_data)
		var/item_tier = lowertext(item_data["tier"])
		var/target_tab

		if(item_tier == "light" || item_tier == lowertext("[PURCHASE_SECTION_LIGHT]"))
			target_tab = PURCHASE_SECTION_LIGHT
		else if(item_tier == "medium" || item_tier == lowertext("[PURCHASE_SECTION_MEDIUM]"))
			target_tab = PURCHASE_SECTION_MEDIUM
		else if(item_tier == "high" || item_tier == lowertext("[PURCHASE_SECTION_HIGH]"))
			target_tab = PURCHASE_SECTION_HIGH
		else
			continue

		var/item_name = item_data["name"]
		var/item_cost = item_data["cost"]
		var/list/raw_items = item_data["items"]

		var/list/spawn_items = list()
		if(islist(raw_items))
			for(var/type_path in raw_items)
				var/amount = raw_items[type_path]
				spawn_items += list(list(
					"type" = type_path,
					"amount" = amount
				))

		shop_items_by_tab[target_tab] += list(list(
			"id" = "s_[target_tab]_[item_name]",
			"name" = item_name,
			"cost" = item_cost,
			"items" = spawn_items
		))
*/
/datum/smuggler_tgui/proc/get_shop_items(tab)
	return shop_items_by_tab[tab] || list()

