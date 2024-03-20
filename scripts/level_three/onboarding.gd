extends Node

# Handles the onboarding logic for level three
# Guides the player thru building their first solar collector

var has_read_instructions = false
var has_selected_solarpanel = false
var has_tried_undo = false
var has_selected_solarpanel_again = false
var has_placed_solarpanel = false
var has_changed_solarpanel_scale = false
var has_started_build = false
var has_triggered_joke = false
var has_finished_building = false

var has_finished_onboarding = false


# Called when the node enters the scene tree for the first time.
func _ready():
	#$"../intro_dialogue_box".visible = true
	pass


# warning-ignore:unused_argument
func _process(_delta):
	if Input.is_action_just_pressed("right_click"):
		# Tool onboarding
		if has_selected_solarpanel and !has_tried_undo:
			has_tried_undo = true
			$"../tool_dialogue_box".next_dialogue()
			# Allows player to touch the background.
			$"../tool_dialogue_box/background_color".visible = false
			$"../tool_dialogue_box/sc_button".visible = true
# warning-ignore:return_value_discarded
			$"../infra_panel/HBoxContainer/sc_button".connect("pressed", self, "sc_selected_again")
	if Input.is_action_just_pressed("click") and $"../mouse_interaction".play_area_has_focus:
		# Tool onboarding
		if has_tried_undo and !has_placed_solarpanel and has_selected_solarpanel_again:
			has_placed_solarpanel = true
			$"../tool_dialogue_box".next_dialogue()
# warning-ignore:return_value_discarded
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/size_slider").connect("drag_started", self, "sc_size_change")
# warning-ignore:return_value_discarded
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/size_slider/build_button").connect("pressed", self, "sc_build_started")
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/size_slider/build_button").disabled = true
	if has_started_build and !has_finished_building and !has_triggered_joke:
		var timer = $"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch/Timer")
		if timer.time_left > 15 and timer.time_left < 16:
			has_triggered_joke = true
			$"../tool_dialogue_box".next_dialogue()


func _on_info_pop_up_window_pop_up_closed():
	if !has_read_instructions:
		has_read_instructions = true
		$"../info_button_dialogue_box".visible = true
		$"../info/AnimationPlayer".play("pump_scale")


func _on_intro_dialogue_box_dialogue_ended():
	$"../info"._on_info_pressed()


# simple version ends here!
func _on_info_button_dialogue_box_dialogue_ended():
	#$"../simple_tool_dialogue".visible = true
	#$"../tool_dialogue_box".visible = true
	$"../info/AnimationPlayer".stop()
	$"../infra_panel/buttons_animation".play("level_threebuttons_pump")
	#$AnimationPlayer.play("solar_panel_size_pump")


# Tool onboarding
func _on_sc_button_pressed():
	$AnimationPlayer.stop()
	$"../tool_dialogue_box/sc_button".visible = false
	$"../infra_panel/HBoxContainer/sc_button".emit_signal("pressed")
	$"../tool_dialogue_box".next_dialogue()
	has_selected_solarpanel = true

func sc_selected_again():
	if !has_selected_solarpanel_again:
		has_selected_solarpanel_again = true

func sc_size_change():
	if !has_changed_solarpanel_scale:
		has_changed_solarpanel_scale = true
		$"../tool_dialogue_box".next_dialogue()
		$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/size_slider/build_button").disabled = false


func sc_build_started():
	if !has_started_build:
		# Ugly way to make sure the timer has started before we try to modify it
		if $"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch/Timer").time_left == 0:
			yield(get_tree().create_timer(0.1),"timeout")
			sc_build_started()
		else:
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch/Timer").stop()
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch/Timer").start(30)
			# warning-ignore:return_value_discarded
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch/Timer").connect("timeout", self, "sc_build_finished")
			has_started_build = true
			$"../tool_dialogue_box".next_dialogue()
			# remove timer timeout connection from level three so we can step in
			# no need to worry about reconnecting, it's done each time teh build button is pressed
			$"../mouse_interaction/YSort".get_child(0).get_node("CanvasLayer/stopwatch").disconnect("build_finished", $"..", "_on_build_finished")


func sc_build_finished():
	has_finished_building = true
	$"../tool_dialogue_box".next_dialogue()
	$"../tool_dialogue_box/Panel/next_dialogue".visible = true


# This is the end of the onboarding
func _on_next_dialogue_pressed():
	has_finished_onboarding = true
	$"..".calculate_turn_score()
	queue_free()
