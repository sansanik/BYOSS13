/* to do list
сделать ускоритель частиц
добавить в коробки теслы и синугярки платы под ускоритель частиц
обновить до текущей версии парадизов

сделать выбор класса
*/
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
	var A = pick(//obj/item/storage/box/tesla,\
			//obj/item/storage/box/singulo,
			/obj/structure/closet/crate/engineering/solarpannel)//,\
			//obj/structure/closet/crate/engineering/supermatter)
	if(uses == 0)
		new /obj/effect/landmark/resources/rare(user.loc)
		new /obj/effect/landmark/resources/common(user.loc)
		new /obj/effect/huinya(user.loc)
		new A(user.loc)
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

/obj/structure/closet/crate/engineering/solarpannel
	name = "solar pamel crate"
	desc = "An solar panel crate."
	icon_state = "electricalcrate"
	icon_opened = "electricalcrate_open"
	icon_closed = "electricalcrate"
	var/list/possible_contents = list(/obj/item/solar_assembly)

/obj/structure/closet/crate/engineering/solarpannel/populate_contents()
	. = ..()
	for(var/i in 1 to 15)
		var/item = pick(possible_contents)
		new item(src)

/obj/item/circuitboard/tesla
	board_name = "Tesla generator"
	icon_state = "engineering"
	build_path = /obj/machinery/the_singularitygen/tesla
	board_type = "machine"
	origin_tech = "programming=5;magnets=7;powerstorage=7"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/cable_coil = 25,
							//obj/item/stock_parts/matter_bin = 1
							)


/obj/item/circuitboard/rad_collector
	board_name = "Radiation collector"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rad_collector
	board_type = "machine"
	origin_tech = "programming=2;magnets=3;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/matter_bin = 3
							)

/obj/item/circuitboard/singularity
	board_name = "Singularity generator"
	icon_state = "engineering"
	build_path = /obj/machinery/the_singularitygen
	board_type = "machine"
	origin_tech = "programming=4;magnets=7;powerstorage=3"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/matter_bin = 15
							)

/obj/structure/closet/crate/engineering/supermatter
	name = "super matter crate"
	desc = "A super matter crate."
	icon_state = "electricalcrate"
	icon_opened = "electricalcrate_open"
	icon_closed = "electricalcrate"

/obj/structure/closet/crate/engineering/supermatter/populate_contents()
	. = ..()
	new /obj/item/storage/box/rad_collector(src)
	new /obj/item/storage/box/rad_collector(src)
	new /obj/structure/closet/crate/engineering/real_supermatter(src)

/obj/structure/closet/crate/engineering/real_supermatter
	name = "real super matter crate"
	desc = "A real super matter crate."
	icon_state = "electricalcrate"
	icon_opened = "electricalcrate_open"
	icon_closed = "electricalcrate"

/obj/structure/closet/crate/engineering/real_supermatter/populate_contents()
	. = ..()
	new /obj/machinery/atmospherics/supermatter_crystal(src)

/obj/item/storage/box/rad_collector
	name = "Radiation collectors box"
	desc = "RAD!"
	icon_state = "syndi_box"

/obj/item/storage/box/rad_collector/populate_contents()
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)

/obj/item/storage/box/tesla
	name = "Tesla generator box"
	desc = "Shock!"
	icon_state = "syndi_box"

/obj/item/storage/box/tesla/populate_contents()
	new /obj/item/circuitboard/tesla(src)


/obj/item/storage/box/singulo
	name = "Singularity generator box"
	desc = "SiNgUlO iN bOx!"
	icon_state = "syndi_box"

