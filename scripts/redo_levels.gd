extends Node


func _on_redo_stage_3_pressed():
	GameData.current_level = 3
	GameData.has_started_level_3 = false
	GameData.stage_three_score = 0
	GameData.backup_var_0 = ""
	GameData.save_progression()
	get_tree().change_scene("res://scenes/level_three/level_three.tscn")
