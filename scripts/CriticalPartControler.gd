extends Node2D


@export var body_parts : Array[CriticalParts]
var launch_vector : Vector2
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _launch_parts(enemy_id = 1, has_head = true) -> void:
	
	if enemy_id == 2:
		$Body/Sprite.animation = "jumper"
		$LeftArm/Sprite.animation = "jumper"
		$RightArm/Sprite.animation = "jumper"
		$Head/Sprite.animation = "jumper"
		
	if enemy_id == 3:
		$Body/Sprite.animation = "thrower"
		$LeftArm/Sprite.animation = "thrower"
		$RightArm/Sprite.animation = "thrower"
		if has_head == false:
			$Head.visible = false
		else:
			$Head/Sprite.animation = "thrower"
			
	for part in body_parts:
		part._launch(launch_vector)


func _on_deletion_timer_timeout() -> void:
	queue_free()
