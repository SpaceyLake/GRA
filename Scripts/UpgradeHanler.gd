extends Node

var is_upgrading = false
var cycle = 1

func _ready():
	$UpgradeMenu.visible = false
	$UpgradeTimer.timeout.connect(_on_UpgradeTimer_timeout)
	$UpgradeMenu/RefuelingShip.pressed.connect(_on_RefuelingShipPressed)

func _process(_delta):
	#DEBUG
	if Input.get_action_strength("ui_cancel"):
		get_tree().quit()

func finnish_upgrade():
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
	
func _on_RefuelingShipPressed():
	get_parent().base.add_ship()
	finnish_upgrade()
