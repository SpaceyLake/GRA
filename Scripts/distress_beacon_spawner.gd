extends Node

const MIN_LENGTH_FROM_BASE_SQUARED = 200*200
const MIN_LENGTH_FROM_DISTRESS_BEACON_SQUARED = 100*100
const MIN_LENGTH_FROM_SHIP_SQUARED = 100*100
const MIN_LENGTH_FROM_PIRATE_BASE = 320*320

@export var time_decreasment:float = 0.99
var timer:Timer = Timer.new()
var needs:int = 5
var needs_float:float = 0
@onready var size = Vector2(1920, 1080)
@onready var camera:Camera2D = get_parent().get_node("Camera")
var pirate_bases:Array = []
var rnd: RandomNumberGenerator = RandomNumberGenerator.new()
var path_marker_pool:Array = []

@onready var base:Node2D = get_parent().get_node("Base")

func _ready():
	for node in get_parent().get_children():
		if node is StaticBody2D and node.get_collision_layer_value(6):
			pirate_bases.append(node)
	add_child(timer)
	timer.timeout.connect(_timeout)
	rnd.randomize()
	timer.start(1)

func _process(delta):
	needs_float += delta*((2+pow(global.difficulty/120.0,2))/15)
	if needs_float > 1:
		needs += floor(needs_float)
		needs_float -= floor(needs_float)

func _timeout():
	timer.stop()
	if needs < 1:
		timer.start(15)
		return
	var accepted_proposition:bool = false
	var proposed_position: Vector2
	while not accepted_proposition:
		var x_range:float = size.x/(camera.zoom.x*2) - 100
		var y_range:float = size.y/(camera.zoom.y*2) - 100
		proposed_position = Vector2(rnd.randf_range(-x_range, x_range), rnd.randf_range(-y_range, y_range))
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
		for pirate_base in pirate_bases:
			if pirate_base.global_position.distance_squared_to(proposed_position) < MIN_LENGTH_FROM_PIRATE_BASE:
				accepted_proposition = false
				break
	var distress_beacon:Node2D = distress_beacon_pool.request_distress_beacon(proposed_position)
	var beacon_needs = rnd.randi_range(min(needs, 1+global.difficulty/120), min(needs, 3+(global.difficulty/60)))
	distress_beacon.set_needs(beacon_needs)
	needs -= beacon_needs
	var time = 5
	if needs > 6+(global.difficulty/30):
		time = 1
	elif needs < 1+global.difficulty/120:
		time = 15
		
	timer.start(time)
