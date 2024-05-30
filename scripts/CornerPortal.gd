extends Portal

class_name Corner_Portal

func _init():
	visible = false
	should_be_hidden = true
	
func _process(delta):

	if visible == false && ($RayCast2D.is_colliding() || $RayCast2D2.is_colliding()) :
		should_be_hidden = false
		visible = true
		call_deferred("reset")

		$AnimatedSprite2D/AnimationPlayer.play("Appear")
		$AppearingAudio.play()
	
	elif $RayCast2D.is_colliding() || $RayCast2D2.is_colliding():
		call_deferred("reset")
		
	if visible:	
		if previous_portal.visible == true && next_portal.visible == true:
			$AnimatedSprite2D.animation = "Open"
			previous_portal.neighbour_portal_opened()
			next_portal.neighbour_portal_opened()
			
		elif previous_portal.visible == true:
			$AnimatedSprite2D.animation = "NextClosed"
			previous_portal.neighbour_portal_opened()
				
		elif next_portal.visible == true:
			$AnimatedSprite2D.animation = "PreviousClosed"
			next_portal.neighbour_portal_opened()
				
		else:
			$AnimatedSprite2D.animation = "Closed"


func disapear():	
	should_be_hidden = true
	
	$AnimatedSprite2D/AnimationPlayer.play("Dissappear")	
	
	if previous_portal.should_be_hidden == false && next_portal.should_be_hidden == false:
		previous_portal.neighbour_portal_opened()
		next_portal.neighbour_portal_opened()
		
	elif previous_portal.should_be_hidden == false:
		previous_portal.neighbour_portal_opened()
		
	elif next_portal.should_be_hidden == false:
		next_portal.neighbour_portal_opened()
		
	await $AnimatedSprite2D/AnimationPlayer.animation_finished
	visible = false
	connection_order = 1
	
func neighbour_portal_opened():
	
	if visible == false:
		if previous_portal.visible == true && next_portal.visible == true:
			$AnimatedSprite2D.animation = "Open"			
			
		elif previous_portal.visible == true:
			$AnimatedSprite2D.animation = "NextClosed"
			
		elif next_portal.visible == true:
			$AnimatedSprite2D.animation = "PreviousClosed"
			
		else:
			$AnimatedSprite2D.animation= "Closed"
			
func reset():
	
	match connection_order:
		0:
			if next_portal.visible:
				if next_portal.get_node("AnimatedSprite2D/Timer").time_left < 0.48:
					next_portal.connection_order = 0
					next_portal.reset()
		1:
			if next_portal.visible:
				if next_portal.get_node("AnimatedSprite2D/Timer").time_left < 0.48:
					next_portal.connection_order = 0
					next_portal.reset()
			if previous_portal.visible:	
				if previous_portal.get_node("AnimatedSprite2D/Timer").time_left < 0.48:
					previous_portal.reset()
					previous_portal.connection_order = 2
		2:
			if previous_portal.visible:	
				if previous_portal.get_node("AnimatedSprite2D/Timer").time_left < 0.48:
					previous_portal.reset()
					previous_portal.connection_order = 2
					
	$AnimatedSprite2D/Timer.start()	
