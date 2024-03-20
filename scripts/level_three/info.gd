extends TextureButton


func _on_info_pressed():
	$"../CanvasLayer/info_pop_up_window".visible = true
	

func _on_info_pop_up_window_pop_up_opened():
	visible = false


func _on_info_pop_up_window_pop_up_closed():
	visible = true


func _on_dialogue_box_dialogue_ended():
	$"../CanvasLayer/info_pop_up_window".visible = true
