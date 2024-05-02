/obj/machinery/atmospherics/binary/circulator
	name = "circulator"
	desc = "A gas circulator turbine and heat exchanger."
	icon = 'icons/obj/power.dmi'
	icon_state = "circ-unassembled"
	anchored = FALSE

	var/kinetic_efficiency = 0.04 //combined kinetic and kinetic-to-electric efficiency
	var/volume_ratio = 0.2

	var/recent_moles_transferred = 0
	var/last_heat_capacity = 0
	var/last_temperature = 0
	var/last_pressure_delta = 0
	var/last_worldtime_transfer = 0
	var/last_stored_energy_transferred = 0
	var/volume_capacity_used = 0
	var/stored_energy = 0
	var/temperature_overlay

	density = TRUE

/obj/machinery/atmospherics/binary/circulator/Initialize()
	. = ..()
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."
	air1.volume = 400

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/removed
	if(anchored && !(stat&BROKEN) && network1)
		var/input_starting_pressure = air1.return_pressure()
		var/output_starting_pressure = air2.return_pressure()
		last_pressure_delta = max(input_starting_pressure - output_starting_pressure - 5, 0)

		//only circulate air if there is a pressure difference (plus 5kPa kinetic, 10kPa static friction)
		if(air1.temperature > 0 && last_pressure_delta > 5)

			//Calculate necessary moles to transfer using PV = nRT
			recent_moles_transferred = (last_pressure_delta*network1.volume/(air1.temperature * R_IDEAL_GAS_EQUATION))/3 //uses the volume of the whole network, not just itself
			volume_capacity_used = min( (last_pressure_delta*network1.volume/3)/(input_starting_pressure*air1.volume) , 1) //how much of the gas in the input air volume is consumed

			//Calculate energy generated from kinetic turbine
			stored_energy += 1/ADIABATIC_EXPONENT * min(last_pressure_delta * network1.volume , input_starting_pressure*air1.volume) * (1 - volume_ratio**ADIABATIC_EXPONENT) * kinetic_efficiency

			//Actually transfer the gas
			removed = air1.remove(recent_moles_transferred)
			if(removed)
				last_heat_capacity = removed.heat_capacity()
				last_temperature = removed.temperature

				//Update the gas networks.
				network1.update = 1

				last_worldtime_transfer = world.time
		else
			recent_moles_transferred = 0

		update_icon()
		return removed

/obj/machinery/atmospherics/binary/circulator/proc/return_stored_energy()
	last_stored_energy_transferred = stored_energy
	stored_energy = 0
	return last_stored_energy_transferred

/obj/machinery/atmospherics/binary/circulator/Process()
	..()

	if(last_worldtime_transfer < world.time - 50)
		recent_moles_transferred = 0
		update_icon()

/obj/machinery/atmospherics/binary/circulator/on_update_icon()
	icon_state = anchored ? "circ-assembled" : "circ-unassembled"
	overlays.Cut()
	if (stat & (BROKEN|NOPOWER) || !anchored)
		return 1
	if (last_pressure_delta > 0 && recent_moles_transferred > 0)
		if (temperature_overlay)
			overlays += image('icons/obj/power.dmi', temperature_overlay)
		if (last_pressure_delta > 5*ONE_ATMOSPHERE)
			overlays += image('icons/obj/power.dmi', "circ-run")
		else
			overlays += image('icons/obj/power.dmi', "circ-slow")
	else
		overlays += image('icons/obj/power.dmi', "circ-off")

	return 1

/obj/machinery/atmospherics/binary/circulator/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		anchored = !anchored
		user.visible_message("[user.name] [anchored ? "secures" : "unsecures"] the bolts holding [src.name] to the floor.", \
					"You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.", \
					"You hear a ratchet")

		if(anchored)
			temperature_overlay = null
			if(dir & (NORTH|SOUTH))
				initialize_directions = NORTH|SOUTH
			else if(dir & (EAST|WEST))
				initialize_directions = EAST|WEST

			atmos_init()
			build_network()
			if (node1)
				node1.atmos_init()
				node1.build_network()
			if (node2)
				node2.atmos_init()
				node2.build_network()
		else
			if(node1)
				node1.disconnect(src)
				qdel(network1)
			if(node2)
				node2.disconnect(src)
				qdel(network2)

			node1 = null
			node2 = null
		update_icon()

	else
		..()

