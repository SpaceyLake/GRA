extends Node

var is_upgrading = false
var is_paused = false
var cycle = 1

func _ready():
	global.menu_hanler = self
	
	$DarkOverlay/UpgradeMenu.visible = false
	$DarkOverlay/PauseMenu.visible = false
	$DarkOverlay/LoseMenu.visible = false
	$AnimationPlayer.play_backwards("Darken")
	
	$UpgradeTimer.timeout.connect(_on_UpgradeTimer_timeout)
	$DarkOverlay/UpgradeMenu/RefuelingShip.pressed.connect(_on_RefuelingShip_pressed)
	$DarkOverlay/LoseMenu/ButtonReturn.pressed.connect(_on_ButtonReturn_pressed)
	
	$DarkOverlay/LoseMenu/ButtonReturn.mouse_entered.connect(_on_hover_ButtonReturn)
	$DarkOverlay/LoseMenu/ButtonReturn.mouse_exited.connect(_on_stop_hover_ButtonReturn)

func  _exit_tree():
	global.menu_hanler = null

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

func game_lost():
	get_tree().paused = true
	$DarkOverlay/LoseMenu.visible = true
	$DarkOverlay/LoseMenu/LabelTitle3.text = "You delivered "+str(global.score)+" fuel"
	$AnimationPlayer.play("Darken")

func _on_UpgradeTimer_timeout():
	is_upgrading = true
	get_tree().paused = true
	$DarkOverlay/UpgradeMenu.visible = true
	
	cycle += 1
	
	$DarkOverlay/UpgradeMenu/LabelTitle.text = "Cycle "+str(cycle)
	
	$AnimationPlayer.play("Darken")

func _on_ButtonReturn_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_hover_ButtonReturn():
	$DarkOverlay/LoseMenu/ButtonReturn/Label.modulate = Color("#3fc778")

func _on_stop_hover_ButtonReturn():
	$DarkOverlay/LoseMenu/ButtonReturn/Label.modulate = Color.WHITE

func _on_RefuelingShip_pressed():
	get_parent().base.add_ship()
	finnish_upgrade()

