extends CharacterBody2D

signal killed(pirate:Node2D)

var destination:Vector2
var min_length:float = 50
var base_speed = 35
var speed = base_speed
var direction:float = 0
var max_turn: float = (3*PI/4)
var scared:bool = false
var target:Node2D
var visible_targets:Array = []
var attack_time:float = 1
var attack_timer:Timer = Timer.new()
var visible_pirates:Array = []
var attackable_targets = []
var attack_target = null
@onready var size: Vector2 = get_viewport().get_size()
@onready var camera:Camera2D = get_parent().get_node("Camera")
@onready var guns = $Guns.get_children()
var next_gun = 0
var base_position:Vector2
var max_charge:float = 50
var min_charge:float = 10
var full_charge:float
var charge:float
var returning_home = false
var in_base:bool = true
var full_health:int = 5
var health:int = full_health
var heal_time:float = 3
var heal_timer:Timer = Timer.new()
var visible_attack_ships:Array = []
var avoid_factor: float = 50
var in_enemy_base:bool = false

func _ready():
	recharge()
	add_child(heal_timer)
	heal_timer.one_shot = true
	heal_timer.wait_time = heal_time
	heal_timer.timeout.connect(heal)
	add_child(attack_timer)
	attack_timer.timeout.connect(attack)
	attack_timer.wait_time = attack_time
	attack_timer.one_shot = true
	direction = randf_range(-PI, PI)
	destination = global_position + random_vector(direction)
	$VisionArea.area_entered.connect(_on_area_entered_vision)
	$VisionArea.area_exited.connect(_on_area_exited_vision)
	$VisionArea.body_entered.connect(_on_body_entered_vision)
	$VisionArea.body_exited.connect(_on_body_exited_vision)
	$PlunderArea.body_entered.connect(_on_body_entered_plunder)
	$AttackArea.body_entered.connect(_on_body_entered_attack)
	$AttackArea.body_exited.connect(_on_body_exited_attack)
	pass

func _physics_process(delta):
	if not in_base:
		charge = move_toward(charge, 0, delta)
	if not scared and not target == null and not returning_home:
		destination = target.global_position
		direction = global_position.angle_to_point(destination)
	if global_position.distance_squared_to(destination) < velocity.length()*velocity.length()*delta*delta:
		destination = global_position + random_vector(direction)
		if abs(position.x) > size.x/(camera.get_min_zoom()*2) - $CollisionShape2D.shape.radius/2 or abs(position.y) > size.y/(camera.get_min_zoom()*2) - $CollisionShape2D.shape.radius/2:
			destination = global_position + destination_vector_from_direction(global_position.angle_to(Vector2.ZERO))
		direction = global_position.angle_to(destination)
		if not in_enemy_base:
			scared = false
			choose_target()
			check_for_attackable()
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
		in_enemy_base = true
		#destination = random_vector(direction)
		var tangent_angle = global_position.angle_to_point(area.global_position) + PI/2
		if destination.normalized().dot(Vector2(cos(tangent_angle), sin(tangent_angle))) > destination.normalized().dot(Vector2(cos(-tangent_angle), sin(-tangent_angle))):
			direction = tangent_angle
		else:
			direction = -tangent_angle
		destination = destination_vector_from_direction(direction) + global_position
		destination += global_position
	
func _on_area_exited_vision(area:Node2D):
	if area.get_collision_layer_value(4):
		in_enemy_base = false

func set_base_position(new_position:Vector2):
	base_position = new_position

func get_destination():
	return destination

func get_direction():
	return direction

func destination_vector_from_direction(angle:float):
	return Vector2.RIGHT.rotated(angle)*max(randf_range(min_length, $VisionArea/CollisionShape2D.shape.radius), (100 if scared else 0))

func random_vector(current_direction:float):
	direction = current_direction+randf_range(-1, 1)*max_turn
	var diff = global_position.angle_to_point(base_position) - direction
	diff = wrap(diff, -PI, PI)
	direction += diff * (1 - charge/full_charge)
	var new_destination = Vector2.RIGHT.rotated(direction)
	var separation_froce:Vector2 = Vector2.ZERO
	for attack_ship in visible_attack_ships:
		if not attack_ship.is_stunned():
			separation_froce += attack_ship.global_position.direction_to(global_position)
	new_destination += separation_froce * avoid_factor
	new_destination = new_destination.normalized()*max(randf_range(min_length, $VisionArea/CollisionShape2D.shape.radius), (100 if scared else 0))
	direction = new_destination.angle()
	return new_destination

