extends Node2D


@export var body_parts : Array[CriticalParts]
var launch_vector : Vector2
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _launch_parts() -> void:
	for part in body_parts:
		part._launch(launch_vector)
