extends Node

# Holds the weather data
# that might end up meaning all the ober 8000 hrs of it

const ULKOLAMPOTILA = [-3.6] # C
const SATEILY = [0] # W/m2
const SAHKO = [65700] # Wh
const LAMMITYS = [122901] # Wh
const KELPOISUUS = [false]

# Seasons
# winter 59 days * 24 = 1415hrs index = 1415 - 1 = 1414 range = 0 to 1414
# spring 92 days * 24 = 2208 hrs index = 1414  + 2208 = 3623 range = 1415 to 3623
# summer 92 days * 24 = 2208 hrs index = 3623  + 2208 = 6071 range = 3624 to 5831
# autumn 91 days * 24 = 2184 hrs index = 5831 + 2184 = 8015 range = 5832 to 8015
# winter 31 days * 24 = 744 hrs index = 8015 + 744 = 8759 range = 8016 to 8759

var weather_dictionary
# Weather dictionary is constructed from a json that holds all the weather data
# Data is accessable with:
# LAMMITYS, SAHKO, SATEILY, ULKOLAMPOTILA
#
# For level 2 each hour is valid if SATEILY is > 50
# Electricity consumption per season
var spring_SAHKO = 0
var summer_SAHKO = 0
var autumn_SAHKO = 0
var winter_SAHKO = 0

func _ready():
	weather_dictionary = read_json_file("res://data/weather_data.json")
	#print(weather_dictionary.size())
	print(weather_dictionary[3623])
	# Here the range needs to be one index higher for teh for loop
	spring_SAHKO = calculate_electricity_consumption_per_season(1415, 3624)
	summer_SAHKO = calculate_electricity_consumption_per_season(3624, 5832)
	autumn_SAHKO = calculate_electricity_consumption_per_season(5832, 8016)
	winter_SAHKO = calculate_electricity_consumption_per_season(8016, 8760)
	winter_SAHKO += calculate_electricity_consumption_per_season(0, 1415)
	print(spring_SAHKO + summer_SAHKO + autumn_SAHKO + winter_SAHKO)
	
	
func calculate_electricity_consumption_per_season(range_min, range_max):
	var sum = 0
	for i in range(range_min, range_max, 1):
		sum += weather_dictionary[i].SAHKO
	return sum


func read_json_file(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = parse_json(content_as_text)
	# some items are imported as strings, let's make them floats
	for hour in content_as_dictionary:
		hour.ULKOLAMPOTILA = float(hour.ULKOLAMPOTILA)
		hour.SATEILY = float(hour.SATEILY)
		hour.LAMMITYS = float(hour.LAMMITYS)
	return content_as_dictionary
