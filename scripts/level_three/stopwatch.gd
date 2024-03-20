extends Control

signal build_finished
var build_time = 0

func _process(_delta):
	$timer_text.bbcode_text = String(int($Timer.time_left)) + " s"


func start(area):
	visible = true
	build_time = abs(area)
	#$Timer.start(abs(float(area)/100)) # For debugging only
	$Timer.start(abs(area))
	$AnimationPlayer.play("size_pump")
	if !is_connected("build_finished", get_node("/root/level_three"), "_on_build_finished"):
		# warning-ignore:return_value_discarded
		connect("build_finished", get_node("/root/level_three"), "_on_build_finished")


func _on_Timer_timeout():
	visible = false
	emit_signal("build_finished")
