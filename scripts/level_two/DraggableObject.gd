class_name DraggableObject
extends Sprite

var drag = false
var drag_offset = Vector2()
var original_z_index = 0  # Store the original z_index of this object

func _ready():
	self.add_to_group("papers")
	# other code

	self.texture = preload("res://art/stage 2/report_2.png")  # Set your texture here


func _input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
	if event.is_action_pressed("click"):
		#print("clicked")
		var tex_size = texture.get_size()
		var rect = Rect2(global_position - tex_size / 2, tex_size)
		#print(rect)
		if rect.has_point(event.position):
			#print("clicked on rect")
			drag = true
			drag_offset = global_position - event.position
			bring_to_front()
			get_tree().set_input_as_handled()
	#elif event is InputEventMouseButton and !event.pressed and event.button_index == BUTTON_LEFT:
	if event.is_action_released("click"):
		if drag:
			drag = false
			# Do NOT reset the z_index here. Keep the object on top.
	elif drag and event is InputEventMouseMotion:
		global_position = event.position + drag_offset


func bring_to_front():
	var highest_z_index = 0
	for sibling in get_parent().get_children():
		if sibling == self:
			continue
		#print("Sibling: ", sibling.name)  # Print the name of each sibling
		if sibling.has_method("is_object_draggable"):


			#print("Found a DraggableObject: ", sibling.name, " with z_index: ", sibling.z_index)
			highest_z_index = max(highest_z_index, sibling.z_index)
	#print("Highest z_index among siblings: ", highest_z_index)
	z_index = highest_z_index + 1
	#print("New z_index of dragged object: ", z_index)
	
func is_object_draggable():
	return true

