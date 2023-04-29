extends Area2D

var needs: int = 5
var timeout: float = 20
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
	else:
		_timeout()

func _on_body_entered(body: Node2D):
	needs -= body.deliver(needs)
	if not needs:
		print("Success")
		distress_beacon_pool.return_distress_beacon(self)

func _timeout():
	print("Fail")
	distress_beacon_pool.return_distress_beacon(self)
