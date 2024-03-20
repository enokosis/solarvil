extends Button


func _on_next_level_pressed():
	GameData.current_level = 3
	get_tree().change_scene("res://scenes/lobby.tscn")
