extends Area2D

var portal_visibility = false

func _process(delta):
	if !$RayCast2D.is_colliding() && portal_visibility:
		portal_visibility = false
	
	elif $RayCast2D.is_colliding() && !portal_visibility: 
		$Portal.visible = true
		$Portal/AnimationPlayer.play("Appearing")
		portal_visibility = true
		
	if $RayCast2D.is_colliding():
		$Portal/Timer.start(1.0)  
		
func _wall_altering_bullets(area):
	if area.name.contains("Car") or area.name.contains("House"):
		$Portal.visible = true
		$Portal/AnimationPlayer.play("Appearing")
		
