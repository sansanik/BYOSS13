/datum/map/byoss13
	fluff_name = "Build your own space station 13"
	technical_name = "BYOSS13"
	map_path = "_maps/map_files220/BYOSS13/ByoSS13.dmm"
	webmap_url = ""


// Убери нах если нихуя не работает! от сюда..
/obj/effect/landmark/resources
	name = "resources"
	var/T

/obj/effect/landmark/resources/New()
	. = ..()
	spawn_item()
	del(src)

/obj/effect/landmark/resources/Del()
	sleep(T)
	new src.type(src.loc)
	..()

/obj/effect/landmark/resources/proc/spawn_item()
	var/build_path = kind_of_resources()
	return (new build_path(src.loc))

/obj/effect/landmark/resources/proc/kind_of_resources()
	return

/obj/effect/landmark/resources/common
	name = "Common resources"
	T = 1200

/obj/effect/landmark/resources/common/kind_of_resources()
	return pick(/obj/item/stack/sheet/metal/fifty,\
		 /obj/item/stack/sheet/plasteel/fifty,\
		 /obj/item/stack/sheet/plastic/fifty,\
		 /obj/item/stack/sheet/glass/fifty)

/obj/effect/landmark/resources/common/Del()
	..()

/obj/effect/landmark/resources/rare
	name = "Rare resources"
	T = 3000

/obj/effect/landmark/resources/rare/kind_of_resources()
	return pick(/obj/item/stack/sheet/mineral/silver/fifty,\
		 /obj/item/stack/sheet/mineral/titanium/fifty,\
		 /obj/item/stack/sheet/mineral/gold/fifty,\
		 /obj/item/stack/sheet/mineral/plasma/fifty,\
		 /obj/item/stack/sheet/mineral/uranium/fifty,\
		 /obj/item/stack/ore/bluespace_crystal/fifty,\
		 /obj/item/stack/sheet/mineral/diamond/fifty)

/obj/item/stack/ore/bluespace_crystal/fifty
	amount = 50

/obj/effect/landmark/resources/rare/Del()
	..()

/obj/item/shahta_nahui
	name = "Bluespace miner"
	desc = "Помечает точку в пространстве в которой будут появлятся ресурсы"
	icon = '_maps/map_files220/BYOSS13/segs.dmi'
	icon_state = "killniggers"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/uses = 0

/obj/item/shahta_nahui/attack_self(mob/user)
	if(uses == 0)
		new /obj/effect/landmark/resources/rare(user.loc)
		new /obj/effect/landmark/resources/common(user.loc)
		new /obj/effect/huinya(user.loc)
	uses = 1
	del(src)
	return

/obj/effect/huinya
	name = "bluspace miner's portal"
	desc = "Портал из которого ебашат ресурсы"
	icon = '_maps/map_files220/BYOSS13/segs.dmi'
	icon_state = "miner"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/giblooser
	name = "gibber"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = 1
	invisibility = 101

/obj/effect/giblooser/Bumped(mob/gay)
	if(ismob(gay))
		gay.gib()
	return

// режим тфки \/ -|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-

/area/shuttle/arrival/station/red
	icon_state = "shuttle"
	name = "red base"

/area/shuttle/arrival/station/blue
	icon_state = "shuttle"
	name = "blue base"

/datum/map/tfis
	fluff_name = "Team fortress in space!"
	technical_name = "TFIS"
	map_path = "_maps/map_files220/BYOSS13/TFiS.dmm"
	webmap_url = ""
	var blue_score = 0
	var red_score = 0


/obj/effect/ctf_case_place
	name = "base"
	desc = "Сюда пихать вражеский кейс, и здесь спавнится ваш"
	icon = '_maps/map_files220/BYOSS13/segs.dmi'
	var command = ""
	var spawned_case = 0
	var red_score = 0
	var blue_score = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/ctf_case_place/Initialize(mapload)
	. = ..()
	case_spawn()

/obj/effect/ctf_case_place/proc/case_spawn()
	return


/obj/effect/ctf_case_place/red/case_spawn()
	//command = "red"
	if(spawned_case < 3)
		new /obj/item/tfis/case/red(src.loc)
		spawned_case += 1
	..()

/obj/effect/ctf_case_place/blue/case_spawn()
	//command = "blue"
	if(spawned_case < 3)
		new /obj/item/tfis/case/blue(src.loc)
		spawned_case += 1
	..()

/obj/effect/ctf_case_place/red
	..()
	name = "Red base"
	icon_state = "red_base"


/obj/effect/ctf_case_place/blue
	..()
	name = "Blue base"
	icon_state = "blue_base"

/obj/effect/ctf_case_place/proc/case_cap()
	GLOB.major_announcement.Announce("Red [red_score] - Blue [blue_score]", "", 'sound/AI/power_overload.ogg')

/obj/effect/ctf_case_place/red/case_cap(obj/item/Obb)
	del(Obb)
	red_score += 1
	..()

/obj/effect/ctf_case_place/blue/case_cap(obj/item/Obb)
	del(Obb)
	blue_score += 1
	..()

/obj/effect/ctf_case_place/red/attackby(obj/item/Cb, mob/user)
	if(Cb.type == /obj/item/tfis/case/blue)
		case_cap(Cb)

/obj/effect/ctf_case_place/blue/attackby(obj/item/Cr, mob/user)
	if(Cr.type == /obj/item/tfis/case/red)
		case_cap(Cr)

/obj/item/tfis/case
	name = "case"
	desc = "Очень секретные разведданные"
	icon = '_maps/map_files220/BYOSS13/segs.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/*
/obj/item/tfis/case/Del()
	..()

/obj/item/tfis/case/red/Del()
	/obj/effect/ctf_case_place/red/case_spawn()
	//call(/obj/effect/ctf_case_place/red,"case_spawn")()
	..()

/obj/item/tfis/case/blue/Del()
	/obj/effect/ctf_case_place/blue/case_spawn()
	//call(/obj/effect/ctf_case_place/blue,"case_spawn")()
	..()
*/
/obj/item/tfis/case/red
	..()
	name = "Red case"
	icon_state = "red_case"

/obj/item/tfis/case/blue
	..()
	name = "Blue case"
	icon_state = "blue_case"

/obj/effect/landmark/spawner/late/crew/red
	name = "Late Join Crew"

/obj/effect/landmark/spawner/late/crew/red/Initialize(mapload)
	spawner_list = GLOB.latejoin
	return ..()

/obj/effect/landmark/spawner/late/crew/blue
	name = "Late Join Crew"

/obj/effect/landmark/spawner/late/crew/blue/Initialize(mapload)
	spawner_list = GLOB.latejoin
	return ..()
/*
/datum/game_mode/ctf
	name = "Capture the flag"

/datum/game_mode/ctf/announce()
	to_chat(world, "<B>The current game mode is - Capture the flag!</B>")
	to_chat(world, "<B>Here is a war of 2 teams, red and blue!</B>")

/datum/game_mode/ctf/make_teams()
	var/list/datum/mind/possible_manns = get_players_for_role(ROLE_MANN)
	*/