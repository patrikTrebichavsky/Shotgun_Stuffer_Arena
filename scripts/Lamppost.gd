extends Bullet_Base


class_name Lamppost

@export var pierce_damage_threshold : int

func _ready():
	
	await get_tree().create_timer(0.1).timeout
	$InitialEdge.set_deferred("monitoring",false)
	$Edge.set_deferred("monitoring",true)
	$Body.set_deferred("monitoring",true)
	
	
func _on_edge_hit(body):
	
	if "Wall" in body.name:
		linear_velocity = Vector2.ZERO
		$Edge.set_deferred("monitoring",false)
		$Body.set_deferred("monitoring",false)
		return
		
	hitcount += 1
	
	if hitcount <= 3 and (body.hp <= pierce_damage_threshold or (body.id == 20 and body.hp < (body.hp_max/4))):
		
		$StabSound.random_pitch_play()
		$CollisionParticles.emitting = true
		
		var impaled_enemy = $PiercedBodies.get_node("ImpaledEnemySprite"+str(hitcount))
		var enemy_sprite_temp =  body.get_node("AnimatedSprite2D")
		impaled_enemy.global_rotation = enemy_sprite_temp.global_rotation
		if body.id == 2:
			impaled_enemy.animation = "jumper"
		elif body.id == 3:
			if body.has_head :
				impaled_enemy.animation = "thrower"
			else:
				impaled_enemy.animation = "thrower_headless"
		elif body.id == 20:
			impaled_enemy.animation = "double_thrower"
		else:
			impaled_enemy.animation = "basic"
			
		
		var instance = load("res://scenes/TextPopUp.tscn").instantiate()
		add_child(instance)
		instance.global_position = impaled_enemy.global_position
		instance._display_message(str(pierce_damage_threshold*10), "#A4A5AE", 35)
		body._delete_enemy()
	
func _on_body_hit(body):
		
		if "Wall" in body.name:
			return
		
		$HitSound.random_pitch_play()
		
		var push_back = (body.position-position).normalized() * push_back_multiplier
		body.got_shot(damage, push_back)

func delete_bullet():
	
	$Edge.set_deferred("monitoring",false)
	$Body.set_deferred("monitoring",false)
	visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
