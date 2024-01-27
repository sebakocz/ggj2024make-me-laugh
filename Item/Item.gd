extends StaticBody2D
class_name Item

@export var applicable_trait: Character.Trait

var clickable = false
var interactable = true
var used_by: Character = null

@onready var state_chart = $StateChart

signal clicked

func _on_area_2d_mouse_entered():
	if !clickable or !interactable:
		return
		
	set_modulate(Color.RED)
	set_scale(Vector2(1.1, 1.1))

func _on_area_2d_mouse_exited():
	if !interactable or !clickable:
		return

	set_modulate(Color.WHITE)
	set_scale(Vector2(1, 1))

func set_clickable(setter):
	self.clickable = setter

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and clickable and interactable:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)
			set_modulate(Color.WHITE)
			set_scale(Vector2(1, 1))
			state_chart.send_event("start_use")

func _on_cooldown_state_entered():
	set_modulate(Color.GRAY)
	interactable = false

func _on_cooldown_state_exited():
	set_modulate(Color.WHITE)
	interactable = true