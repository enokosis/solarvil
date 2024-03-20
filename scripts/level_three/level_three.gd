extends Node

# Handles managing the stats and their visual representation
# Calculations for the right answers are also done here

# Accessing the singleton data scene
onready var game_data = get_node("/root/GameData")
onready var data = get_node("/root/GameData").get_node("data_variables")
onready var weather_data = get_node("/root/GameData").get_node("weather_data")
onready var weather_data_dictionary = weather_data.weather_dictionary
onready var tarkistuslaskelma = get_node("/root/GameData").get_node("tarkistuslaskelma")
onready var audio_manager = get_node("/root/AudioManager")

const START_FUNDS = 20000000
var current_funds = 20000000 # 20 million is the limit of funds that can be spent
var current_population = 0
var current_energy_demand = 0
var current_solar_collector_area = 0
var current_energy_production = 0
var current_energy_reserve_cabability = 0

var energy_reserve_cabability_at_start = 0
var energy_reserve_cabability_at_end = 0

# how the numbers should be in the end according to the excel
# solar collector area m2 = 2455
# energy reserve amount MWh = 129
# formula
# ST-Lämpö, if this is under 0 it should be shown as 0
# Aurinkokeräimen pinta-ala, m2 * Kerroin Fr * (Tau-alfa-tulo * Säteily, W/m2 - Häviökerroin, W/m2K * (Veden sisäänmenolämpötila aurinkokeräimelle, C - Ulkolämpötila, C))
# PV-Sähkö
# Aurinkokeräimen pinta-ala, m2 * PV-hyötysuhde * Säteily, W/m2

var charge_difference = 0
var over_sizing = 0
var soc = 0
var sustainability = 0

var rounds_dict = {}

var weather_dict = {} # size should be 8763

onready var report_fields = [$report/report_points/ScrollContainer/VBoxContainer/sustainability_report/sustainability_percentage, $report/report_points/ScrollContainer/VBoxContainer/balance_report/balance_mwh, $report/report_points/ScrollContainer/VBoxContainer/sizing_report/sizing_m2, $report/report_points/ScrollContainer/VBoxContainer/soc_report/soc_percentage]

var player_score = 0
var used_turns = 0
var turn_limit = 10

# Game states
enum GAME_STATE {NONE, INFRA_PLACED, INFRA_MODIFY, BUILD_IN_PROGRESS}
var game_state = GAME_STATE.NONE

# Report writing
onready var report_investment = $report/report_points/ScrollContainer/VBoxContainer/HBoxContainer8/investment
onready var report_used_turns = $report/report_points/ScrollContainer/VBoxContainer/HBoxContainer9/tries

# Budget stuff
var total_round_cost = 0
var orange_budget_treshold = false
var warn_about_budget = true
var prices = [] # used to store energy reserve and solar collector prices

func _ready():
	if GameData.has_started_level_3:
		$intro_dialogue_box.visible = false
		$Onboarding.has_read_instructions = true
		current_funds = GameData.current_funds
		current_energy_reserve_cabability = GameData.current_energy_reserve_cabability
		current_solar_collector_area = GameData.current_solar_collector_area
		used_turns = int(GameData.backup_var_1)
	if current_energy_reserve_cabability != 0 or current_solar_collector_area != 0:
		# The player has some infra built
		# Loading possible saved items back into scene
		GameData.load_saved_items()
	$stats_ui/HBoxContainer/funds.bbcode_text = String(current_funds)
	$stats_ui/HBoxContainer/energy_reserve.bbcode_text = String(current_energy_reserve_cabability)
	$stats_ui/HBoxContainer/energy_production.bbcode_text = String(current_solar_collector_area)
	print(current_funds)
	$round_info/round.bbcode_text = "[center]" + String(used_turns + 1) + "[/center]"
	# Load game data and see what needs to do
	
	rounds_dict[0] = {"tasapaino":0, "mitoitus":0, "akkukesto":0, "omavaraisuus":0}
	# creates a dictionary of weather data that we can modify during gameplay
	for i in range(0, 8760, 1):
		weather_dict[i] = {"st_lampo":0, "pv_sahko":0, "lampoalijaama":0, "lampopumppu":0, "sahkotot":0, "sahkoalijaama":0, "sahkoylijaama":0, "lataus":0, "akku":0, "purku":0, "nettoalijaama":0}
	calculate_st_lampo()
	$stats_ui/HBoxContainer/funds.bbcode_text = String(current_funds)
	
	GameData.has_started_level_3 = true


