extends Node2D

onready var option_button1 = $VBoxContainer/OptionButton1
onready var counter_indicator = $CounterIndicator
onready var light_bulb = $VBoxContainer/HBoxContainer/LightBulb
onready var submit_button = $VBoxContainer/SubmitButton
onready var score_label = $VBoxContainer/HBoxContainer/ScoreLabel
onready var question_label = $VBoxContainer/QuestionLabel

onready var data_manager = get_parent().get_node("data_manager")
var answer_memory = {}

var correct_answer1
var is_answer_correct = false
var score = 0
var data_index = 0

var questions = [

	{
		"question": "Aurinkopaneelin tuottama sähkö tunnille {hour}, Wh",
		"func": "calculate_solar_electricity_production",
		"data_keys": ["SATEILY"],
		"static_keys": ["PV/T-pinta-ala (m2)", "PV-hyötysuhde"],
		"answer_key": "Aurinkopaneelin tuottama sähkö (Wh)"
	},
	{
		"question": "Aurinkokeräimen tuottama lämpö tunnille {hour}, Wh",
		"func": "calculate_solar_collector_heat_production",
		"data_keys": ["SATEILY", "ULKOLAMPOTILA"],
		"static_keys": ["PV/T-pinta-ala (m2)", "Kerroin Fr", "Tau-alfa-tulo", "Häviökerroin (W/m2K)", "Veden sisäänmenolämpötila aurinkokeräimelle (C)"],
		"answer_key": "Aurinkokeräimen tuottama lämpö (Wh)"
	},
	{
		"question": "Sähköylijäämä tunnille {hour}, Wh",
		"func": "subtract_values",
		"data_keys": ["Aurinkopaneelin tuottama sähkö (Wh)", "SAHKO"],
		"static_keys": [],
		"answer_key": "Sähköylijäämä (Wh)"
	},
	{
		"question": "Lämmön nettoalijäämä tunnille {hour}, Wh",
		"func": "subtract_values",
		"data_keys": ["LAMMITYS", "Aurinkokeräimen tuottama lämpö (Wh)"],
		"static_keys": [],
		"answer_key": "Lämmön nettoalijäämä (Wh)"
	},
	{
		"question": "Lämpöpumpun sähköntarve tunnille {hour}, Wh",
		"func": "calculate_heat_pump_electricity",
		"data_keys": ["Lämmön nettoalijäämä (Wh)"],
		"static_keys": ["Lämpöpumpun COP"],
		"answer_key": "Lämpöpumpun sähköntarve (Wh)"
	},
	{
		"question": "Kokonaissähköntarve tunnille {hour}, Wh",
		"func": "add_values",
		"data_keys": ["SAHKO", "Lämpöpumpun sähköntarve (Wh)"],
		"static_keys": [],
		"answer_key": "Kokonaissähköntarve (Wh)"
	},
	{
		"question": "Sähköalijäämä tunnille {hour}, Wh",
		"func": "subtract_values",
		"data_keys": ["Kokonaissähköntarve (Wh)", "Aurinkopaneelin tuottama sähkö (Wh)"],
		"static_keys": [],
		"answer_key": "Sähköalijäämä (Wh)"
	}

]


var current_question_index = 0

func _ready():
	counter_indicator.text = str(data_index + 1)
	light_bulb.modulate = Color(1,1,1,0)
	update_score_label()
	submit_button.connect("pressed", self, "_on_SubmitButton_pressed")
	set_correct_answers()

