extends Node2D

func _ready():
	path_marker_pool.node_creation_parent = self
	distress_beacon_pool.node_creation_parent = self

func _process(_delta):
	#DEBUG
	if Input.get_action_strength("ui_cancel"):
		get_tree().quit()
	
	$CanvasLayer.scale = Vector2.ONE / $Camera.zoom
	$CanvasLayer/Label.text = str(global.score)

func _exit_tree():
	path_marker_pool.node_creation_parent = null
	distress_beacon_pool.node_creation_parent = null
