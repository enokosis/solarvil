extends Control


onready var weather_data = get_node("/root/GameData").get_node("weather_data")

onready var grid = $Panel/GridContainer

func _ready():
	add_data_to_table()
#	var text_node = RichTextLabel.new()
#	text_node.bbcode_text = String(23456)
#	text_node.bbcode_enabled = true
#	text_node.fit_content_height = true
#	grid.add_child(text_node)


func add_data_to_table():
	if weather_data.weather_dictionary.size() != 0:
		for i in range(0,25,1):
			create_text_node(weather_data.weather_dictionary[i].ULKOLAMPOTILA)
			create_text_node(weather_data.weather_dictionary[i].SATEILY)
			create_text_node(weather_data.weather_dictionary[i].SAHKO)
			create_text_node(weather_data.weather_dictionary[i].LAMMITYS)
	else:
		print("Weather data dictionary is empty.")


func create_text_node(item):
	var text_node = RichTextLabel.new()
	text_node.bbcode_text = String(item)
	text_node.bbcode_enabled = true
	text_node.fit_content_height = true
	grid.add_child(text_node)


#func add_data_to_table():
#	if weather_data.weather_dictionary.size() != 0:
#		for i in range(0,25,1):
#			create_text_node(weather_data.weather_dictionary[i].ULKOLAMPOTILA, weather_data.weather_dictionary[i].SATEILY, weather_data.weather_dictionary[i].SAHKO, weather_data.weather_dictionary[i].LAMMITYS)
#	else:
#		print("Weather data dictionary is empty.")
#
#
#func create_text_node(item0, item1, item2, item3):
#	var text_node = RichTextLabel.new()
#	text_node.bbcode_text = String(item0) + " " + String(item1) + " " +  String(item2) + " " +  String(item3)
#	text_node.bbcode_enabled = true
#	text_node.fit_content_height = true
#	grid.add_child(text_node)
