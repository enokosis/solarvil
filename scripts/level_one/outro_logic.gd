extends Node

# Level 1 outro logic

onready var data = get_node("/root/GameData")
var outro_index = 0
onready var outro_length = 5
var player_name = ""
var player_info = ""

func _on_next_dialogue_pressed():
	outro_index += 1
	if outro_index == 1:
		$"../outro_dialogue_box/naming".visible = true
		$"../outro_dialogue_box/Panel/next_dialogue".visible = false
	elif outro_index == outro_length-2:
		$"../outro_dialogue_box/Panel/next_dialogue".visible = false
		$"../outro_dialogue_box/save_game".visible = true


func _on_save_game_pressed():
	data.player_name = player_name
	GameData.player_full_info = player_info
	# if player gets here and quit, game should load level two next
	data.current_level = 2
	data.save_progression()
	get_tree().change_scene("res://scenes/lobby.tscn")


func _on_apply_name_pressed():
	if $"../outro_dialogue_box/naming/name_input/first_name".text != "" and $"../outro_dialogue_box/naming/name_input/last_name".text != "" and $"../outro_dialogue_box/naming/name_input/student_number".text != "":
		$"../outro_dialogue_box/Panel/next_dialogue".visible = true
		$"../outro_dialogue_box/naming".visible = false
		player_name = $"../outro_dialogue_box/naming/name_input/first_name".text
		player_info = $"../outro_dialogue_box/naming/name_input/first_name".text + " " +  $"../outro_dialogue_box/naming/name_input/last_name".text + " " + $"../outro_dialogue_box/naming/name_input/student_number".text
		GameData.player_student_number = int($"../outro_dialogue_box/naming/name_input/student_number".text)
		print(player_info)
		$"../outro_dialogue_box".next_dialogue()
		$"../outro_dialogue_box/Panel/dialogue/5".bbcode_text = "Hauska tavata " + player_name + "! \nOlet nyt valmis siirtymään eteenpäin."
