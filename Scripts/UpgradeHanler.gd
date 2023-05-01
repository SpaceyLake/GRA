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
	
	$DarkOverlay/UpgradeMenu/RefuelingShip.visible = false
	$DarkOverlay/UpgradeMenu/AttackShip.visible = false
	$DarkOverlay/UpgradeMenu/RescueShip.visible = false	
	
	$UpgradeTimer.timeout.connect(_on_UpgradeTimer_timeout)
	$DarkOverlay/UpgradeMenu/RefuelingShip.pressed.connect(_on_RefuelingShip_pressed)
	$DarkOverlay/UpgradeMenu/AttackShip.pressed.connect(_on_AttackShip_pressed)
	$DarkOverlay/UpgradeMenu/RescueShip.pressed.connect(_on_RescueShip_pressed)	
	
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
	
	$DarkOverlay/UpgradeMenu/RefuelingShip.visible = false
	$DarkOverlay/UpgradeMenu/AttackShip.visible = false
	$DarkOverlay/UpgradeMenu/RescueShip.visible = false	
	#get_parent().base.add_ship()

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
	
	if cycle == 2:
		$DarkOverlay/UpgradeMenu/RefuelingShip.visible = true
		$DarkOverlay/UpgradeMenu/RefuelingShip.global_position = $DarkOverlay/UpgradeMenu/Marker1.global_position		
		$DarkOverlay/UpgradeMenu/AttackShip.visible = true
		$DarkOverlay/UpgradeMenu/AttackShip.global_position = $DarkOverlay/UpgradeMenu/Marker2.global_position
	else:
		var upgrade = global.rng.randf_range(0, 1)
		if upgrade < 0.2:
			$DarkOverlay/UpgradeMenu/AttackShip.visible = true
			$DarkOverlay/UpgradeMenu/AttackShip.global_position = $DarkOverlay/UpgradeMenu/Marker1.global_position
			$DarkOverlay/UpgradeMenu/RescueShip.visible = true
			$DarkOverlay/UpgradeMenu/RescueShip.global_position = $DarkOverlay/UpgradeMenu/Marker2.global_position		
		elif upgrade < 0.5:
			$DarkOverlay/UpgradeMenu/RefuelingShip.visible = true
			$DarkOverlay/UpgradeMenu/RefuelingShip.global_position = $DarkOverlay/UpgradeMenu/Marker1.global_position
			$DarkOverlay/UpgradeMenu/RescueShip.visible = true
			$DarkOverlay/UpgradeMenu/RescueShip.global_position = $DarkOverlay/UpgradeMenu/Marker2.global_position		
		else:
			$DarkOverlay/UpgradeMenu/RefuelingShip.visible = true
			$DarkOverlay/UpgradeMenu/RefuelingShip.global_position = $DarkOverlay/UpgradeMenu/Marker1.global_position		
			$DarkOverlay/UpgradeMenu/AttackShip.visible = true
			$DarkOverlay/UpgradeMenu/AttackShip.global_position = $DarkOverlay/UpgradeMenu/Marker2.global_position

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

func _on_AttackShip_pressed():
	get_parent().base.spawn_attack_ship()
	finnish_upgrade()

func _on_RescueShip_pressed():
	get_parent().base.spawn_rescue_ship()
	finnish_upgrade()

