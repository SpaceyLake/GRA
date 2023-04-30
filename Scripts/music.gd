extends AudioStreamPlayer

func _input(event):
	if event.is_action_pressed("mute"):
		if playing:
			stop()
		else:
			play(0)
