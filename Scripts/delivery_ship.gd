extends CharacterBody2D

var howered:bool = false
var selected:bool = false
var destinations:Array = []
var cargo: int = 0
var max_cargo: int = 5
var base_position:Vector2 = Vector2(-1, -1)

var base_speed = 40
var speed = base_speed

func _ready():
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	$Node/PathLine.add_point(global_position)

func _physics_process(delta):
	if not destinations.is_empty() and global_position.distance_to(waypoint_next_pos()) < velocity.length()*delta:
		global_position = waypoint_next_pos()
		velocity = Vector2.ZERO
		waypoint_skip()
	if not destinations.is_empty():
#		$Sprite2D.look_at(destinations.front().global_position)
		velocity = global_position.direction_to(waypoint_next_pos())*speed
		#Rotate
		var diff = global_position.angle_to_point(waypoint_next_pos()) - global_rotation
		diff = wrap(diff, -PI, PI)
		global_rotation += sign(diff) * min(5 * delta, abs(diff))

	move_and_slide()
	$Node/PathLine.set_point_position(0, global_position)
	$GPUParticles2D.emitting = velocity != Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if howered:
			select_ship(true)
		else:
			select_ship(false)
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if not Input.is_action_pressed("shift"):
			waypoint_clear()
		add_waypoint(get_global_mouse_position())



func update_speed():
	speed = base_speed - cargo*4

func set_base_position(new_position):
	base_position = new_position

func select_ship(select:bool):
	selected = select
	$Sprite2D.modulate = Color("#BDD156") if selected else Color("#3fc778")
	$CargoMeter.tint_progress = Color("#BDD156") if selected else Color("#3fc778")
	$Node/PathLine.visible = selected
	for marker in destinations:
		marker.visible = selected

func deliver(delivering_cargo:int):
	var delivered_cargo:int = min(cargo, delivering_cargo)
	set_cargo(cargo - delivered_cargo)
	if cargo <= 0 and waypoint_count() <= 1 and waypoint_next_pos().distance_squared_to(global_position) < 2500:
		return_home()
	return delivered_cargo

func set_cargo(new_cargo:int):
	cargo = min(new_cargo, max_cargo)
	$CargoMeter.value = cargo
	update_speed()

func add_waypoint(pos:Vector2):
	var marker = path_marker_pool.request_path_marker(pos)
	marker.visible = selected
	destinations.append(marker)
	$Node/PathLine.add_point(pos)

func waypoint_count():
	return destinations.size()

func waypoint_clear():
	for marker in destinations:
		path_marker_pool.return_path_marker(marker)
	destinations.clear()
	$Node/PathLine.clear_points()
	$Node/PathLine.add_point(global_position)

func waypoint_skip():
	path_marker_pool.return_path_marker(destinations.pop_front())
	$Node/PathLine.remove_point(1)
	if cargo <= 0 and destinations.is_empty():
		return_home()

func waypoint_next_pos():
	if destinations.is_empty():
		return null
	return destinations.front().global_position

func update_rotation():
	if not destinations.is_empty():
		global_rotation = global_position.angle_to_point(destinations.front().global_position)

func return_home():
	if base_position == Vector2(-1, -1):
		return
	waypoint_clear()
	add_waypoint(base_position)

func is_howering():
	howered = true

func is_not_howering():
	howered = false

func restart_particles():
	$GPUParticles2D.restart()
