extends Node2D

var selected_character: Character = null

func _ready():
	for character in get_tree().get_nodes_in_group("character"):
		character.connect("clicked", _on_character_clicked)
	
	for item in get_tree().get_nodes_in_group("item"):
		item.connect("clicked", _on_item_clicked)

func _on_character_clicked(character):
	if selected_character != null:
		selected_character.set_modulate(Color.WHITE)
		selected_character.selected = false
	selected_character = character
	selected_character.set_modulate(Color.RED)
	selected_character.selected = true
	_enable_items(true)

func _on_item_clicked(item):
	selected_character.set_item(item)
	_enable_items(false)

func _enable_items(enable: bool):
	for item in get_tree().get_nodes_in_group("item"):
		item.set_clickable(enable)