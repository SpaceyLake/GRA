extends CharacterBody2D

var howered:bool = false
var selected:bool = false
var destinations:Array = []
var cargo: int = 0
var base_position:Vector2

func _ready():
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	$Node/PathLine.add_point(global_position)

func _physics_process(delta):
	if not destinations.is_empty() and global_position.distance_to(destinations.front().global_position) < velocity.length()*delta:
		velocity = Vector2.ZERO
		path_marker_pool.return_path_marker(destinations.pop_front())
		$Node/PathLine.remove_point(1)
	if not destinations.is_empty():
#		$Sprite2D.look_at(destinations.front().global_position)
		velocity = global_position.direction_to(destinations.front().global_position)*20
		#Rotate
		var diff = global_position.angle_to_point(destinations.front().global_position) - global_rotation
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
			for marker in destinations:
				path_marker_pool.return_path_marker(marker)
			destinations.clear()
			$Node/PathLine.clear_points()
			$Node/PathLine.add_point(global_position)
		destinations.append(path_marker_pool.request_path_marker(get_global_mouse_position()))
		$Node/PathLine.add_point(get_global_mouse_position())

func set_base_position(new_position):
	base_position = new_position

func select_ship(select:bool):
	selected = select
	$Sprite2D.modulate = Color("#BDD156") if selected else Color("#3fc778")
	$Node/PathLine.visible = selected
	for marker in destinations:
		marker.visible = selected

func deliver(delivering_cargo:int):
	var delivered_cargo:int = min(cargo, delivering_cargo)
	cargo -= delivered_cargo
	return delivered_cargo

func add_waypoint(pos:Vector2):
	var marker = path_marker_pool.request_path_marker(pos)
	marker.visible = selected
	destinations.append(marker)
	$Node/PathLine.add_point(pos)

func set_goal_roation():
	if not destinations.is_empty():
		global_rotation = global_position.angle_to_point(destinations.front().global_position)

func is_howering():
	howered = true

func is_not_howering():
	howered = false

func restart_particles():
	$GPUParticles2D.restart()