func calculate_turn_score():
	print("Calculating score ... ")
	used_turns += 1
	
	# BUG CAPTURING
	if current_energy_reserve_cabability == 0 or current_solar_collector_area == 0:
		fix_no_infra_bug()
	
	# Game calculates score for
	# Tasapaino muutos
	# Mitoitus muutos
	# Akkukesto muutos
	# Omavaraisuus muutos
	
	energy_reserve_cabability_at_start = current_energy_reserve_cabability

	for hour in weather_dict:
		weather_dict[hour].st_lampo = tarkistuslaskelma.st_lampo(current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].pv_sahko = tarkistuslaskelma.pv_sahko(current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].lampoalijaama = tarkistuslaskelma.lampoalijaama(weather_dict[hour].st_lampo, hour)
	for hour in weather_dict:
		weather_dict[hour].lampopumppu = tarkistuslaskelma.lampopumppu(weather_dict[hour].lampoalijaama)
	for hour in weather_dict:
		weather_dict[hour].sahkotot = tarkistuslaskelma.sahkotot(weather_dict[hour].lampopumppu, hour)
	for hour in weather_dict:
		weather_dict[hour].sahkoalijaama = tarkistuslaskelma.sahkoalijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].sahkoylijaama = tarkistuslaskelma.sahkoylijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].lataus = tarkistuslaskelma.lataus(weather_dict[hour].sahkoylijaama)
	
	tarkistuslaskelma.akku_purku(weather_dict, energy_reserve_cabability_at_start)
	
	for hour in weather_dict:
		weather_dict[hour].nettoalijaama = tarkistuslaskelma.nettoalijaama(weather_dict[hour].sahkoalijaama, weather_dict[hour].purku)
	
	# Tasapaino
	energy_reserve_cabability_at_end = weather_dict[8759].akku / 1000000
	charge_difference = energy_reserve_cabability_at_end - energy_reserve_cabability_at_start
	#print("charge_difference is ", charge_difference)
	
	# Akkukesto
	var energy_reserve_lowest_point_during_year = 1000000000
	var energy_reserve_highest_point_during_year = 0
	for hour in weather_dict:
		if weather_dict[hour].akku < energy_reserve_lowest_point_during_year:
			energy_reserve_lowest_point_during_year = weather_dict[hour].akku
		if weather_dict[hour].akku > energy_reserve_highest_point_during_year:
			energy_reserve_highest_point_during_year = weather_dict[hour].akku
	if energy_reserve_highest_point_during_year > 0:
		soc = float(energy_reserve_lowest_point_during_year) / energy_reserve_highest_point_during_year
	else:
		soc = energy_reserve_lowest_point_during_year / 0.00001

	# Omavaraisuus
	var yearly_energy_consumption = 0
	for hour in weather_dict:
		yearly_energy_consumption += weather_dict[hour].sahkotot
	#print("sahkotot for whole year is ", yearly_energy_consumption)
	yearly_energy_consumption = yearly_energy_consumption * 0.000001
	var energy_needed_from_grid = 0
	for hour in weather_dict:
		energy_needed_from_grid += weather_dict[hour].nettoalijaama
	#print("nettoalijaama for whole year is ", energy_needed_from_grid)
	energy_needed_from_grid = energy_needed_from_grid / 1000000
	sustainability = ((yearly_energy_consumption - energy_needed_from_grid) / (yearly_energy_consumption))
	
	# Mitoitus
	#if charge_difference > 0:
		#over_sizing = charge_difference
	if charge_difference > energy_needed_from_grid:
		over_sizing = charge_difference
	else:
		over_sizing = energy_needed_from_grid
	print(charge_difference, " ", energy_needed_from_grid)
	#else:
		#over_sizing = 0
	
	var difference_score = calculate_difference_score(current_solar_collector_area, energy_reserve_cabability_at_start, charge_difference, -0.2, 0.2, -1, 1000)
	#print("difference score is ", difference_score)
	$report/report_points/ScrollContainer/VBoxContainer/difference/difference_score.bbcode_text = String(int(round(difference_score)))
	var over_sizing_score = calculate_oversizing_score(current_solar_collector_area, over_sizing, 85)
	#print("over_sizing_score ", over_sizing_score)
	$report/report_points/ScrollContainer/VBoxContainer/Ylimitoitus/oversizing_score.bbcode_text = String(int(round(over_sizing_score)))
	var soc_score = calculate_soc_score(current_solar_collector_area, soc, 0.19, 0.21, 0, 0.3)
	#print("soc score ", soc_score)
	$report/report_points/ScrollContainer/VBoxContainer/SOC/soc_score.bbcode_text = String(int(round(soc_score)))
	var sustainability_score = calculate_sustainability_score(current_solar_collector_area, sustainability, 0, 1)
	#print("sustainability score ", sustainability_score)
	$report/report_points/ScrollContainer/VBoxContainer/Sustainability/sustainability_Score.bbcode_text = String(int(round(sustainability_score)))
	player_score = int(round(total_score(0.2, difference_score, 0.2, over_sizing_score, 0.2, soc_score, 0.4, sustainability_score, used_turns, turn_limit)))
	if player_score < 0:
		player_score = 0
	
	charge_difference = int(round(charge_difference))
	soc = int(round(soc*100))
	sustainability = int(round(sustainability * 100))
	
	$report.show_report()
	
	audio_manager.play_good()
	# Report page 1
	report_fields[0].bbcode_text = String(charge_difference) + " MWh"
	#report_fields[0].set("theme_override_colors/font_color", determine_text_color())
	report_fields[1].bbcode_text = String(int(round(over_sizing))) + " MWh"
	report_fields[2].bbcode_text = String(soc) + "%"
	report_fields[3].bbcode_text = String(sustainability) + "%"
	
	# This function call should be relevant only to players
	# with the bug that they have 20M funds and 0 investments
	decrease_funds(total_round_cost)
	
	# Report writing
	print("current funds ", current_funds)
	report_investment.bbcode_text = String((abs(int(float(START_FUNDS - current_funds) / 1000000)))) + " M"
	if current_funds < 5000000:
		report_investment.modulate = Color.orange
	elif current_funds == 0:
		report_investment.modulate = Color.palevioletred
	report_used_turns.bbcode_text = String(used_turns)
	if used_turns > 6:
		report_used_turns.modulate = Color.orange
	elif used_turns > 10:
		report_used_turns.modulate = Color.palevioletred
	$report/report_points/ScrollContainer/VBoxContainer/Score/player_score.bbcode_text = String(player_score)
	
	# Report page 2 scoring
	var points = int(round((rounds_dict[used_turns-1].tasapaino - difference_score) * -1))
	$report/report_points/ScrollContainer/VBoxContainer/difference/difference_delta.modulate = check_report_point_color(points)
	$report/report_points/ScrollContainer/VBoxContainer/difference/difference_delta.bbcode_text = String(points)
	points = int(round((rounds_dict[used_turns-1].mitoitus - over_sizing_score) * -1))
	$report/report_points/ScrollContainer/VBoxContainer/Ylimitoitus/over_sizing_delta.modulate = check_report_point_color(points)
	$report/report_points/ScrollContainer/VBoxContainer/Ylimitoitus/over_sizing_delta.bbcode_text = String(points)
	points = int(round((rounds_dict[used_turns-1].akkukesto - soc_score) * -1))
	$report/report_points/ScrollContainer/VBoxContainer/SOC/soc_delta.modulate = check_report_point_color(points)
	$report/report_points/ScrollContainer/VBoxContainer/SOC/soc_delta.bbcode_text = String(points)
	points = int(round((rounds_dict[used_turns-1].omavaraisuus - sustainability_score) * -1))
	$report/report_points/ScrollContainer/VBoxContainer/Sustainability/sustainability_delta.modulate = check_report_point_color(points)
	$report/report_points/ScrollContainer/VBoxContainer/Sustainability/sustainability_delta.bbcode_text = String(points)
	# save round data
	rounds_dict[used_turns] = {"tasapaino":difference_score, "mitoitus":over_sizing_score, "akkukesto":soc_score, "omavaraisuus":sustainability_score}
	
	$feedback.give_feedback(sustainability_score, difference_score, over_sizing_score, soc_score)
	

