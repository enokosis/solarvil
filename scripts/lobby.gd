extends Control


onready var move_button = $move_to_scene

func _ready():
	if GameData.current_level == 2:
		move_button.text = "Siirry tasolle 2"
		$message/message.bbcode_text = "[center]Kootkaa työryhmänne ja aloittakaa peli yhdessä.[/center]"
	elif GameData.current_level == 3:
		move_button.text = "Siirry tasolle 3"
		$message/message.bbcode_text = "[center]Kun olet valmis, siirry eteenpäin.[/center]"
	elif GameData.current_level == 4:
		move_button.text = "Siirry leaderboardiin"
		$message/message.bbcode_text = "[center]Siirry lähettämään pisteesi leaderboardiin.[/center]"


func _on_move_to_scene_pressed():
	if GameData.current_level == 2:
		get_tree().change_scene("res://scenes/level_two/role_selection.tscn")
	elif GameData.current_level == 3:
		get_tree().change_scene("res://scenes/level_three/level_three.tscn")
	elif GameData.current_level == 4:
		get_tree().change_scene("res://scenes/leaderboard.tscn")