/obj/machinery/atmospherics/binary/circulator/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate Circulator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, 90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."


/obj/machinery/atmospherics/binary/circulator/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate Circulator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained() || anchored)
		return

	src.set_dir(turn(src.dir, -90))
	desc = initial(desc) + " Its outlet port is to the [dir2text(dir)]."



/obj/machinery/power/teg
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg-unassembled"
	density = TRUE
	anchored = FALSE

	power_state = IDLE_POWER_USE
	active_power_consumption = 300 //Watts, W hope.  Just enough to do the computer and display things.

	var/max_power = 3000000 //MEGAWATTS //INF, WAS 500000
	var/thermal_efficiency = 0.65

	var/obj/machinery/atmospherics/binary/circulator/circ1
	var/obj/machinery/atmospherics/binary/circulator/circ2

	var/last_circ1_gen = 0
	var/last_circ2_gen = 0
	var/last_thermal_gen = 0
	var/stored_energy = 0
	var/lastgen1 = 0
	var/lastgen2 = 0
	var/effective_gen = 0
	var/lastgenlev = 0

/obj/machinery/power/teg/New()
	..()
	desc = initial(desc) + " Rated for [round(max_power/1000)] kW."
	spawn(1)
		reconnect()

//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/teg/proc/reconnect()
	if(circ1)
		circ1.temperature_overlay = null
	if(circ2)
		circ2.temperature_overlay = null
	circ1 = null
	circ2 = null
	if(src.loc && anchored)
		if(src.dir & (EAST|WEST))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)

			if(circ1 && circ2)
				if(circ1.dir != NORTH || circ2.dir != SOUTH)
					circ1 = null
					circ2 = null

		else if(src.dir & (NORTH|SOUTH))
			circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,NORTH)
			circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,SOUTH)

			if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
				circ1 = null
				circ2 = null
	update_icon()

/obj/machinery/power/teg/on_update_icon()
	icon_state = anchored ? "teg-assembled" : "teg-unassembled"
	overlays.Cut()
	if (circ1)
		circ1.temperature_overlay = null
	if (circ2)
		circ2.temperature_overlay = null
	if (stat & (NOPOWER|BROKEN))
		return 1
	else
		if (lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")
			if (circ1 && circ2)
				var/extreme = (lastgenlev > 9) ? "ex" : ""
				if (circ1.last_temperature < circ2.last_temperature)
					circ1.temperature_overlay = "circ-[extreme]cold"
					circ2.temperature_overlay = "circ-[extreme]hot"
				else
					circ1.temperature_overlay = "circ-[extreme]hot"
					circ2.temperature_overlay = "circ-[extreme]cold"
		return 1

/obj/machinery/power/teg/Process()
	if(!circ1 || !circ2 || !anchored || stat & (BROKEN|NOPOWER))
		stored_energy = 0
		return

	updateDialog()

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()

	lastgen2 = lastgen1
	lastgen1 = 0
	last_thermal_gen = 0
	last_circ1_gen = 0
	last_circ2_gen = 0

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/energy_transfer = delta_temperature*air2_heat_capacity*air1_heat_capacity/(air2_heat_capacity+air1_heat_capacity)
			var/heat = energy_transfer*(1-thermal_efficiency)
			last_thermal_gen = energy_transfer*thermal_efficiency

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity
		//playsound(src.loc, 'sound/effects/beam.ogg', 25, 0, 10,  is_ambiance = 1)

	//Transfer the air
	if (air1)
		circ1.air2.merge(air1)
	if (air2)
		circ2.air2.merge(air2)

	//Update the gas networks
	if(circ1.network2)
		circ1.network2.update = 1
	if(circ2.network2)
		circ2.network2.update = 1


	//Exceeding maximum power leads to some power loss
	if(effective_gen > max_power && prob(5))
		//var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		//s.set_up(3, 1, src)
		//s.start()
		stored_energy *= 0.5
		if (powernet)
			powernet.apcs_overload(0, 2, 5)


	//Power
	last_circ1_gen = circ1.return_stored_energy()
	last_circ2_gen = circ2.return_stored_energy()
	stored_energy += last_thermal_gen + last_circ1_gen + last_circ2_gen
	lastgen1 = stored_energy*0.4 //smoothened power generation to prevent slingshotting as pressure is equalized, then restored by pumps
	stored_energy -= lastgen1
	effective_gen = (lastgen1 + lastgen2) / 2

	// update icon overlays and power usage only when necessary
	var/genlev = max(0, min( round(11*effective_gen / max_power), 11))
	if(effective_gen > 100 && genlev == 0)
		genlev = 1
	if(genlev != lastgenlev)
		lastgenlev = genlev
		update_icon()
	add_avail(effective_gen)

/obj/machinery/power/teg/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!default_unfasten_wrench(user, I, 0))
		return
	if(!anchored)
		disconnect()
	else
		connect()