func check_report_point_color(points):
	if points > 0:
		return Color.greenyellow
	elif points == 0:
		return Color.white
	else:
		return Color.palevioletred

func calculate_st_lampo():
	for hour in weather_dict:
		weather_dict[hour].st_lampo = tarkistuslaskelma.st_lampo(current_solar_collector_area, hour)
	print(weather_dict[12].st_lampo)


func calculate_pv_sahko():
	for hour in weather_dict:
		weather_dict[hour].pv_sahko = tarkistuslaskelma.pv_sahko(current_solar_collector_area, hour)
	print(weather_dict[12].pv_sahko)


# This function is only used to fix a previous bug
func decrease_funds(amount):
	print("Funds decreased for ", amount)
	# this fixes a previous which bug caused that:
	# if the the game is saved and reopened between sessions
	# the amount is going to be zero and current funds 20m
	if amount == 0 and current_funds == 20000000:
		print("Trying to fix no-budget-decrease bug!")
		var infra = $mouse_interaction/YSort.get_children()
		var sc_amount = 0
		var er_amount = 0
		if infra.size() > 0:
			for item in infra:
				if item.is_in_group("solar_collector"):
					sc_amount += item.area
				elif item.is_in_group("energy_reserve"):
					er_amount += item.area
		# work around the fact that infra data could've been saved
		# seems dangerous, but this if block should only be callable in case
		# the no-budget-decrease bug is present
		if current_energy_reserve_cabability != 0:
			current_energy_reserve_cabability = 0
		if current_solar_collector_area != 0:
			current_solar_collector_area = 0
		funds_decrease(er_amount, sc_amount)
		amount = total_round_cost
	
	if amount != 0:
		current_funds = START_FUNDS - amount
		
	if current_funds >= 0:# - amount >= 0:
		#current_funds -= amount
		current_funds = int(current_funds)
		$stats_ui/HBoxContainer/funds.bbcode_text = String(current_funds)
		return true
	else:
		print("Not enough money!")
		return false
	if current_funds < 5000000 and !orange_budget_treshold:
		orange_budget_treshold = true
		$stats_ui/HBoxContainer/funds.modulate = Color.orange
		warn_about_budget = true
	if current_funds == 0:
		$stats_ui/HBoxContainer/funds.modulate = Color.palevioletred


