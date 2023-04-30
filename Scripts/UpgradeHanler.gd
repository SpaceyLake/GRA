extends Node

var is_upgrading = false
var is_paused = false
var cycle = 1

func _ready():
	$DarkOverlay/UpgradeMenu.visible = false
	$DarkOverlay/PauseMenu.visible = false
	$AnimationPlayer.play_backwards("Darken")
	
	$UpgradeTimer.timeout.connect(_on_UpgradeTimer_timeout)
	$DarkOverlay/UpgradeMenu/RefuelingShip.pressed.connect(_on_RefuelingShipPressed)

func _process(_delta):
	#DEBUG
	if Input.get_action_strength("ui_cancel"):
		get_tree().quit()
	
	if not is_upgrading and Input.is_action_just_pressed("ui_accept"):
		is_paused = !is_paused
		get_tree().paused = is_paused
		$DarkOverlay/PauseMenu.visible = is_paused
		$UpgradeTimer.paused = is_paused
		if is_paused:
			$AnimationPlayer.play("Darken")
		else:
			$AnimationPlayer.play_backwards("Darken")

func finnish_upgrade():
	is_upgrading = false
	get_tree().paused = false
	$DarkOverlay/UpgradeMenu.visible = false
	$AnimationPlayer.play_backwards("Darken")
	$UpgradeTimer.start()
	
	get_parent().base.add_ship()

func _on_UpgradeTimer_timeout():
	is_upgrading = true
	get_tree().paused = true
	$DarkOverlay/UpgradeMenu.visible = true
	
	cycle += 1
	
	$DarkOverlay/UpgradeMenu/LabelTitle.text = "Cycle "+str(cycle)
	
	$AnimationPlayer.play("Darken")
	
func _on_RefuelingShipPressed():
	get_parent().base.add_ship()
	finnish_upgrade()
