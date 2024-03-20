extends Node2D

signal infra_placed
signal infra_modified
signal step_back

# Handled the instantiation and modification of infrastructure scenes
# Knows which infra item is currently selected by the player
# and if the player is clicking on the playable area

onready var level_three = $".."
onready var audio_manager = get_node("/root/AudioManager")
var selected_infrastructure = ""
var infra_amount = 1
var play_area_has_focus = false

var house_scene = preload("res://scenes/level_three/house.tscn")
var solar_collector_scene = preload("res://scenes/level_three/solar_collector.tscn")
var energy_reserve_scene = preload("res://scenes/level_three/energy_reserve.tscn")

# Undo logic
#var previous_placed_items = []

func _process(_delta):
	if Input.is_action_just_pressed("click") and play_area_has_focus:
		if selected_infrastructure == "solar_collector":
			add_solar_collector()
		elif selected_infrastructure == "energy_reserve":
			add_energy_reserve()
	if Input.is_action_just_pressed("right_click"):
		if selected_infrastructure != "":
			clear_selected_infrastructure()
			$"../infra_panel".hide_highlights()
		if level_three.game_state == level_three.GAME_STATE.INFRA_PLACED:
			emit_signal("step_back")
		if level_three.game_state == level_three.GAME_STATE.INFRA_MODIFY:
			emit_signal("step_back")


func add_solar_collector():
	var solar_collector = solar_collector_scene.instance()
	solar_collector.position = get_global_mouse_position()
	solar_collector.set_canvas()
	solar_collector.get_node("CanvasLayer/size_slider").visible = true
	$YSort.add_child(solar_collector)
	#previous_placed_items.append(solar_collector)
	emit_signal("infra_placed", solar_collector)
	audio_manager.play_good_click()
	#print(solar_collector.get_node("CanvasLayer/size_slider").visible)


func add_energy_reserve():
	var energy_reserve = energy_reserve_scene.instance()
	energy_reserve.position = get_global_mouse_position()
	energy_reserve.set_canvas()
	energy_reserve.get_node("CanvasLayer/size_slider").visible = true
	$YSort.add_child(energy_reserve)
	#previous_placed_items.append(energy_reserve)
	emit_signal("infra_placed", energy_reserve)
	audio_manager.play_good_click()


func clear_selected_infrastructure():
	selected_infrastructure = ""
	infra_amount = 1


func _on_infra_item_clicked(item):
	if !level_three.game_state == level_three.GAME_STATE.BUILD_IN_PROGRESS and !level_three.game_state == level_three.GAME_STATE.INFRA_PLACED:
		emit_signal("infra_modified", item)
		item.dismantle()

# dead code
func _on_solarpanel_clicked(item):
	if !level_three.game_state == level_three.GAME_STATE.BUILD_IN_PROGRESS and !level_three.game_state == level_three.GAME_STATE.INFRA_PLACED:
		emit_signal("infra_modified", item)
		item.dismantle()
	#if selected_infrastructure == "remover":
		#if item.area > 1:
			#emit_signal("infra_modified")
			#item.dismantle()
		#else:
			#audio_manager.play_bad_click()
func _on_energy_reserve_clicked(item):
	if !level_three.game_state == level_three.GAME_STATE.BUILD_IN_PROGRESS and !level_three.game_state == level_three.GAME_STATE.INFRA_PLACED:
		emit_signal("infra_modified", item)
		item.dismantle()


# These make sure that and item can only be added
# when the mouse is hovering on top of the playable area
# would not work on mobile, as there is no hover

func _on_ColorRect_mouse_entered():
	play_area_has_focus = true


func _on_ColorRect_mouse_exited():
	play_area_has_focus = false


func _on_TextureRect_mouse_entered():
	play_area_has_focus = true


func _on_TextureRect_mouse_exited():
	play_area_has_focus = false
