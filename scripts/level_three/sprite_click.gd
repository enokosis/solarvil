extends Sprite

signal click

func _input(event):
	if event.is_action_pressed("click"):
		var pos = global_position + offset * scale# - ( (texture.get_size() / 2.0) if centered else Vector2())
		if Rect2(pos, texture.get_size() * scale.x).has_point(event.position):
			emit_signal("click")
