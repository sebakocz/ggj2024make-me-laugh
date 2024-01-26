extends CharacterBody2D

@export var target: Node2D

@export var speed: float = 100

@export var min_distance: float = 10

@onready var nav = $NavigationAgent2D

func _ready():
	nav.target_position = target.global_position

func _physics_process(_delta):
	var direction = nav.get_next_path_position() - global_position

	if direction.length() < min_distance:
		return

	direction = direction.normalized()

	velocity = direction * speed

	move_and_slide()