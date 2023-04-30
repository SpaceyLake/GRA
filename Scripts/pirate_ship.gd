extends CharacterBody2D

var destination:Vector2
var min_length:float = 50
var base_speed = 20
var speed = base_speed
var direction:float = 0
var max_turn: float = (3*PI/4)
var scared:bool = false
var target:Node2D
var calming:bool = false
var visible_targets:Array = []

func _ready():
	direction = randf_range(-PI, PI)
	destination = global_position + random_vector(direction)
	$VisionArea.area_entered.connect(_on_area_entered_vision)
	$VisionArea.area_exited.connect(_on_area_exited_vision)
	$VisionArea.body_entered.connect(_on_body_entered_vision)
	$VisionArea.body_exited.connect(_on_body_exited_vision)
	$PlunderArea.body_entered.connect(_on_body_entered_plunder)
	pass

func _physics_process(delta):
	if not scared and not target == null:
		destination = target.global_position
		direction = destination.angle()
	if global_position.distance_squared_to(destination) < velocity.length()*velocity.length()*delta*delta:
		destination = global_position + random_vector(direction)
		if calming:
			calming = false
			scared = false
			choose_target()
	else:
		velocity = global_position.direction_to(destination)*speed
		var diff = global_position.angle_to_point(destination) - global_rotation
		diff = wrap(diff, -PI, PI)
		global_rotation += sign(diff) * min(5 * delta, abs(diff))
	move_and_slide()

func _on_area_entered_vision(area:Node2D):
	if area.get_collision_layer_value(4):
		target = null
		scared = true
		destination = random_vector(direction)
		if destination.dot(global_position.direction_to(area.global_position)) > 0:
			destination = destination.rotated(PI)
			direction = destination.angle()
		destination += global_position
	
func _on_area_exited_vision(area:Node2D):
	if area.get_collision_layer_value(4):
		calming = true

func random_vector(current_direction:float):
	direction = current_direction+randf_range(-1, 1)*max_turn
	return Vector2.RIGHT.rotated(direction)*(randf_range($CollisionShape2D.shape.radius + min_length, $VisionArea/CollisionShape2D.shape.radius) + (100 if scared else 0))

func _on_body_entered_vision(body:Node2D):
	if body.get_collision_layer_value(3):
		pass
	elif body.get_collision_layer_value(2):
		body.update_cargo.connect(_updated_cargo)
		if body.get_cargo_amount() > 0:
			visible_targets.append(body)
			choose_target()

func _on_body_exited_vision(body:Node2D):
	if body.get_collision_layer_value(2):
		print("Target exited")
		body.update_cargo.disconnect(_updated_cargo)
		visible_targets.erase(body)
		choose_target()
		print(visible_targets)
		print(target)

func choose_target():
	if not visible_targets.is_empty():
		target = visible_targets.front()
		for visible_target in visible_targets:
			if visible_target.get_cargo_amount() > target.get_cargo_amount():
				target = visible_target
			elif visible_target.get_cargo_amount() == target.get_cargo_amount():
				if global_position.distance_squared_to(target.global_position) > global_position.distance_squared_to(visible_target.global_position):
					target = visible_target
	else:
		target = null

func _updated_cargo(body:Node2D):
	if body.get_cargo_amount() == 0:
		visible_targets.erase(body)
	choose_target()

func _on_body_entered_plunder(body):
	if not body.get_cargo_amount() == 0:
		body.set_cargo(0)
		body.return_home()
