extends Node

# Store stuff here that needs to be accessed in multiple scenes
# Ie. player score, player name, player level

var player_name = "" # added to saved
var player_full_info = "" # added to saved
var player_student_number = 0 # added to saved
var team_name = 1 # Index of Työryhmä, 1-100 # added to saved
var player_role = "" # added to saved ["LVI-suunnittelija", "Yleishenkilö Jantunen", "Energiakonsultti"]
var team_size = 1 # added to saved

var current_score = 0 # added to saved
var current_level = 1

# Level 2
var game_keys = [
	326589, 639190, 215227, 863500, 756929, 586942, 652278, 375733, 788578, 684612, 827059, 719551, 244291, 219394, 982597, 442878, 210176, 691271, 911206, 567338, 111942, 870254, 527794, 540751, 406151, 664985, 699371, 542080, 362509, 255333, 890189, 780632, 593008, 578146, 399179, 734141, 298328, 716194, 439878, 221506, 272780, 677028, 389845, 458903, 581668, 724765, 963787, 170119, 579471, 468369, 788758, 631409, 451689, 415429, 488957, 727944, 920154, 546997, 225716, 300473, 319393, 829699, 195554, 954960, 993321, 235442, 552497, 909494, 609478, 968103, 982384, 190594, 744908, 978701, 837717, 703071, 170753, 815767, 947643, 369435, 845933, 443578, 997283, 856660, 321427, 315112, 297571, 977191, 240872, 196540, 420233, 308817, 828367, 942817, 417090, 109307, 689853, 299819, 270049, 208851
]
var stage_two_score = 1 # added to saved

# Level 3
var has_started_level_3 = false # added to saved
var current_solar_collector_area = 0 # added to saved
var current_energy_reserve_cabability = 0 # added to saved
var current_funds = 20000000 # added to saved
var stage_three_score = 1 # added to saved

#func set_score(new_score):
	#score = new_score

# When player saves and quits during a build process in level three
# the current time gets saved in the OS.get_unix_time() format
var saved_time = 0 # added to saved
var difference_between_times = 0 # seconds between saving and loading

var rng = RandomNumberGenerator.new()  # Create a new RNG object
var session_id = ""

# Backup vars, adding stuff later might break saving and loading, so these currently unused variables can be used if stuff is added later
var backup_var_0 = ""
var backup_var_1 = ""
var backup_var_2 = ""
var backup_var_3 = ""
var backup_var_5 = ""


func get_team_size():
	return team_size
	
func get_player_role():
	return player_role
	
func set_team_size(size):
	team_size = size
	
func set_player_role(role):
	player_role = role
	
func set_session_id(id):
	session_id = id
	rng.seed = session_id.hash() 


func generate_sensor_data():
	# Use rng to generate synchronized random numbers
	var sensor_data = rng.randf_range(-10.0, 10.0)
	return sensor_data


func _ready():
	load_saved_progression()


func _input(event):
	if event.is_action_pressed("remove_savegames"):
		pass
#		var dir = Directory.new()
#		dir.remove("user://savegame.save")
#		dir.remove("user://saveditems.save")
#		print("Saved games removed.")


func increment_score(amount):
	current_score += amount
	
	
# These functions save needed information onto disk or into browser's cache.
func save_progression():
	# Saving the user instantiated infra items
	var saved_items = File.new()
	saved_items.open("user://saveditems.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		
		# Store the save dictionary as a new line in the save file.
		saved_items.store_line(to_json(node_data))
	saved_items.close()
	
	# This is how you would save an array
	# player_inventory = []
	# for item in inventory.player_inventory:
	# 	player_inventory.append(inventory.player_inventory)
	# print(player_inventory)
	
	var save_dict = {
		# General
		"current_level": current_level,
		# Stage 1
		"player_name": player_name,
		"player_full_info": player_full_info,
		"player_student_number": player_student_number,
		"player_role": player_role,
		# Stage 2
		"team_name": team_name,
		"team_size": team_size,
		"stage_two_score": stage_two_score,
		# Stage 3
		"has_started_level_3": has_started_level_3,
		"saved_time" : saved_time,
		"current_solar_collector_area": current_solar_collector_area,
		"current_energy_reserve_cabability": current_energy_reserve_cabability,
		"current_funds": current_funds,
		"stage_three_score": stage_three_score,
		# level three used rounds
		"backup_var_1": backup_var_1,
		# score submitted to leaderboard
		"backup_var_0": backup_var_0,
		# Backup vars
		"backup_var_2": backup_var_2,
		"backup_var_3": backup_var_3,
		"backup_var_5": backup_var_5
	}
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save_dict))
	print("Game saved!")
	save_game.close()


func load_saved_progression():
	# Loading other game data
	var save_game = File.new()
	print(save_game.file_exists("user://savegame.save"))
	if not save_game.file_exists("user://savegame.save"):
		print("No save game present!")
		return # Error! We don't have a save to load.
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
#		saved_time = node_data["saved_time"]
#		current_level = node_data["current_level"]
#		has_started_level_3 = node_data["has_started_level_3"]
#		score = node_data["score"]
#		current_solar_collector_area = node_data["current_solar_collector_area"]
#		current_energy_reserve_cabability = node_data["current_energy_reserve_cabability"]
#		current_funds = node_data["current_funds"]
#		player_name = node_data["player_name"]
#		team_name = node_data["team_name"]
#		player_role = node_data["player_role"]
#		team_size = node_data["team_size"]
		for i in node_data.keys():
			self.set(i, node_data[i])
		
	#print("saved time is ", saved_time)
	difference_between_times = OS.get_unix_time() - saved_time
	#print("difference between saved and current time is ", difference_between_times)
	
	if current_level == 1:
		get_tree().change_scene("res://scenes/level_one/level_one.tscn")
	elif current_level == 2:
		get_tree().change_scene("res://scenes/lobby.tscn")
	elif current_level == 3:
		if !has_started_level_3:
			get_tree().change_scene("res://scenes/lobby.tscn")
		else:
			get_tree().change_scene("res://scenes/level_three/level_three.tscn")
	elif current_level == 4:
		get_tree().change_scene("res://scenes/lobby.tscn")
	
	save_game.close()


func load_saved_items():
	var saved_items = File.new()
	if not saved_items.file_exists("user://saveditems.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	saved_items.open("user://saveditems.save", File.READ)
	while saved_items.get_position() < saved_items.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(saved_items.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
		
		new_object.init()
	
	saved_items.close()
