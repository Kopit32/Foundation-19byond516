/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/observer/ghost/G = usr
	var/list/A = list()
	A |= GLOB.living_mob_list_
	A |= GLOB.player_list
	var/mob/fh = tgui_input_list(G, "Choose a player to orbit", "Orbit", A)
	if(istype(fh))
		G.follow(fh)
	else if(isnull(fh))
		return
	else
		var/turf/T = get_turf(fh)
		G.ghost_to_turf(T)

/atom/movable/screen/ghost/become_scp
	name = "Become an SCP"
	icon_state = "become_scp"

/atom/movable/screen/ghost/become_scp/Click()
	var/mob/observer/ghost/G = usr
	if(!istype(G))
		return
	G?.become_scp()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/observer/ghost/G = usr
	if(G.can_reenter_corpse)
		G.reenter_corpse()
	else
		to_chat(G, SPAN_WARNING("You can't re-enter your corpse!"))

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/observer/ghost/G = usr
	var/A = tgui_input_list(G, "Teleport", "Teleport to an Area", area_repository.get_areas_by_z_level())
	if(A != "Cancel")
		G.dead_tele(A)

/atom/movable/screen/ghost/move_up
	name = "Move Up"
	icon_state = "move_up"
	screen_loc = ui_ghost_move_up

/atom/movable/screen/ghost/move_up/Click(location, control, params)
	var/mob/M = usr
	M.up()

/atom/movable/screen/ghost/move_down
	name = "Move Down"
	icon_state = "move_down"
	screen_loc = ui_ghost_move_down

/atom/movable/screen/ghost/move_down/Click(location, control, params)
	var/mob/M = usr
	M.down()
