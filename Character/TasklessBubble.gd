extends AnimatedSprite2D

func _on_active_state_entered():
	play("default")

func _on_idle_state_exited():
	queue_free()