/obj/item/storage/box/singulo/populate_contents()
	new /obj/item/circuitboard/singularity(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
	new /obj/item/circuitboard/rad_collector(src)
// teg\/
/*
/obj/item/storage/box/teg
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon_state = "pda_box"

/obj/item/storage/box/teg/populate_contents()
	new /obj/item/circuitboard/circulator(src)
	new /obj/item/circuitboard/circulator(src)
	new /obj/item/circuitboard/teg(src)
*/
//teg/\

// режим тфки \/ -|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-|X|-




GLOBAL_LIST_EMPTY(redstart)
GLOBAL_LIST_EMPTY(bluestart)
GLOBAL_LIST_EMPTY(tfwalls)

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
	w_class = WEIGHT_CLASS_BULKY
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

/datum/game_mode/ctf
	name = "Capture the flag"
	config_tag = "ctf"
	required_players = 0
	required_enemies = 0
	var/list/datum/mind/red = new
	var/list/datum/mind/blue = new

/datum/game_mode/ctf/announce()
	to_chat(world, "<B>The current game mode is - Capture the flag!</B>")
	to_chat(world, "<B>Here is a war of 2 teams, red and blue!</B>")

/datum/game_mode/ctf/can_start()
	//to_chat(world, "<B>Начали делать команды</B>")
	var/list/datum/mind/possible_manns = get_players_for_role(ROLE_MANN)
	//to_chat(world, possible_manns.len)
	var/datum/mind/mann
	//for(var/datum/mind/mann in possible_manns.len)
	while(possible_manns.len>0)
		mann = pick(possible_manns)
		if(possible_manns.len % 2 == 0)
			red += mann
			//to_chat(world, "<B>+Красный</B>")
		else
			blue += mann
			//to_chat(world, "<B>+Синий</B>")
		possible_manns -= mann
		modePlayer += mann
		mann.assigned_role = SPECIAL_ROLE_MANN //So they aren't chosen for other jobs.
		mann.special_role = SPECIAL_ROLE_MANN
		mann.set_original_mob(mann.current)
	return 1


/datum/game_mode/ctf/pre_setup()
	//PROC_REF(make_teams)
	//to_chat(world, "<B>Пре сетап</B>")
	//to_chat(world, red.len)
	//to_chat(world, blue.len)
	for(var/datum/mind/rman in red)
		rman.current.loc = pick(GLOB.redstart)
		//to_chat(world, "<B>Спавн красного</B>")
	for(var/datum/mind/bman in blue)
		bman.current.loc = pick(GLOB.bluestart)
		//to_chat(world, "<B>Спавн синего</B>")
	..()
	return 1

/datum/game_mode/ctf/post_setup()
	//to_chat(world, "<B>Пост сетап</B>")
	for(var/datum/mind/blueman in blue)
		log_game("[key_name(blueman)] has been selected as a Blue Mann")
		equip_blue(blueman.current)
		//if(use_huds)
			//update_mann_icons_added(blueman)
	for(var/datum/mind/redman in red)
		log_game("[key_name(redman)] has been selected as a Red Mann")
		equip_red(redman.current)
		//if(use_huds)
			//update_mann_icons_added(redman)
	//to_chat(world, "<B>Конец приготавлений</B>")
	for(var/obj/effect/landmark/timewall/Walls in GLOB.tfwalls)
		Walls.Destroywalls()
	..()


/*datum/game_mode/proc/update_mann_icons_added(datum/mind/mann_mind)
	var/datum/atom_hud/antag/mannhud = GLOB.huds[MANN_HUD_RED]
	mannhud.join_hud(mann_mind.current)
	set_antag_hud(mann_mind.current, ((mann_mind in red)// ? "hudwizard" : "apprentice")) ??????
*/
/obj/effect/landmark/spawner/ctf
	name = "invalid"
	//icon_state = "Wiz"

/obj/effect/landmark/spawner/ctf/Initialize(mapload)
	return ..()
/obj/effect/landmark/spawner/ctf/red
	name = "red"
	//icon_state = "Wiz"

/obj/effect/landmark/spawner/ctf/red/Initialize(mapload)
	spawner_list = GLOB.redstart
	return ..()

/obj/effect/landmark/spawner/ctf/blue
	name = "blue"
	//icon_state = "Wiz"

/obj/effect/landmark/spawner/ctf/blue/Initialize(mapload)
	spawner_list = GLOB.bluestart
	return ..()

/datum/game_mode/proc/equip_red(mob/living/carbon/human/red_mann)
	//to_chat(world, "<B>Одеваю красного</B>")
	if(!istype(red_mann))
		return

	qdel(red_mann.wear_suit)
	qdel(red_mann.head)
	qdel(red_mann.shoes)
	qdel(red_mann.r_hand)
	qdel(red_mann.r_store)
	qdel(red_mann.l_store)
	red_mann.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(red_mann), SLOT_HUD_JUMPSUIT)
	red_mann.equip_to_slot_or_del(new /obj/item/clothing/head/beret(red_mann), SLOT_HUD_HEAD)
	red_mann.equip_to_slot_or_del(new /obj/item/card/id/admin(red_mann), SLOT_HUD_WEAR_ID)
	red_mann.dna.species.after_equip_job(null, red_mann)
	red_mann.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	red_mann.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(red_mann), SLOT_HUD_SHOES)
	red_mann.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(red_mann), SLOT_HUD_BACK)
	if(red_mann.dna.species.speciesbox)
		red_mann.equip_to_slot_or_del(new red_mann.dna.species.speciesbox(red_mann), SLOT_HUD_IN_BACKPACK)
	else
		red_mann.equip_to_slot_or_del(new /obj/item/storage/box/survival(red_mann), SLOT_HUD_IN_BACKPACK)
	red_mann.faction = list("Red")
	red_mann.mind.offstation_role = TRUE

	red_mann.update_icons()
	//to_chat(world, "<B>Одел красного</B>")
	return TRUE

