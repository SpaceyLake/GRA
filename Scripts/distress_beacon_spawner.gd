extends Node

const MIN_LENGTH_FROM_BASE = 200

var time_decreasment:int = 1
var time:int = 15
var timer:Timer = Timer.new()
@onready var size: Vector2 = get_viewport().get_size()
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()

var distress_beacon = preload("res://Scenes/path_marker.tscn")
var path_marker_pool:Array = []

@onready var base_position:Vector2 = get_parent().get_node("Base").get_position()

func _ready():
	print(size)
	print(get_parent().get_children())
	add_child(timer)
	timer.timeout.connect(_timeout)
	rnd.randomize()
	timer.start(time)
	print("Timer started")

func _timeout():
	timer.stop()
	time -= 1
	print("Beacon spawned")
	var proposed_position: Vector2 = Vector2(rnd.randf_range(0, size.x), rnd.randf_range(0, size.y))
	while proposed_position.distance_to(base_position) < MIN_LENGTH_FROM_BASE:
		proposed_position = Vector2(rnd.randf_range(0, size.x), rnd.randf_range(0, size.y))
	distress_beacon_pool.request_distress_beacon(proposed_position)
	timer.start(time)
