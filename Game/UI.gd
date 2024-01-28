extends CanvasLayer

@export var star_count_label: Label
@export var money_label: Label
@export var day_label: Label
@export var shop: Node
@export var cast: Node

@onready var laugh_bar = $LaughBar
@onready var smiley = %Smiley

signal trying_to_buy_item(itemName: String)
signal trying_to_buy_character(characterIndex: int)

# func _on_character_selected(character: Character):
# 	if character == null:
# 		value_name.text = ""
# 		value_likes.text = ""
# 		value_hates.text = ""
# 		sprite.texture = null
# 		info_panel.visible = false
# 		return

# 	info_panel.visible = true
# 	value_name.text = character.name
# 	value_likes.text = Character.Trait.keys()[character.good_trait].to_lower()
# 	value_hates.text = Character.Trait.keys()[character.bad_trait].to_lower()
# 	sprite.texture = character.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("Idle", 0) # whack
# 	sprite.scale = Vector2(1.8, 1.8) # idk why the the sprite size explodes - this is a fix

func _on_main_laught_points_changed(points):
	var tween = get_tree().create_tween()
	tween.tween_property(laugh_bar, "value", points, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	smiley.get_node("AnimationPlayer").play("Smiley_Impulse")

func _update_star_count_label(count: int):
	star_count_label.visible = count > 0
	star_count_label.text = "x" + str(count)
	var anim = star_count_label.get_node("AnimationPlayer")
	anim.play("Bump")
	await get_tree().create_timer(anim.current_animation_length).timeout
	anim.play("Pulse")

func _on_main_laught_stars_changed(stars: int):
	_update_star_count_label(stars)

func _on_cooking_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Cooking")

func _on_gardening_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Gardening")

func _on_guitar_gui_input(event):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Guitar")

func _on_painting_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Painting")
		
func _on_karaoke_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Karaoke")

func _on_reading_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		trying_to_buy_item.emit("Reading")

func _on_main_money_changed(money: int):
	money_label.text = "$" + str(money)
	var anim = money_label.get_node("AnimationPlayer")
	anim.play("Bump")

func _on_main_day_changed(day: int):
	day_label.text = "Day " + str(day)
	var anim = day_label.get_node("AnimationPlayer")
	anim.play("Bump")

func _on_main_bought_item(item):
	# find the item in the shop
	var item_node = shop.get_node(item)
	# transparent tween
	var tween = create_tween()
	tween.tween_property(item_node, "modulate:a", 0, .6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	item_node.queue_free()

func _on_main_characters_changed(characters: Array):
	_update_character_info(characters)

func _update_character_info(characters: Array):
	# update cast info
	for i in range(characters.size()):
		var character = characters[i]
		var cast_character = cast.get_child(i)
		var stress_string = ""
		for j in range(character.stress_level):
			stress_string += "- "
		cast_character.get_node("GridContainer").get_node("Name_Value").text = character.name
		var current_stress_string = cast_character.get_node("GridContainer").get_node("Stress_Value").text
		if current_stress_string.length() > stress_string.length():
			# red feedback
			var tween = create_tween()
			tween.tween_property(cast_character, "modulate", Color.GREEN, .15)
			tween.tween_property(cast_character, "modulate", Color.WHITE, .15)
			pass
		elif current_stress_string.length() < stress_string.length():
			# green feedback
			var tween = create_tween()
			tween.tween_property(cast_character, "modulate", Color.RED, .15)
			tween.tween_property(cast_character, "modulate", Color.WHITE, .15)
			pass
		cast_character.get_node("GridContainer").get_node("Stress_Value").text = stress_string
		cast_character.get_node("GridContainer").get_node("Likes_Value").text = Character.Trait.keys()[character.good_trait].to_lower()
		cast_character.get_node("GridContainer").get_node("Hates_Value").text = Character.Trait.keys()[character.bad_trait].to_lower()
		cast_character.get_node("Sprite2D").texture = character.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("Idle", 0) # whack
		cast_character.get_node("Sprite2D").scale = Vector2(1.8, 1.8) # idk why the the sprite size explodes - this is a fix

func _on_character_1_gui_input(event):
	if event is InputEventMouseButton:
		trying_to_buy_character.emit(0)

func _on_character_2_gui_input(event):
	if event is InputEventMouseButton:
		trying_to_buy_character.emit(1)

func _on_character_3_gui_input(event):
	if event is InputEventMouseButton:
		trying_to_buy_character.emit(2)