extends AnimatedSprite2D

@export var seconds_till_death = 1.5

func _on_animation_finished():
	$Emoji.visible = true
	await get_tree().create_timer(seconds_till_death).timeout
	queue_free()

func initialize(trait_result: Character.TraitResult):
	var emoji = null
	match trait_result:
		Character.TraitResult.NEUTRAL:
			emoji = _get_random_emoji_from_path(_get_emojis_dir_path("Neutral"))
		Character.TraitResult.GOOD:
			emoji = _get_random_emoji_from_path(_get_emojis_dir_path("Good"))
		Character.TraitResult.BAD:
			emoji = _get_random_emoji_from_path(_get_emojis_dir_path("Bad"))
	
	if emoji != null:
		# res://Assets/Emojis/Neutral/38_face with raised eyebrow.png
		$Emoji.texture = load(emoji)
		$Emoji.visible = false
	else:
		queue_free()

func _get_emojis_dir_path(emoji_type: String) -> String:
	return "res://Assets/Emojis/" + emoji_type

func _get_random_emoji_from_path(path: String) -> String:
	var emoji_files = DirAccess.get_files_at(path)
	var random_index = randi() % emoji_files.size()
	return path + "/" + emoji_files[random_index].replace(".import", "")
