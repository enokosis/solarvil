extends Control

# Generate question for player.
# If player succeeds, let them pass.
# Player has three turns to try and score points.
# If they fail, they don't score but are allowed to proceed

onready var data = get_node("/root/GameData").get_node("data_variables")
onready var weather_data = get_node("/root/GameData").get_node("weather_data")

# Questions in the multiple choice task:
# Aurinkopaneelin tuottama sähkö, Wh
# Aurinkokeräimen tuottama lämpö, Wh
# Lämmön nettoalijäämä, Wh
# Lämpöpumpun sähköntarve, Wh
# Kokonaissähköntarve, Wh
# Sähköalijäämä, Wh
# Sähköylijäämä, Wh

onready var header = $pop_up_window/Panel/header
onready var button_labels = [$pop_up_window/Panel/HBoxContainer/answer_0/label, $pop_up_window/Panel/HBoxContainer/answer_1/label, $pop_up_window/Panel/HBoxContainer/answer_2/label]
var selected_answer = null
var current_correct_answer = null
onready var selected_highlights = [$pop_up_window/Panel/HBoxContainer/answer_0/selected, $pop_up_window/Panel/HBoxContainer/answer_1/selected, $pop_up_window/Panel/HBoxContainer/answer_2/selected]

var task_question_index = 0 # 6 is max
var hour = null


func _ready():
	randomize()
	hide_highlights()
	find_valid_hour()

func find_valid_hour():
	hour = int(rand_range(0, 8760))
	if weather_data.weather_dictionary[hour].SATEILY > 0:
		print("hour selected is ", hour + 1)
		print("Säteily is ", weather_data.weather_dictionary[hour].SATEILY)
		aurinkopaneelin_tuottama_sahko()
	else:
		find_valid_hour()


# Functions to determine new questions

func aurinkopaneelin_tuottama_sahko():
	var correct_answer = int(round(data.PV_T_area * data.PV_hyotysuhde * weather_data.weather_dictionary[hour].SATEILY))
	current_correct_answer = correct_answer
	print(correct_answer)
	var false_answer_0 = int(round(data.PV_T_area * weather_data.weather_dictionary[hour].SATEILY))
	var false_answer_1 = int(round(data.PV_T_area * 0.3 * weather_data.weather_dictionary[hour].SATEILY))
	var labels = button_labels.duplicate()
	labels.shuffle()
	labels[0].bbcode_text = "[center]" + String(correct_answer) + "[/center]"
	labels[1].bbcode_text = "[center]" + String(false_answer_0) + "[/center]"
	labels[2].bbcode_text = "[center]" + String(false_answer_1) + "[/center]"

func aurinkopaneelin_tuottama_lampo():
	pass

func lammon_nettoalijaama():
	pass

func lampopumpun_sahkontarve():
	pass

func kokonaissahkontarve():
	pass

func sahkoalijaama():
	pass
	
func sahkoylijaama():
	pass


func hide_highlights():
	for highlight in selected_highlights:
		highlight.visible = false


func _on_answer_0_pressed():
	if selected_highlights[0].visible != true:
		hide_highlights()
		selected_highlights[0].visible = true
		selected_answer = 0
	else:
		hide_highlights()
		selected_answer = null


func _on_answer_1_pressed():
	if selected_highlights[1].visible != true:
		hide_highlights()
		selected_highlights[1].visible = true
		selected_answer = 1
	else:
		hide_highlights()
		selected_answer = null


func _on_answer_2_pressed():
	if selected_highlights[2].visible != true:
		hide_highlights()
		selected_highlights[2].visible = true
		selected_answer = 2
	else:
		hide_highlights()
		selected_answer = null


func _on_evaluate_pressed():
	if selected_answer != null:
		var player_answer = int(button_labels[selected_answer].bbcode_text)
		print(player_answer)
		if player_answer == current_correct_answer:
			task_question_index += 1
			print("correct :-)")
			if task_question_index == 1:
				aurinkopaneelin_tuottama_lampo()
			elif task_question_index == 2:
				lammon_nettoalijaama()
			elif task_question_index == 3:
				lampopumpun_sahkontarve()
			elif task_question_index == 4:
				kokonaissahkontarve()
			elif task_question_index == 5:
				sahkoalijaama()
			elif task_question_index == 6:
				sahkoylijaama()
		else:
			print("uncorrect :-(")
