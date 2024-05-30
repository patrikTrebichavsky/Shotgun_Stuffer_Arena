extends Bullet_Base


class_name Lamppost

@export var pierce_damage_threshold : int

func _ready():
	await get_tree().create_timer(0.1).timeout
	$Body.body_entered.disconnect(_on_edge_hit)
	$Body.body_entered.connect(_on_body_hit)
	
func _on_edge_hit(body):
	
	if "Wall" in body.name:
		linear_velocity = Vector2.ZERO
		$Edge.set_deferred("monitoring",false)
		$Body.set_deferred("monitoring",false)
		return
		
	hitcount += 1
	
	if hitcount <= 3 and body.hp <= pierce_damage_threshold:
		
		$StabSound.play()
		$CollisionParticles.emitting = true
		
		var impaled_enemy = get_node("ImpaledEnemySprite"+str(hitcount))
		var enemy_sprite_temp =  body.get_node("AnimatedSprite2D")
		impaled_enemy.global_rotation = enemy_sprite_temp.global_rotation
		if body.id == 2:
			impaled_enemy.animation = "jumper"
		elif body.id == 3:
			if body.has_head :
				impaled_enemy.animation = "thrower"
			else:
				impaled_enemy.animation = "thrower_headless"
		else:
			impaled_enemy.animation = "basic"
			
		
		var instance = load("res://scenes/TextPopUp.tscn").instantiate()
		add_child(instance)
		instance.position = impaled_enemy.position
		instance._display_message(str(pierce_damage_threshold*10), "#A4A5AE", 35)
		body.delete_enemy()

	
func _on_body_hit(body):
		
		if "Wall" in body.name:
			return
		
		$HitSound.play()
		var push_back = (body.position-position).normalized() * push_back_multiplier
		body.got_shot(damage, push_back)

func delete_bullet():
	
	$Edge.set_deferred("monitoring",false)
	$Body.set_deferred("monitoring",false)
	visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
