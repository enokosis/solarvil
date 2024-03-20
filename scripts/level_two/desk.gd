extends Control

onready var sensor_sahko = $Sensor_sahko
onready var sensor_lammitus = $Sensor_lammitys
onready var sensor_lampotila = $Sensor_lampotila
onready var sensor_sateilu = $Sensor_sateilu
onready var answer_machine = $answer_machine

# DEBUG ONLY
export var is_debug = false

func _ready():
	print("Desk entered")
	if !is_debug:
		set_visibility_based_on_role()

func set_visibility_based_on_role():
	print(GameData.get_player_role())


	answer_machine.visible = GameData.get_player_role() == "Pelinjohtaja"

	$countdown_timer.visible = GameData.get_player_role() == "Pelinjohtaja"

	
	# Resetting visibility of all sensors
	set_all_sensors_visibility(false)
	
	
	match GameData.get_player_role():
		"Pelinjohtaja":
			choose_random_sensor_for_gamemaster()
		"Energiakonsultti":
			sensor_sahko.visible = true
			sensor_sateilu.visible = true
		"LVI-suunnittelija":
			sensor_lammitus.visible = true
			sensor_lampotila.visible = true
		"Yleishenkilö Jantunen":
			set_all_sensors_visibility(true)
			
#	match int(GameData.get_team_size()):
#		1:  # Single player
#			set_all_sensors_visibility(true)
#
#		2:  # Two players
#			if GameData.get_player_role() == "Pelinjohtaja":
#				sensor_lammitus.visible = true
#				sensor_sateilu.visible = true
#			else:  # The other player
#				sensor_lampotila.visible = true
#				sensor_sahko.visible = true
#
#		3:  # Three players
#			match GameData.get_player_role():
#				"Pelinjohtaja":
#					choose_random_sensor_for_gamemaster()
#				"Energiakonsultti":
#					sensor_sahko.visible = true
#					sensor_sateilu.visible = true
#				"LVI-suunnittelija":
#					sensor_lammitus.visible = true
#					sensor_lampotila.visible = true
#				"Yleishenkilö Jantunen":
#					set_all_sensors_visibility(true)

func set_all_sensors_visibility(is_visible: bool):
	sensor_sahko.visible = is_visible
	sensor_lammitus.visible = is_visible
	sensor_lampotila.visible = is_visible
	sensor_sateilu.visible = is_visible
	
	
func choose_random_sensor_for_gamemaster():
	var sensors = [sensor_sahko, sensor_lammitus, sensor_lampotila, sensor_sateilu]
	set_all_sensors_visibility(false)  # Make sure all are invisible first
	var random_index = randi() % sensors.size()
	sensors[random_index].visible = true


func _on_intro_dialogue_box_dialogue_ended():
	$countdown_timer.start_timer()
