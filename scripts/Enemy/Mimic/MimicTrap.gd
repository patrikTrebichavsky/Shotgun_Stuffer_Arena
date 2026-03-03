extends Node2D

@export var armed = true

func trap_activated(body: Node2D):

	if armed:
		armed = false
		
		var devoured_bodies = $DevouredArea.get_overlapping_bodies()
		
		for devoured_body in devoured_bodies:
			devoured_body.scripted_movement(true,false,position,0.15)
		
		$AnimationPlayer.play("Crunch")
