extends CharacterBody2D
class_name Character

const RANDOM_NAMES = [
	"Alex",
	"Jordan",
	"Taylor",
	"Casey",
	"Riley",
	"Jamie",
	"Sam",
	"Avery",
	"Reese",
	"Cameron",
	"Blake",
	"Dakota",
	"Morgan",
	"Quinn",
	"Skyler",
	"Charlie",
	"Emery",
	"Finley",
	"Peyton",
	"Sawyer"
]

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

var stress_level: int = 0

const STRESS_THRESHOLD = 5

@export var thought_bubble: PackedScene

@onready var nav = $NavigationAgent2D
@onready var state_chart = $StateChart
@onready var animation_tree = $AnimationTree
@onready var highlight = $Highlight
@onready var busy_bubble = $BusyBubble

signal clicked(character: Character)
signal finished_use(result: TraitResult)
signal auto_pick_start(character: Character)
signal changed_info(character: Character)

var current_target: Item = null
var selected: bool = false
var busy = false
var active = false

func initialize(new_name: String, new_good_trait: Trait, new_bad_trait: Trait):
	name = new_name
	good_trait = new_good_trait
	bad_trait = new_bad_trait

	# how to do animations? idk, whatever

func set_target(target: Vector2):
	nav.target_position = target

func set_item(item: Item):
	set_target(item.global_position)
	item.set_mask(self)
	current_target = item
	state_chart.send_event("set_target")
	highlight.visible = false
	highlight.set_modulate(Color.WHITE)
	busy = true

func auto_set_item(item: Item):
	set_item(item)
	item.auto_pick()
	auto_pick_start.emit(self)

func _on_moving_state_physics_processing(_delta: float):
	if current_target == null:
		# bug but I guess a feature, allows player to wait a lil
		return

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
	if busy or !active:
		return

	highlight.visible = true

func _on_area_2d_mouse_exited():
	if selected:
		return
	
	highlight.visible = false

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if busy or !active:
			busy_bubble.visible = true
			await get_tree().create_timer(1).timeout
			busy_bubble.visible = false
			return

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)

			# prevent event propagation
			get_tree().get_root().set_input_as_handled()

func _on_using_state_exited():
	var result = _check_trait(current_target.applicable_trait)

	# stress penalty
	if result == TraitResult.BAD:
		stress_level += 1
		if stress_level >= STRESS_THRESHOLD:
			print("stress level reached")
			state_chart.send_event("inactivated")
	elif result == TraitResult.GOOD:
		stress_level -= 1 if stress_level > 0 else 0
	changed_info.emit(self)
	
	if current_target != null:
		current_target.used_by_mask.visible = false
		current_target.state_chart.send_event("finish_use")

	# thought bubble
	if !active:
		return
	
	var bubble = thought_bubble.instantiate()
	bubble.initialize(result)
	add_child(bubble)

	current_target = null
	busy = false
	finished_use.emit(result)

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
		if !item.occupied and item.interactable:
			unoccupied_items.append(item)

	if unoccupied_items.size() == 0:
		return null

	return unoccupied_items[randi() % unoccupied_items.size()]

func _on_using_state_entered():
	current_target.used_by_mask.visible = false

func _on_active_state_entered():
	active = true
	changed_info.emit(self)

func _on_inactive_taken():
	active = false
	await get_tree().create_timer(2.5).timeout
	changed_info.emit(self)
	queue_free()