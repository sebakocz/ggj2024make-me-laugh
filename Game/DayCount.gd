extends Label

@onready var audio = $AudioStreamPlayer

func _on_animated_sprite_2d_animation_looped():
	audio.play()
