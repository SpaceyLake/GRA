extends Node

var is_upgrading = false
var cycle = 1

func _ready():
	$UpgradeTimer.timeout.connect(_on_UpgradeTimer_timeout)
	$UpgradeMenu.visible = false

func _process(_delta):
	#DEBUG
	if Input.get_action_strength("ui_cancel"):
		get_tree().quit()
	
	if Input.get_action_strength("ui_accept") and is_upgrading:
		is_upgrading = false
		get_tree().paused = false
		$UpgradeMenu.visible = false
		$UpgradeTimer.start()
		
		get_parent().base.add_ship()

func _on_UpgradeTimer_timeout():
	is_upgrading = true
	get_tree().paused = true
	$UpgradeMenu.visible = true
	
	cycle += 1
	
	$UpgradeMenu/LabelTitle.text = "Cycle "+str(cycle)
	
	$AnimationPlayer.play("OpenUpgradeMenu")
	
