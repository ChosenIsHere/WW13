var/global/obj/map_metadata/map = null

/obj/map_metadata
	name = ""
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1
	simulated = 0
	invisibility = 101
	var/ID = null
	var/prishtina_blocking_area_type = null
	var/last_crossing_block_status[2]

/obj/map_metadata/New()
	..()
	map = src
	icon = null
	icon_state = null

// called from the ticker process
/obj/map_metadata/proc/tick()
	if (last_crossing_block_status[GERMAN] == 0)
		if (germans_can_cross_blocks())
			world << "<font size = 4>The Germans may now cross the invisible wall!</font>"
	if (last_crossing_block_status[RUSSIAN] == 0)
		if (soviets_can_cross_blocks())
			world << "<font size = 4>The Soviets may now cross the invisible wall!</font>"

	last_crossing_block_status[GERMAN] = germans_can_cross_blocks()
	last_crossing_block_status[RUSSIAN] = soviets_can_cross_blocks()

/obj/map_metadata/proc/check_prishtina_block(var/mob/living/carbon/human/H, var/turf/T)
	var/area/A = get_area(T)
	if (A.type == prishtina_blocking_area_type)
		if (!H.faction)
			return 1
		else
			switch (H.faction)
				if (PARTISAN, CIVILIAN, RUSSIAN)
					return soviets_can_cross_blocks()
				if (GERMAN)
					return germans_can_cross_blocks()
	return 1

/obj/map_metadata/proc/soviets_can_cross_blocks()
	return 1

/obj/map_metadata/proc/germans_can_cross_blocks()
	return 1

/obj/map_metadata/proc/announce_mission_start(var/preparation_time = 0)
	return 1

/obj/map_metadata/forest
	ID = "Forest Map (200x529)"
	prishtina_blocking_area_type = /area/prishtina/forest/invisible_wall

/obj/map_metadata/forest/germans_can_cross_blocks()
	return mission_announced

/obj/map_metadata/forest/soviets_can_cross_blocks()
	if (mission_announced && tickerProcess.time_elapsed >= 6000)
		return 1

/obj/map_metadata/forest/announce_mission_start(var/preparation_time = 0)
	world << "<font size=4>The German assault has started after [preparation_time / 600] minutes of preparation.</font><br>"

/obj/map_metadata/minicity
	ID = "City Map (70x70)"
	prishtina_blocking_area_type = /area/prishtina/no_mans_land/invisible_wall

/obj/map_metadata/minicity/germans_can_cross_blocks()
	return tickerProcess.time_elapsed >= 7200

/obj/map_metadata/minicity/soviets_can_cross_blocks()
	return tickerProcess.time_elapsed >= 7200

/obj/map_metadata/minicity/announce_mission_start(var/preparation_time)
	return 1