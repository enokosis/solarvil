extends Control

onready var slider = $scroll_bar
onready var report = $report_points

var start_pos = 1000
var old_value = 0

func _ready():
	old_value = slider.value


func _on_scroll_bar_value_changed(value):
	report.rect_position = Vector2(report.rect_position.x, report.rect_position.y + (old_value - value))
	old_value = value
	$scroll_bar/AnimationPlayer.play("RESET")


func show_report():
	$report_points/AnimationPlayer.play("report_appears")
	$scroll_bar.value = 0
	report.rect_position = Vector2(112,8)


func _on_AnimationPlayer_animation_finished(anim_name):
	pass
	#$scroll_bar/AnimationPlayer.play("size_pump")
