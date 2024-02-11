extends Bullet_Base

class_name House


func _enemy_hit(body):
	
	
		#$CollisionSound.play()
		
		var push_back = Vector2.ZERO
		
		
		var temp = body.get_node("AnimatedSprite2D")
		
		temp.animation = "crushed"
		
		body.got_shot(damage, push_back, true)
		
		if !$AnimationPlayer.is_playing() :
			
			$CollisionParticles.position.y = randi_range(-180,180)
			
			$CollisionSound.play()
			$AnimationPlayer.play("house_shake")
			$CollisionParticles.emitting = true
