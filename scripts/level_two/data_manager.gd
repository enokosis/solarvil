extends Node

var data_path = "res://data/weather_data.json"
var data = []

func _ready():
	data = load_json_data(data_path)
	data = filter_data(data, "SATEILY", 1)
	shuffle_array(data)

func filter_data(data, key, threshold):
	var filtered_data = []
	for item in data:
		if float(item[key]) >= threshold:
			filtered_data.append(item)
	return filtered_data


func is_above_threshold(element, key, threshold):
	return element[key] >= threshold

func load_json_data(path):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		return data
	else:
		print("Error: File not found!")
		return null

func shuffle_array(arr):
	for i in range(arr.size() - 1, 0, -1):
		var j = GameData.rng.randi() % (i + 1)
		# Manually swap the elements
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp

func get_data_at_index(data_type, index):
	if index < data.size():
		var data_point = data[index]
		print(data_point)
		if data_type in data_point:
			return data_point[data_type]
		else:
			print("Error: Data type not found!")
			return null
	else:
		print("Error: Index out of range!")
		return null

var static_data = {
	"PV/T-pinta-ala (m2)": 1000,
	"PV-hyötysuhde": 0.15,
	"Lämpöpumpun COP": 5,
	"Akuston energiahyötysuhde": 0.9,
	"Kerroin Fr": 0.7,
	"Tau-alfa-tulo": 0.85,
	"Häviökerroin (W/m2K)": 1,
	"Veden sisäänmenolämpötila aurinkokeräimelle (C)": 25
}

func get_static_data(key):
	if key in static_data:
		return static_data[key]
	else:
		print("Error: Static data key not found!")
		return null
