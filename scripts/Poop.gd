extends Bullet_Base

var doggy_path = load("res://scenes/Doggy.tscn")
var poop_path = load("res://scenes/PoopSticked.tscn")

func _enemy_hit(body):
	
		
	if hitcount == 0:
		
		hitcount += 1
		$CollisionSound.random_pitch_play()
		$CollisionParticles.emitting = true
		$AnimatedSprite2D.visible = false
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		linear_velocity = Vector2.ZERO
		position= previous_position
		
		if !"Wall" in body.name:
			var temp_poop 
			var temp_doggy		
			var main = get_parent()
			
			temp_poop = poop_path.instantiate()
			body.get_node("AnimatedSprite2D").call_deferred("add_child",temp_poop)
			temp_poop.global_rotation = rotation
			
			temp_doggy = doggy_path.instantiate()
			main.call_deferred("add_child",temp_doggy)
			temp_doggy.targeted_enemy = targeted_enemy
			temp_doggy.marked_enemy = body
			temp_doggy.poop_node = temp_poop
			temp_doggy.position = position
			
			if body.position.x < position.x:
				temp_doggy.position.x = temp_doggy.position.x - (DisplayServer.window_get_size().x/2)-400
			else:
				temp_doggy.position.x = temp_doggy.position.x + (DisplayServer.window_get_size().x/2)+400
						
		delete_bullet()
