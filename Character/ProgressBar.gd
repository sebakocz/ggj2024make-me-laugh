extends ProgressBar

@export var use_duration: float = 3.0

func _on_using_state_entered():
	visible = true
	value = 0.0

func _on_using_state_physics_processing(delta: float):
	value += delta / use_duration * 100.0

func _on_using_state_exited():
	visible = false
