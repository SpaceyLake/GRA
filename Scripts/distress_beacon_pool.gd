extends Node

var node_creation_parent = null

var scn_distress_beacon = preload("res://Scenes/distress_beacon.tscn")
var distress_beacon_pool:Array = []
var distress_beacons_placed:Array = []

func reset():
	distress_beacon_pool = []
	distress_beacons_placed = []

func request_distress_beacon(location):
	var node_instance = null
	if distress_beacon_pool.is_empty():
		if node_creation_parent == null:
			print_debug("node_creation_parent is null")
			return null
		node_instance = scn_distress_beacon.instantiate()
		node_creation_parent.add_child(node_instance)
	else:
		node_instance = distress_beacon_pool.pop_front()
		_distress_beacon_set_active(node_instance, true)
	node_instance.global_position = location
	distress_beacons_placed.append(node_instance)
	return node_instance

func return_distress_beacon(distress_beacon):
	distress_beacons_placed.erase(distress_beacon)
	_distress_beacon_set_active(distress_beacon, false)
	distress_beacon_pool.push_back(distress_beacon)

func _distress_beacon_set_active(distress_beacon, active):
	distress_beacon.visible = active
	distress_beacon.set_process(active)
	distress_beacon.set_physics_process(active)
	distress_beacon.set_process_input(active)
	distress_beacon.set_process_internal(active)
	distress_beacon.set_process_unhandled_input(active)
	distress_beacon.set_process_unhandled_key_input(active)
	distress_beacon.get_node("CollisionShape2D").set_deferred("disabled", not active)
	if active:
		distress_beacon.reset_timer()
		distress_beacon.play_spawn_animation()
