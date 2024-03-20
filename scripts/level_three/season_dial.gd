extends Node2D

# Handles advancing the season
# Keeps track of the current season and year

signal new_year
signal new_season

var seasons = [ "spring", "summer", "autumn"," winter"]
var current_season = 1
onready var season_info = $"../season_info"
var current_year = 1
onready var year_info = $"../year_info"
var clicks = 0

# This needs to be done differently if the current season is shown on top instead of showing it down
# see how the animation and season names dont match

func _on_next_season_pressed():
	if current_season != seasons.size() - 1:
		current_season += 1
		if current_season == 1:
			$AnimationPlayer.play("summer-autumn")
			season_info.bbcode_text = "[center]KEVÄT[/center]"
		elif current_season == 2:
			$AnimationPlayer.play("autumn-winter")
			season_info.bbcode_text = "[center]KESÄ[/center]"
		elif current_season == 3:
			$AnimationPlayer.play("winter-spring")
			season_info.bbcode_text = "[center]SYKSY[/center]"
		print("next season")
	else:
		current_season = 0
		$AnimationPlayer.play("spring-summer")
		season_info.bbcode_text = "[center]TALVI[/center]"
		print("reset")
	emit_signal("new_season")
	clicks += 1
	if clicks % 4 == 0:
		current_year += 1
		year_info.bbcode_text = "[center]" + String(current_year) + ". vuosi[/center]"
		emit_signal("new_year")
