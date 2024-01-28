extends AudioStreamPlayer

func _on_main_laught_points_changed(points: int):
	if points < 100:
		return
	play()
