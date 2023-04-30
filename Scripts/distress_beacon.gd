extends Area2D

var fuel_marker = load("res://Sprites/DistressBeaconFuelMarker.svg")

var needs: int = 5
var timeout: float = 120
var timer: float = timeout

var has_alarmed = false

func _ready():
	body_entered.connect(_on_body_entered)
	$AlarmTimer.timeout.connect(_alarm_timeout)
	$AudioSpawn.pitch_scale = randf_range(0.5, 2)
	$AudioSpawn.play()

func _process(delta):
	timer -= delta
	if timer > 0:
		var progress = (timer/timeout)
		var color = Color("#3fc778")
		if progress < 0.2:
			color = Color("#e1534a")
			if $AlarmTimer.is_stopped():
				$AlarmTimer.start()
		elif progress < 0.4:
			color = Color("#f29546")
			if not has_alarmed:
				has_alarmed = true
				$AudioAlarm1.play()
		elif progress < 0.6:
			color = Color("#ffce00")
		elif progress < 0.8:
			color = Color("#bdd156")
		
		$Sprite2D.modulate = color
		$TextureProgressBar.tint_progress = color
		$TextureProgressBar.value = $TextureProgressBar.max_value*progress
		queue_redraw()
	else:
		if timer < -5:
			_timeout()

func play_spawn_animation():
	$AnimationPlayer.play("Spawn")

func reset_timer():
	timer = timeout
	has_alarmed = false
	$AudioSpawn.pitch_scale = randf_range(0.5, 2)
	$AudioSpawn.play()
	$AlarmTimer.stop()

func set_needs(new_needs:int):
	needs = new_needs
	queue_redraw()

func _on_body_entered(body: Node2D):
	if body.get_collision_layer_value(2):
		var amount = body.deliver(needs)
		set_needs(needs - amount)
		global.score += amount
		if not needs:
			print("Success")
			$AlarmTimer.stop()
			distress_beacon_pool.return_distress_beacon(self)
	elif body.get_collision_layer_value(8):
		if body.rescue():
			timer = timeout
			$AlarmTimer.stop()

func _timeout():
	print("Fail")
	$AlarmTimer.stop()
	global.game_lost()
	distress_beacon_pool.return_distress_beacon(self)

func _alarm_timeout():
	$AudioAlarm2.play()
#	var progress = (timer/timeout)
#	if progress < 0.2:
#		$AudioAlarm2.play()
#	else:
#		$AudioAlarm1.play()

func _draw():
	var step = (2*PI)/needs
	for i in range(needs):
		var angle = step*i+(PI/2)
		draw_set_transform(Vector2.ZERO, angle, Vector2(1, 1))
		draw_texture(fuel_marker, Vector2(30,-6.5), $Sprite2D.modulate)