func increase_energy_demand(amount):
	current_energy_demand += amount
	$stats_ui/HBoxContainer/energy_demand.bbcode_text = String(current_energy_demand)
	

func increace_population(amount):
	current_population += amount
	$stats_ui/HBoxContainer/population.bbcode_text = String(current_population)


func increase_solar_collector_area(amount):
	current_solar_collector_area += amount
	print("Current sc area is ", current_solar_collector_area)
	$stats_ui/HBoxContainer/energy_production.bbcode_text = String(current_solar_collector_area)
	

# dead code
func increase_energy_production(amount):
	current_energy_production += amount
	$stats_ui/HBoxContainer/energy_production.bbcode_text = String(current_energy_production)


func increase_energy_reserve(amount):
	print(amount)
	current_energy_reserve_cabability += amount
	print(current_energy_reserve_cabability)
	$stats_ui/HBoxContainer/energy_reserve.bbcode_text = String(current_energy_reserve_cabability)


func calculate_difference_score(B2, B3, B16, D16, E16, C16, F16):
	print("difference is ", B16)
	if B2 > 0 and B3 > 0:
		var condition1 = 0
		var condition2 = 0
		var condition3 = 0
		var condition4 = 0

		if B16 >= D16 and B16 <= E16:
			condition1 = 100

		if B16 < C16 or B16 > F16:
			condition2 = 0

		if B16 >= C16 and B16 < D16:
			condition3 = ((B16 - C16) / (D16 - C16)) * 100

		if B16 > E16 and B16 <= F16:
			condition4 = 100 - ((B16 - E16) / (F16 - E16)) * 100

		return condition1 + condition2 + condition3 + condition4
	else:
		return 0


func calculate_oversizing_score(B2, B17, E17):
	if B2 > 0:
		if B17 < E17:
			return 100 - (B17 / E17) * 100
		else:
			return 0
	else:
		return 0


