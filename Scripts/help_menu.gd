extends Node2D

@onready var instructions:Array = $Instructions.get_children()
var current_instruction:int = 0

func _ready():
	for l in instructions:
		l.visible = false
	instructions[0].visible = true
	
	$ButtonNext.pressed.connect(_on_pressed_Next)
	$ButtonBack.pressed.connect(_on_pressed_Back)
	
	$ButtonNext.mouse_entered.connect(_on_hover_Next)
	$ButtonBack.mouse_entered.connect(_on_hover_Back)
	
	$ButtonNext.mouse_exited.connect(_on_stop_hover_Next)
	$ButtonBack.mouse_exited.connect(_on_stop_hover_Back)

func _on_pressed_Next():
	instructions[current_instruction].visible = false
	if current_instruction < instructions.size()-1:
		current_instruction += 1
	instructions[current_instruction].visible = true

func _on_pressed_Back():
	instructions[current_instruction].visible = false
	if current_instruction > 0:
		current_instruction -= 1
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	instructions[current_instruction].visible = true


func _on_hover_Next():
	$ButtonNext/Label.modulate = Color("#3fc778")

func _on_hover_Back():
	$ButtonBack/Label.modulate = Color("#e1534a")


func _on_stop_hover_Next():
	$ButtonNext/Label.modulate = Color.WHITE

func _on_stop_hover_Back():
	$ButtonBack/Label.modulate = Color.WHITE