/datum/game_mode/proc/equip_blue(mob/living/carbon/human/blue_mann)
	//to_chat(world, "<B>Одеваю синего</B>")
	if(!istype(blue_mann))
		return

	qdel(blue_mann.wear_suit)
	qdel(blue_mann.head)
	qdel(blue_mann.shoes)
	qdel(blue_mann.r_hand)
	qdel(blue_mann.r_store)
	qdel(blue_mann.l_store)
	blue_mann.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue(blue_mann), SLOT_HUD_JUMPSUIT)
	blue_mann.equip_to_slot_or_del(new /obj/item/clothing/head/beret/blue(blue_mann), SLOT_HUD_HEAD)
	blue_mann.equip_to_slot_or_del(new /obj/item/card/id/admin(blue_mann), SLOT_HUD_WEAR_ID)
	blue_mann.dna.species.after_equip_job(null, blue_mann)
	blue_mann.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	blue_mann.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(blue_mann), SLOT_HUD_SHOES)
	blue_mann.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(blue_mann), SLOT_HUD_BACK)
	if(blue_mann.dna.species.speciesbox)
		blue_mann.equip_to_slot_or_del(new blue_mann.dna.species.speciesbox(blue_mann), SLOT_HUD_IN_BACKPACK)
	else
		blue_mann.equip_to_slot_or_del(new /obj/item/storage/box/survival(blue_mann), SLOT_HUD_IN_BACKPACK)
	blue_mann.faction = list("Blue")
	blue_mann.mind.offstation_role = TRUE

	blue_mann.update_icons()
	//to_chat(world, "<B>Одел синего</B>")
	return TRUE

/obj/item/disk/design_disk/rifle
	name = "rifle creation disk"
	desc = "A gift from the GOD."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/rifle/Initialize()
	. = ..()
	//var/datum/design/rifle/G = new
	blueprint = new /datum/design/rifle

/datum/design/rifle //Починил
	name = "Rifle"
	desc = "A rifle disk."
	id = "rifleTF"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_SILVER= 3500)
	build_path = /obj/item/gun/energy/laser
	category = list("Weapons")
	build_type = PROTOLATHE
	requires_whitelist = TRUE

/obj/effect/landmark/timewall
	name = "timewallspawner"
	icon = '_maps/map_files220/BYOSS13/segs.dmi'
	icon_state = "tf_wall"

/obj/effect/landmark/timewall/Initialize(mapload)
	GLOB.tfwalls += src
	new /turf/simulated/wall/indestructible(src.loc)
	return ..()

/obj/effect/landmark/timewall/proc/Destroywalls()
	del(src)

/obj/effect/landmark/timewall/Del()
	sleep(6000)
	new /turf/space(src.loc)

//...до сюда