extends Node2D

signal build
signal click

var level_three = null
var funds_text = null
var total_price = 83000 # orig price * area

var price = 83000
var energy_reserve_cabability = 1 # MWh

var is_dismantling = false
var old_area = 0


func _ready():
	level_three = get_node("/root/level_three")
	funds_text = level_three.get_node("stats_ui/HBoxContainer/funds")


# The canvas keeps the UI items on top of everything
func set_canvas():
	$CanvasLayer.offset = position


func _on_size_slider_drag_ended(_value_changed):
	$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " MWh" + "[/center]"

 
func _on_build_button_pressed():
	# First check that we are not dismantling the item
	if !is_dismantling:
		# Then check if we have money to build this
		if level_three.decrease_funds(price * energy_reserve_cabability):
			$CanvasLayer/size_slider.visible = false
			if !is_connected("build", level_three, "_on_energy_reserve_build_started"):
	# warning-ignore:return_value_discarded
				connect("build", level_three, "_on_energy_reserve_build_started")
			emit_signal("build", energy_reserve_cabability)
			$CanvasLayer/stopwatch.start(energy_reserve_cabability)
			if !is_connected("click", level_three.get_node("mouse_interaction"), "_on_energy_reserve_clicked"):
	# warning-ignore:return_value_discarded
				connect("click", level_three.get_node("mouse_interaction"), "_on_energy_reserve_clicked")
		else:
			get_node("/root/AudioManager").play_bad_click()
			level_three.get_node("stats_ui/HBoxContainer/funds_icon/AnimationPlayer").play("size_pump")
			# Goodbye, i was too expensive
			$kill_timer.start()
	else:
		if energy_reserve_cabability != old_area:
			var difference = (old_area - energy_reserve_cabability) * -1
			emit_signal("build", difference)
			$CanvasLayer/stopwatch.start(difference)
		$CanvasLayer/size_slider.visible = false

func _on_size_slider_value_changed(value):
	$CanvasLayer/size_slider/size_text.bbcode_text = "[center]" + String($CanvasLayer/size_slider.value) + " MWh" + "[/center]"
	var scale_factor = 1 + value / 100
	$Sprite.scale = Vector2(scale_factor, scale_factor)
	energy_reserve_cabability = value
	# Check money
	#total_price = $CanvasLayer/size_slider.value * energy_reserve_cabability
	#print(total_price)
	#funds_text.bbcode_text = String(int(funds_text.bbcode_text) - total_price)


func dismantle():
	is_dismantling = true
	old_area = energy_reserve_cabability
	$CanvasLayer/size_slider.visible = true
	$CanvasLayer/size_slider.max_value = energy_reserve_cabability


func hide_build_ui():
	$CanvasLayer/size_slider.visible = false


func _on_Sprite_click():
	emit_signal("click", self)


func _on_kill_timer_timeout():
	queue_free()
