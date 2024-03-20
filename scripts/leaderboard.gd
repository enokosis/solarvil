extends Node

var server_url = "https://solar-village-leaderboard.glitch.me/"

onready var name_input = $MainVBox/InputHBox/NameInput
onready var team_input = $MainVBox/InputHBox/TeamInput
onready var stage2_input = $MainVBox/InputHBox/Stage2Input
onready var stage3_input = $MainVBox/InputHBox/Stage3Input
onready var student_number_input = $MainVBox/InputHBox/StudentNumberInput
onready var submit_score_button = $MainVBox/SubmitScoreButton
onready var refresh_leaderboard_button = $RefreshLeaderboardButton
onready var leaderboard_grid = $ScrollContainer/LeaderboardGrid

var http_request = HTTPRequest.new()

# Submission checks
var able_to_submit_score = true
var is_submitting = false


func _ready():
	add_child(http_request)
	submit_score_button.connect("pressed", self, "_on_SubmitScoreButton_pressed")
	refresh_leaderboard_button.connect("pressed", self, "_on_RefreshLeaderboardButton_pressed")
	
	# Set appropriate text
	name_input.text = GameData.player_name
	#team_input.placeholder_text = "Team"
	$MainVBox/InputHBox/TeamSelection.value = GameData.team_name
	stage2_input.text = String(GameData.stage_two_score)
	stage3_input.text = String(GameData.stage_three_score)
	student_number_input.text = String(GameData.player_student_number)
	
	submit_score_button.text = "Lähetä pisteet!"
	refresh_leaderboard_button.text = "Päivitä leaderboard"
	
	get_stage2_score()
	
	# To debug player data, it's printed here
	print("Player full info is ", GameData.player_full_info)
	print("Player Stage 2 score is ", GameData.stage_two_score)
	print("Player Stage 3 score is ", GameData.stage_three_score)

func _on_SubmitScoreButton_pressed():
	var name = name_input.text.strip_edges()
	var surname = GameData.player_full_info.split(" ")
	var team = "Työryhmä " + String($MainVBox/InputHBox/TeamSelection.value)
	var stage2 = stage2_input.text.strip_edges().to_int()
	var stage3 = stage3_input.text.strip_edges().to_int()
	var student_number =  student_number_input.text.strip_edges()
	
	if $cheatboard.we_are_cheating:
		surname = $MainVBox/InputHBox/SurnameInput.text.strip_edges()
	else:
		print(surname.size())
		if surname.size() > 1:
			surname = surname[1]
	
	if name == "" or team == "" or student_number == "": #stage2 <= 0 or stage3 <= 0 or student_number == "":
		print("Invalid input")
		return
	
	var data = {
		"name": name,
		"surname": surname,
		"team": team,
		"stage2": stage2,
		"stage3": stage3,
		"total": stage2 + stage3,
		"studentNumber": student_number
	}
	
	print("Sending data:", data)
	var headers = ["Content-Type: application/json"]
	
	if http_request.is_connected("request_completed", self, "_on_ScoreSubmit_completed"):
		http_request.disconnect("request_completed", self, "_on_ScoreSubmit_completed")
	
	http_request.connect("request_completed", self, "_on_ScoreSubmit_completed")
	http_request.request(server_url + "submitscore", headers, false, HTTPClient.METHOD_POST, JSON.print(data))
	
	# Setting this to false, if the request is succesful it gets set to true
	able_to_submit_score = false
	is_submitting = true


func _on_ScoreSubmit_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", self, "_on_ScoreSubmit_completed")
	
	if response_code == 200:
		able_to_submit_score = true
		print("Score submitted successfully")
	else:
		print("Failed to submit score: ", response_code)
	
	_on_RefreshLeaderboardButton_pressed()

func _on_RefreshLeaderboardButton_pressed():
	# Disconnect if connected
	if http_request.is_connected("request_completed", self, "_on_LeaderboardFetch_completed"):
		http_request.disconnect("request_completed", self, "_on_LeaderboardFetch_completed")
	
	# Connect and request
	http_request.connect("request_completed", self, "_on_LeaderboardFetch_completed")
	http_request.request(server_url + "getleaderboard")
	
	update_leaderboard_feedback()

func _on_LeaderboardFetch_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", self, "_on_LeaderboardFetch_completed")
	
	if response_code == 200:
		var data = JSON.parse(body.get_string_from_utf8()).result
		update_leaderboard(data)
		$leaderboard_timer.start()
	else:
		update_failed()
		print("Failed to fetch leaderboard: ", response_code)

func update_leaderboard(data):
	# Clear previous leaderboard entries from GridContainer
	for child in leaderboard_grid.get_children():
		child.queue_free()
	
	# Add headers
	for header in ["Nimi", "Työryhmä", "Pisteet - Taso 2", "Pisteet - Taso 3", "Yhteensä"]:
		var label = Label.new()
		label.text = header
		label.add_color_override("font_color", Color(252/255.0, 193/255.0, 26/255.0))  # Sun color for headers
		leaderboard_grid.add_child(label)
	
	# Add entries
	for entry in data:
		for key in ["name", "team", "stage2", "stage3", "total"]:
			var label = Label.new()
			label.text = str(entry[key])
			leaderboard_grid.add_child(label)


func update_leaderboard_feedback():
	# Player feedback
	$update_failed_message.visible = false
	$ScrollContainer.visible = false
	$sun_icon.visible = true


func update_successful():
	$ScrollContainer.visible = true
	$sun_icon.visible = false
	
	
func update_failed():
	$sun_icon.visible = false
	$update_failed_message.visible = true


func _on_leaderboard_timer_timeout():
	if able_to_submit_score:
		$ScrollContainer.visible = true
		$sun_icon.visible = false
		if is_submitting:
			change_submission_to_message()
			# save the information that the score is submitted
			GameData.backup_var_0 = "score_submitted"
			GameData.save_progression()
	else:
		$sun_icon.visible = false
		$update_failed_message.visible = true
	is_submitting = false


func _on_info_pressed():
	$info_pop_up_window.visible = true


# changes the submission form to a message indicating a successful score submission
func change_submission_to_message():
	$MainVBox.visible = false
	$successful_submission_message.visible = true


func _on_settings_pressed():
	$settings_pop_up_window.visible = true


func get_stage2_score():
	# Disconnect if connected
	if http_request.is_connected("request_completed", self, "_on_stage2_fetch_completed"):
		http_request.disconnect("request_completed", self, "_on_stage2_fetch_completed")
	
	# Connect and request
	http_request.connect("request_completed", self, "_on_stage2_fetch_completed")
	http_request.request(server_url + "getStage2ScoreForTeam?team=Työryhmä%20" + str(GameData.team_name))


func _on_stage2_fetch_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", self, "_on_stage2_fetch_completed")
	
	if response_code == 200:
		var data = JSON.parse(body.get_string_from_utf8()).result
		if "stage2" in data:
			stage2_input.text = data["stage2"]
		else:
			print("Team not found in the database")
	else:
		print("HTTP request failed with response code: " + str(response_code))
		
	# Fetch initial leaderboard
	_on_RefreshLeaderboardButton_pressed()