func calculate_soc_score(B3, B18, D18, E18, C18, F18):
	if B3 > 0:
		var condition1 = 0
		var condition2 = 0
		var condition3 = 0
		var condition4 = 0

		if B18 >= D18 and B18 <= E18:
			condition1 = 100

		if B18 < C18 or B18 > F18:
			condition2 = 0

		if B18 >= C18 and B18 < D18:
			condition3 = ((B18 - C18) / (D18 - C18)) * 100

		if B18 > E18 and B18 <= F18:
			condition4 = 100 - ((B18 - E18) / (F18 - E18)) * 100

		return condition1 + condition2 + condition3 + condition4
	else:
		return 0


func calculate_sustainability_score(B2, B19, D19, E19):
	if B2 > 0:
		if B19 >= D19 and B19 <= E19:
			return ((B19 - D19) / (E19 - D19)) * 100
		else:
			return 0
	else:
		return 0


func total_score(G16, H16, G17, H17, G18, H18, G19, H19, B21, B22):
	var result = G16 * H16 + G17 * H17 + G18 * H18 + G19 * H19

	if B21 > B22:
		result -= B21 - B22

	return result


func determine_text_color():
	var color = Color(1,1,1,1)
	return color

# dead code
func _on_season_dial_new_season():
	# decrease_funds(house.price)
	increase_energy_demand(25 * 0.02)
	increace_population(25)
	#print(st_lampo())
	#print(pv_sahko())
func _on_season_dial_new_year():
	pass # Replace with function body.
func _on_next_turn_pressed():
	calculate_turn_score()


func _on_ok_button_pressed():
	$report/AnimationPlayer.play_backwards("report_appears")
	$report_points/AnimationPlayer.play("report_appears")
	game_state = GAME_STATE.NONE



func _on_points_report_ok_button_pressed():
	# Next round!
	print("New round started!")
	game_state = GAME_STATE.NONE
	$report/report_points/AnimationPlayer.play("report_disappears")
	$report/report_points.rect_position.y = 8
	$report/report_points/ScrollContainer.scroll_vertical = 0
	$infra_panel.show_infra_panel()
	$infra_panel/buttons_animation.play("level_threebuttons_pump")
	if warn_about_budget:
		$budget_warning.visible = true
		warn_about_budget = false
	# update round indicator
	$round_info/round.bbcode_text = "[center]" + String(used_turns+1) + "[/center]"
	if used_turns == 6:
		$round_info/round_bg.modulate = Color.orange
	elif used_turns == 9:
		$round_info/round_bg.modulate = Color.palevioletred


func _on_build_finished():
	calculate_turn_score()


func _on_infra_item_build_started(area, type):
	if type == "solar_collector":
		increase_solar_collector_area(area)
	elif type == "energy_reserve":
		increase_energy_reserve(area)
	game_state = GAME_STATE.BUILD_IN_PROGRESS


func _on_infra_item_modify_started(difference, type):
	if type == "solar_collector":
		increase_solar_collector_area(-difference)
	elif type == "energy_reserve":
		increase_energy_reserve(-difference)
	game_state = GAME_STATE.BUILD_IN_PROGRESS


# dead code
func _on_solarpanel_build_started(area):
	increase_solar_collector_area(area)
	game_state = GAME_STATE.BUILD_IN_PROGRESS
	#$infra_panel/AnimationPlayer.play("toggle_infra_ui")
func _on_energy_reserve_build_started(area):
	increase_energy_reserve(area)
	game_state = GAME_STATE.BUILD_IN_PROGRESS
	#$infra_panel/AnimationPlayer.play("toggle_infra_ui")


func _on_mouse_interaction_infra_placed(_item):
	game_state = GAME_STATE.INFRA_PLACED
	$infra_panel.show_build_button()


func _on_mouse_interaction_step_back():
	pass
	#if game_state == GAME_STATE.INFRA_PLACED:
		#$infra_panel.hide_build_button()
		#game_state = GAME_STATE.NONE


func _on_mouse_interaction_infra_modified(_item):
	#print("game_state is ", game_state)
	if game_state != GAME_STATE.BUILD_IN_PROGRESS and game_state != GAME_STATE.INFRA_PLACED:
		game_state = GAME_STATE.INFRA_MODIFY


