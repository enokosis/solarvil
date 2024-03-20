extends Control


# Accessing the singleton data scene
onready var game_data = get_node("/root/GameData")


func _ready():
	game_data.current_level = 2
