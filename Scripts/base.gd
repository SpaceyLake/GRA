extends Area2D

var howered:bool = false
var selected:bool = false
const cargo_ship:PackedScene = preload("res://Scenes/delivery_ship.tscn")
@export var nr_ships = 3
@export var scroll_sensitivity = 5
var scroll_state = 0
var docked_ships:Array = []
var deployed_ships:Array = []
var launched_ship:Node2D
var selected_ship:Node2D
var cargo_amount = 5
var max_cargo = 20
var min_cargo = 1
var ship_radius:float

func _ready():
	if cargo_ship.can_instantiate():
		for i in nr_ships:
			var new_ship:Node2D = cargo_ship.instantiate()
			add_sibling.call_deferred(new_ship)
			new_ship.global_position = global_position
			new_ship.set_base_position(global_position)
			ship_radius = new_ship.get_radius()
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	body_entered.connect(_on_body_entered)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
		scroll_state += 1
		if scroll_state == scroll_sensitivity:
			scroll_state = 0
			cargo_amount = min(max_cargo, cargo_amount + 1)
			print(cargo_amount)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
		scroll_state -= 1
		if scroll_state == -scroll_sensitivity:
			scroll_state = 0
			cargo_amount = max(min_cargo, cargo_amount - 1)
			print(cargo_amount)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if howered:
			selected = true
		else:
			selected = false
			launched_ship = null
			selected_ship = null
		$Sprite2D.modulate = Color("#BDD156") if selected else Color("#3fc778")
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if global_position.distance_squared_to(get_global_mouse_position()) > ($CollisionShape2D.shape.radius + ship_radius + 2)*($CollisionShape2D.shape.radius + ship_radius + 2):
			if selected_ship == null and not docked_ships.is_empty():
					launched_ship = docked_ships.pop_front()
					deployed_ships.append(launched_ship)
					launched_ship.set_cargo(cargo_amount)
					launched_ship.global_position = global_position + global_position.direction_to(get_global_mouse_position()) * ($CollisionShape2D.shape.radius + ship_radius + 1)
					launched_ship.add_waypoint(get_global_mouse_position())
					launched_ship.update_rotation()
					ship_active(launched_ship, true)
					if (Input.is_action_pressed("shift")):
						selected_ship = launched_ship
						selected_ship.select_ship(true)
	elif event is InputEventKey and event.is_action_released("shift"):
		if not selected_ship == null:
			selected_ship.select_ship(false)
			selected_ship = null

func get_deployed_ships():
	return deployed_ships

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
		current_ship.waypoint_clear()

func _on_body_entered(body: Node2D):
	if body.waypoint_count() == 0:
		deployed_ships.erase(body)
		body.select_ship(false)
		ship_active(body, false)
		docked_ships.append(body)
		return
	if body.waypoint_next_pos().distance_squared_to(global_position) < (($CollisionShape2D.shape.radius+ship_radius)*($CollisionShape2D.shape.radius+ship_radius)):
		if body.waypoint_count() == 1:
			deployed_ships.erase(body)
			body.select_ship(false)
			ship_active(body, false)
			docked_ships.append(body)
		else:
			body.set_cargo(cargo_amount)
			body.waypoint_skip()
	else:
		body.set_cargo(cargo_amount)
