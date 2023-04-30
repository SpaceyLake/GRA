extends StaticBody2D

const pirate_ship:PackedScene = preload("res://Scenes/pirate_ship.tscn")

var max_pirates:int = 2
var pirates:int = 0
var dead_pirates: Array = []
var pirate_spawn_time:float = 10
var pirate_spawn_timer: Timer = Timer.new()

func _ready():
	add_child(pirate_spawn_timer)
	pirate_spawn_timer.timeout.connect(spawn_pirate)
	$SafeArea.body_entered.connect(pirate_returning_to_base)
	$SafeArea.body_exited.connect(pirate_leaving_base)
	spawn_pirate()

func spawn_pirate():
	pirate_spawn_timer.stop()
	if not dead_pirates.is_empty():
		var pirate:Node2D = dead_pirates.pop_front()
		pirate.killed.connect(kill_pirate)
		var random_angle: float = randf_range(-PI, PI)
		var pirate_position:Vector2 = Vector2(cos(random_angle), sin(random_angle)) * ($CollisionShape2D.shape.radius + pirate.get_node("CollisionShape2D").shape.radius + 5)
		pirate.global_position = pirate_position + global_position
		activate_pirate(pirate, true)
	elif pirates < max_pirates:
		pirates +=1
		var pirate:Node2D = pirate_ship.instantiate()
		pirate.set_base_position(global_position)
		add_sibling.call_deferred(pirate)
		var random_angle: float = randf_range(-PI, PI)
		var pirate_position:Vector2 = Vector2(cos(random_angle), sin(random_angle)) * ($CollisionShape2D.shape.radius + pirate.get_node("CollisionShape2D").shape.radius + 5)
		pirate.global_position = pirate_position + global_position
	if not dead_pirates.is_empty() or pirates < max_pirates:
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
	pirate.get_node("CollisionShape2D").set_deferred("disabled", not active)
	if active == false:
		pirate.global_position = global_position

func pirate_returning_to_base(pirate:Node2D):
	if pirate.get_collision_layer_value(3):
		pirate.returned_to_base()

func pirate_leaving_base(pirate:Node2D):
	pirate.left_base()
