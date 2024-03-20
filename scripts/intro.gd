extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer_TeamName/Label.text = "Team Name:"
	$VBoxContainer/HBoxContainer_Role/Label.text = "Role:"

	theme = preload("res://ui/basic_theme.tres")
	#Conenct buttons to functions
	$VBoxContainer/VBoxContainer2/Stage2.connect("pressed", self, "_on_Stage2Button_pressed")
	$VBoxContainer/VBoxContainer2/Stage3.connect("pressed", self, "_on_Stage3Button_pressed")

	#role dropdown menu
	$VBoxContainer/HBoxContainer_Role/RoleChoiceMenu.add_item("Game master")
	$VBoxContainer/HBoxContainer_Role/RoleChoiceMenu.add_item("Solar engineer")
	$VBoxContainer/HBoxContainer_Role/RoleChoiceMenu.add_item("Electrician")

# Function to handle Stage 2 button press
func _on_Stage2Button_pressed():
	on_Stage_choice()
	get_tree().change_scene("res://scenes/level_two/role_selection.tscn")

# Function to handle Stage 3 button press
func _on_Stage3Button_pressed():
	on_Stage_choice()
	get_tree().change_scene("res://scenes/level_three/level_three.tscn")

func on_Stage_choice():
	GameData.team_name = $VBoxContainer/HBoxContainer_TeamName/TeamName.text  # assuming LineEdit node is named "TeamNameLineEdit"
	GameData.player_role = $VBoxContainer/HBoxContainer_Role/RoleChoiceMenu.get_text()  # assuming OptionButton node is named "RoleOptionButton"
	GameData.save_progression()




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
