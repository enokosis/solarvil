extends Node

onready var audio_player = $AudioStreamPlayer
var good_clicks = [preload("res://sounds/click_2_B.wav"), preload("res://sounds/click_3_B.wav"), preload("res://sounds/click_3_G.wav")]
var good_audio = preload("res://sounds/points.wav")
var bad_clicks = [preload("res://sounds/no_2_B.wav"), preload("res://sounds/no_2_G.wav")]


func play_good():
	audio_player.stream = good_audio
	audio_player.play()


func play_bad():
	audio_player.stream = bad_clicks[randi() % bad_clicks.size()]
	audio_player.play()


# Randomly selects an audio clip and plays it. Randomness to add variety.
func play_good_click():
	audio_player.stream = good_clicks[randi() % good_clicks.size()]
	audio_player.play()


func play_bad_click():
	audio_player.stream = bad_clicks[randi() % bad_clicks.size()]
	audio_player.play()
