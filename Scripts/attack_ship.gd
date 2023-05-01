extends CharacterBody2D

signal stunned_signal(ship:Node2D, is_stunned:bool)

var howered:bool = false
var selected:bool = false
var destinations:Array = []
var base_position:Vector2 = Vector2(-1, -1)
var full_health:int = 6
var health:int = full_health
var stunned:bool = false
var heal_time:float = 2.5
var heal_timer:Timer = Timer.new()
var visible_targets:Array = []
var attack_time:float = 1
var attack_timer:Timer = Timer.new()
var attacked_timer:Timer = Timer.new()
var attacked_time = 1.5
var times_attacked = 0

@onready var guns = $Guns.get_children()
var next_gun = 0

var base_speed = 30
var speed = base_speed
var patrol:bool = false

var color_normal:Color = Color("#007DC7")
var color_selected:Color = Color("#92F4FF")
var color_stunned:Color = Color("#243F72")

func _ready():
	add_child(attack_timer)
	attack_timer.timeout.connect(attack)
	attack_timer.wait_time = attack_time
	attack_timer.one_shot = true
	add_child(attacked_timer)
	attacked_timer.timeout.connect(not_attacked)
	attacked_timer.wait_time = attacked_time
	attacked_timer.one_shot = true
	$AttackArea.body_entered.connect(_on_body_entered_attack_area)
	$AttackArea.body_exited.connect(_on_body_exited_attack_area)
	global.new_selected.connect(update_selected)
	add_child(heal_timer)
	heal_timer.one_shot = true
	heal_timer.wait_time = heal_time
	heal_timer.timeout.connect(heal)
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)
	$Node/PathLine.add_point(global_position)

func _physics_process(delta):
	if not destinations.is_empty() and global_position.distance_to(waypoint_next_pos()) < velocity.length()*delta:
		global_position = waypoint_next_pos()
		if patrol:
			add_waypoint(waypoint_next_pos())
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
		if Input.is_action_pressed("ctrl") and waypoint_count() > 0:
			patrol = true
		elif not Input.is_action_pressed("shift"):
			waypoint_clear()
			patrol = false
		else:
			patrol = false
		add_waypoint(get_global_mouse_position())

func get_radius():
	return $CollisionShape2D.shape.radius

func set_base_position(new_position):
	base_position = new_position

func select_ship(select:bool):
	if stunned:
		return
	selected = global.select(self, select)
	$Sprite2D.modulate = color_selected if selected else color_normal
	$Node/PathLine.visible = selected
	for marker in destinations:
		marker.visible = selected

func add_waypoint(pos:Vector2):
	if waypoint_count() == 0 and velocity == Vector2.ZERO:
		$AudioLaunch.play()
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

func is_stunned():
	return stunned

func waypoint_skip():
	path_marker_pool.return_path_marker(destinations.pop_front())
	$Node/PathLine.remove_point(1)

func attacked(attacker_position:Vector2):
	health -= 1
	if waypoint_count() == 0:
		var escape_direction = attacker_position.angle_to_point(global_position)
		times_attacked += 1
		add_waypoint(global_position + Vector2(cos(escape_direction), sin(escape_direction)) * 100 * times_attacked)
		attacked_timer.stop()
		attacked_timer.start(attacked_time)
	if health == full_health - 1:
		heal_timer.start(heal_time)
	if health == 0:
		set_stunned(true)
		return_home()
		stunned_signal.emit(self, stunned)

func heal():
	health += 1
	if health == full_health:
		heal_timer.stop()
	else:
		heal_timer.start(heal_time)

func awaken():
	set_stunned(false)
	stunned_signal.emit(self, stunned)

func set_stunned(stunning:bool):
	if stunning and selected:
		select_ship(false)
	stunned = stunning
	if stunned:
		$Sprite2D.modulate = color_stunned
	else:
		$Sprite2D.modulate = color_normal

func update_selected(old_selected:Node2D):
	if old_selected == self:
		select_ship(global.select(self, false))

func _on_body_entered_attack_area(body:Node2D):
	visible_targets.append(body)
	if visible_targets.size() == 1:
		attack_timer.start(attack_time)
	pass

func _on_body_exited_attack_area(body:Node2D):
	visible_targets.erase(body)
	if visible_targets.is_empty():
		attack_timer.stop()
	pass

func attack():
	if not visible_targets.is_empty():
		next_gun += 1
		if next_gun >= guns.size():
			next_gun -= guns.size()
		if not stunned:
			laser_pool.request_laser(guns[next_gun].global_position, visible_targets.front().global_position+Vector2.RIGHT.rotated(randf_range(-PI, PI))*randf_range(0,10), $Sprite2D.modulate)
			visible_targets.front().attacked(global_position)
		attack_timer.start(attack_time)
	else:
		attack_timer.stop()
	pass

func is_home():
	if stunned:
		velocity = Vector2.ZERO
		waypoint_clear()
		health = full_health
		heal_timer.stop()
		awaken()

func not_attacked():
	times_attacked = 0
	attacked_timer.stop()
