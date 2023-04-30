extends StaticBody2D

const pirate_ship:PackedScene = preload("res://Scenes/pirate_ship.tscn")

var max_pirates:int = 2
var pirates:int = 0
var dead_pirates: Array = []
var pirate_spawn_time:float = 10
var pirate_spawn_timer: Timer = Timer.new()
var visible_targets:Array = []
var attack_time:float = 0.75
var attack_timer:Timer = Timer.new()

func _ready():
	add_child(attack_timer)
	attack_timer.timeout.connect(attack)
	attack_timer.wait_time = attack_time
	attack_timer.one_shot = true
	add_child(pirate_spawn_timer)
	pirate_spawn_timer.timeout.connect(spawn_pirate)
	$SafeArea.body_entered.connect(pirate_returning_to_base)
	$SafeArea.body_exited.connect(pirate_leaving_base)
	$AttackArea.body_entered.connect(_body_entered_attack_area)
	$AttackArea.body_exited.connect(_body_exited_attack_area)
	spawn_pirate()

func spawn_pirate():
	max_pirates = 2 + global.difficulty/120
	pirate_spawn_timer.stop()
	if not dead_pirates.is_empty():
		var pirate:Node2D = dead_pirates.pop_front()
		var random_angle: float = randf_range(-PI, PI)
		var pirate_position:Vector2 = Vector2(cos(random_angle), sin(random_angle)) * ($CollisionShape2D.shape.radius + pirate.get_node("CollisionShape2D").shape.radius + 5)
		pirate.global_position = pirate_position + global_position
		activate_pirate(pirate, true)
	elif pirates < max_pirates:
		pirates +=1
		var pirate:Node2D = pirate_ship.instantiate()
		pirate.killed.connect(kill_pirate)
		pirate.set_base_position(global_position)
		add_sibling.call_deferred(pirate)
		var random_angle: float = randf_range(-PI, PI)
		var pirate_position:Vector2 = Vector2(cos(random_angle), sin(random_angle)) * ($CollisionShape2D.shape.radius + pirate.get_node("CollisionShape2D").shape.radius + 5)
		pirate.global_position = pirate_position + global_position
	pirate_spawn_timer.start(pirate_spawn_time)

func add_pirate():
	max_pirates += 1
	if pirate_spawn_timer.is_stopped():
		pirate_spawn_timer.start(pirate_spawn_time)

func kill_pirate(pirate:Node2D):
	activate_pirate(pirate, false)
	dead_pirates.append(pirate)
	if pirate_spawn_timer.is_stopped():
		pirate_spawn_timer.start(pirate_spawn_time)

func activate_pirate(pirate:Node2D, active:bool):
	pirate.velocity = Vector2.ZERO
	pirate.visible = active
	pirate.set_process(active)
	pirate.set_physics_process(active)
	pirate.set_process_input(active)
	pirate.set_process_internal(active)
	pirate.set_process_unhandled_input(active)
	pirate.set_process_unhandled_key_input(active)
	pirate.restart_particles()
	pirate.recharge()
	pirate.fill_health()
	pirate.get_node("CollisionShape2D").set_deferred("disabled", not active)
	if active == false:
		pirate.global_position = global_position

func pirate_returning_to_base(pirate:Node2D):
	if pirate.get_collision_layer_value(3):
		pirate.returned_to_base()

func pirate_leaving_base(pirate:Node2D):
	pirate.left_base()

func attack():
	var targets_to_erase:Array = []
	for target in visible_targets:
		laser_pool.request_laser(global_position, target.global_position+Vector2.RIGHT.rotated(randf_range(-PI, PI))*randf_range(0,10), $Sprite2D.modulate)
		target.attacked()
		if target.is_stunned():
			targets_to_erase.append(target)
	for target in targets_to_erase:
		visible_targets.erase(target)
	if not visible_targets.is_empty():
		attack_timer.start(attack_time)
	else:
		attack_timer.stop()

func _body_entered_attack_area(body:Node2D):
	visible_targets.append(body)
	if visible_targets.size() == 1:
		attack_timer.start(attack_time)

func _body_exited_attack_area(body:Node2D):
	visible_targets.erase(body)
	if visible_targets.is_empty():
		attack_timer.stop()
