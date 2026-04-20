/obj/item/reagent_containers/glass/bottle/scp610
	name = "SCP-610"
	desc = "A sealed container containing a highly contagious fleshy infection. Extremely dangerous."
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "scp012"



// ============================================================================
// SCP-610 FLESH MOBS
// ============================================================================
/mob/living/simple_animal/hostile/scp610_fleshman
	name = "SCP-610 Fleshman"
	desc = "A fleshman created by SCP-610. Dangerous and fast."
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "flesh610man"
	// icon_living = "zombie"
	// icon_dead = "zombie_dead"
	// icon_gib = "zombie_gib"

/mob/living/simple_animal/melee/scp610_flesh_walker
	name = "SCP-610 Fleshwalker"
	desc = "A fleshwalker created by SCP-610. Very dangerous with spiky legs, oh run."
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "flesh_walker"
	// icon_living = "zombie"
	// icon_dead = "zombie_dead"
	// icon_gib = "zombie_gib"

/mob/living/simple_animal/hostile/scp610_half_infested
	name = "SCP-610 Infested"
	desc = "A human, infested with SCP-610, on his way to evolve..."
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "example_human_meat_bubble"

// ============================================================================
// SCP-610 FLESH STRUCTURES
// ============================================================================

/obj/structure/flesh_structure
	name = "flesh structure"
	desc = "doing some stuff"
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "flesh_stolb"

/obj/structure/flesh_structure/flesh_generator
	name = "flesh generator"
	desc = "healing, powering..."
	icon_state = "flesh_generator"

/obj/structure/flesh_structure/flesh_cable_vert
	name = "flesh cable"
	desc = "some essence or power or something is coming through these flesh ways..."
	icon_state = "flesh_cable_vertical"

/obj/structure/flesh_structure/flesh_cable_horz
	name = "flesh cable"
	desc = "some essence or power or something is coming through these flesh ways..."
	icon_state = "flesh_cable_horiz"

/obj/structure/flesh_structure/flesh_cable_center
	name = "flesh cable"
	desc = "some essence or power or something is coming through these flesh ways..."
	icon_state = "flesh_cable_center"


// ============================================================================
// SCP-610 FLESH TURFS
// ============================================================================

/turf/flesh
	name = "flesh turf"
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "flesh_turf_creep"

/turf/flesh/node
	name = "flesh turf"
	icon = 'icons/SCP/scp-610.dmi'
	icon_state = "flesh_turf_node"
