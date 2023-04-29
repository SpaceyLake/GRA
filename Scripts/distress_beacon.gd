extends Area2D

var needs: int = 5
var timeout: float = 20
var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_timeout)
	timer.start(timeout)

func _on_body_entered(body: Node2D):
	needs -= body.deliver(needs)
	if not needs:
		print("Success")
		queue_free()

func _timeout():
	print("Fail")
	queue_free()