/obj/machinery/power/teg/CanUseTopic(mob/user)
	if(!anchored)
		return STATUS_CLOSE
	return ..()

/obj/machinery/power/teg/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/teg/attack_ghost(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	ui_interact(user)

/obj/machinery/power/teg/attack_hand(mob/user)
	if(..())
		user << browse(null, "window=teg")
		return
	ui_interact(user)

/obj/machinery/power/generator/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.set_dir(turn(src.dir, 90))

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	src.set_dir(turn(src.dir, -90))

/obj/machinery/power/teg/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/teg/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TEG",  name)
		ui.open()

/obj/machinery/power/teg/ui_data(mob/user)
	var/list/data = list()
	if(!powernet)
		data["error"] = "Unable to connect to the power network!"
	else if(cold_circ && hot_circ)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.get_outlet_air()
		var/datum/gas_mixture/cold_circ_air2 = cold_circ.get_inlet_air()
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.get_outlet_air()
		var/datum/gas_mixture/hot_circ_air2 = hot_circ.get_inlet_air()

		data["cold_dir"] = dir2text(cold_dir)
		data["hot_dir"] = dir2text(hot_dir)
		data["output_power"] = round(lastgen)
		// Temps are K, pressures are kPa, power is W
		data["cold_inlet_temp"] = round(cold_circ_air2.temperature, 0.1)
		data["hot_inlet_temp"] = round(hot_circ_air2.temperature, 0.1)
		data["cold_outlet_temp"] = round(cold_circ_air1.temperature, 0.1)
		data["hot_outlet_temp"] = round(hot_circ_air1.temperature, 0.1)
		data["cold_delta_temp"] = data["cold_outlet_temp"] - data["cold_inlet_temp"]
		data["cold_inlet_pressure"] = round(cold_circ_air2.return_pressure(), 0.1)
		data["hot_inlet_pressure"] = round(hot_circ_air2.return_pressure(), 0.1)
		data["cold_outlet_pressure"] = round(cold_circ_air1.return_pressure(), 0.1)
		data["hot_outlet_pressure"] = round(hot_circ_air1.return_pressure(), 0.1)
		data["warning_switched"] = (data["cold_inlet_temp"] > data["hot_inlet_temp"])
		data["warning_cold_pressure"] = (data["cold_inlet_pressure"] < 1000)
		data["warning_hot_pressure"] = (data["hot_inlet_pressure"] < 1000)
	else
		data["error"] = "Unable to locate all parts!"
	return data

/obj/machinery/power/teg/ui_act(action, params)
	if(..())
		return
	if(action == "check")
		if(!powernet || !cold_circ || !hot_circ)
			connect()
			return TRUE


/obj/item/circuitboard/teg
	board_name = "Thermo electric generator"
	icon_state = "engineering"
	build_path = /obj/machinery/power/teg
	board_type = "machine"
	origin_tech = "programming=6;magnets=6;powerstorage=6"
	req_components = list(
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stack/cable_coil = 5,
							//obj/item/stock_parts/matter_bin = 1
							)

/obj/item/circuitboard/circulator
	board_name = "Circulator"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/binary/circulator
	board_type = "machine"
	origin_tech = "programming=2;magnets=4;powerstorage=3"
	req_components = list(
							/obj/item/stack/cable_coil = 5,
							/obj/item/stock_parts/matter_bin = 1
							)
