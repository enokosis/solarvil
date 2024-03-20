extends Control

onready var data = get_node("/root/GameData")

var question_index = 0 # max 4
var is_button_pumping = false
var chosen_value = 0.5
onready var slider = $background/body/HBoxContainer/likeness_slider

# Questions
var lvi_designer_questions = ["Haluan työskennellä yksin.", "Kirjoitan mieluummin.", "Olen sisäänpäinkääntynyt.", "Olen järjestelmällinen.", "Minua kiinnostavat enemmän tekniset yksityiskohdat."]
var energy_consult_questions = ["Haluan työskennellä ryhmässä.", "Puhun mieluummin.", "Olen ulospäinsuuntautunut.", "Olen spontaani.", "Minua kiinnostaa enemmän kokonaisuus."]
onready var question_0 = $background/body/HBoxContainer/question_0
onready var question_1 = $background/body/HBoxContainer/question_1

# Roles
var role_value = 0.0
var answers_0 = []
var answers_1 = []
var role = ""
var roles = ["LVI-suunnittelija", "Yleishenkilö Jantunen", "Energiakonsultti"]

# evalutation
var timer_index = 0
var loading_index = 1
onready var loading_text = $background/evaluation/evaluating_loading

func _ready():
	question_0.bbcode_text = "[center]" + lvi_designer_questions[question_index] + "[/center]"
	question_1.bbcode_text = "[center]" + energy_consult_questions[question_index] + "[/center]"
	#evaluate()
	
	
func _on_next_question_pressed():
	question_0.rect_scale = Vector2(1,1)
	question_1.rect_scale = Vector2(1,1)
	
	chosen_value = slider.value
	question_index += 1
	is_button_pumping = false
	$background/body/next_question/AnimationPlayer.play("RESET")
	answers_0.append(chosen_value)
	answers_1.append(1 - chosen_value)
	print(chosen_value, " ", 1 - chosen_value)
	if question_index < 5:
		question_0.bbcode_text = "[center]" + lvi_designer_questions[question_index] + "[/center]"
		question_1.bbcode_text = "[center]" + energy_consult_questions[question_index] + "[/center]"
		slider.value = 0.5
	else:
		# Questionnare has ended
		var sum_0 = 0
		for answer in answers_0:
			sum_0 += answer
		var sum_1 = 0
		for answer in answers_1:
			sum_1 += answer
		sum_0 = float(sum_0 / 5)
		sum_1 = float(sum_1 / 5)
		print(sum_0, " ", sum_1)
		if sum_0 > sum_1:
			role_value = sum_0
		elif sum_1 > sum_0:
			role_value = sum_1
		elif sum_0 == sum_1:
			role_value = sum_0
		
		print(role_value)
		if role_value < 0.45:
			role = roles[2]
		elif role_value >= 0.45 and role_value < 0.55:
			role = roles[1]
		elif role_value >= 0.55:
			role = roles[0]
		print(role)
		
		$background/body.visible = false
		$background/evaluation.visible = true
		data.player_role = role
		evaluate()


func evaluate():
	$background/evaluation/evaluating_loading.visible_characters = loading_index
	loading_index += 1
	if loading_index == 6:
		loading_index = 0
	timer_index += 1
	if timer_index <= 35:
		$background/evaluation/Timer.start()
	else:
		$background/evaluation.visible = false
		$background/results.visible = true
		$background/results/resulting_role.bbcode_text = "[center]" + role + "[/center]"


func _on_likeness_slider_value_changed(value):
	# not necessary to track it here tbh
	print(chosen_value, " ", value)
	var scale_value = slider.step / 2
	if chosen_value > value:
		question_0.rect_scale = Vector2(question_0.rect_scale.x+scale_value,question_0.rect_scale.x+scale_value)
		question_1.rect_scale = Vector2(question_1.rect_scale.x-scale_value,question_1.rect_scale.y-scale_value)
	else:
		question_0.rect_scale = Vector2(question_0.rect_scale.x-scale_value,question_0.rect_scale.x-scale_value)
		question_1.rect_scale = Vector2(question_1.rect_scale.x+scale_value,question_1.rect_scale.y+scale_value)
	#if value == 0.5:
		#question_0.rect_scale = Vector2(1,1)
		#question_1.rect_scale = Vector2(1,1)
	chosen_value = value


func _on_likeness_slider_drag_ended(value_changed):
	if !is_button_pumping:
		$background/body/next_question/AnimationPlayer.play("size_pump")


func _on_Timer_timeout():
	timer_index += 1
	evaluate()


func _on_done_pressed():
	$background/results.visible = false
	$outro_dialogue_box.visible = true
	$background/sun_animation.visible = false
	$background/header.visible = false


# intro is done
func _on_intro_dialogue_box_dialogue_ended():
	$background/body.visible = true
	$background/sun_animation.visible = true
	$background/header.visible = true
