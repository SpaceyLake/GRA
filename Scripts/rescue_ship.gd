extends CharacterBody2D

var howered:bool = false
var selected:bool = false
var destinations:Array = []
var base_position:Vector2 = Vector2(-1, -1)
var can_rescue:bool = true
var speed = 60

var color_normal:Color = Color("#3fc778")
var color_selected:Color = Color("#BDD156")

func _ready():
	global.new_selected.connect(update_selected)
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	$Node/PathLine.add_point(global_position)

func _physics_process(delta):
	if not destinations.is_empty() and global_position.distance_to(waypoint_next_pos()) < velocity.length()*delta:
		global_position = waypoint_next_pos()
		velocity = Vector2.ZERO
		waypoint_skip()
	if not destinations.is_empty():
		velocity = global_position.direction_to(waypoint_next_pos())*speed
		var diff = global_position.angle_to_point(waypoint_next_pos()) - global_rotation
		diff = wrap(diff, -PI, PI)
		global_rotation += sign(diff) * min(5 * delta, abs(diff))

	move_and_slide()
	$Node/PathLine.set_point_position(0, global_position)
	$GPUParticles2D.emitting = velocity != Vector2.ZERO
	$GPUParticles2D2.emitting = velocity != Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		select_ship(howered)
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if not Input.is_action_pressed("shift"):
			waypoint_clear()
		add_waypoint(get_global_mouse_position())

func get_radius():
	return $CollisionShape2D.shape.radius

func set_base_position(new_position):
	base_position = new_position

func select_ship(select:bool):
	selected = global.select(self, select)
	$Sprite2D.modulate = color_selected if selected else color_normal
	$SpritePlus.modulate = color_selected if selected else color_normal
	$Node/PathLine.visible = selected
	for marker in destinations:
		marker.visible = selected

func add_waypoint(pos:Vector2):
	if waypoint_count() == 0 and velocity == Vector2.ZERO:
		#$AudioLaunch.play()
		pass
	var marker = path_marker_pool.request_path_marker(pos, color_selected)
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
	if not can_rescue and destinations.is_empty():
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

func update_selected(old_selected:Node2D):
	if old_selected == self:
		select_ship(global.select(self, false))

func fill_rescue():
	if not can_rescue:
		can_rescue = true
		$SpritePlus.visible = true
		velocity = Vector2.ZERO
		waypoint_skip()

func rescue():
	if can_rescue:
		can_rescue = false
		$SpritePlus.visible = false
		return true
	return false
