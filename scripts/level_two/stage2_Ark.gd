extends Node2D


#debug more for extra info
var debug_mode = true

var timer
var timer_active = true  # To check if the timer is active
# Declare variables for initial parameters

var pvt_surface_area = 1000
var pv_efficiency = 0.15
var heat_pump_COP = 5
var battery_efficiency = 0.9

var outside_temp = -8
var solar_radiation = 6.3
var electricity_consumption = 51400
var heat_consumption = 167593

# Declare variables for user inputs
var solar_electricity_production
var heat_produced

# Declare a variable to hold the score
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var theme = load("res://UI/basic_theme.tres")
	$UIV.theme = theme

	var playerRole= GameData.player_role 
	$UIV/WelcomeLabel.text = "Welcome to the stage 2.\nYour team is: " +  GameData.team_name + "\nYour role is : " +playerRole
	# Update the text of each label to display the initial parameters
	get_node("UIV/UIH1/VBoxColumn1/Label_PVT_Surface_Area").text = "PVT Surface Area: " + str(pvt_surface_area)
	get_node("UIV/UIH1/VBoxColumn1/Label_PV_Efficiency").text = "PV Efficiency: " + str(pv_efficiency)
	get_node("UIV/UIH1/VBoxColumn1/Label_Heat_Pump_COP").text = "Heat Pump COP: " + str(heat_pump_COP)
	get_node("UIV/UIH1/VBoxColumn1/Label_Battery_Efficiency").text = "Battery Efficiency: " + str(battery_efficiency)

	get_node("UIV/UIH1/VBoxColumn2/Label_Outside_Temp").text = "Outside Temp: " + str(outside_temp)
	get_node("UIV/UIH1/VBoxColumn2/Label_Solar_Radiation").text = "Solar Radiation: " + str(solar_radiation)
	get_node("UIV/UIH1/VBoxColumn2/Label_Electricity_Consumption").text = "Electricity Consumption: " + str(electricity_consumption)
	get_node("UIV/UIH1/VBoxColumn2/Label_Heat_Consumption").text = "Heat Consumption: " + str(heat_consumption)

	roleCensor(playerRole)
	# Perform the initial calculations
	get_node("UIV/UIH2/VBoxColumn1/Label_Energy_Produced").text = "Enter Solar Electricity Produced:"
	get_node("UIV/UIH2/VBoxColumn1/Label_Heat_Produced").text = "Enter Heat Produced:"
	perform_calculations()
	
	# Initialize and configure the timer
	timer = $UIV/Timer
	timer.set_wait_time(8)  # Set time limit to 30 seconds
	timer.start()

func _process(delta):
	if timer_active:
		$UIV/TimerLabel.text = "Time left: " + str(int(timer.get_time_left())) + "s"


# Function to perform calculations based on initial parameters and user inputs
func perform_calculations():
	# Example calculations (You should replace these with actual formulas)
	solar_electricity_production = pvt_surface_area * pv_efficiency * solar_radiation
	heat_produced = pvt_surface_area * solar_radiation * (1 - pv_efficiency)
	if debug_mode:
		get_node("UIV/Debug_1").text = "DEBUG Calculated  solar energy: " +str(solar_electricity_production)
		get_node("UIV/Debug_2").text = "DEBUG Calculated  heat production: " +str(heat_produced)

# Function to validate user inputs
func validate_inputs(user_solar_electricity, user_heat_produced):
	if user_solar_electricity == str(solar_electricity_production) and user_heat_produced == str(heat_produced):
		# Output "Correct" and proceed to next stage
		get_node("UIV/Score_Feedback").text = "Correct"
		score += 1  # Increment the score
		get_node("UIV/Score_Meter").text = "Score: " + str(score)  # Update the score meter
	else:
		# Output "Incorrect" and ask to try again
		get_node("UIV/Score_Feedback").text = "Incorrect, please try again."


# Function connected to the "Submit" button to handle the submission
func _on_SubmitButton_pressed():
	# Collect user inputs from the input fields
	# For example:
	var user_solar_electricity = get_node("UIV/UIH2/VBoxColumn2/LineEdit_Energy_Produced").text
	var user_heat_produced = get_node("UIV/UIH2/VBoxColumn2/LineEdit_Heat_Produced").text

	# Validate the inputs
	validate_inputs(user_solar_electricity, user_heat_produced)

func _on_Timer_timeout():
	get_node("UIV/Score_Feedback").text = "Time's up!"
	timer_active = false  # Stop updating the timer label
	get_node("UIV/SubmitButton").set_disabled(true)  # Disable the submit button

func roleCensor(role):
	# Configure visibility of values depending on role
	var placeholder_text = "####"
	match role:
		"Solar engineer":
			get_node("UIV/UIH1/VBoxColumn2/Label_Electricity_Consumption").text = "Electricity Consumption: " + placeholder_text
			get_node("UIV/UIH1/VBoxColumn2/Label_Heat_Consumption").text = "Heat Consumption: " + placeholder_text
			
		"Electrician":
			get_node("UIV/UIH1/VBoxColumn2/Label_Outside_Temp").text = "Outside Temp: " + placeholder_text
			get_node("UIV/UIH1/VBoxColumn2/Label_Solar_Radiation").text = "Solar Radiation: " + placeholder_text
			get_node("UIV/UIH1/VBoxColumn2/Label_Heat_Consumption").text = "Heat Consumption: " + placeholder_text
			
		"HVAC":
			get_node("UIV/UIH1/VBoxColumn2/Label_Outside_Temp").text = "Outside Temp: " + placeholder_text
			get_node("UIV/UIH1/VBoxColumn2/Label_Solar_Radiation").text = "Solar Radiation: " + placeholder_text
			get_node("UIV/UIH1/VBoxColumn2/Label_Electricity_Consumption").text = "Electricity Consumption: " + placeholder_text
			
		"Game master":
			pass  # Do nothing, Game master sees everything

