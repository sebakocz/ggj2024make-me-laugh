extends Sprite2D

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "modulate:a", .2, .4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, .4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