func _on_report_button_pressed():
	show_previous_record()


func show_previous_record():
	if rounds_dict.size() > 1:
		$report.show_report()


func _on_infra_panel_builds_reset():
	game_state = GAME_STATE.NONE


# Calculating funds decrease here
# Doesn't remove funds from budget
func funds_decrease(energy_reserve_amount, solar_collector_amount):
	total_round_cost = 0
	print("trying to decrease funds")
	prices.clear()
	var _energy_reserve_cabability_at_start = current_energy_reserve_cabability + energy_reserve_amount
	var _current_solar_collector_area = current_solar_collector_area + solar_collector_amount

	for hour in weather_dict:
		weather_dict[hour].st_lampo = tarkistuslaskelma.st_lampo( _current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].pv_sahko = tarkistuslaskelma.pv_sahko( _current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].lampoalijaama = tarkistuslaskelma.lampoalijaama(weather_dict[hour].st_lampo, hour)
	for hour in weather_dict:
		weather_dict[hour].lampopumppu = tarkistuslaskelma.lampopumppu(weather_dict[hour].lampoalijaama)
	for hour in weather_dict:
		weather_dict[hour].sahkotot = tarkistuslaskelma.sahkotot(weather_dict[hour].lampopumppu, hour)
	for hour in weather_dict:
		weather_dict[hour].sahkoalijaama = tarkistuslaskelma.sahkoalijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].sahkoylijaama = tarkistuslaskelma.sahkoylijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].lataus = tarkistuslaskelma.lataus(weather_dict[hour].sahkoylijaama)
	
	tarkistuslaskelma.akku_purku(weather_dict, _energy_reserve_cabability_at_start)
	
	for hour in weather_dict:
		weather_dict[hour].nettoalijaama = tarkistuslaskelma.nettoalijaama(weather_dict[hour].sahkoalijaama, weather_dict[hour].purku)
	
	# Tasapaino
	energy_reserve_cabability_at_end = weather_dict[8759].akku / 1000000
	charge_difference = energy_reserve_cabability_at_end - _energy_reserve_cabability_at_start
	
	var energy_reserve_highest_point_during_year = 0
	for hour in weather_dict:
		if weather_dict[hour].akku > energy_reserve_highest_point_during_year:
			energy_reserve_highest_point_during_year = weather_dict[hour].akku
	
	var energy_reserve_cost = energy_reserve_highest_point_during_year / 1000000 * 83000
	print("energy_reserve_cost ", energy_reserve_cost)
	var solar_collector_cost = solar_collector_amount * 500
	total_round_cost = energy_reserve_cost + solar_collector_cost
	print("solar collector cost ", solar_collector_cost)
	print("total cost ", total_round_cost)
	prices.append(energy_reserve_cost)
	prices.append(solar_collector_cost)
#	if START_FUNDS - total_round_cost >= 0:
#		return true
#	else:
#		return false


func can_build(energy_reserve_amount, solar_collector_amount):
	funds_decrease(energy_reserve_amount, solar_collector_amount)
	if START_FUNDS - total_round_cost >= 0:
		return true
	else:
		return false


func fix_no_infra_bug():
	var infra = $mouse_interaction/YSort.get_children()
	if current_energy_reserve_cabability == 0:
		var er_amount = 0
		for item in infra:
			if item.is_in_group("energy_reserve"):
				er_amount += item.area
		$stats_ui/HBoxContainer/energy_reserve.bbcode_text = String(er_amount)
	if current_solar_collector_area == 0:
		var sc_amount = 0
		for item in infra:
			if item.is_in_group("solar_collector"):
				sc_amount += item.area
		$stats_ui/HBoxContainer/energy_production.bbcode_text = String(sc_amount)


