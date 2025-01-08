extends Node2D


@export var body_parts : Array[CriticalParts]
var launch_vector : Vector2
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _launch_parts() -> void:
	for part in body_parts:
		print(launch_vector)
		part._launch(launch_vector)


func _on_deletion_timer_timeout() -> void:
	queue_free()
