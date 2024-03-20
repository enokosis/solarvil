extends Panel

signal pop_up_closed()
signal pop_up_opened()


func _ready():
# warning-ignore:return_value_discarded
	self.connect("visibility_changed", self, "_on_calculation_pop_up_visibility_changed")


func _on_pop_up_done_button_down():
	emit_signal("pop_up_closed")
	self.visible = false

func _on_calculation_pop_up_visibility_changed():
	#print("my visibilty changed", self)
	if self.visible:
		emit_signal("pop_up_opened")
