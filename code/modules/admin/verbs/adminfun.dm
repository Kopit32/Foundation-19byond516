/client/proc/smite(mob/living/target as mob)
	set category = "Fun"
	set name = "Smite"
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		return

	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in subtypesof(/datum/smite)

	if(QDELETED(target) || !punishment)
		return

	var/datum/smite/smite = new punishment
	var/configuration_success = smite.configure(usr)
	if (configuration_success == FALSE)
		return
	smite.effect(src, target)


/client/proc/global_flick_light()
	set popup_menu = FALSE
	set category = "Fun"
	set name = "Global flick light"
	set desc = "Global flick light like dancepoll."

	if(!check_rights(R_FUN)) return

	SSstatistics.add_field_details("admin_verb","FLG") //Unique identifier for global flick

	switch(alert("Are you sure to flick ALL lights?.",,"Yes","No"))
		if("No")
			return
		else
			log_and_message_staff("[src] flicks ALL lights.")
			for(var/obj/machinery/light/L in world)
				L.flicker(rand(10, 20))

/client/proc/local_flick_light()
	set popup_menu = FALSE
	set category = "Fun"
	set name = "Local flick light"
	set desc = "Local flick light like dancepoll."

	if(!check_rights(R_FUN)) return

	SSstatistics.add_field_details("admin_verb","FLL") //Unique identifier for local flick

	log_and_message_staff("[src] flicks local lights.")

	var/area/A = get_area(usr)
	for(var/obj/machinery/light/L in A)
		L.flicker(rand(10, 20))
