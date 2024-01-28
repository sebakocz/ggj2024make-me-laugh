extends Node

var move_by = 50

func _ready():
	_shuffle_audience()
	animate_audience()

func _shuffle_audience():
	var audience_members = get_children()
	# swap audience members randomly
	for person in audience_members:
		var random_person = audience_members[randi() % audience_members.size()]
		var person_pos = person.position
		var random_person_pos = random_person.position
		person.position = random_person_pos
		random_person.position = person_pos
		person.z_index = person.position.y
		random_person.z_index = random_person.position.y

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
