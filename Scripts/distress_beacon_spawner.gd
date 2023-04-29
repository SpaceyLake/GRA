extends Node

const MIN_LENGTH_FROM_BASE_SQUARED = 200*200
const MIN_LENGTH_FROM_DISTRESS_BEACON_SQUARED = 100*100

var time_decreasment:int = 1
var time:int = 15
var timer:Timer = Timer.new()
@export var min_need:int = 1
@export var max_need:int = 3
@onready var size: Vector2 = get_viewport().get_size()
@onready var camera:Camera2D = get_parent().get_node("Camera")
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
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
	var accepted_proposition:bool = false
	var proposed_position: Vector2
	while not accepted_proposition:
		proposed_position = Vector2(rnd.randf_range(-size.x * camera.zoom.x/2, size.x * camera.zoom.x/2), rnd.randf_range(-size.y * camera.zoom.y/2, size.y * camera.zoom.y/2))
		accepted_proposition = true
		if proposed_position.distance_squared_to(base_position) < MIN_LENGTH_FROM_BASE_SQUARED:
			accepted_proposition = false
			continue
		for distress_beacon in distress_beacon_pool.distress_beacons_placed:
			if distress_beacon.global_position.distance_squared_to(proposed_position) < MIN_LENGTH_FROM_DISTRESS_BEACON_SQUARED:
				accepted_proposition = false
				break
	var distress_beacon:Node2D = distress_beacon_pool.request_distress_beacon(proposed_position)
	distress_beacon.set_needs(rnd.randi_range(min_need, max_need))
	timer.start(time)
