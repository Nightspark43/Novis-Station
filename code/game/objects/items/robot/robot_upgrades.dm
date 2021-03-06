// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/require_module = 0
	var/installed = 0

/obj/item/borg/upgrade/proc/action(var/mob/living/silicon/robot/R)
	if(R.stat == DEAD)
		usr << "<span class='warning'>The [src] will not function on a deceased robot.</span>"
		return 1
	return 0


/obj/item/borg/upgrade/reset
	name = "robotic module reset board"
	desc = "Used to reset a cyborg's module. Destroys any other upgrades applied to the robot."
	icon_state = "cyborg_upgrade1"
	require_module = 1

/obj/item/borg/upgrade/reset/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.uneq_all()
	R.modtype = initial(R.modtype)
	R.hands.icon_state = initial(R.hands.icon_state)

	R.notify_ai(ROBOT_NOTIFICATION_MODULE_RESET, R.module.name)
	R.module.Reset(R)
	qdel(R.module)
	R.module = null
	R.updatename("Default")
	R.hasarmor = 0
	R.hasrepair = 0
	R.hasegun = 0
	R.hasthermal = 0

	return 1

/obj/item/borg/upgrade/rename
	name = "robot reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = "default name"

/obj/item/borg/upgrade/rename/attack_self(mob/user as mob)
	heldname = sanitizeSafe(input(user, "Enter new robot name", "Robot Reclassification", heldname), MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	R.notify_ai(ROBOT_NOTIFICATION_NEW_NAME, R.name, heldname)
	R.name = heldname
	R.custom_name = heldname
	R.real_name = heldname

	return 1

/obj/item/borg/upgrade/floodlight
	name = "robot floodlight module"
	desc = "Used to boost cyborg's light intensity."
	icon_state = "cyborg_upgrade1"

/obj/item/borg/upgrade/floodlight/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.intenselight)
		usr << "This cyborg's light was already upgraded"
		return 0
	else
		R.intenselight = 1
		R.update_robot_light()
		R << "Lighting systems upgrade detected."
	return 1

/obj/item/borg/upgrade/restart
	name = "robot emergency restart module"
	desc = "Used to force a restart of a disabled-but-repaired robot, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(var/mob/living/silicon/robot/R)
	if(R.health < 0)
		usr << "You have to repair the robot before using this module!"
		return 0

	if(!R.key)
		for(var/mob/observer/ghost/ghost in player_list)
			if(ghost.mind && ghost.mind.current == R)
				R.key = ghost.key

	R.stat = CONSCIOUS
	R.switch_from_dead_to_living_mob_list()
	R.notify_ai(ROBOT_NOTIFICATION_NEW_UNIT)
	return 1


/obj/item/borg/upgrade/vtec
	name = "robotic VTEC Module"
	desc = "Used to kick in a robot's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/vtec/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.speed == -1)
		return 0

	R.speed--
	return 1


/obj/item/borg/upgrade/tasercooler
	name = "robotic Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	require_module = 1


/obj/item/borg/upgrade/tasercooler/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!R.module || !(type in R.module.supported_upgrades))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0

	var/obj/item/weapon/gun/energy/taser/mounted/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
	if(!T)
		T = locate() in R.module.modules
	if(!T)
		usr << "This robot has had its taser removed!"
		return 0

	if(T.recharge_time <= 2)
		R << "Maximum cooling achieved for this hardpoint!"
		usr << "There's no room for another cooling unit!"
		return 0

	else
		T.recharge_time = max(2 , T.recharge_time - 4)

	return 1

/obj/item/borg/upgrade/jetpack
	name = "mining robot jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity mining operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/jetpack/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!R.module || !(type in R.module.supported_upgrades))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0
	else
		R.module.modules += new/obj/item/weapon/tank/jetpack/carbondioxide
		for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
			R.internals = src
		//R.icon_state="Miner+j"
		return 1

/obj/item/borg/upgrade/rcd
	name = "engineering robot RCD"
	desc = "A rapid construction device module for use during construction operations."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/rcd/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(!R.module || !(type in R.module.supported_upgrades))
		R << "Upgrade mounting error!  No suitable hardpoint detected!"
		usr << "There's no mounting point for the module!"
		return 0
	else
		R.module.modules += new/obj/item/weapon/rcd/borg(R.module)
		return 1

/obj/item/borg/upgrade/syndicate/
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a robot."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(var/mob/living/silicon/robot/R)
	if(..()) return 0

	if(R.emagged == 1)
		return 0

	R.emagged = 1
	return 1

/obj/item/borg/upgrade/armour
	name = "reactive plating Module"
	desc = "Used to install reactive armour plating, increasing a robots resistance to harm."
	icon_state = "cyborg_upgrade2"
	require_module = 1

/obj/item/borg/upgrade/armour/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(R.hasarmor == 0)
		var/datum/robot_component/armour/A = R.get_armour()
		A.max_damage = 120
		R.maxHealth = 270
		if(R.damagemulti > 0.80)
			R.damagemulti -= 0.15
		if(R.damagethresh < 10)
			R.damagethresh += 5
		R.hasarmor = 1
		return 1
	else
		usr << "This module is already installed!"
		return 0

/obj/item/borg/upgrade/repair
	name = "self repair module"
	desc = "An internal module designed to allow robots to repair themselves and others."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/repair/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(R.hasrepair == 0)
		R.module.modules += new/obj/item/borg/repairtool(R.module)
		R.hasrepair = 1
		return 1
	else
		usr << "This module is already installed!"
		return 0

/obj/item/borg/upgrade/egun
	name = "unauthorized energy gun module"
	desc = "A highly illegal module that can be used to install unlicensed lethal weaponry in cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/egun/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(R.hasegun == 0)
		R.module.modules += new/obj/item/weapon/gun/energy/gun/nuclear/mounted(R.module)
		R.hasegun = 1
		return 1
	else
		usr << "This module is already installed!"
		return 0

/obj/item/borg/upgrade/thermal
	name = "unauthorized thermal module"
	desc = "A highly illegal module that can be used to install unlicensed thermal spectrum scanners in cyborgs."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/thermal/action(var/mob/living/silicon/robot/R)
	if(..()) return 0
	if(R.hasthermal == 0)
		R.module.modules += new/obj/item/borg/sight/thermal(R.module)
		R.hasthermal = 1
		return 1
	else
		usr << "This module is already installed!"
		return 0