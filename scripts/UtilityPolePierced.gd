extends Node2D

@export var electrocute_dmg = 1
@export var push_back_multiplier = 50

var targeted_enemy
var pierced_enemy

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
				
				if body == pierced_enemy && body.hp <= 0:
					var body_timer = body.get_node("DeathTimer")
					
					$DeletionTimer.stop()
					
					body_timer.stop()
					body_timer.start($DeletionTimer.wait_time)
				
				body.flash()
			pierced_enemy.flash()
		3:
			$AnimatedSprite2D/ElectricPulse.self_modulate = Color("ffffffA0")

func delete_bullet():
	
	$Electricity.set_deferred("monitoring",false)
	visible = false
	$AnimatedSprite2D.stop()
	await get_tree().create_timer(1.0).timeout
	queue_free()
