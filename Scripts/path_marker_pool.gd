extends Node

var node_creation_parent = null

var scn_path_marker = preload("res://Scenes/path_marker.tscn")
var path_marker_pool:Array = []

func request_path_marker(location):
	var node_instance = null
	if path_marker_pool.is_empty():
		if node_creation_parent == null:
			print_debug("node_creation_parent is null")
			return
		node_instance = scn_path_marker.instantiate()
		node_creation_parent.add_child(node_instance)
	else:
		node_instance = path_marker_pool.pop_front()
		_marker_set_active(node_instance, true)
	node_instance.global_position = location
	return node_instance


func return_path_marker(path_marker):
	_marker_set_active(path_marker, false)
	path_marker_pool.push_back(path_marker)

func _marker_set_active(path_marker, active):
	path_marker.visible = active
	path_marker.set_process(active)
	path_marker.set_physics_process(active)
	path_marker.set_process_input(active)
	path_marker.set_process_internal(active)
	path_marker.set_process_unhandled_input(active)
	path_marker.set_process_unhandled_key_input(active)
