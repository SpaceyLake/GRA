extends Node

var node_creation_parent = null

var scn_laser = preload("res://Scenes/laser.tscn")
var laser_pool:Array = []

func request_laser(point1:Vector2, point2:Vector2, color:Color):
	var node_instance = null
	if laser_pool.is_empty():
		if node_creation_parent == null:
			print_debug("node_creation_parent is null")
			return null
		node_instance = scn_laser.instantiate()
		node_creation_parent.add_child(node_instance)
	else:
		node_instance = laser_pool.pop_front()
		_laser_set_active(node_instance, true)
	node_instance.set_line(point1, point2, color)
	return node_instance


func return_laser(laser):
	_laser_set_active(laser, false)
	laser_pool.push_back(laser)

func _laser_set_active(path_marker, active):
	path_marker.visible = active
	path_marker.set_process(active)
	path_marker.set_physics_process(active)
	path_marker.set_process_input(active)
	path_marker.set_process_internal(active)
	path_marker.set_process_unhandled_input(active)
	path_marker.set_process_unhandled_key_input(active)
		
