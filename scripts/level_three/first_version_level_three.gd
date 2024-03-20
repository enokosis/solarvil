extends Node

# Handles managing the stats and their visual representation
# Calculations for the right answers are also done here

# Accessing the singleton data scene
onready var data = get_node("/root/GameData").get_node("data_variables")
onready var weather_data = get_node("/root/GameData").get_node("weather_data")

var current_funds = 20000000 # 20 million
var current_population = 0
var current_energy_demand = 0
var current_solar_collector_area = 0
var current_energy_production = 0
var current_energy_reserve_cababilty = 0

# how the numbers should be in the end according to the excel
# solar collector area m2 = 2455
# energy reserve amount MWh = 129

# formulas
# ST-Lämpö, if this is under 0 it should be shown as 0
# Aurinkokeräimen pinta-ala, m2 * Kerroin Fr * (Tau-alfa-tulo * Säteily, W/m2 - Häviökerroin, W/m2K * (Veden sisäänmenolämpötila aurinkokeräimelle, C - Ulkolämpötila, C))
# PV-Sähkö
# Aurinkokeräimen pinta-ala, m2 * PV-hyötysuhde * Säteily, W/m2

func _ready():
	pass #print(data.PV_T_area)


# there's no real data implemented atm, so these function are just using the first index in any array

func st_lampo():
	var result = current_solar_collector_area * data.KERROIN_FR * (data.TAU_ALFA_TULO * weather_data.SATEILY[0] - data.HAVIOKERROIN * (data.VEDEN_SISAANMENOLAMPOTILA - weather_data.ULKOLAMPOTILA[0]))
	if result < 0 or result == -0: # for whatever reason the zero might be negative lol
		result = 0
	return result


func pv_sahko():
	var result = current_solar_collector_area * data.PV_hyotysuhde * weather_data.SATEILY[0]
	return result


func decrease_funds(amount):
	if current_funds - amount >= 0:
		current_funds -= amount
		$stats_ui/HBoxContainer/funds.bbcode_text = String(current_funds)
		return true
	else:
		print("Not enough money!")
		return false


func increase_energy_demand(amount):
	current_energy_demand += amount
	$stats_ui/HBoxContainer/energy_demand.bbcode_text = String(current_energy_demand)
	

func increace_population(amount):
	current_population += amount
	$stats_ui/HBoxContainer/population.bbcode_text = String(current_population)


func increase_solar_collector_area(amount):
	current_solar_collector_area += amount
	
	
func increase_energy_production(amount):
	current_energy_production += amount
	$stats_ui/HBoxContainer/energy_production.bbcode_text = String(current_energy_production)


func increase_energy_reserve(amount):
	current_energy_reserve_cababilty += amount
	$stats_ui/HBoxContainer/energy_reserve.bbcode_text = String(current_energy_reserve_cababilty)



func _on_season_dial_new_season():
	# decrease_funds(house.price)
	increase_energy_demand(25 * 0.02)
	increace_population(25)
	print(st_lampo())
	print(pv_sahko())


func _on_season_dial_new_year():
	pass # Replace with function body.
