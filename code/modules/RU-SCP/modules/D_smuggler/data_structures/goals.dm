GLOBAL_LIST_INIT(goals_list, list(/datum/goal/id_card/security))

/datum/goal
	var/goal_name
	var/done = FALSE
	var/desc
	var/reward

/datum/goal/proc/check_condition(list/checking)
	if(!length(checking))
		return FALSE
	done = TRUE
	return done

/datum/goal/id_card
	var/list/minimal_access = list()
/datum/goal/id_card/check_condition(list/checking)
	if(!length(checking))
		return FALSE
	for(var/obj/item/card/id/I in checking)
		for(var/access in I.access)
			if(access in minimal_access)
				done = TRUE
				break
	return done

/datum/goal/item
	var/list/avaiable_item = list()
	var/need_all = FALSE

/datum/goal/item/check_condition(list/checking)
	if(!length(checking))
		return FALSE

	var/list/remove_list = list()
	if(need_all)

		for(var/item_path in avaiable_item)
			var/obj/item/I = locate(item_path) in checking
			if(!I)
				return FALSE
			else
				remove_list += I
		QDEL_LAZYLIST(remove_list)
		done = TRUE
		return done

	else

		for(var/item_path in avaiable_item)
			var/obj/item/I = locate(item_path) in checking
			if(I)
				done = TRUE
				qdel(I)
				return done

/datum/goal/id_card/security
	goal_name = "Карта охранника"
	desc = "Просто притащи карту с достаточным доступом. Может тогда достану тебе снарягу охранника"
	minimal_access = list(ACCESS_SECURITY_LVL3, ACCESS_SECURITY_LVL4, ACCESS_SECURITY_LVL5)
	reward = 150

/datum/goal/item/scp
	goal_name = "Аномалия"
	desc = "Любой предмет, свойства которого... Необъяснимы наукой, так сказать. Большего я не могу тебе рассказать. У меня есть некоторые связи. Может быть они тебе помогут"
	avaiable_item = list(/obj/item/rig/light/stealth/scp5000, /obj/item/rig/light/stealth/scp5000/working)
	reward = 600

/datum/goal/item/gun
	goal_name = "Огнестрел"
	desc = "Нет я тебе просто так что-то тяжелое не дам. Достань хоть какую-то пушку, тогда и поговорим"
	avaiable_item = list()
	reward = 200

/datum/goal/item/tools
	goal_name = "Самодельные инструменты"
	desc = "Не думай что мне нужен этот мусор. Просто проверяю насколько ты там устроился. Если достанешь, то так уж и быть можешь купить что-нибудь покрепче. Принеси лом, отвертку, ключ и кусачки"
	avaiable_item = list(/obj/item/crowbar/makeshift, /obj/item/screwdriver/makeshift, /obj/item/wrench/makeshift, /obj/item/wirecutters/makeshift)
	need_all = TRUE
	reward = 60
