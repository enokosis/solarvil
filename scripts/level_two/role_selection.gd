extends Control

#onready var welcome_label = $holder/WelcomeLabel
onready var role_buttons = $holder/RoleButtons
onready var key_display_label = $holder/KeyDisplayInputContainer/KeyDisplayLabel
onready var key_input_field = $holder/KeyDisplayInputContainer/KeyInputField
onready var team_size_label = $holder/TeamSizeContainer/TeamSizeLabel
onready var team_size_spin_box = $holder/TeamSizeContainer/TeamSizeSpinBox
onready var start_game_button = $StartGameButton

var game_key = ""
var selected_role = ""
var player_team = 1 # Index on Työryhmä spinbox

func _ready():
	
	# Connect button signals
	role_buttons.get_node("GameMasterButton").connect("pressed", self, "_on_GameMaster_selected")
	role_buttons.get_node("SolarEngineerButton").connect("pressed", self, "_on_SolarEngineer_selected")
	role_buttons.get_node("ElectricianButton").connect("pressed", self, "_on_Electrician_selected")
	start_game_button.connect("pressed", self, "_on_StartGameButton_pressed")
	
	game_key = GameData.game_keys[$holder/SpinBox.value]

	# Set button text
	#role_buttons.get_node("GameMasterButton").text = "Choose: Game Master"
	#role_buttons.get_node("SolarEngineerButton").text = "Choose: Solar Engineer"
	#role_buttons.get_node("ElectricianButton").text = "Choose: Electrician"
	#start_game_button.text = "Press to Start Game When Ready"

	# Initialize UI text
	#welcome_label.text = "Welcome to the game! Please select your role and share the game key with other players."
	team_size_label.text = "Select Team Size:"

	# Configure SpinBox
	team_size_spin_box.min_value = 1
	team_size_spin_box.max_value = 3
	team_size_spin_box.step = 1
	team_size_spin_box.value = 1  # Initial value
	
	# Select the role automatically for the player based on their test result
	if GameData.player_role != "":
		if GameData.player_role == "LVI-suunnittelija":
			$holder/RoleButtons/ElectricianButton.pressed = true
			_on_Electrician_selected()
		elif GameData.player_role == "Yleishenkilö Jantunen":
			$holder/RoleButtons/jantunen_button.pressed = true
			_on_jantunen_button_pressed()
		elif GameData.player_role == "Energiakonsultti":
			$holder/RoleButtons/SolarEngineerButton.pressed = true
			_on_SolarEngineer_selected()
			

func _on_GameMaster_selected():
	selected_role = "Pelinjohtaja"
	# I modified this to use predetermined game_keys, found in an array in GameData
	# This way each team has the same key
	#game_key = str(randi() % 900_000 + 100_000)  # Generate a random 6-digit number
	#key_display_label.text = "Game Key: " + game_key
	#key_input_field.visible = false
	start_game_button.disabled = false

func _on_SolarEngineer_selected():
	selected_role = "Energiakonsultti"
	#key_display_label.text = "Enter Game Key:"
	#key_input_field.visible = true
	start_game_button.disabled = false

func _on_Electrician_selected():
	selected_role = "LVI-suunnittelija"
	#key_display_label.text = "Enter Game Key:"
	#key_input_field.visible = true
	start_game_button.disabled = false

func _on_jantunen_button_pressed():
	selected_role = "Yleishenkilö Jantunen"
	start_game_button.disabled = false
	
func _on_StartGameButton_pressed():
	#if selected_role in ["SolarEngineer", "Electrician"] and #key_input_field.text == "":
		#print("Please enter the game key.")
		#return

	#var session_key = game_key if selected_role == "GameMaster" else key_input_field.text
	var session_key = String(game_key)
	print(session_key)
	# Set session id and player role in GameData
	GameData.set_session_id(session_key)
	GameData.set_player_role(selected_role)
	GameData.set_team_size(team_size_spin_box.value)  # Store the selected team size
	
	# Transition to the main game scene
	get_tree().change_scene("res://scenes/level_two/desk.tscn")


func _on_SpinBox_value_changed(value):
	player_team = value
	GameData.team_name = player_team
	game_key = GameData.game_keys[value]


func _on_info_pressed():
	$info_pop_up_window.visible = true
