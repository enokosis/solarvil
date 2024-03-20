extends Node2D


onready var calculate_button = $VBoxMain/CalculateButton
onready var usage_counter = $VBoxMain/HBoxContainer/UsageCounter

onready var cooldown_timer = $CooldownTimer
onready var cooldown_label = $VBoxMain/HBoxContainer/CooldownLabel

onready var help_button = $VBoxMain/HBoxChoice/HelpButton  # Adjust the path as needed
onready var explanation_panel = $VBoxMain/ExplanationPanel  # Adjust the path as needed
onready var explanation_label = $VBoxMain/ExplanationPanel/ExplanationLabel  # Adjust the path as needed

onready var calculation_dropdown = $VBoxMain/HBoxChoice/CalculationDropdown  # Assuming a dropdown is added to the scene

var max_uses = 3
var current_uses = 0
var cooldown_time = 15.0
var on_cooldown = false

var formula_name = ""
var report_scene = preload("res://scenes/level_two/report_calculator.tscn")  # Preload the report scene

# Printed report visuals
export var color: Color
var type_name = ""

# Calculator background
onready var background = $calculator_texture

var calculation_types = [
	{
		#"type": "solar_electricity_production", 
		"type": "Aurinkopaneelin_tuottama_sähkö,_Wh", 
		"func": "calculate_solar_electricity_production", 
		"inputs": ["PV/T-pinta-ala (m2)", "PV-hyötysuhde", "Säteily (W/m2)"],
		"description": "Aurinkopaneelin tuottama sähkö, Wh = [color=yellow](PV/T-pinta-ala, m2)[/color] * [color=lime](PV-hyötysuhde)[/color] * [color=aqua](Säteily, W/m2)[/color]."
	},
	{
		#"type": "electricity_surplus", 
		"type": "Sähköylijäämä, Wh", 
		"func": "subtract_values", 
		"inputs": ["Aurinkopaneelin tuottama sähkö (Wh)", "Kokonaissähköntarve (Wh)"],
		"description": "Sähköylijäämä, Wh = [color=yellow](Aurinkopaneelin tuottama sähkö, Wh)[/color] - [color=lime](Kokonaissähköntarve, Wh)[/color]."
		
	},
	{
		#"type": "solar_collector_heat_production",
		"type": "Aurinkokeräimen tuottama lämpö, Wh",
		"func": "calculate_solar_collector_heat_production",
		"inputs": [
			"PV/T-pinta-ala (m2)",
			"Kerroin Fr",
			"Tau alfa tulo",
			"Säteily (W/m2)",
			"Häviökerroin (W/m2K)",
			"Veden sisäänmenolämpötila aurinkokeräimelle (C)",
			"Ulkolämpötila (C)"
		],
		"description": "Aurinkokeräimen tuottama lämpö, Wh = [color=yellow](PV/T-pinta-ala, m2)[/color] * [color=lime](Kerroin Fr)[/color] * ([color=aqua](Tau alfa tulo)[/color] * [color=blue](Säteily, W/m2)[/color] - [color=fuchsia](Häviökerroin, W/m2K)[/color] * ([color=red](Veden sisäänmenolämpötila aurinkokeräimelle, C)[/color] - [color=green](Ulkolämpötila, C)[/color]))"
	},
	{
		#"type": "heat_net_deficit",
		"type": "Lämmön nettoalijäämä, Wh",
		"func": "subtract_values",
		"inputs": ["Lämmönkulutus (Wh)", "Aurinkokeräimen tuottama lämpö (Wh)"],
		"description": "Lämmön nettoalijäämä, Wh = [color=yellow](Lämmönkulutus, Wh)[/color] - [color=lime](Aurinkokeräimen tuottama lämpö, Wh)[/color]."
	},
	{
		#"type": "heat_pump_electricity_need",
		"type": "Lämpöpumpun sähköntarve, Wh",
		"func": "calculate_heat_pump_electricity",
		"inputs": ["Lämmön nettoalijäämä (Wh)", "Lämpöpumpun COP"],
		"description": "Lämpöpumpun sähköntarve, Wh = [color=yellow](Lämmön nettoalijäämä, Wh)[/color] / [color=lime](Lämpöpumpun COP)[/color]."
	},
	{
		#"type": "total_electricity_need",
		"type": "Kokonaissähköntarve, Wh",
		"func": "add_values",
		"inputs": ["Sähkönkulutus (Wh)", "Lämpöpumpun sähköntarve (Wh)"],
		"description": "Kokonaissähköntarve, Wh = [color=yellow](Sähkönkulutus, Wh)[/color] + [color=lime](Lämpöpumpun sähköntarve, Wh)[/color]. "
	},
	{
		#"type": "electricity_deficit",
		"type": "Sähköalijäämä, Wh",
		"func": "subtract_values",
		"inputs": ["Kokonaissähköntarve (Wh)", "Aurinkopaneelin tuottama sähkö (Wh)"],
		"description": "Sähköalijäämä, Wh = [color=yellow](Kokonaissähköntarve, Wh)[/color] - [color=lime](Aurinkopaneelin tuottama sähkö, Wh)[/color]."
	}
]


