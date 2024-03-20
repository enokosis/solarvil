extends Node

onready var data = get_node("/root/GameData")
onready var level_three = $".."

#var exit_dialogue_index = 0

func _on_door_button_pressed():
	save()
	$"../report_and_quit_panel/HBoxContainer/door_button/saved_message/AnimationPlayer".play("saved_message")


func save():
	data.saved_time = OS.get_unix_time()
	data.current_level = 3
	data.has_started_level_3 = true
	data.current_energy_reserve_cabability = level_three.current_energy_reserve_cabability
	data.current_solar_collector_area = level_three.current_solar_collector_area
	data.current_funds = level_three.current_funds
	GameData.backup_var_1 = str(level_three.used_turns)
	GameData.stage_three_score = $"..".player_score
	data.save_progression()


func _on_quit_game_pressed():
	$"../CanvasLayer/exit_level_dialogue".visible = true

func _on_next_dialogue_pressed():
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/next_dialogue".visible = false
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/yes".visible = true
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/no".visible = true


func _on_yes_pressed():
	# if these conditions are met, something is wrong!
	if level_three.player_score == 0 and level_three.current_solar_collector_area >= 31:
		print("Something wrong with the scoring, recalculating...")
		if !level_three.recalculate_player_score():
			print("For some reason, your score cannot be calculated.")
	GameData.current_level = 4
	GameData.backup_var_1 = str(level_three.used_turns)
	GameData.stage_three_score = $"..".player_score
	GameData.save_progression()
	get_tree().change_scene("res://scenes/lobby.tscn")


func _on_no_pressed():
	$"../CanvasLayer/exit_level_dialogue".visible = false
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/next_dialogue".visible = true
	$"../CanvasLayer/exit_level_dialogue/dialogue_box".dialogue_index = 0
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/yes".visible = false
	$"../CanvasLayer/exit_level_dialogue/dialogue_box/Panel/no".visible = false
