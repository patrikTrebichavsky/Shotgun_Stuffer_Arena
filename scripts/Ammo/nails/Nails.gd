extends Bullet_Base

var sticked = load("res://scenes/Nails/NailsSticked.tscn")
var placed = load("res://scenes/Nails/NailsPlaced.tscn")

var target_position
var main

func _ready() -> void:
	main = get_parent()

func _physics_process(delta: float) -> void:
	
	if hitcount > 0:
		return
	
	if position >= target_position + Vector2(-20,-20) and  position <= target_position + Vector2(+20,+20):
		var temp = placed.instantiate()
		temp.position = position
		main.call_deferred("add_child",temp)
		
		hitcount += 1
		
		delete_bullet()
		
func _enemy_hit(body):
		
	if hitcount == 0:
		
		
		hitcount += 1
		$CollisionSound.random_pitch_play()
		$CollisionParticles.emitting = true
		$AnimatedSprite2D.visible = false
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		linear_velocity = Vector2.ZERO
		position = previous_position
		
		var temp
		
		if !"Wall" in body.name:
			
			temp = sticked.instantiate()
			body.get_node("AnimatedSprite2D").call_deferred("add_child",temp)
			temp.global_rotation = rotation
			temp.nailed_enemy = body
			temp.targeted_enemy = targeted_enemy
			temp.push_back = push_back
			
			if body == targeted_enemy:
				damage = damage*2
				body.got_shot(damage, push_back, false, true)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(damage, push_back)
			
		delete_bullet()
