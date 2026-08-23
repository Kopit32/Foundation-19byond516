/obj/item/skill_book
	name = "Guide book"
	desc = "Boring book"
	icon_state = "nothing"
	var/skill
	var/max_skill = SKILL_TRAINED

/obj/item/skill_book/attack_self(mob/user)
	if(!user)
		return
	if(user.skill_check(skill, max_skill))
		to_chat(user, SPAN_WARNING("You cannot get anything new from this book"))
		return
	if(do_after(user, 1 MINUTE, src))
		user.skillset.skill_list[skill] += 1
		qdel(src)

/obj/item/skill_book/construction
	name = "Construction book"
	skill = SKILL_CONSTRUCTION

/obj/item/skill_book/melee
	name = "Melee book"
	skill = SKILL_COMBAT

/obj/item/skill_book/electricity
	name = "Electricity book"
	skill = SKILL_ELECTRICAL

/obj/item/clothing/head/smuggler_cap
	name = "Black cap"
	desc = "Black cap"
	icon_state = "kotli"

/obj/item/clothing/glasses/smuggler_glasses
	name = "Glasses"
	desc = "Glasses"
	icon_state = "kotli_ochki"

/obj/item/zipgun_tube
	name = "tube"
	desc = "tube"
	icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	icon_state = "tube"
	force = 10
	base_parry_chance = 15

/obj/item/zipgun_tube/play_drop_sound()
	playsound(src, 'sounds/effects/truba-upala.ogg', 50, 1)

/obj/item/gun/projectile/zipgun
	name = "zip gun"
	desc = "Little more than a barrel, handle, and firing mechanism."
	icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	icon_state = "zipgun"
	item_state = "sawnshotgun"
	handle_casings = CYCLE_CASINGS
	load_method = SINGLE_CASING
	max_shells = 1
	has_safety = FALSE
	w_class = ITEM_SIZE_NORMAL
	caliber = "9mm"
	health_max = 100

/obj/item/gun/projectile/zipgun/toggle_safety(mob/user)
	to_chat(user, SPAN_WARNING("There's no safety on \the [src]!"))

/obj/item/gun/projectile/handle_post_fire()
	..()
	if(prob(30))
		damage_health(25)
/obj/item/gun/projectile/handle_death_change()
	explosion(get_turf(src), 0, 0, 0, 2)
	qdel(src)

/obj/item/phone
	name = "phone"
	desc = ""
	icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	icon_state = "phone"

/obj/effect/random_tool
	var/list/tool_pool = list(/obj/item/screwdriver = 15, /obj/item/wrench = 15, /obj/item/weldingtool = 15, /obj/item/wirecutters = 15, /obj/item/crowbar = 15, /obj/item/device/multitool = 10)
/obj/effect/random_tool/Initialize()
	. = ..()
	var/tool_type = pickweight(tool_pool)
	new tool_type(get_turf(src))
	qdel(src)

/obj/item/storage/box/lcz_guard_kit
	name = "security outfit box"
	desc = "A battered supply box."
	icon_state = "box"
	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_LARGE   // влезают броник и ремень
	storage_slots = 12
	max_storage_space = 100
	startswith = list(
		/obj/item/clothing/under/rank/security/lcz,
		/obj/item/clothing/shoes/dutyboots,
		/obj/item/clothing/suit/armor/vest/scp/medarmor,
		/obj/item/clothing/head/helmet/scp/security,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/glasses/sunglasses/sechud/goggles,
		/obj/item/clothing/gloves/thick/swat/lcz,
		/obj/item/device/radio/headset/headset_sec_lcz,
		/obj/item/card/id/junseclvl2lcz/forged,
		/obj/item/storage/belt/holster/security,
		/obj/item/melee/telebaton,
		/obj/item/handcuffs
	)

/obj/item/storage/box/lcz_guard_kit/open(mob/user)
	if(max_storage_space > DEFAULT_BOX_STORAGE)
		max_w_class = ITEM_SIZE_NORMAL
		storage_slots = 7
		max_storage_space = DEFAULT_BOX_STORAGE
	. = ..()

/obj/item/card/id/junseclvl2lcz/forged
	desc = "A dark purple ID. The laminate looks slightly loose, as if someone had opened it."
	var/name_changed = FALSE

/obj/item/card/id/junseclvl2lcz/forged/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/pen))
		if(name_changed)
			to_chat(user, SPAN_WARNING("The laminate is sealed tight. Nothing can be changed anymore."))
			return
		var/new_name = sanitizeName(input(user, "What name should be written on this card?", "Forging an ID", registered_name) as null|text, allow_numbers = TRUE)
		if(!new_name || !istype(user) || user.incapacitated() || !I.loc || QDELETED(src))
			return
		registered_name = new_name
		SetName("[registered_name]'s ID Card ([assignment])")
		name_changed = TRUE
		user.visible_message(SPAN_NOTICE("\The [user] carefully writes a new name on \the [src] and seals the laminate."))
		to_chat(user, SPAN_NOTICE("You write '[new_name]' onto the card. The laminate seals it for good."))
		return
	return ..()