func _ready():
	calculate_button.connect("pressed", self, "_on_CalculateButton_pressed")
	# New: Connect dropdown item selection to a new function
	calculation_dropdown.connect("item_selected", self, "_on_CalculationDropdown_item_selected")
	explanation_panel.rect_min_size.x = 260

	update_usage_counter()
	# Populate the dropdown with calculation type options
	for calc_type in calculation_types:
		calculation_dropdown.add_item(calc_type["type"].replace("_", " "))#.capitalize())
	
	# Initialize the input fields according to the first calculation type
	_on_CalculationDropdown_item_selected(0)
	!explanation_panel.visible
	help_button.connect("pressed", self, "_on_HelpButton_pressed")
	
func _on_HelpButton_pressed():
	var selected_index = calculation_dropdown.get_selected()
	explanation_label.bbcode_text = calculation_types[selected_index]["description"]
	explanation_panel.visible = !explanation_panel.visible

	
func _on_CalculateButton_pressed():
	if on_cooldown or current_uses >= max_uses:
		return
	
	# New: Collect all input values into an array
	var input_values = []
	for i in $VBoxMain/Inputs.get_children():
		input_values.append(float(i.text))
	
	# New: Get selected calculation type and call the respective function
	var selected_type = calculation_types[calculation_dropdown.get_selected()]
	type_name = selected_type.type.replace("_", " ")
	var result = call(selected_type["func"], input_values)
	
	create_report(result)
	current_uses += 1
	update_usage_counter()
	
	if current_uses >= max_uses:
		start_cooldown()

func _on_CalculationDropdown_item_selected(selected_idx):
	var selected_type = calculation_types[selected_idx]
	
	# Clear existing input fields
	for child in $VBoxMain/Inputs.get_children():
		child.queue_free()
	
	# Create new input fields based on the selected calculation type
	for input_label in selected_type["inputs"]:
		var input_field = LineEdit.new()
		input_field.rect_min_size = Vector2(200, 30)  # Set a minimum size or adjust as needed
		input_field.placeholder_text = input_label
		$VBoxMain/Inputs.add_child(input_field)
		
	# Modify the background to fit the items
	if selected_idx == 2:
		background.rect_size.y = 380
	else:
		background.rect_size.y = 250

func calculate_solar_electricity_production(values):
	# Your formula logic here
	return values[0] * values[1] * values[2]  # Example formula

func subtract_values(values):
	return values[0] - values[1]
	
func calculate_solar_collector_heat_production(values):
	# Aurinkokeräimen tuottama lämpö, Wh
	return values[0] * values[1] * (values[2] * values[3] - values[4] * (values[5] - values[6]))

func calculate_heat_pump_electricity(values):
	# Lämpöpumpun sähköntarve, Wh
	if values[0] == 0:
		return 0
	return values[0] / values[1]

func add_values(values):
	return values[0] + values[1]


func create_report(result):
	var report = report_scene.instance()  # Create an instance of the report
	
	# Add the report as a child of the ROOT or some fixed node
	get_parent().add_child(report)  
	
	# Use call_deferred to ensure set_report_number is called after the report is added to the scene tree
	var index = 0
	report.call_deferred("set_report_number", result, type_name, color)
	
	# Set the global_position of the report to the REPORT_POSITION
	report.global_position = report.REPORT_POSITION


func update_usage_counter():
	usage_counter.text = str(current_uses) + "/" + str(max_uses)

	
func start_cooldown():
	on_cooldown = true
	calculate_button.disabled = true
	
	cooldown_timer.start(cooldown_time)  # Start the cooldown timer
	
	# Connect the timer's timeout signal to a function to update the UI
	cooldown_timer.connect("timeout", self, "_on_CooldownTimer_timeout")
	
	# Update the label every second
	set_process(true)
	
	$VBoxMain/HBoxContainer/UsageCounter.visible = false

# Function to update the UI when the timer times out
func _on_CooldownTimer_timeout():
	on_cooldown = false
	calculate_button.disabled = false
	current_uses = 0
	update_usage_counter()
	cooldown_label.text = "Käyttökerrat"
	
	# Disconnect the timer's timeout signal to avoid multiple connections
	cooldown_timer.disconnect("timeout", self, "_on_CooldownTimer_timeout")
	
	# Stop updating the label every second
	set_process(false)
	
	$VBoxMain/HBoxContainer/UsageCounter.visible = true

# Function to update the label every frame
func _process(delta):
	if on_cooldown:
		cooldown_label.text = str(int(cooldown_timer.time_left)) + "s cooldown" #+ "/" +str(cooldown_time)+ "s cooldown"
