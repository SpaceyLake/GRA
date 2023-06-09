extends Node2D

@onready var base = $Base

func _ready():
	path_marker_pool.node_creation_parent = self
	distress_beacon_pool.node_creation_parent = self
	laser_pool.node_creation_parent = self
	path_marker_pool.reset()
	distress_beacon_pool.reset()
	laser_pool.reset()
	
	global.difficulty = 0

func _process(delta):
	$MenuHanler/DarkOverlay.scale = Vector2.ONE / $Camera.zoom
	$GUI.scale = Vector2.ONE / $Camera.zoom	
	$GUI/Label.text = str(global.score)
	
	global.difficulty += delta

func _exit_tree():
	path_marker_pool.node_creation_parent = null
	distress_beacon_pool.node_creation_parent = null
	laser_pool.node_creation_parent = null
