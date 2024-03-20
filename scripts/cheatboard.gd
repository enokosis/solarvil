extends Node

# Allows for the entering of totally customisable data into the leaderboard
var password = "S4kuL4rs"
var we_are_cheating = false
var enter_cheatboard = false

func _input(event):
	if event.is_action_pressed("cheatboard"):
		$cheatboard_timer.start()
		enter_cheatboard = true
	if event.is_action_released("cheatboard"):
		enter_cheatboard = false


func _on_cheatboard_timer_timeout():
	if enter_cheatboard:
		$"../cheatboard_sign_in".visible = true
		enter_cheatboard = false


func _on_submit_password_pressed():
	if $"../cheatboard_sign_in/password".text == password:
		we_are_cheating = true
		$"../MainVBox/InputHBox/Stage2Input".editable = true
		$"../MainVBox/InputHBox/Stage3Input".editable = true
		$"../MainVBox/labels/Surname".visible = true
		$"../MainVBox/InputHBox/SurnameInput".visible = true
		$"../cheatboard_sign_in".visible = false
