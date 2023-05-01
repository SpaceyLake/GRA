extends Node2D

func _ready():
	$ButtonPlayGame.pressed.connect(_on_pressed_PlayGame)
	$ButtonHowToPlay.pressed.connect(_on_pressed_HowToPlay)
	$ButtonQuit.pressed.connect(_on_pressed_Quit)
	
	$ButtonPlayGame.mouse_entered.connect(_on_hover_PlayGame)
	$ButtonHowToPlay.mouse_entered.connect(_on_hover_HowToPlay)
	$ButtonQuit.mouse_entered.connect(_on_hover_Quit)
	
	$ButtonPlayGame.mouse_exited.connect(_on_stop_hover_PlayGame)
	$ButtonHowToPlay.mouse_exited.connect(_on_stop_hover_HowToPlay)
	$ButtonQuit.mouse_exited.connect(_on_stop_hover_Quit)

func _on_pressed_PlayGame():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_pressed_HowToPlay():
	get_tree().change_scene_to_file("res://Scenes/help_menu.tscn")

func _on_pressed_Quit():
	get_tree().quit()

func _on_hover_PlayGame():
	$ButtonPlayGame/Label.modulate = Color("#3fc778")

func _on_hover_HowToPlay():
	$ButtonHowToPlay/Label.modulate = Color("#007dc7")

func _on_hover_Quit():
	$ButtonQuit/Label.modulate = Color("#e1534a")

func _on_stop_hover_PlayGame():
	$ButtonPlayGame/Label.modulate = Color.WHITE

func _on_stop_hover_HowToPlay():
	$ButtonHowToPlay/Label.modulate = Color.WHITE

func _on_stop_hover_Quit():
	$ButtonQuit/Label.modulate = Color.WHITE
