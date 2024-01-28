extends Node

var move_by = 50

func animate_audience():
	var audience_members = get_children()
	for audience_member in audience_members:
		await get_tree().create_timer(.1).timeout
		var tween = create_tween()
		tween.tween_property(audience_member, "position:y", - move_by, .2).as_relative()
		tween.tween_property(audience_member, "position:y", move_by, .2).as_relative()

func _on_main_laught_points_changed(points: int):
	if points < 100:
		return
	animate_audience()
