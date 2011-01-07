/*
Deployable items

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_medlab = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44

*/

/obj/machinery/depolyable
	name = "deployable"
	desc = "deployable"
	icon = 'deployable.dmi'
	layer = 5.0
//	req_access = list(access_security)

/obj/machinery/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'deployable.dmi'
	layer = 5.0
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 100.0
	var/maxhealth = 100.0
	var/locked = 0.0
	req_access = list(access_maint_tunnels)

	New()
		..()

		src.icon_state = "barrier[src.locked]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
			if (src.allowed(user))
				src.locked = !src.locked
				src.anchored = !src.anchored
				src.icon_state = "barrier[src.locked]"
				user << "Barrier lock toggled."
				return
			return
		else if (istype(W, /obj/item/weapon/wrench))
			if (src.health < src.maxhealth)
				src.health = src.maxhealth
				for(var/mob/O in viewers(src, null))
					O << "\red [user] repairs the [src]!"
				return
			return
		else
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 0.75
				if("brute")
					src.health -= W.force * 0.5
				else
			if (src.health <= 0)
				src.explode()
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				src.explode()
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					src.explode()
				return

	meteorhit()
		src.explode()
		return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			src.explode()
		return

	bullet_act(flag, A as obj)
		switch(flag)
			if (PROJECTILE_BULLET)
				src.health -= 20
			//if (PROJECTILE_WEAKBULLET || PROJECTILE_BEANBAG) //Detective's revolver fires marshmallows
			//	src.health -= 2
			if (PROJECTILE_LASER)
				src.health -= 20
			if (PROJECTILE_PULSE)
				src.health -=50
		if (src.health <= 0)
			src.explode()

	proc/explode()

		for(var/mob/O in hearers(src, null))
			O.show_message("\red <B>[src] blows apart!</B>", 1)
		var/turf/Tsec = get_turf(src)

	/*	var/obj/item/stack/rods/ =*/
		new /obj/item/stack/rods(Tsec)

		var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		explosion(src.loc,-1,-1,0)
		if(src)
			del(src)