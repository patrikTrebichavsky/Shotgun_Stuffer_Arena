extends Node2D

@export var body_parts : Array[CriticalParts]
var launch_vector : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _launch_parts(num_of_heads = 2, num_of_arms = 4) -> void:
	
	if num_of_heads == 2:
		$HeadLeft.visible = false
		$HeadRight.visible = false

	var arm_count_diff = 4 - num_of_arms

	for value in arm_count_diff+1:
		match value:
			1:
				$SideLeftArm.visible = false
			2:
				$FrontLeftArm.visible = false
			3:
				$FrontRightArm.visible = false
			4:
				$SideRightArm.visible = false
	
			
	for part in body_parts:
		part._launch(launch_vector,0)
	
	
	

func _on_deletion_timer_timeout() -> void:
	queue_free()
