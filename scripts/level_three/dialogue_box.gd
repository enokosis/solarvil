extends Panel

signal dialogue_ended

onready var dialogues = []
var dialogue_index = 0


func _ready():
	for item in $Panel/dialogue.get_children():
		dialogues.append(item)
	for dialogue in dialogues:
		dialogue.visible = false
	dialogues[dialogue_index].visible = true


func next_dialogue():
	dialogues[dialogue_index].visible = false
	dialogue_index += 1
	if dialogue_index == dialogues.size()-1:
		$Panel/next_dialogue.text = "selvä!"
	dialogues[dialogue_index].visible = true


func _on_next_dialogue_pressed():
	if dialogue_index < dialogues.size()-1:
		next_dialogue()
	else:
		visible = false
		emit_signal("dialogue_ended")
	# When clicked the button grabs focus. Let's release it here for visual sakes. Bad for accessibility!
	$Panel/next_dialogue.focus_mode = false
