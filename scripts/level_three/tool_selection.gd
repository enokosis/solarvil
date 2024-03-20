extends Panel

# Controls which infrastructure item is selected
# toggle between an item
# send information to the node that handles the instantiation of the infra scenes
# also handles other building logic

signal builds_reset

onready var level_three = $".."
onready var mouse_interaction = $"../mouse_interaction"
onready var selected_highlights = [$HBoxContainer/house_button/selected, $HBoxContainer/sc_button/selected, $HBoxContainer/er_button/selected, $HBoxContainer/remover_button/selected]

onready var buttons = [$HBoxContainer/house_button, $HBoxContainer/sc_button, $HBoxContainer/er_button, $HBoxContainer/remover_button]
onready var amount_panel = $"../infra_amount_panel"

var is_infra_hidden = false

# Building logic
var is_build_button_visible = false
var to_be_built = []
var is_modify_button_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_highlights()


func hide_highlights():
	for highlight in selected_highlights:
		highlight.visible = false
	$"../infra_ghost".visible = false


# there's a smarter way to do the toggling between highlighted items
# i'm too lazy to figure it out now

# dead code
func _on_house_button_pressed():
	if selected_highlights[0].visible != true:
		hide_highlights()
		selected_highlights[0].visible = true
		mouse_interaction.selected_infrastructure = "house"
		show_amount_panel(0)
	else:
		hide_highlights()
		amount_panel.visible = false
		mouse_interaction.clear_selected_infrastructure()


func _on_sc_button_pressed():
	# We can only build when nothing else is happening
	if !level_three.game_state == level_three.GAME_STATE.INFRA_MODIFY and !level_three.game_state == level_three.GAME_STATE.BUILD_IN_PROGRESS:
		if selected_highlights[1].visible != true:
			hide_highlights()
			selected_highlights[1].visible = true
			mouse_interaction.selected_infrastructure = "solar_collector"
			#show_amount_panel(1)
			$"../infra_ghost".visible = true
			$"../infra_ghost".switch_to_solar_panel()
		else:
			hide_highlights()
			amount_panel.visible = false
			mouse_interaction.clear_selected_infrastructure()
	if $buttons_animation.is_playing():
		$buttons_animation.stop()


func _on_er_button_pressed():
	if !level_three.game_state == level_three.GAME_STATE.INFRA_MODIFY and !level_three.game_state == level_three.GAME_STATE.BUILD_IN_PROGRESS:
		if selected_highlights[2].visible != true:
			hide_highlights()
			selected_highlights[2].visible = true
			mouse_interaction.selected_infrastructure = "energy_reserve"
			#show_amount_panel(2)
			$"../infra_ghost".visible = true
			$"../infra_ghost".switch_to_energy_reserve()
		else:
			hide_highlights()
			amount_panel.visible = false
			mouse_interaction.clear_selected_infrastructure()
	if $buttons_animation.is_playing():
		$buttons_animation.stop()

# dead code
func show_amount_panel(button_index):
	amount_panel.visible = false # hack to make the on_visibility_change signal trigger
	amount_panel.visible = true
	amount_panel.rect_global_position = buttons[button_index].rect_global_position
	amount_panel.rect_global_position -= Vector2(90/2, 120/2)


func _on_mouse_interaction_infra_placed(item):
	hide_highlights()
	mouse_interaction.clear_selected_infrastructure()
	to_be_built.append(item)
	#$AnimationPlayer.play("toggle_infra_ui")
	#is_infra_hidden = true 

# dead code
func _on_remover_button_pressed():
	if selected_highlights[3].visible != true:
		hide_highlights()
		selected_highlights[3].visible = true
		mouse_interaction.selected_infrastructure = "remover"
		#show_amount_panel(2)
		$"../infra_ghost".visible = true
		$"../infra_ghost".switch_to_remover()
	else:
		hide_highlights()
		amount_panel.visible = false
		mouse_interaction.clear_selected_infrastructure()


func show_infra_panel():
	$AnimationPlayer.play_backwards("toggle_infra_ui")
	is_infra_hidden = false
	print("Revealing infra panel.")


func _on_mouse_interaction_infra_modified(item):
	show_modify_button()
	if !to_be_built.has(item):
		to_be_built.append(item)


func show_build_button():
	if !is_build_button_visible:
		$build/AnimationPlayer.play("reveal_button")
		is_build_button_visible = true


func hide_build_button():
	$build/AnimationPlayer.play_backwards("reveal_button")
	is_build_button_visible = false


func show_modify_button():
	if !is_modify_button_visible:
		$modify/AnimationPlayer.play("reveal_button")
		is_modify_button_visible = true


func hide_modify_button():
	$modify/AnimationPlayer.play_backwards("reveal_button")
	is_modify_button_visible = false


