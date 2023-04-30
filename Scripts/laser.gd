extends Node2D

func _ready():
	$Line2D.add_point(Vector2.ZERO)
	$Line2D.add_point(Vector2.ZERO)	

func set_line(point1:Vector2, point2:Vector2, color:Color):
	$Line2D.set_point_position(0, point1)
	$Line2D.set_point_position(1, point2)
	$Line2D.default_color = color
	$AnimationPlayer.play("Fire")

func return_self():
	laser_pool.return_laser(self)
