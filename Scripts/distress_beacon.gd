extends Area2D

var fuel_marker = load("res://Sprites/DistressBeaconFuelMarker.svg")

var needs: int = 5
var timeout: float = 60
var timer: float = timeout

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	timer -= delta
	if timer > 0:
		var progress = (timer/timeout)
		var color = Color("#3fc778")
		if progress < 0.2:
			color = Color("#e1534a")
		elif progress < 0.4:
			color = Color("#f29546")
		elif progress < 0.6:
			color = Color("#ffce00")
		elif progress < 0.8:
			color = Color("#bdd156")
		
		$Sprite2D.modulate = color
		$TextureProgressBar.tint_progress = color
		$TextureProgressBar.value = $TextureProgressBar.max_value*progress
		queue_redraw()
	else:
		_timeout()

func play_spawn_animation():
	$AnimationPlayer.play("Spawn")

func reset_timer():
	timer = timeout

func set_needs(new_needs:int):
	needs = new_needs
	queue_redraw()

func _on_body_entered(body: Node2D):
	var amount = body.deliver(needs)
	set_needs(needs - amount)
	global.score += amount
	if not needs:
		print("Success")
		distress_beacon_pool.return_distress_beacon(self)

func _timeout():
	print("Fail")
	distress_beacon_pool.return_distress_beacon(self)

func _draw():
	var step = (2*PI)/needs
	for i in range(needs):
		var angle = step*i+(PI/2)
		draw_set_transform(Vector2.ZERO, angle, Vector2(1, 1))
		draw_texture(fuel_marker, Vector2(30,-6.5), $Sprite2D.modulate)