# Undo logic
func step_back():
	if level_three.game_state == level_three.GAME_STATE.INFRA_PLACED:
		if to_be_built.size() == 1:
			#$"../stats_ui/HBoxContainer/funds".bbcode_text = String(int($"../stats_ui/HBoxContainer/funds".bbcode_text) + to_be_built[0].total_price)
			to_be_built[0].queue_free()
			to_be_built.clear()
			hide_build_button()
			emit_signal("builds_reset")
		elif to_be_built.size() > 1:
			#$"../stats_ui/HBoxContainer/funds".bbcode_text = String(int($"../stats_ui/HBoxContainer/funds".bbcode_text) + to_be_built[to_be_built.size()-1].total_price)
			to_be_built[to_be_built.size()-1].queue_free()
			to_be_built.remove(to_be_built.size()-1)
			print(to_be_built)
		else:
			print("Nothing to step back to")
	elif level_three.game_state == level_three.GAME_STATE.INFRA_MODIFY:
		if to_be_built.size() == 1:
			to_be_built[0].hide_build_ui()
			to_be_built.clear()
			hide_modify_button()
			emit_signal("builds_reset")
		elif to_be_built.size() > 1:
			to_be_built[to_be_built.size()-1].hide_build_ui()
			to_be_built.remove(to_be_built.size()-1)
			print(to_be_built)
		else:
			print("Nothing to step back to")
	

func _on_build_pressed():
	print("Build pressed.")
	# First let's check if there's enough money
	var energy_reserve_amount = 0
	for item in to_be_built:
		if item.is_in_group("energy_reserve"):
			energy_reserve_amount += item.area
	var solar_collector_amount = 0
	for item in to_be_built:
		if item.is_in_group("solar_collector"):
			solar_collector_amount += item.area
	# Calling the function that does the checking
	if level_three.can_build(energy_reserve_amount, solar_collector_amount):
		# This determines if the build is actually allowed or not!
		var is_successful = false
		var build_times = []
		for item in to_be_built:
			item._on_build_button_pressed()
			build_times.append(item.get_node("CanvasLayer/stopwatch").build_time)
			if item.old_area > 1 or item.old_area == 0:
				is_successful = true
		
		if to_be_built.size() > 1:
			# Find highest build time
			var highest_time = build_times.max()
			print("highest time is ", highest_time)
			# Make sure there is only one with that time
			var highest_time_item_count = 0
			for item in to_be_built:
				var item_time = item.get_node("CanvasLayer/stopwatch").build_time
				if item_time == highest_time:
					# For the highest time item, save the timers time
					if highest_time_item_count == 0:
						item.time_left_in_timer = item.get_node("CanvasLayer/stopwatch/Timer").time_left
					highest_time_item_count += 1
					if highest_time_item_count > 1:
						if item.get_node("CanvasLayer/stopwatch").is_connected("build_finished", get_node("/root/level_three"), "_on_build_finished"):
							item.get_node("CanvasLayer/stopwatch").disconnect("build_finished", get_node("/root/level_three"), "_on_build_finished")
				else:
					if item.get_node("CanvasLayer/stopwatch").is_connected("build_finished", get_node("/root/level_three"), "_on_build_finished"):
						item.get_node("CanvasLayer/stopwatch").disconnect("build_finished", get_node("/root/level_three"), "_on_build_finished")
		to_be_built.clear()
		if is_build_button_visible:
			hide_build_button()
		if is_modify_button_visible:
			hide_modify_button()
		# If it's okay to build
		if is_successful:
			# Hide the infra UI so player cannot build anymore :-)
			$AnimationPlayer.play("toggle_infra_ui")
			is_infra_hidden = true 
			# Remove the used money from budget
			level_three.decrease_funds(level_three.total_round_cost)
	else:
		print("Not enough money for current system!")
		for item in to_be_built:
			item.too_expensive()


func _on_mouse_interaction_step_back():
	step_back()


func _on_modify_pressed():
	_on_build_pressed()

func update_energy_reserve_price():
	# First get the amount of energy reserve
	var energy_reserve_amount = 0
	for item in to_be_built:
		if item.is_in_group("energy_reserve"):
			energy_reserve_amount += item.area
	var solar_collector_amount = 0
	for item in to_be_built:
		if item.is_in_group("solar_collector"):
			solar_collector_amount += item.area
	level_three.funds_decrease(energy_reserve_amount, solar_collector_amount)
	var cost_per_reserve = 0
	if energy_reserve_amount > 0:
		cost_per_reserve = level_three.prices[0] / energy_reserve_amount
	for item in to_be_built:
		if item.is_in_group("energy_reserve"):
			var current_amount = item.get_node("CanvasLayer/size_slider").value
			item.get_node("CanvasLayer/size_slider/price_text").bbcode_text = "[center]-" + str(int(cost_per_reserve * current_amount)) + " €[/center]"
	
