extends CharacterBody2D

var howered:bool = false
var selected:bool = false
var destinations:Array = []
var cargo: int = 0

func _ready():
	mouse_entered.connect(is_howering)
	mouse_exited.connect(is_not_howering)

func _physics_process(delta):
	if not destinations.is_empty() and position.distance_to(destinations.front()) < velocity.length()*delta:
			velocity = Vector2.ZERO
			destinations.pop_front()
	if not destinations.is_empty():
			look_at(destinations.front())
			velocity = position.direction_to(destinations.front())*20
	move_and_slide()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if howered:
			selected = true
		else:
			selected = false
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if Input.is_action_pressed("shift"):
			destinations.append(get_global_mouse_position())
		else:
			destinations = [get_global_mouse_position()]

func deliver(delivering_cargo:int):
	var delivered_cargo:int = min(cargo, delivering_cargo)
	cargo = delivering_cargo
	return delivering_cargo

func is_howering():
	howered = true

func is_not_howering():
	howered = false
