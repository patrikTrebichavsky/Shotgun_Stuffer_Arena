extends Bullet_Base

class_name House

#var hitting_edge_wall = false
#
#func _process(delta):
	#if $RayCast2D.is_colliding() && hitting_edge_wall == false:
		#hitting_edge_wall = true
		#var temp = load("res://scenes/Portal.tscn").instantiate()
		#var main_node = get_parent()
		#main_node.add_child(temp)
		#temp.position = $RayCast2D.get_collision_point()
		#
		#var temp_rot = abs(rotation)
		#if temp_rot > 360:
			#temp_rot -= 360W
		#
		#
		#if temp_rot < 45:
			#temp.rotation += 0
		#elif temp_rot < 135:
			#temp.rotation += 90
		#elif temp_rot < 225:
			#temp.rotation += 180
		#elif temp_rot < 315:
			#temp.rotation += 270
		#else :
			#temp.rotation = 0
			#
func _enemy_hit(body):
	
		if body.name.contains("Outer"):
			return
	
		var temp = body.get_node("AnimatedSprite2D")
		
		var push_back = Vector2.ZERO
		
		if body.name.contains("Wall"):
			body.cracked()
			$CollisionSound.random_pitch_play()		
			return
				
		#if body == targeted_enemy:
			#body.got_shot(damage*2, push_back, false, true)
			#$CriticalSound.random_pitch_play()
		#else:
		body.got_shot(damage, push_back)
		
		temp.animation = "crushed"
		
		if !$AnimationPlayer.is_playing() :
			
			$CollisionParticles.position.y = randi_range(-180,180)
			
			$CollisionSound.random_pitch_play()		
			$AnimationPlayer.play("house_shake")
			$CollisionParticles.emitting = true

	
func delete_bullet():
	
	$HouseArea.set_deferred("monitoring",false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
