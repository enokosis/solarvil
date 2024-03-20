extends DraggableObject

var report_number = -1
onready var report_sprite# = self
onready var label = $ReportLabel  # Assuming ReportLabel is the name of the label node in the editor
onready var printer = get_parent().get_node("printer")
onready var REPORT_POSITION = Vector2(printer.global_position.x,printer.global_position.y + 50)  #Vector2(300, 130)  # Adjust this position as per your needs
onready var tween = $ReportTween
onready var tex = preload("res://art/stage 2/report_2.png")


func _ready():
	if not label:
		print("Error: ReportLabel not found!")
		return
	position.y = REPORT_POSITION.y - 70  # Start 50 units above the final y position
	tween.interpolate_property(self, "position:y", position.y, REPORT_POSITION.y, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)

	tween.start()
	

	# Set up label properties
	label.rect_min_size = Vector2(50, 25)
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.rect_pivot_offset = label.rect_min_size / 2.0

	# Set up font
	#var dynamic_font = DynamicFont.new()
	#dynamic_font.font_data = preload("res://ui/Karla-VariableFont_wght.ttf")
	#dynamic_font.size = 20  # Set the font size you want

	#label.add_font_override("normal_font", dynamic_font)  # Assign the DynamicFont to the label
	#label.add_color_override("font_color", Color(1, 0, 0, 1))  # Set the font color to red
	
func set_report_number(number, index, color):#, sprite_path="res://art/stage 2/report_2.png"):
	if not label:
		print("Error: Label is null!")
		return
	
	report_number = number
	#print("%.2f" % (float(number)))
	label.text = str("%.2f" % (float(number)))
	self.set_texture(tex)
	$CounterLabel.text = str(index)
	z_index = 2
	self_modulate = color
