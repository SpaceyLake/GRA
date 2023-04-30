extends Node2D

var particles:Array = []

func _ready():
	$LineColor.add_point(Vector2.ZERO)
	$LineColor.add_point(Vector2.ZERO)
	$LineWhite.add_point(Vector2.ZERO)
	$LineWhite.add_point(Vector2.ZERO)
	
	particles.append($GPUParticles1)
	particles.append($GPUParticles2)
	particles.append($GPUParticles3)
	particles.append($GPUParticles4)
	

func set_line(point1:Vector2, point2:Vector2, color:Color):
	$LineColor.set_point_position(0, point1)
	$LineColor.set_point_position(1, point2)
	$LineColor.default_color = color
	$LineWhite.set_point_position(0, point1)
	$LineWhite.set_point_position(1, point2)
	$AnimationPlayer.play("Fire")
	
	particles[0].modulate = color
	particles[1].modulate = color
	
	particles[0].global_position = point1
	particles[1].global_position = point2
	particles[2].global_position = point1
	particles[3].global_position = point2	
	
	for p in particles:
		p.restart()
		p.emitting = true
	
	$AudioFire.pitch_scale = randf_range(0.75, 1.5)
	$AudioFire.play()
	
func return_self():
	laser_pool.return_laser(self)
