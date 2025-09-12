extends Bullet_Base

@export var bullet_damage = 3
var reverse_velocity_vector : Vector2
	
func _enemy_hit(body):
	
	if hitcount == 0:
		
		hitcount += 1
		
		$CollisionSound.random_pitch_play()
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		reverse_velocity_vector = linear_velocity.normalized()*-1
		linear_velocity = Vector2.ZERO
		position= previous_position
		
		if !"Wall" in body.name:
			if body == targeted_enemy:
				damage = damage*2
				body.got_shot(damage, push_back, false, true)
				$CriticalSound.random_pitch_play()
				_fire(true)
			else:
				body.got_shot(damage, push_back)
				_fire(false)
			
			
	
func _fire(critical_hit):
	
	$BottomBarrelMuzzleParticles.emitting = true
	$TopBarrelMuzzleParticles.emitting = true
	$BulletParticles.emitting = true
	$ShootSound.play()
	
	var push_back
	
	for body in $Bullets.get_overlapping_bodies():
	
		if !"Wall" in body.name:
			
			push_back = ((body.position-position).normalized()) * push_back_multiplier
			
			if critical_hit:
				body.got_shot(bullet_damage*2, push_back, false, critical_hit)
				get_tree().call_group("slots","incremement_value",bullet_damage*2*slot_recharge_cut)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(bullet_damage, push_back)
				get_tree().call_group("slots","incremement_value",bullet_damage*slot_recharge_cut)

		
		linear_velocity = reverse_velocity_vector*(speed/2)
		var tweener = create_tween()
		tweener.tween_property($AnimatedSprite2D,"rotation",8*PI,2)
	
	$MuzzleFlash.enabled = true
	await get_tree().create_timer(0.1).timeout
	$MuzzleFlash.enabled = false
		
func delete_bullet():
	
	$Shotgun.set_deferred("monitoring",false)
	$Bullets.set_deferred("monitoring",false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
