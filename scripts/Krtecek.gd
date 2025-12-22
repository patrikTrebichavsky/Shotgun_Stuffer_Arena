extends RigidBody2D

@export var speed = 100

func _ready() -> void:
	
	$ScreamSound.play()
	
	linear_velocity = speed * Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	look_at(position+linear_velocity)

func _delete() -> void:
	queue_free()
