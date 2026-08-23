/obj/item/zipgunframe_new
	name = "zip gun frame"
	desc = "A half-finished zip gun."
	icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	icon_state = "zipgun_frame0"
	item_state = "zipgun-solid"

/decl/crafting_stage/new_pipe
	completion_trigger_type = /obj/item/zipgun_tube

/decl/crafting_stage/new_pipe/zipgun_new
	begins_with_object_type = /obj/item/zipgunframe_new
	item_desc = "A half-built zipgun with a barrel loosely fitted to the stock."
	item_icon_state = "zipgun_frame1"
	item_icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	progress_message = "You fit the pipe into the zipgun as a crude barrel."
	next_stages = list(/decl/crafting_stage/screwdriver/zipgun_new)

/decl/crafting_stage/screwdriver/zipgun_new
	progress_message = "You secure the trigger assembly and finish off the zipgun."
	product = /obj/item/gun/projectile/zipgun

/obj/item/clothing/mask/smokable/cigarette/blunt
	name = "Blunt"
	desc = ""
	icon_state = "cigaoff"

/obj/item/clothing/mask/smokable/cigarette/blunt/on_update_icon()
	..()
	cut_overlays()
	if(lit)
		add_overlay(overlay_image(icon, "cigaon", flags=RESET_COLOR))

/decl/crafting_stage/dried_plant/tobacco/blunt_craft
	begins_with_object_type = /obj/item/paper
	item_desc = "Paper with a minced tobaco"
	item_icon_state = "blunt_craft"
	item_icon = 'code/modules/RU-SCP/icons/zipgun_new.dmi'
	progress_message = "You crumble the dried tobacco over the paper."
	next_stages = list(/decl/crafting_stage/hand/blunt_craft)

/decl/crafting_stage/hand/blunt_craft
	progress_message = "You roll the paper up into a blunt."
	product = /obj/item/clothing/mask/smokable/cigarette/blunt
