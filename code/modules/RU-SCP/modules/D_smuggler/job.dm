/datum/job/classd/d_smuggler
	title = "Барыга"
	total_positions = 1
	spawn_positions = 2
	outfit_type = /decl/hierarchy/outfit/job/civ/classd/smuggler
	min_skill = list(
		SKILL_FINANCE = SKILL_TRAINED
	)

/datum/job/classd/d_smuggler/equip(mob/living/carbon/human/H)
	. = ..()
	H.AddComponent(/datum/component/smuggler)

/decl/hierarchy/outfit/job/civ/classd/smuggler
	head = /obj/item/clothing/head/smuggler_cap
	glasses = /obj/item/clothing/glasses/smuggler_glasses
	//l_pocket = /obj/item/paper/smuggler_guide
	r_pocket = /obj/item/material/kitchen/utensil/spoon
