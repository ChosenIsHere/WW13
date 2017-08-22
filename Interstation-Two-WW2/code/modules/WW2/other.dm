var/roundstart_time = 0
var/mercy_period = 1
var/game_started = 0
var/train_checked = 0
var/secret_ladder_message = null

var/list/list_of_germans_who_crossed_the_river = list()

/proc/WW2_train_check()
	if (locate(/obj/effect/landmark/train/german_train_start) in world || train_checked)
		train_checked = 1
		return 1
	else
		return 0

/turf/proc/check_prishtina_block(var/mob/m, var/actual_movement = 0)

	if (isobserver(m))
		return 0

	for (var/obj/prishtina_block/pb in src)
		if (!istype(pb, /obj/prishtina_block/attackers) && !istype(pb, /obj/prishtina_block/defenders))
			return 1 // nobody passes these
		else
			if (istype(pb, /obj/prishtina_block/attackers))
				if (!game_started)
					return 1 // if the game has not started, nobody passes. For benefit of attacking commanders/defenders - prevents ramboing, allows setting up
			else if (istype(pb, /obj/prishtina_block/defenders))
				if (mercy_period)
					var/mob/living/carbon/human/H = m
					if (H && H.original_job && istype(H.original_job, /datum/job/german))
						if (actual_movement)
							if (!istype(H.original_job, /datum/job/german/paratrooper))
								list_of_germans_who_crossed_the_river |= H
								if (list_of_germans_who_crossed_the_river.len > 10 && mercy_period)
									world << "<span class = 'notice'><big>A number of Germans have crossed the river; the Grace Period has been ended early.</span>"
									mercy_period = 0
						return 0 // germans can pass
					return 1 // if the grace period is active, nobody south of the river passes. For the benefit of attackers, so they get time to set up.
	return 0

/obj/prishtina_block
	icon = null
	icon_state = null
	density = 0
	anchored = 1.0
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"

	New()
		icon = null
		icon_state = null
		layer = -1000

	ex_act(severity)
		return 0

/obj/prishtina_block/attackers // block the Germans (or whoever is attacking) from attacking early
	icon = null
	icon_state = null
	density = 0
	anchored = 1.0
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"

	New()
		icon = null
		icon_state = null
		layer = -1000


/obj/prishtina_block/defenders // block the Russian (or whoever is defending) from attacking early
	icon = null
	icon_state = null
	density = 0
	anchored = 1.0
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"

	New()
		icon = null
		icon_state = null
		layer = -1000


/hook/roundstart/proc/game_start()
	roundstart_time = world.time

	world << "<font size=3><span class = 'notice'>It's [lowertext(time_of_day)].</span></font>"

	// spawn mice so soviets have something to eat after they start starving

	var/mice_spawned = 0
	var/max_mice = rand(40,50)

	for (var/area/prishtina/soviet/bunker/area in world)
		for (var/turf/t in area.contents)
			if (t.density)
				continue
			if (istype(t, /turf/open))
				continue
			if (prob(1))
				new/mob/living/simple_animal/mouse/gray(t)
				++mice_spawned
				if (mice_spawned > max_mice)
					return 1
	return 1

var/wlg_total = 0
var/wlg_rejected = 0
var/wlg_selected_none = 0
var/wlg_selected_grass = 0
var/wlg_selected_bush = 0
var/wlg_selected_border_tree = 0

