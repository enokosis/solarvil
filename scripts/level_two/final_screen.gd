extends Node2D

var score = 0

onready var score_label = $ColorRect/VBoxContainer/ScoreLabel
onready var main_menu_button = $ColorRect/VBoxContainer/MainMenuButton
onready var tween = $Tween

func _ready():
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	var screen_size = get_viewport_rect().size
	$ColorRect.rect_min_size = Vector2(400, 200)  # Adjust the size accordingly
	$ColorRect.rect_position = (screen_size - $ColorRect.rect_min_size) / 2
	
	# Fetch score from the global script
	score = GameData.score
	
	score_label.text = "Score: " + str(score)
	main_menu_button.connect("pressed", self, "_on_MainMenuButton_pressed")

	# Start the animation
	$ColorRect.modulate = Color(1, 1, 1, 0)
	tween.interpolate_property($ColorRect, "modulate", $ColorRect.modulate, Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_MainMenuButton_pressed():
	get_tree().paused = false  # Unpause the game before changing scene
	get_tree().change_scene("res://scenes/level_three/level_three.tscn")
