extends Node2D

var final_screen_scene = preload("res://scenes/level_two/final_screen.tscn")

onready var countdown_timer = $CountdownTimer
onready var time_label = $TimeLabel
onready var dimmer = $Dimmer

func _ready():
	countdown_timer.wait_time = 60
	#countdown_timer.start()
	countdown_timer.connect("timeout", self, "_on_CountdownTimer_timeout")
	
	dimmer.visible = false  # Ensure dimmer is not visible at the start

func _process(delta):
	#time_label.text = "Session: " + GameData.session_id + " Time remaining: " + str(int(countdown_timer.time_left))+"s"
	time_label.text = "Aikaa jäljellä: " + str(int(countdown_timer.time_left))+"s"


func start_timer():
	countdown_timer.start()


func _on_CountdownTimer_timeout():
	# hack for the demo
	pass
	#dimmer.visible = true

	#var final_screen = final_screen_scene.instance()
	#final_screen.pause_mode = Node.PAUSE_MODE_PROCESS
	
	#add_child(final_screen)
	#get_tree().paused = true
