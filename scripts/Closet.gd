extends Bullet_Base

var berserk_path = load("res://scenes/Closet/Berserk/Guts.tscn")
var bomboclat_path = load("res://scenes/Doggy.tscn")
var shaman_path = load("res://scenes/Doggy.tscn")
var ignore_wall = true

func _ready() -> void:
	
	check_crosshair()
	
	await get_tree().create_timer(0.25).timeout
	ignore_wall = false

func _enemy_hit(body):
	
	if ignore_wall and "Wall" in body.name:
		return
		
	if hitcount == 0:
		
		hitcount += 1
		$CollisionSound.random_pitch_play()
		
		if !"Wall" in body.name:
			$CollisionParticles.global_position = body.position
		
		$CollisionParticles.emitting = true
		$AnimatedSprite2D.visible = false
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		linear_velocity = Vector2.ZERO
		position= previous_position
		
		var temp
		var main = get_parent()
		
		match $AnimatedSprite2D.animation:
			"Berserk":
				temp = berserk_path.instantiate()
				temp.player = main.get_node("Player")
			"Shaman":
				temp = shaman_path.instantiate()
			"Bomboclat":
				temp = bomboclat_path.instantiate()
				
		main.call_deferred("add_child", temp)
		temp.position = position
		
		if !"Wall" in body.name:
			if body == targeted_enemy:
				damage = damage*2
				body.got_shot(damage, push_back, false, true)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(damage, push_back)

			
		
		delete_bullet()
