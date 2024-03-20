extends TextureButton


func _ready():
	pass

func _on_exit_level_pressed():
	$"../exit_level_dialogue".visible = true


func _on_yes_pressed():
	GameData.current_level = 3
	GameData.save_progression()
	get_tree().change_scene("res://scenes/lobby.tscn")


func _on_no_pressed():
	$"../exit_level_dialogue".visible = false
