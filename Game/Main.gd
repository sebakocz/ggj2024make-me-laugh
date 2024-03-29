extends Node2D
class_name Main

var selected_character: Character = null

@export var item_state_charts_debug: MarginContainer
@export var character_state_charts_debug: MarginContainer

@export var good_bonus: int = 5
@export var bad_bonus: int = 20

@export var characters_node: Node

@export var character_scene: PackedScene

var laugh_stars: int = 0
var laugh_points = 0

var money = 400
@export var item_cost = 100

@export var character_cost = 100

var day = 1

const MAX_CHARACTERS = 3

@onready var interactables = $Interactables

signal laught_points_changed(points: int)
signal laught_stars_changed(stars: int)
signal characted_selected(character: Character)
signal money_changed(money: int)
signal bought_item(item: String)
signal day_changed(day: int)
signal characters_changed(characters: Array)

func _ready():
	for character in get_tree().get_nodes_in_group("character"):
		character.connect("clicked", _on_character_clicked)
		character.connect("finished_use", _on_character_finished_use)
		character.connect("auto_pick_start", _clear_character)
		character.connect("changed_info", _on_character_changed_info)
		character.connect("tree_exited", _populate_cast)
	
	for item in get_tree().get_nodes_in_group("item"):
		item.connect("clicked", _on_item_clicked)
		item.connect("finished_cooldown", _on_item_finished_cooldown)
		# item.connect("auto_picked", _on_item_clicked) # not needed
	
	_populate_cast()

func _on_character_changed_info(_character: Character):
	characters_changed.emit(characters_node.get_children())

func _populate_cast():
	# check how many we have
	if characters_node.get_children().size() >= MAX_CHARACTERS:
		return
	
	var new_random_character_scene = _random_character_scene()
	var new_character = load(new_random_character_scene).instantiate()

	# make sure it's two different traits
	var trait1 = Character.Trait.values()[randi() % Character.Trait.keys().size()]
	var trait2 = Character.Trait.values()[randi() % Character.Trait.keys().size()]
	while trait1 == trait2:
		trait2 = Character.Trait.values()[randi() % Character.Trait.keys().size()]

	var random_amount_of_spaces = " ".repeat(randi() % 3)

	# generate random character
	new_character.initialize(
		Character.RANDOM_NAMES[randi() % Character.RANDOM_NAMES.size()] + random_amount_of_spaces,
		trait1,
		trait2
	)
	new_character.connect("clicked", _on_character_clicked)
	new_character.connect("finished_use", _on_character_finished_use)
	new_character.connect("auto_pick_start", _clear_character)
	new_character.connect("changed_info", _on_character_changed_info)
	new_character.connect("tree_exited", _populate_cast)
	characters_node.add_child(new_character)

	_populate_cast()

	# move away
	new_character.position = Vector2(1000, 1000)

	characters_changed.emit(characters_node.get_children())

func _random_character_scene():
	var path = "res://Character/List"
	var character_files = DirAccess.get_files_at(path)
	var random_index = randi() % character_files.size()
	return path + "/" + character_files[random_index]

func _on_item_finished_cooldown(item):
	if selected_character == null:
		return
	
	item.set_clickable(true)

func _on_character_clicked(character):
	if selected_character != null:
		selected_character.highlight.set_modulate(Color.WHITE)
		selected_character.highlight.visible = false
		selected_character.selected = false
	selected_character = character
	selected_character.highlight.set_modulate(Color.GRAY)
	selected_character.selected = true
	characted_selected.emit(selected_character)
	_enable_items(true)
	character_state_charts_debug.debug_node(character)

func _clear_character(character: Character):
	if selected_character == character:
		selected_character.highlight.set_modulate(Color.WHITE)
		selected_character.highlight.visible = false
		selected_character.selected = false
		selected_character = null
		characted_selected.emit(null)
		_enable_items(false)

func _on_character_finished_use(trait_result: Character.TraitResult):
	match trait_result:
		Character.TraitResult.GOOD:
			laugh_points += good_bonus
		Character.TraitResult.BAD:
			laugh_points += bad_bonus
		Character.TraitResult.NEUTRAL:
			return
	
	laught_points_changed.emit(laugh_points)

	if laugh_points >= 100:
		laugh_points = 0
		money += 100
		laugh_stars += 1
		await get_tree().create_timer(1).timeout
		laught_points_changed.emit(laugh_points)
		laught_stars_changed.emit(laugh_stars)
		money_changed.emit(money)

func _on_item_clicked(item):
	selected_character.set_item(item)
	selected_character.selected = false
	selected_character = null
	characted_selected.emit(null)
	_enable_items(false)
	item_state_charts_debug.debug_node(item)

func _enable_items(enable: bool):
	for item in get_tree().get_nodes_in_group("item"):
		item.set_clickable(item.interactable and enable)

func _on_ui_trying_to_buy_item(itemName: String):
	for interactable in interactables.get_children():
		if interactable.name == itemName:
			if interactable.bought:
				return
			break

	if money < item_cost:
		return
	
	money -= item_cost
	money_changed.emit(money)
	bought_item.emit(itemName)

	deselect_character()

	# find by name in interactables, activate it
	for interactable in interactables.get_children():
		if interactable.name == itemName:
			interactable.bought = true
			interactable.interactable = true
			interactable.get_node("Sprite2D").modulate = Color.WHITE
			break

func _on_day_timer_timeout():
	day += 1
	day_changed.emit(day)

	# low engagement penalty
	if laugh_points <= 0:
		for character in characters_node.get_children():
			if character.active:
				character.stress_level += 1
				character.changed_info.emit(character)
				if character.stress_level >= Character.STRESS_THRESHOLD:
					character.state_chart.send_event("inactivated")

	laugh_points -= 10
	if laugh_points < 0:
		laugh_points = 0
	laught_points_changed.emit(laugh_points)

func _on_ui_trying_to_buy_character(characterIndex: int):
	if characters_node.get_children()[characterIndex].active:
		return

	if money < character_cost:
		return
	
	money -= character_cost
	money_changed.emit(money)

	# find by id in characters_node, activate it
	var character = characters_node.get_children()[characterIndex]
	var random_vector_around = Vector2(randf(), randf()).normalized() * 80
	character.position = random_vector_around
	character.state_chart.send_event("activated")

	deselect_character()

func deselect_character():
	if selected_character != null:
		selected_character.highlight.set_modulate(Color.WHITE)
		selected_character.highlight.visible = false
		selected_character.selected = false
		selected_character = null
		characted_selected.emit(null)
		_enable_items(false)

var flip = true

func _on_money_changed(_money):
	if !flip:
		return
	flip = false

	$DayTimer.start()
	$UI.get_node("DayCount").get_node("AnimatedSprite2D").play("default")
	$UI.get_node("ArrowLeft").queue_free()