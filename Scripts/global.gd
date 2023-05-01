extends Node2D

var score = 0
var difficulty = 0

signal new_selected(old_selected:Node2D)

var selected:Node2D
var menu_hanler:Node = null
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func select(object:Node2D, selecting:bool):
	if selecting:
		if selected == null:
			selected = object
			return true
		elif selected == object:
			return true
		else:
			if get_global_mouse_position().distance_squared_to(selected.global_position) > get_global_mouse_position().distance_squared_to(object.global_position):
				new_selected.emit(selected)
				selected = object
				return true
			else:
				return false
	else:
		if not selected == null:
			if selected == object:
				selected = null
		return false

func game_lost():
	if menu_hanler == null:
		return
	menu_hanler.game_lost()
