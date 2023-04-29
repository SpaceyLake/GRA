extends Node2D

func _ready():
	path_marker_pool.node_creation_parent = self

func _exit_tree():
	path_marker_pool.node_creation_parent = null
