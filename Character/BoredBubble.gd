extends Sprite2D

func _on_auto_target_taken():
	visible = true
	await get_tree().create_timer(1).timeout
	visible = false