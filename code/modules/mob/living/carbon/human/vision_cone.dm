/////////////VISION CONE///////////////
//Vision cone code. originally by Matt and Honkertron, rewritten by Chaoko99. This vision cone code allows for mobs and/or items to blocked out from a players field of vision.
//It makes use of planes and alpha masks only possible in 513 and above. Look for fov and fov_mask vars to see how it works.
///////////////////////////////////////

//"Made specially for Otuska"
// - Honker

// Optimized by Kachnov

// "Poshel nahuy, Otuska!"
// Rest in Peace, Honker. You will always be in our hearts.
// Replaced with IS12's implementation authored by Chaoko99.
// ~Tsurupeta

//Defines.
#define OPPOSITE_DIR(D) turn(D, 180)

/atom/proc/InCone(atom/center, dir = NORTH)
	if(!get_dist(center, src))
		return FALSE

	var/d = get_dir(center, src)
	var/dx = x - center.x
	var/dy = y - center.y

	if(!d || d == dir)
		return TRUE
	else if(dir & (dir-1)) // Diagonal direction already
		return (d & ~dir) ? FALSE : TRUE
	else if(!(d & dir))
		return FALSE

	// Calculate angle properly for widescreen support
	var/angle = arctan(abs(dy), abs(dx))
	var/half_cone = 45 // 90 degree total FOV

	switch(dir)
		if(NORTH, SOUTH)
			angle = arctan(abs(dx), abs(dy))

	return (angle <= half_cone)

/mob/dead/InCone(mob/center, dir = NORTH)
	return FALSE

/mob/living/InCone(mob/center, dir = NORTH)
	. = ..()

	for (var/grab in grabbed_by)
		var/obj/item/grab/G = grab
		if (G.assailant == center)
			return FALSE
	return .

/proc/cone(atom/center, dir = NORTH, list/L, typecheck = /atom)
	. = list()
	for(var/atom in L)
		var/atom/A = atom
		if (typecheck == /atom || istype(A, typecheck))
			if(A.InCone(center, dir))
				. += A

/mob/proc/update_cone_size()
	if(!isliving(src))
		return
	var/mob/living/L = src
	if(!L.client)
		return
	if(L.fov)
		L.fov.update_size(L.client.view)
	if(L.fov_mask)
		L.fov_mask.update_size(L.client.view)

/mob/living/proc/update_vision_cone()
	if(!client) //This doesn't actually hide shit from clientless mobs, so just keep them from running this.
		return
	check_fov()
	if(fov)
		fov.dir = dir
	if(fov_mask)
		fov_mask.dir = dir

/mob/living/proc/SetFov(show)
	if(!show)
		hide_cone()
	else
		show_cone()

/mob/living/proc/check_fov()
	if(!client)
		return

	if(resting || lying || (client && client.eye != client.mob))
		fov.alpha = 0
		fov_mask.alpha = 0
		return
	else if(usefov)
		show_cone()
	else
		hide_cone()

//Making these generic procs so you can call them anywhere.
/mob/living/proc/show_cone()
	if(fov)
		fov.alpha = 255
		usefov = TRUE
		fov_mask.alpha = 255

/mob/living/proc/hide_cone()
	if(fov)
		fov.alpha = 0
		usefov = FALSE
		fov_mask.alpha = 0
