extends AnimatedSprite2D

func _on_inactive_taken():
	visible = true
	play("default")