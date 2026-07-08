/obj/item/skill_book
	name = "Guide book"
	desc = "Boring book"
	icon_state = "nothing"
	var/skill
	var/max_skill = SKILL_TRAINED

/obj/item/skill_book/attack_self(mob/user)
	if(!user)
		return
	if(!user.skill_check(skill, max_skill))
		to_chat(user, SPAN_WARNING("You cannot get anything new from this book"))
		return
	if(do_after(user, 1 MINUTE, src))
		user.skillset.skill_list[skill] += user.skillset.skill_list[skill] + 1
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
