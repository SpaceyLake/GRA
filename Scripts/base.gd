extends Area2D

var howered:bool = false
var selected:bool = false
const cargo_ship:PackedScene = preload("res://Scenes/delivery_ship.tscn")
@export var nr_ships = 5
var docked_ships:Array = []
var launched_ship:Node2D
@onready var world:Node2D = get_parent()
var cargo_amount = 5

func _ready():
	if cargo_ship.can_instantiate():
		for i in nr_ships:
			docked_ships.append(cargo_ship.instantiate())
			world.add_child.call_deferred(docked_ships.back())
			docked_ships.back().global_position = global_position
			ship_active(docked_ships.back(), false)
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	body_entered.connect(_on_body_entered)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if howered:
			selected = true
		else:
			selected = false
			launched_ship = null
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if (not Input.is_action_pressed("shift") or launched_ship == null) and not docked_ships.is_empty():
				launched_ship = docked_ships.pop_front()
				launched_ship.cargo = cargo_amount
				ship_active(launched_ship, true)
				#launched_ship.add_waypoint(get_global_mouse_position())
	elif event is InputEventKey and event.is_action_pressed("shift"):
		if not launched_ship == null:
			launched_ship.selected = true
	elif event is InputEventKey and event.is_action_released("shift"):
		if not launched_ship == null:
			launched_ship.selected = false
		

func is_howering():
	howered = true
	print("Howering")

func is_not_howering():
	howered = false
	print("Not howering")

func ship_active(current_ship:Node2D, active:bool):
	current_ship.visible = active
	current_ship.set_process(active)
	current_ship.set_physics_process(active)
	current_ship.set_process_input(active)
	current_ship.set_process_internal(active)
	current_ship.set_process_unhandled_input(active)
	current_ship.set_process_unhandled_key_input(active)
	if active == false:
		current_ship.global_position = global_position

func _on_body_entered(body: Node2D):
	if body != launched_ship:
		pass
		#ship_active(body, false)
