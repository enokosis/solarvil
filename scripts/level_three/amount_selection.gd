extends Panel

# Controls how much any given infrastructure is selected

onready var mouse_interaction = $"../mouse_interaction"
onready var selected_highlights = [$"HBoxContainer/1_button/selected", $"HBoxContainer/10_button/selected", $"HBoxContainer/100_button/selected"]


func _ready():
	self.visible = false
	hide_highlights()
	# in this case the first button is always active when the panel is made visible
	selected_highlights[0].visible = true


func hide_highlights():
	for highlight in selected_highlights:
		highlight.visible = false

# there's a smarter way to do the toggling between highlighted items
# i'm too lazy to figure it out now


func _on_1_button_pressed():
	if selected_highlights[0].visible != true:
		hide_highlights()
		selected_highlights[0].visible = true
		mouse_interaction.infra_amount = 1
	#else:
		#hide_highlights()
		#mouse_interaction.clear_selected_infrastructure()


func _on_10_button_pressed():
	if selected_highlights[1].visible != true:
		hide_highlights()
		selected_highlights[1].visible = true
		mouse_interaction.infra_amount = 10
	#else:
		#hide_highlights()
		#mouse_interaction.clear_selected_infrastructure()


func _on_100_button_pressed():
	if selected_highlights[2].visible != true:
		hide_highlights()
		selected_highlights[2].visible = true
		mouse_interaction.infra_amount = 100
	#else:
		#hide_highlights()
		#mouse_interaction.clear_selected_infrastructure()


func _on_infra_amount_panel_visibility_changed():
	hide_highlights()
	# in this case the first button is always active when the panel is made visible
	selected_highlights[0].visible = true
