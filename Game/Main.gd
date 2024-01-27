extends Node2D
class_name Main

var selected_character: Character = null

@export var item_state_charts_debug: MarginContainer
@export var character_state_charts_debug: MarginContainer

@export var good_bonus: int = 1
@export var bad_bonus: int = 3

var laugh_points = 0

signal laught_points_changed(points: int)
signal characted_selected(character: Character)

func _ready():
	for character in get_tree().get_nodes_in_group("character"):
		character.connect("clicked", _on_character_clicked)
		character.connect("finished_use", _on_character_finished_use)
	
	for item in get_tree().get_nodes_in_group("item"):
		item.connect("clicked", _on_item_clicked)

func _on_character_clicked(character):
	if selected_character != null:
		selected_character.set_modulate(Color.WHITE)
		selected_character.selected = false
	selected_character = character
	selected_character.set_modulate(Color.RED)
	selected_character.selected = true
	characted_selected.emit(selected_character)
	_enable_items(true)
	character_state_charts_debug.debug_node(character)

func _on_character_finished_use(trait_result: Character.TraitResult):
	match trait_result:
		Character.TraitResult.GOOD:
			laugh_points += good_bonus
		Character.TraitResult.BAD:
			laugh_points += bad_bonus
	
	laught_points_changed.emit(laugh_points)

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
