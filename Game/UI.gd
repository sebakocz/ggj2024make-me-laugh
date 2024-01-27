extends CanvasLayer

@export var value_name: Label
@export var value_likes: Label
@export var value_hates: Label
@export var sprite: Sprite2D

func _ready():
	get_parent().characted_selected.connect(_on_character_selected)

func _on_character_selected(character: Character):
	value_name.text = character.name
	value_likes.text = Character.Trait.keys()[character.good_trait].to_lower()
	value_hates.text = Character.Trait.keys()[character.bad_trait].to_lower()
	sprite.texture = character.get_node("AnimatedSprite2D").sprite_frames.get_frame_texture("Idle", 0) # whack
	sprite.scale = Vector2(1.8, 1.8) # idk why the the sprite size explodes - this is a fix