/hook/startup/proc/spawn_bushes()
//	world << "<b>Generating wild life. Experimental.</b>"
/*	wlg_total = 0
	wlg_rejected = 0
	wlg_selected_none = 0
	wlg_selected_grass = 0
	wlg_selected_bush = 0
	wlg_selected_border_tree = 0
*/
//	var/spawned_secret_ladder = 0

	if (!config.debug) // this fun piece of code causes way too much startup lag

		spawn(100)

			if (prob(50))
		//		spawned_secret_ladder = 1
				message_admins("There is no secret entrance to the soviet bunker this round!")
			else
				secret_ladder_message = "<span class = 'notice'><b>There is a secret ladder to the inside of the Soviet bunker somewhere in the forest. If you find it, you will gain a huge advantage over the enemy.</b></span>"

		// this is disabled because
			// 1. there are trees on the map
			// 2. fuck the game taking so long to start up
			// - Kachnov

		/*	for(var/turf/floor/plating/grass/T in grass_turf_list)

				if(T.z != 1)
					continue
				if(!istype(T))
					continue

				if (prob(1) && T.x > 171 && !spawned_secret_ladder)
					spawned_secret_ladder = 1
					var/obj/structure/multiz/ladder/ww2/ladder = new/obj/structure/multiz/ladder/ww2(T)
					ladder.area_id = "sovsecret"
					ladder.ladder_id = "ww2-l-sovsecret-1"
					ladder.target = ladder.find_target()
					ladder.target.target = ladder
					message_admins("Secret entrance to the soviet bunker spawned at [T.x],[T.y],[T.z]")
					for (var/obj/structure/wild/w in T)
						qdel(w)
					for (var/obj/structure/flora/f in T)
						qdel(f)

				wlg_total++
				if(T.contents.len > 1)
					wlg_rejected++
					continue

				for(var/dir in cardinal)
					var/turf/C = get_step(T, dir)
					if(istype(C, /turf/wall) || istype(C, /turf/wall/rockwall))
						wlg_selected_border_tree++
						new /obj/structure/wild/tree(T)
						break

				if (!locate(/obj/structure) in T)
					var/rn = rand(1, 100)
					switch(rn)
						if(1 to 80)
							wlg_selected_none++
							continue
						if(81 to 99)
							wlg_selected_grass++
							var/grass = pick(/obj/structure/flora/ausbushes/sparsegrass,
											/obj/structure/flora/ausbushes/sparsegrass,
											/obj/structure/flora/ausbushes/fullgrass,
											/obj/structure/flora/ausbushes/lavendergrass)
							new grass(T)
						//if(97 to 99)
						//	var/flowers = pick(/obj/structure/flora/ausbushes/ywflowers,
						//					/obj/structure/flora/ausbushes/brflowers,
						//					/obj/structure/flora/ausbushes/ppflowers)
						//	new flowers(T)
						else
							wlg_selected_bush++
							var/bushes = pick(/obj/structure/flora/ausbushes,
											/obj/structure/flora/ausbushes/reedbush,
											/obj/structure/flora/ausbushes/leafybush,
											/obj/structure/flora/ausbushes/palebush,
											/obj/structure/flora/ausbushes/stalkybush,
											/obj/structure/flora/ausbushes/grassybush,
											/obj/structure/flora/ausbushes/fernybush,
											/obj/structure/flora/ausbushes/sunnybush,
											/obj/structure/flora/ausbushes/genericbush,
											/obj/structure/flora/ausbushes/pointybush)
							new bushes(T)*/
	return 1

var/mission_announced = 0

/hook/train_move/proc/announce_mission_start()

	if(mission_announced)
		return 1

	mission_announced = 1

	var/preparation_time = world.time - roundstart_time

	world << "<font size=4>The German assault has started after [preparation_time / 600] minutes of preparation.</font><br>"


	if (mercy_period && WW2_train_check())
		world << "<font size=3>The Russian side can't attack until after 10 minutes.</font><br>"

	game_started = 1
//	ticker.can_latejoin_ruforce = 0
//	ticker.can_latejoin_geforce = 0

	if (WW2_train_check())
		spawn (10 MINUTES) // because byond minutes are a long fucking time, this should be long enough to build defenses. maybe. - Kachnov
			if (mercy_period)
				mercy_period = 0
				world << "<font size=4>The 10 minute grace period has ended. Soviets and Partisans may now cross the river.</font>"

	world << "<font size=3>Balance report: [job_master.geforce_count] German, [job_master.ruforce_count] Soviet and [job_master.civilian_count] Civilians/Partisans.</font>"

	for (var/obj/structure/simple_door/key_door/keydoor in world)
		if (findtext(keydoor.name, "Squad"))
			if (findtext(keydoor.name, "Preparation"))
				keydoor.Open()