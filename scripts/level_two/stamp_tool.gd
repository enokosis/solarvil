extends TextureButton

# Connect the pressed signal to a function
func _ready():
	connect("pressed", self, "_on_StampTool_pressed")

func _on_StampTool_pressed():
	var global_mouse_position = get_global_mouse_position()
	var papers = get_tree().get_nodes_in_group("papers")
	
	for paper in papers:
		if paper.global_rect.has_point(global_mouse_position):
			paper.place_stamp(global_mouse_position)
			return
