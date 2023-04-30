extends Node

const MIN_LENGTH_FROM_BASE_SQUARED = 200*200
const MIN_LENGTH_FROM_DISTRESS_BEACON_SQUARED = 100*100
const MIN_LENGTH_FROM_SHIP_SQUARED = 100*100

@export var time_decreasment:float = 0.99
var time:float = 15
var timer:Timer = Timer.new()
@export var min_need:int = 1
@export var max_need:int = 3
@onready var size: Vector2 = get_viewport().get_size()
@onready var camera:Camera2D = get_parent().get_node("Camera")
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
var path_marker_pool:Array = []

@onready var base:Node2D = get_parent().get_node("Base")

func _ready():
	add_child(timer)
	timer.timeout.connect(_timeout)
	rnd.randomize()
	timer.start(time)

func _timeout():
	timer.stop()
	time *= time_decreasment
	var accepted_proposition:bool = false
	var proposed_position: Vector2
	while not accepted_proposition:
		proposed_position = Vector2(rnd.randf_range(-size.x/(camera.zoom.x*2), size.x/(camera.zoom.x*2)), rnd.randf_range(-size.y/(camera.zoom.y*2), size.y/(camera.zoom.y*2)))
		accepted_proposition = true
		if proposed_position.distance_squared_to(base.get_position()) < MIN_LENGTH_FROM_BASE_SQUARED:
			accepted_proposition = false
			continue
		for distress_beacon in distress_beacon_pool.distress_beacons_placed:
			if distress_beacon.global_position.distance_squared_to(proposed_position) < MIN_LENGTH_FROM_DISTRESS_BEACON_SQUARED:
				accepted_proposition = false
				break
		if accepted_proposition == false:
			continue
		for ship in base.get_deployed_ships():
			if ship.global_position.distance_squared_to(proposed_position) < MIN_LENGTH_FROM_SHIP_SQUARED:
				accepted_proposition = false
				break
	var distress_beacon:Node2D = distress_beacon_pool.request_distress_beacon(proposed_position)
	distress_beacon.set_needs(rnd.randi_range(min_need, max_need))
	timer.start(time)
