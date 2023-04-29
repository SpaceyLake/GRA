extends Camera2D

@export var zoom_decrease = 0.5/900
@export var min_zoom = 0.5
@export var start_zoom = 1

func _ready():
	zoom.x = start_zoom
	zoom.y = start_zoom

func _process(delta):
	if zoom.x <= min_zoom and zoom.y <= min_zoom:
		zoom.x = min_zoom
		zoom.y = min_zoom
	else:
		zoom.x -= zoom_decrease * delta
		zoom.y -= zoom_decrease * delta
