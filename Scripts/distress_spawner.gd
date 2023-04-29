extends Node

var time_decreasment:int = 1
var time:int = 15
var timer:Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.timeout.connect(_timeout)
	timer.start(time)

func _timeout():
	timer.stop()
	time -= 1
	timer.start(time)
	