func _on_body_entered_vision(body:Node2D):
	if body.get_collision_layer_value(3):
		if body == self:
			pass
		else: 
			visible_pirates.append(body)
	elif body.get_collision_layer_value(2):
		body.update_cargo_signal.connect(_updated_cargo)
		if body.get_cargo_amount() > 0:
			visible_targets.append(body)
			choose_target()
	elif body.get_collision_layer_value(7):
		visible_attack_ships.append(body)
		destination = random_vector(direction) + global_position

func _on_body_exited_vision(body:Node2D):
	if body.get_collision_layer_value(3):
		if body == self:
			pass
		else: 
			visible_pirates.erase(body)
	elif body.get_collision_layer_value(2):
		body.update_cargo_signal.disconnect(_updated_cargo)
		visible_targets.erase(body)
		choose_target()
	elif body.get_collision_layer_value(7):
		visible_attack_ships.erase(body)

func _on_body_entered_attack(body:Node2D):
	if body.get_collision_layer_value(2):
		body.stunned_signal.connect(update_attack_status)
		attackable_targets.append(body)
		if body == target:
			if not target.is_stunned():
				attack_timer.start(attack_time)

func _on_body_exited_attack(body:Node2D):
	body.stunned_signal.disconnect(update_attack_status)
	attackable_targets.erase(body)
	if body == target:
		choose_target()
		if not target == null and not attackable_targets.find(target) == -1:
			if not target.is_stunned():
				if attack_timer.is_stopped():
					attack_timer.start(attack_time)
		else:
			attack_timer.stop()

func check_for_attackable():
	if not target == null and not attackable_targets.find(target) == -1:
		if not target.is_stunned():
			if attack_timer.is_stopped():
				attack_timer.start(attack_time)

func attack():
	if not target == null and not scared and not returning_home:
		laser_pool.request_laser(guns[next_gun].global_position, target.global_position+Vector2.RIGHT.rotated(randf_range(-PI, PI))*randf_range(0,10), $Sprite2D.modulate)
		next_gun += 1
		if next_gun >= guns.size():
			next_gun -= guns.size()
		target.attacked()
		if target.is_stunned():
			attack_timer.stop()
		else:
			attack_timer.start(attack_time)
	else:
		attack_timer.stop()
	pass

func choose_target():
	if not visible_targets.is_empty():
		target = visible_targets.front()
		for visible_target in visible_targets:
			if (visible_target.get_cargo_amount() * 40)*(visible_target.get_cargo_amount() * 40)/global_position.distance_squared_to(visible_target.global_position) > (target.get_cargo_amount()*40*target.get_cargo_amount()*40)/global_position.distance_squared_to(target.global_position):
				target = visible_target
	else:
		target = null
		destination = random_vector(direction) + global_position

func _updated_cargo(body:Node2D):
	if body.get_cargo_amount() == 0:
		visible_targets.erase(body)
	elif not visible_targets.find(body) == -1:
		visible_targets.append(body)
		
	choose_target()
	if not target == null and not attackable_targets.find(target) == -1:
		if not target.is_stunned():
			if attack_timer.is_stopped():
				attack_timer.start(attack_time)
				return
	else:
		attack_timer.stop()

func return_home():
	returning_home = true
	charge = 0

func _on_body_entered_plunder(body):
	if not body.get_cargo_amount() == 0 and not scared and not returning_home:
		body.set_cargo(0)
		body.return_home()
		return_home()
		destination = random_vector(direction) + global_position

func update_attack_status(ship:Node2D, stunned:bool):
	if ship == target:
		if stunned:
			attack_timer.stop()
		else:
			attack_timer.start(attack_time)

func recharge():
	full_charge = randf_range(min_charge, max_charge)
	charge = full_charge
	returning_home = false

func returned_to_base():
	in_base = true
	recharge()

func left_base():
	in_base = false

func fill_health():
	health = full_health

func attacked(attacker_position:Vector2):
	health -= 1
	scared = true
	var escape_direction = attacker_position.angle_to_point(global_position)
	destination = global_position + destination_vector_from_direction(escape_direction)
	if health == full_health - 1:
		heal_timer.start(heal_time)
	if health == 0:
		killed.emit(self)
		heal_timer.stop()

func restart_particles():
	$GPUParticles2D.restart()

func heal():
	health += 1
	if health == full_health:
		heal_timer.stop()
	else:
		heal_timer.start(heal_time)
