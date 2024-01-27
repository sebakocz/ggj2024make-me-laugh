extends CharacterBody2D
class_name Character

enum Trait {
	GUITAR,
	READING,
	PAINTING,
	KARAOKE,
	COOKING,
	GARDENING
}

enum TraitResult {
	NEUTRAL,
	GOOD,
	BAD
}

@export var good_trait: Trait
@export var bad_trait: Trait

@export var speed: float = 100
@export var min_distance: float = 40

@onready var nav = $NavigationAgent2D
@onready var state_chart = $StateChart
@onready var animation_tree = $AnimationTree
@onready var highlight = $Highlight

signal clicked(character: Character)
signal finished_use(result: TraitResult)

var current_target: Item = null
var selected: bool = false
var busy = false

func set_target(target: Vector2):
	nav.target_position = target

func set_item(item: Item):
	set_target(item.global_position)
	current_target = item
	state_chart.send_event("set_target")
	set_modulate(Color.WHITE)
	busy = true

func auto_set_item(item: Item):
	set_item(item)
	item.auto_pick()

func _on_moving_state_physics_processing(_delta: float):
	var direction = nav.get_next_path_position() - global_position
	var distance = current_target.global_position - global_position
	
	# TODO: this is whack
	if distance.length() < min_distance:
		state_chart.send_event("reached_target")
		return

	direction = direction.normalized()

	velocity = direction * speed

	if !_is_diag(direction) and direction != Vector2.ZERO: # idk, just some magic
		animation_tree.set("parameters/Move/blend_position", direction)

	move_and_slide()

func _on_area_2d_mouse_entered():
	if busy:
		return

	set_modulate(Color.RED)
	set_scale(Vector2(1.1, 1.1))

func _on_area_2d_mouse_exited():
	if !selected:
		set_modulate(Color.WHITE)
	set_scale(Vector2(1, 1))

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if busy:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

			# prevent event propagation
			get_tree().get_root().set_input_as_handled()

func _on_using_state_exited():
	current_target.state_chart.send_event("finish_use")
	finished_use.emit(_check_trait(current_target.applicable_trait))
	current_target = null
	busy = false

func _check_trait(trait_to_be_checked: Trait) -> TraitResult:
	if trait_to_be_checked == good_trait:
		return TraitResult.GOOD
	elif trait_to_be_checked == bad_trait:
		return TraitResult.BAD
	else:
		return TraitResult.NEUTRAL
	
func _is_diag(vector: Vector2=Vector2.ZERO) -> bool:
	if abs(vector.aspect()) == 1:
		return true
	else:
		return false

func _on_auto_target_taken():
	var random_item = _get_random_unoccupied_item()
	if random_item == null:
		# return to idle state, basically try again later
		state_chart.send_event("reached_target")
		return

	auto_set_item(random_item)

func _get_random_unoccupied_item() -> Item:
	var items = get_tree().get_nodes_in_group("item")
	var unoccupied_items = []

	for item in items:
		if !item.occupied:
			unoccupied_items.append(item)

	if unoccupied_items.size() == 0:
		return null

	return unoccupied_items[randi() % unoccupied_items.size()]
