extends Node

var dialogue_index = 0
var http_request = HTTPRequest.new()
var server_url = "https://sparkling-mysterious-beak.glitch.me/"
# Submission checks
var able_to_submit_score = true

func trigger_intro():
	#$"../printer".visible = false
	$"../countdown_timer".visible = false
	$"../level_two_outro".visible = true


func _on_save_game_pressed():
	$"../level_two_outro/dialogue_box".next_dialogue()
	$"../level_two_outro/dialogue_box/Panel/next_dialogue".visible = true
	$"../level_two_outro/save_game".visible = false
	GameData.current_level = 3
	GameData.stage_two_score = $"../answer_machine".score
	GameData.save_progression()


func _on_dialogue_box_dialogue_ended():
	get_tree().change_scene("res://scenes/lobby.tscn")


func _on_next_dialogue_pressed():
	dialogue_index += 1
	if dialogue_index == 2:
		$"../level_two_outro/save_game".visible = true
		$"../level_two_outro/dialogue_box/Panel/next_dialogue".visible = false


func save_score_to_leaderboard():
	var data = {
		"name": GameData.player_name,
		"team": GameData.team_name,
		"stage2": $"../answer_machine".score,
		"studentNumber": GameData.player_student_number
	}
	
	print("Sending data:", data)
	var headers = ["Content-Type: application/json"]
	
	if http_request.is_connected("request_completed", self, "_on_ScoreSubmit_completed"):
		http_request.disconnect("request_completed", self, "_on_ScoreSubmit_completed")
	
	http_request.connect("request_completed", self, "_on_ScoreSubmit_completed")
	http_request.request(server_url + "submitscore", headers, false, HTTPClient.METHOD_POST, JSON.print(data))
	
	# Setting this to false, if the request is succesful it gets set to true
	able_to_submit_score = false
	
	
func _on_ScoreSubmit_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", self, "_on_ScoreSubmit_completed")
	
	if response_code == 200:
		able_to_submit_score = true
		#get_tree().change_scene("res://scenes/lobby.tscn")
		print("Score submitted successfully")
	else:
		print("Failed to submit score: ", response_code)