func recalculate_player_score():
	energy_reserve_cabability_at_start = current_energy_reserve_cabability

	for hour in weather_dict:
		weather_dict[hour].st_lampo = tarkistuslaskelma.st_lampo(current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].pv_sahko = tarkistuslaskelma.pv_sahko(current_solar_collector_area, hour)
	for hour in weather_dict:
		weather_dict[hour].lampoalijaama = tarkistuslaskelma.lampoalijaama(weather_dict[hour].st_lampo, hour)
	for hour in weather_dict:
		weather_dict[hour].lampopumppu = tarkistuslaskelma.lampopumppu(weather_dict[hour].lampoalijaama)
	for hour in weather_dict:
		weather_dict[hour].sahkotot = tarkistuslaskelma.sahkotot(weather_dict[hour].lampopumppu, hour)
	for hour in weather_dict:
		weather_dict[hour].sahkoalijaama = tarkistuslaskelma.sahkoalijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].sahkoylijaama = tarkistuslaskelma.sahkoylijaama(weather_dict[hour].sahkotot, weather_dict[hour].pv_sahko)
	for hour in weather_dict:
		weather_dict[hour].lataus = tarkistuslaskelma.lataus(weather_dict[hour].sahkoylijaama)
	
	tarkistuslaskelma.akku_purku(weather_dict, energy_reserve_cabability_at_start)
	
	for hour in weather_dict:
		weather_dict[hour].nettoalijaama = tarkistuslaskelma.nettoalijaama(weather_dict[hour].sahkoalijaama, weather_dict[hour].purku)
	
	# Tasapaino
	energy_reserve_cabability_at_end = weather_dict[8759].akku / 1000000
	charge_difference = energy_reserve_cabability_at_end - energy_reserve_cabability_at_start
	
	# Akkukesto
	var energy_reserve_lowest_point_during_year = 1000000000
	var energy_reserve_highest_point_during_year = 0
	for hour in weather_dict:
		if weather_dict[hour].akku < energy_reserve_lowest_point_during_year:
			energy_reserve_lowest_point_during_year = weather_dict[hour].akku
		if weather_dict[hour].akku > energy_reserve_highest_point_during_year:
			energy_reserve_highest_point_during_year = weather_dict[hour].akku
	if energy_reserve_highest_point_during_year > 0:
		soc = float(energy_reserve_lowest_point_during_year) / energy_reserve_highest_point_during_year
	else:
		soc = energy_reserve_lowest_point_during_year / 0.00001

	# Omavaraisuus
	var yearly_energy_consumption = 0
	for hour in weather_dict:
		yearly_energy_consumption += weather_dict[hour].sahkotot
	yearly_energy_consumption = yearly_energy_consumption * 0.000001
	var energy_needed_from_grid = 0
	for hour in weather_dict:
		energy_needed_from_grid += weather_dict[hour].nettoalijaama
	energy_needed_from_grid = energy_needed_from_grid / 1000000
	sustainability = ((yearly_energy_consumption - energy_needed_from_grid) / (yearly_energy_consumption))
	
	# Mitoitus
	if charge_difference > energy_needed_from_grid:
		over_sizing = charge_difference
	else:
		over_sizing = energy_needed_from_grid
	print(charge_difference, " ", energy_needed_from_grid)
	
	var difference_score = calculate_difference_score(current_solar_collector_area, energy_reserve_cabability_at_start, charge_difference, -0.2, 0.2, -1, 1000)
	$report/report_points/ScrollContainer/VBoxContainer/difference/difference_score.bbcode_text = String(int(round(difference_score)))
	var over_sizing_score = calculate_oversizing_score(current_solar_collector_area, over_sizing, 85)
	$report/report_points/ScrollContainer/VBoxContainer/Ylimitoitus/oversizing_score.bbcode_text = String(int(round(over_sizing_score)))
	var soc_score = calculate_soc_score(current_solar_collector_area, soc, 0.19, 0.21, 0, 0.3)
	$report/report_points/ScrollContainer/VBoxContainer/SOC/soc_score.bbcode_text = String(int(round(soc_score)))
	var sustainability_score = calculate_sustainability_score(current_solar_collector_area, sustainability, 0, 1)
	$report/report_points/ScrollContainer/VBoxContainer/Sustainability/sustainability_Score.bbcode_text = String(int(round(sustainability_score)))
	player_score = int(round(total_score(0.2, difference_score, 0.2, over_sizing_score, 0.2, soc_score, 0.4, sustainability_score, used_turns, turn_limit)))
	if player_score < 0:
		player_score = 0
		
	if player_score > 0:
		return true
	else:
		return false
