/mob/living/simple_animal/hostile/scp1206
	name = "SCP-1206-RU"
	desc = "Small humanoid figure with industrial pipes protruding from its back. Thick grey smoke continuously billows from its body."
	icon = 'icons/SCP/SCP-1206-RU.dmi'
	icon_state = "smoker_man"
	gender = NEUTER
	maxHealth = 250

	var/list/affected_people = list()
	var/active = TRUE

/mob/living/simple_animal/hostile/scp1206/Initialize()
	. = ..()
	ai_holder_type = /datum/ai_holder/simple_animal/melee

/mob/living/simple_animal/hostile/scp1206/Life()
	. = ..()
	if(!active)
		return

	// Simple smoke effect
	for(var/mob/living/L in viewers(3, src))
		if(L == src)
			continue
		if(prob(60))
			L << SPAN_WARNING("You inhale strange grey smoke. Your lungs burn.")

/mob/living/simple_animal/hostile/scp1206/attack_hand(mob/victim)
	if(isliving(victim))
		visible_message(SPAN_WARNING("[src] breathes smoke directly into [victim]'s face!"))
		to_chat(victim, SPAN_USERDANGER("You cannot breathe!"))
		victim.Stun(40)
		victim.Weaken(30)

/mob/living/simple_animal/hostile/scp1206/death(gibbed)
	visible_message(SPAN_NOTICE("All smoke stops flowing from [src]'s pipes."))
	return ..()
