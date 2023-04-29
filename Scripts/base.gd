extends Area2D

var howered:bool = false
var selected:bool = false
const cargo_ship:PackedScene = preload("res://Scenes/delivery_ship.tscn")
@export var nr_ships = 1
var docked_ships:Array = []
var launched_ship:Node2D
var selected_ship:Node2D
var cargo_amount = 5

func _ready():
	if cargo_ship.can_instantiate():
		for i in nr_ships:
			var new_ship:Node2D = cargo_ship.instantiate()
			add_sibling.call_deferred(new_ship)
			new_ship.global_position = global_position
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
			selected_ship = null
		$Sprite2D.modulate = Color("#BDD156") if selected else Color("#3fc778")
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if selected_ship == null and not docked_ships.is_empty():
				print(docked_ships)
				launched_ship = docked_ships.pop_front()
				print(docked_ships)
				launched_ship.cargo = cargo_amount
				launched_ship.add_waypoint(get_global_mouse_position())
				launched_ship.set_goal_roation()
				ship_active(launched_ship, true)
				if (Input.is_action_pressed("shift")):
					selected_ship = launched_ship
					selected_ship.select_ship(true)
	elif event is InputEventKey and event.is_action_released("shift"):
		if not selected_ship == null:
			selected_ship.select_ship(false)
			selected_ship = null

func is_howering():
	howered = true

func is_not_howering():
	howered = false

func ship_active(current_ship:Node2D, active:bool):
	current_ship.visible = active
	current_ship.set_process(active)
	current_ship.set_physics_process(active)
	current_ship.set_process_input(active)
	current_ship.set_process_internal(active)
	current_ship.set_process_unhandled_input(active)
	current_ship.set_process_unhandled_key_input(active)
	current_ship.restart_particles()
	if active == false:
		current_ship.global_position = global_position

func _on_body_entered(body: Node2D):
	if body != launched_ship:
		body.select_ship(false)
		ship_active(body, false)
		docked_ships.append(body)
