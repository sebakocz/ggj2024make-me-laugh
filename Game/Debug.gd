extends Node

func _physics_process(delta):
	if !OS.is_debug_build():
		return

	# Esc - quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()