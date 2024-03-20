extends TextureButton

var report_scene = preload("res://scenes/level_two/report.tscn")
var _sensor_type = "SAHKO"  # Default sensor type
var counter = 0

# GUI elements
onready var type_label = $TypeLabel
onready var counter_label = $CounterLabel
onready var data_manager = get_parent().get_node("data_manager")

export var color: Color 

# Setter method for sensor_type
func sensor_type(new_type):
	# Types don't iclude Ä or Ö in the data table
	match new_type:
		"SAHKÖ":
			_sensor_type = "SAHKO"
		"LÄMMITYS":
			_sensor_type = "LAMMITYS"
		"ULKOLÄMPÖTILA":
			_sensor_type = "ULKOLAMPOTILA"
		"SÄTEILY":
			_sensor_type = "SATEILY"
	type_label.text = new_type

func _ready():
	connect("pressed", self, "_on_Sensor_pressed")
	sensor_type("SÄHKO")
	update_counter_display()
	self_modulate = color

func _on_Sensor_pressed():
	counter += 1
	update_counter_display()

	var report = report_scene.instance()
	var data_value = data_manager.get_data_at_index(_sensor_type, counter - 1)
	report.call_deferred("set_report_number", data_value, counter, color)
	#report.set_report_number(data_value)

	get_parent().add_child(report)
	report.global_position = report.REPORT_POSITION
	
	# Modify sensor data visualiser
	$AnimatedSprite.speed_scale = rand_range(0.1, 1)

func update_counter_display():
	if counter == 0:
		counter_label.text = "-"
	else:
		counter_label.text = str(counter)
