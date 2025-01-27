/////AUGMENTATION SURGERIES//////
//SURGERY STEPS

/datum/surgery_step/replace_limb
	name = "Заменить Конечность"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100)
	time = 32
	var/obj/item/bodypart/L = null // L because "limb"
/datum/surgery_step/replace_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage) && istype(tool.contents[1], /obj/item/bodypart))
		tool = tool.contents[1]
	var/obj/item/bodypart/aug = tool
	if(!aug.is_robotic_limb() && !aug.forcereplace) // forcereplace used here to allow for replacing limbs with synthflesh variants
		to_chat(user, "<span class='warning'>That's not an augment, silly!</span>")
		return -1
	if(aug.body_zone != target_zone)
		to_chat(user, "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>")
		return -1
	L = surgery.operated_bodypart
	if(L)
		if(aug.is_robotic_limb())
			display_results(user, target, "<span class ='notice'>You begin to augment [target]'s [parse_zone(user.zone_selected)]...</span>",
				"[user] begins to augment [target]'s [parse_zone(user.zone_selected)] with [aug].",
				"[user] begins to augment [target]'s [parse_zone(user.zone_selected)].")
		else
			display_results(user, target, "<span class ='notice'>You begin to replace [target]'s [parse_zone(user.zone_selected)]...</span>",
				"[user] begins to replace [target]'s [parse_zone(user.zone_selected)] with [aug].",
				"[user] begins to replace [target]'s [parse_zone(user.zone_selected)].")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", "<span class ='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")

//ACTUAL SURGERIES
/datum/surgery/augmentation
	name = "Augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace_limb)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE

//The augmentation surgery for synthetic limbs
/datum/surgery/augmentation/synth
	requires_bodypart_type = BODYPART_HYBRID
	steps = list(/datum/surgery_step/mechanic_open, /datum/surgery_step/pry_off_plating, /datum/surgery_step/cut_wires, /datum/surgery_step/prepare_electronics, /datum/surgery_step/replace_limb)

//SURGERY STEP SUCCESSES
/datum/surgery_step/replace_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/bodypart/tool, datum/surgery/surgery)
	if(L)
		if(istype(tool, /obj/item/organ_storage))
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = tool.contents[1]
		if(istype(tool) && user.temporarilyRemoveItemFromInventory(tool))
			tool.replace_limb(target, TRUE)
		if(tool.is_robotic_limb())
			display_results(user, target, "<span class='notice'>You successfully augment [target]'s [parse_zone(target_zone)].</span>",
				"[user] successfully augments [target]'s [parse_zone(target_zone)] with [tool]!",
				"[user] successfully augments [target]'s [parse_zone(target_zone)]!")
		else
			display_results(user, target, "<span class='notice'>You successfully replace [target]'s [parse_zone(target_zone)].</span>",
				"[user] successfully replaces [target]'s [parse_zone(target_zone)] with [tool]!",
				"[user] successfully replaces [target]'s [parse_zone(target_zone)]!")
		log_combat(user, target, "augmented", addition="by giving them a new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		to_chat(user, "<span class='warning'>[target] has no organic [parse_zone(target_zone)] there!</span>")
	return TRUE
