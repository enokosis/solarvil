extends Sprite

var solar_panel_image = preload("res://art/solar_panel.png")
var energy_reserve_image = preload("res://art/energy_reserve.png")
var remover_image = preload("res://art/remover.png")


func _ready():
	switch_to_solar_panel()


func _process(_delta):
	position = get_global_mouse_position()


func switch_to_solar_panel():
	set_texture(solar_panel_image)


func switch_to_energy_reserve():
	set_texture(energy_reserve_image)


func switch_to_remover():
	set_texture(remover_image)
