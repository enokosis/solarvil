extends Control

var dialogue_index = 0
var team_name = ""


func _ready():
	$role_selection/role_panel/player_role.text = GameData.player_role
	# actually this is already saved in level 1 outro script
	#GameData.current_level = 2


func _on_dialogue_box_dialogue_ended():
	#$role_selection.visible = true
	self.visible = false


func _on_apply_name_pressed():
	$dialogue_box.next_dialogue()
	$dialogue_box/Panel/next_dialogue.visible = true
	$dialogue_box/naming.visible = false
	team_name = $dialogue_box/naming/enter_name.text
	$"dialogue_box/Panel/dialogue/6".bbcode_text = "Okei " + team_name + "! \nMenikö se kaikilla oikein? Hienoa, siirrytään eteenpäin."


func _on_next_dialogue_pressed():
	dialogue_index += 1
#	if dialogue_index == 1:
#		$dialogue_box/Panel/next_dialogue.visible = false
#		$dialogue_box/naming.visible = true


func _on_game_master_pressed():
	visible = false


func _on_player_role_pressed():
	visible = false
