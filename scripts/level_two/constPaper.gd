extends Node2D

var constants_1 = {
	"PV/T-pinta-ala (m2)": 1000,
	"PV-hyötysuhde": 0.15,
	"Lämpöpumpun COP": 5,
	"Akuston energiahyötysuhde": 0.9
}

var constants_2 = {
	"Kerroin Fr": 0.7,
	"Tau-alfa-tulo": 0.85,
	"Häviökerroin (W/m2K)": 1,
	"Veden sisäänmenolämpötila aurinkokeräimelle (C)": 25
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var label_1 = $Panel/solarpan
	var label_2 = $Panel2/systemSet
	
	$Panel/ColorRect.color = Color(1, 0.98, 0.78)  # Light paper color
	$Panel2/ColorRect.color = Color(0.98, 0.94, 0.75)  # Slightly darker paper color


	set_text_to_label(label_1, constants_1, "Lähtöarvot \n")
	set_text_to_label(label_2, constants_2, "Aurinkokeräimen parametrit \n")



func set_text_to_label(label, constants, title):
#	var text = "[color=black][b]" + title + "[/b][/color]\n"
#	for key in constants:
#		text += "[color=black]" + key + ": " + str(constants[key]) + "[/color]\n"
#	label.bbcode_text = text
	var text = title + "\n"
	for key in constants:
		text += key + ": " + str(constants[key]) + "\n"
	label.bbcode_text = text

