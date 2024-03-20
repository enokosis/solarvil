extends Node2D

signal build
signal click

var price = 500 #
var area = 1 # m2
var energy_production = 0 # kWh

var is_dismantling = false
var old_area = 0


# The canvas keeps the UI items on top of everything
func set_canvas():
	$CanvasLayer.offset = position


func _on_size_slider_drag_ended(value_changed):
	$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " m2" + "[/center]"

 
func _on_build_button_pressed():
	if !is_dismantling:
		# Check if we have money to build this
		if get_node("/root/level_three").decrease_funds(price * area):
			if !is_connected("build", get_node("/root/level_three"), "_on_solarpanel_build_started"):
				# warning-ignore:return_value_discarded
				connect("build", get_node("/root/level_three"), "_on_solarpanel_build_started")
			emit_signal("build", area)
			$CanvasLayer/size_slider.visible = false
			$CanvasLayer/stopwatch.start(area)
			if !is_connected("click", get_node("/root/level_three").get_node("mouse_interaction"), "_on_solarpanel_clicked"):
				# warning-ignore:return_value_discarded
				connect("click", get_node("/root/level_three").get_node("mouse_interaction"), "_on_solarpanel_clicked")
		else:
			get_node("/root/AudioManager").play_bad_click()
			get_node("/root/level_three/stats_ui/HBoxContainer/funds_icon/AnimationPlayer").play("size_pump")
			# Goodbye, i was too expensive
			$kill_timer.start()
			
	else:
		if area != old_area:
			var difference = (old_area - area) * -1
			emit_signal("build", difference)
			$CanvasLayer/stopwatch.start(difference)
		$CanvasLayer/size_slider.visible = false


func _on_size_slider_value_changed(value):
	$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " m2" + "[/center]"
	var scale_factor = 1 + value / 1000
	$Sprite.scale = Vector2(scale_factor, scale_factor)
	area = value


func dismantle():
	is_dismantling = true
	old_area = area
	$CanvasLayer/size_slider.visible = true
	$CanvasLayer/size_slider.max_value = area


func hide_build_ui():
	$CanvasLayer/size_slider.visible = false


func _on_Sprite_click():
	emit_signal("click", self)


func _on_kill_timer_timeout():
	queue_free()
