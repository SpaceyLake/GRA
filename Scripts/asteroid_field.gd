extends Area2D

const n = 30
const c = 75/sqrt(n)
const golden_ratio = 1.61803398875
const step = (2*PI)/pow(golden_ratio, 2)

const small = preload("res://Sprites/AsteroidSmall.svg")
const medium = preload("res://Sprites/AsteroidMedium.svg")
const large = preload("res://Sprites/AsteroidLarge.svg")


func _draw():
	for i in n:
		draw_set_transform(Vector2.ZERO, step*i, Vector2(1, 1))
		draw_texture(small, Vector2(-8+c*sqrt(i),-8)+Vector2.RIGHT.rotated(randf_range(-PI, PI)*randf_range(0,2)), Color("#B8614E") if randi_range(0,1) else Color("#F29546"))
