extends Node2D

signal build
signal click
signal modify

var level_three = null
var tool_selection = null
export var price = 500 #
export var area = 1 # m2 or mwh
export var timer_multiplier = 1
export(String, "solar_collector", "energy_reserve") var type

var energy_production = 0 # kWh for solar collector

var is_dismantling = false
var old_area = 0

var scale_factor
var time_left_in_timer = 0 # if the game is saved and quit while a timer is on, it's saved here
var is_saved = false


func _ready():
	level_three = get_node("/root/level_three")
	tool_selection = level_three.get_node("infra_panel")


func init():
	if is_saved:
		print("i was saved and loaded")
		# Setup based on saved data
		if type == "solar_collector":
			scale_factor = 1 + area / 1000
		elif type == "energy_reserve":
			scale_factor = 1 + area / 100
		$Sprite.scale = Vector2(scale_factor, scale_factor)
		# There is still a timer running
		if time_left_in_timer != 0:
			level_three.game_state = level_three.GAME_STATE.BUILD_IN_PROGRESS
			time_left_in_timer = time_left_in_timer - GameData.difference_between_times
			if time_left_in_timer < 0:
				time_left_in_timer = 0
			$CanvasLayer/stopwatch.start(time_left_in_timer)
		set_canvas()
		#$CanvasLayer/size_slider.max_value = area
		#$CanvasLayer/size_slider.value = area
		if !is_connected("click", level_three.get_node("mouse_interaction"), "_on_infra_item_clicked"):
			# warning-ignore:return_value_discarded
			connect("click", level_three.get_node("mouse_interaction"), "_on_infra_item_clicked")


# The canvas keeps the UI items on top of everything
func set_canvas():
	$CanvasLayer.offset = position


func _on_size_slider_drag_ended(value_changed):
	area = $CanvasLayer/size_slider.value
	if type == "solar_collector":
		$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " m2" + "[/center]"
	elif type == "energy_reserve":
		$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " MWh" + "[/center]"
	$CanvasLayer/size_slider/price_text.bbcode_text = "[center]-" + String(area * price) + "€[/center]"
	tool_selection.update_energy_reserve_price()

 
func _on_build_button_pressed():
	if !is_dismantling:
		# This is now done before calling this function
		# Check if we have money to build this
		#if level_three.decrease_funds(price * area):
		add_to_group("persist")
		$CanvasLayer/size_slider.visible = false
		# Start the stopwatch
		$CanvasLayer/stopwatch.start(area * timer_multiplier)
		if !is_connected("build", level_three, "_on_infra_item_build_started"):
			# warning-ignore:return_value_discarded
			connect("build", level_three, "_on_infra_item_build_started")
		emit_signal("build", area, type)
		# connect click signal
		if !is_connected("click", level_three.get_node("mouse_interaction"), "_on_infra_item_clicked"):
				# warning-ignore:return_value_discarded
				connect("click", level_three.get_node("mouse_interaction"), "_on_infra_item_clicked")
#		else:
#			get_node("/root/AudioManager").play_bad_click()
#			get_node("/root/level_three/stats_ui/HBoxContainer/funds_icon/AnimationPlayer").play("size_pump")
#			# Goodbye, i was too expensive
#			$CanvasLayer/size_slider/price_text.modulate = Color.red
#			$CanvasLayer/size_slider/price_text/AnimationPlayer.play("size_pump")
#			$kill_timer.start(10)
			
	else:
		if area != old_area:
			if !is_connected("modify", level_three, "_on_infra_item_modify_started"):
				# warning-ignore:return_value_discarded
				connect("modify", level_three, "_on_infra_item_modify_started")
			#var difference = (old_area - area) * -1
			#emit_signal("build", difference, type)
			emit_signal("modify", area, type)
			$CanvasLayer/stopwatch.start(area * timer_multiplier)
		$CanvasLayer/size_slider.visible = false


func _on_size_slider_value_changed(value):
	if type == "solar_collector":
		$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String(value) + " m2" + "[/center]"
		scale_factor = 1 + value / 1000
	elif type == "energy_reserve":
		$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String(value) + " MWh" + "[/center]"
		scale_factor = 1 + value / 100
	$CanvasLayer/size_slider/price_text.bbcode_text = "[center]-" + String(value * price) + "€[/center]"
	$Sprite.scale = Vector2(scale_factor, scale_factor)
	area = value
	tool_selection.update_energy_reserve_price()


func dismantle():
	is_dismantling = true
	old_area = area
	$CanvasLayer/size_slider.visible = true
	$CanvasLayer/size_slider.max_value = area
	$CanvasLayer/size_slider.value = area


func hide_build_ui():
	$CanvasLayer/size_slider.visible = false


func _on_Sprite_click():
	emit_signal("click", self)


func too_expensive():
	get_node("/root/AudioManager").play_bad_click()
	get_node("/root/level_three/stats_ui/HBoxContainer/funds_icon/AnimationPlayer").play("size_pump")
	# Goodbye, i was too expensive
	$CanvasLayer/size_slider/price_text.modulate = Color.red
	$CanvasLayer/size_slider/price_text/AnimationPlayer.play("size_pump")
	$kill_timer.start(10)


func _on_kill_timer_timeout():
	get_node("/root/level_three/stats_ui/HBoxContainer/funds_icon/AnimationPlayer").stop()
	# Goodbye, i was too expensive
	$CanvasLayer/size_slider/price_text.modulate = Color.white
	$CanvasLayer/size_slider/price_text/AnimationPlayer.stop()
	$kill_timer.start(10)
	#queue_free()


func save():
	print("i was saved")
	if time_left_in_timer != 0: # So, this is the item with the highest active timer
		time_left_in_timer = $CanvasLayer/stopwatch/Timer.time_left
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"time_left_in_timer": time_left_in_timer,
		"area": area,
		"is_saved": true,
		"type": type
	}
	return save_dict


func _on_stopwatch_build_finished():
	time_left_in_timer = 0
