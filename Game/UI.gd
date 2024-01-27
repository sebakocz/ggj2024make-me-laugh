extends CanvasLayer

@export var value_name: Label
@export var value_likes: Label
@export var value_hates: Label
@export var sprite: Sprite2D

@onready var laugh_bar = $LaughBar

func _ready():
	get_parent().characted_selected.connect(_on_character_selected)

func _on_character_selected(character: Character):
	if character == null:
		value_name.text = ""
		value_likes.text = ""
		value_hates.text = ""
		sprite.texture = null
		return

	value_name.text = character.name
	value_likes.text = Character.Trait.keys()[character.good_trait].to_lower()
	value_hates.text = Character.Trait.keys()[character.bad_trait].to_lower()
	sprite.texture = character.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("Idle", 0) # whack
	sprite.scale = Vector2(1.8, 1.8) # idk why the the sprite size explodes - this is a fix

func _on_main_laught_points_changed(points):
	if points == 0:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(laugh_bar, "value", points, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var increase_by = .3
	var smiley = laugh_bar.get_node("Smiley")
	tween.tween_property(smiley, "scale", Vector2(smiley.scale.x + increase_by, smiley.scale.y + increase_by), .3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(smiley, "scale", Vector2(smiley.scale.x - increase_by, smiley.scale.y - increase_by), .3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	