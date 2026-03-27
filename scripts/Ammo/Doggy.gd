extends Bullet_Base

@export var bite_damage = 4 

var marked_enemy

var poop_node 

var direction_vector 
var start_point 

var body_reached = false
var poop_taken = false
var doggy_ready = true

func _ready() -> void:
	$BarkSprite.visible = false
	start_point = position
	
	
	
func _physics_process(delta: float) -> void: 
	
	if !doggy_ready:
		return
	
	if marked_enemy != null && !body_reached:
		direction_vector = (marked_enemy.position-global_position).normalized()
		linear_velocity = direction_vector * speed
		look_at(marked_enemy.position)
		
	elif poop_taken:
		direction_vector = (start_point-global_position).normalized()
		linear_velocity = direction_vector * speed
		look_at(start_point)
		
		if position >= start_point + Vector2(-20,-20) and  position <= start_point + Vector2(+20,+20):
			body_reached = false
			delete_bullet()


func _enemy_hit(body):
	
	var push_back = linear_velocity.normalized() * push_back_multiplier
	
		
	if !"Wall" in body.name:
		
		if marked_enemy == body && !poop_taken:
			
			if body == targeted_enemy:
				body.got_shot(bite_damage*2, push_back, false, true)
				get_tree().call_group("slots","incremement_value",bite_damage*2*slot_recharge_cut)
			else :
				body.got_shot(bite_damage, push_back, false, false)
				get_tree().call_group("slots","incremement_value",bite_damage*slot_recharge_cut)

				
			$BiteSound.random_pitch_play() 
			poop_node.call_deferred("queue_free")
			
			$PoopSprite.visible = true	
			body_reached = true
			linear_velocity = Vector2.ZERO
			await get_tree().create_timer(0.5).timeout
			poop_taken = true
		elif !marked_enemy == body:	
			if body == targeted_enemy:
				body.got_shot(damage*2, push_back, false, true)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(damage, push_back)
				$BumpSound.random_pitch_play()


func _poop_hit(area):
	
	var area_parent = area.get_parent() 
	
	if poop_node == area_parent && !poop_taken:
			
		$BiteSound.random_pitch_play() 
		poop_node.call_deferred("queue_free")
			
		$PoopSprite.visible = true	
		body_reached = true
		linear_velocity = Vector2.ZERO
		await get_tree().create_timer(0.5).timeout
		poop_taken = true


func delete_bullet():
	
	$DoggyAnimSprite.stop()
	$DoggyAnimSprite.visible = false
	$BarkTimer.stop()
	$PoopSprite.visible = false
	$BarkSprite.visible = false
	doggy_ready = false
	
	
	$Area2D.set_deferred("monitoring",false)
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _on_bark_timer_timeout() -> void:
	$BarkSound.random_pitch_play()
	$BarkSprite.visible = true


func _on_bark_sound_finished() -> void:
	$BarkSprite.visible = false
