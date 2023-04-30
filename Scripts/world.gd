extends Node2D

@onready var base = $Base

func _ready():
	path_marker_pool.node_creation_parent = self
	distress_beacon_pool.node_creation_parent = self

func _process(_delta):
	$UpgradeHanler/DarkOverlay.scale = Vector2.ONE / $Camera.zoom
	$GUI.scale = Vector2.ONE / $Camera.zoom	
	$GUI/Label.text = str(global.score)

func _exit_tree():
	path_marker_pool.node_creation_parent = null
	distress_beacon_pool.node_creation_parent = null
