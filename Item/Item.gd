extends StaticBody2D
class_name Item

@export var applicable_trait: Character.Trait

var clickable = false
var interactable = true
var occupied = false

@onready var state_chart = $StateChart
@onready var area = $Area2D
@onready var highlight = $Highlight
@onready var used_by_mask = $UsedByMask

signal clicked(item: Item)
signal finished_cooldown(item: Item)
# signal auto_picked(item: Item)

func _on_area_2d_mouse_entered():
	if !clickable or !interactable:
		return
	
	scale = Vector2(1.1, 1.1)

func _on_area_2d_mouse_exited():
	if !interactable or !clickable:
		return
	
	scale = Vector2(1, 1)

func set_clickable(setter):
	self.clickable = setter
	highlight.visible = setter

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and clickable and interactable:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)
			state_chart.send_event("start_use")
			interactable = false
			occupied = true
			scale = Vector2(1, 1)

func auto_pick():
	# emit_signal("auto_picked", self)
	state_chart.send_event("start_use")
	interactable = false
	occupied = true
	scale = Vector2(1, 1)

func _on_cooldown_state_entered():
	_deactivate()

func _on_cooldown_state_exited():
	finished_cooldown.emit(self)
	_activate()

func _deactivate():
	set_modulate(Color.GRAY)
	modulate.a = 0.5
	interactable = false
	occupied = false
	highlight.visible = clickable
	used_by_mask.visible = false

func _activate():
	set_modulate(Color.WHITE)
	modulate.a = 1
	interactable = true

func set_mask(character: Character):
	used_by_mask.visible = true
	used_by_mask.get_child(0).texture = character.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("Idle", 0)