func set_correct_answers():
	print("Setting Correct Answers")  # Debug print

	var data_keys = questions[current_question_index]["data_keys"]
	var static_keys = questions[current_question_index]["static_keys"]
	
	var values = []
	for key in data_keys:
		var value
		if key in answer_memory:
			value = answer_memory[key]
		else:
			value = data_manager.get_data_at_index(key, data_index)
		
		print("Dynamic Data - Key: ", key, ", Value: ", value)  # Debug print
		
		if value != null and str(value).is_valid_float():
			values.append(float(value))
		else:
			print("Error: Invalid value for float conversion: ", value)
			return
	for key in static_keys:
		var value = data_manager.get_static_data(key)
		print("Static Data - Key: ", key, ", Value: ", value)  # Debug print
		if value != null and str(value).is_valid_float():
			values.append(float(value))
		else:
			print("Error: Invalid value for float conversion: ", value)
			return
	
	var question_text = questions[current_question_index]["question"].format({"hour": str(data_index + 1)})
	question_label.text = question_text
	
	correct_answer1 = call(questions[current_question_index]["func"], values)
	# If answers are negative, they are considered to be zero
	if correct_answer1 < 0:
		correct_answer1 = 0
	
	# Store answer in memory if the key is in data_keys
	if "answer_key" in questions[current_question_index]:
		var key = questions[current_question_index]["answer_key"]
		answer_memory[key] = correct_answer1
	
	print("Calculated Answer: ", correct_answer1)  # Debug print
	print("values are ", values)
	update_option_button_options(correct_answer1, option_button1)

func calculate_solar_electricity_production(values):
	return values[0] * values[1] * values[2]

# changing the value index order here, because they are listed in the wrong order
func calculate_solar_collector_heat_production(values):
	return values[2] * values[3] * (values[4] * values[0] - values[5] * (values[6] - values[1]))

func subtract_values(values):
	return values[0] - values[1]

func calculate_heat_pump_electricity(values):
	return values[0] / values[1]

func add_values(values):
	return values[0] + values[1]

	
func check_answers():
	is_answer_correct = str(correct_answer1) == option_button1.get_item_text(option_button1.selected)

func update_light_bulb_and_score():
	if is_answer_correct:
		light_bulb.modulate = Color(0,1,0,1)
		score += 10
	else:
		light_bulb.modulate = Color(1,0,0,1)
		score -= 10
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score)
	GameData.stage_two_score = score

func _on_SubmitButton_pressed():
	print("Submit Button Pressed")  # Debug print
	check_answers()
	update_light_bulb_and_score()
	
	current_question_index += 1  # Move to the next question
	
	# Check if we've gone through all questions for the current hour
	if current_question_index >= len(questions):
		current_question_index = 0  # Reset question index
		data_index += 1  # Move to the next data point
		# When all questions are asked the game ends
		GameData.stage_two_score = score
		$"../outro_logic".trigger_intro()
		print("Final score of stage 2 is ", GameData.stage_two_score)
	
	counter_indicator.text = str(data_index + 1)
	set_correct_answers()
	
	# Make machine the correct size
	#print($VBoxContainer.rect_size.y)
	#$machine_bottom.scale.y = $machine_bottom.scale.y * ($VBoxContainer.rect_size.y / 145)
	#$machine_bottom.position.y += 

	
func update_option_button_options(correct_answer, option_button):
	var choices = generate_choices(correct_answer)
	option_button.clear()
	for choice in choices:
		option_button.add_item(str(choice))
	shuffle_option_button_items(option_button)

func generate_choices(correct_answer):
	var incorrect_answer1 = correct_answer
	var incorrect_answer2 = correct_answer
	
	var attempts = 0  # Adding a counter to avoid infinite loop
	while incorrect_answer1 == correct_answer and attempts < 100:
		incorrect_answer1 = correct_answer * float(rand_range(0.5, 1.5)) +1  # Modified multiplier range
		attempts += 1
	
	attempts = 0  # Resetting the counter
	while (incorrect_answer2 == correct_answer or incorrect_answer2 == incorrect_answer1) and attempts < 100:
		incorrect_answer2 = correct_answer * float(rand_range(0.5, 1.5)) -1  # Modified multiplier range
		attempts += 1
	
	if attempts == 100:
		print("Warning: Struggling to generate distinct incorrect answers")
	
	return [correct_answer, incorrect_answer1, incorrect_answer2]


func shuffle_option_button_items(option_button):
	var items = []
	for i in range(option_button.get_item_count()):
		items.append(option_button.get_item_text(i))
	items.shuffle()
	option_button.clear()
	for item in items:
		option_button.add_item(item)
