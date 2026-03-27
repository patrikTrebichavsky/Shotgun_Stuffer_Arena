extends Bullet_Base
	
@export var electrocute_dmg = 1
@export var utility_pole_pierced = load("res://scenes/UtilityPolePierced.tscn")
func _ready():
	
	await get_tree().create_timer(0.1).timeout
	$InitialEdge.set_deferred("monitoring",false)
	$Edge.set_deferred("monitoring",true)
	$Body.set_deferred("monitoring",true)

func _on_edge_hit(body):
	
	
	if hitcount == 0:
	
		hitcount += 1
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		linear_velocity = Vector2.ZERO
		$Edge.set_deferred("monitoring",false)
		$Body.set_deferred("monitoring",false)
		
		if !"Wall" in body.name:
			if body == targeted_enemy:
				body.got_shot(damage*2, push_back, false, true, true)
				get_tree().call_group("slots","incremement_value",damage*2*slot_recharge_cut)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(damage, push_back, false, false, true)
				get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)
			
			#Root node doesnt rotate so we need to call Animation sprite which rotates
			var temp = utility_pole_pierced.instantiate()
			var body_anim = body.get_node("AnimatedSprite2D")
			
			body_anim.call_deferred("add_child",temp)
			temp.targeted_enemy = targeted_enemy
			temp.pierced_enemy = body
			$DeletionTimer.stop()
			
			if body.hp <= 0 :
				var body_timer = body.get_node("DeathTimer")
				
				body_timer.stop()
				body_timer.start($DeletionTimer.wait_time)
			else:
				var pierced_timer = temp.get_node("DeletionTimer")
			
				pierced_timer.call_deferred("start",$DeletionTimer.wait_time)
				
			queue_free()
			 	
			



func _on_animated_sprite_2d_frame_changed() -> void:
	match $AnimatedSprite2D.frame:
		0:
			$AnimatedSprite2D/ElectricPulse.self_modulate = Color("ffffff00")
		2:
			$PulseSound.random_pitch_play()
			$AnimatedSprite2D/ElectricPulse.self_modulate = Color("ffffff")
			$AnimatedSprite2D/CabelParticlesRight.emitting =  true
			$AnimatedSprite2D/CabelParticlesLeft.emitting =  true
			
			for body in $Electricity.get_overlapping_bodies():
				
				if "Wall" in body.name:
					continue
					
				if body == targeted_enemy:
					var push_back = (body.position-self.position).normalized() * push_back_multiplier
					body.got_conditioned(electrocute_dmg*2,push_back,false,true,"electrocute")
				else:
					body.got_conditioned(electrocute_dmg,Vector2.ZERO,true,false,"electrocute")
				
				body.flash()
		3:
			$AnimatedSprite2D/ElectricPulse.self_modulate = Color("ffffffA0")

func delete_bullet():
	
	$Edge.set_deferred("monitoring",false)
	$Body.set_deferred("monitoring",false)
	$Electricity.set_deferred("monitoring",false)
	visible = false
	$AnimatedSprite2D.stop()
	await get_tree().create_timer(1.0).timeout
	queue_free()
