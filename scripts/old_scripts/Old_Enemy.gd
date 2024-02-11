extends CharacterBody2D

signal enemy_killed(xp)

@export var speed = 200.0
@export var hp = 3
@export var xp = 1

var player_position : Vector2 
var target_position




func _physics_process(delta):


	if hp <= 0:
		
		$Area2D/CollisionShape2D.disabled = true
		$Particles.emitting = true
		$AnimatedSprite2D.animation = "death"
		$DeathTimer.start()
		$DeathSound.play()
		
		emit_signal("enemy_killed", xp)
		set_physics_process(false)
		
	else:
		
		velocity = position.direction_to(player_position).normalized() * speed
		
		rotate(get_angle_to(player_position))
		move_and_slide()


func player_is_dead():
	$GruntTimer.stop()
	set_physics_process(false)


func delete_enemy():
	queue_free()


func got_shot(damage):
	hp -= damage


func update_player_position(position):
	player_position = position


func _on_grunt_timer_timeout():
	$GruntSound.play()


func _on_area_2d_body_entered(body):
	var damage = body.damage
	body._enemy_hit()
	got_shot(damage)
