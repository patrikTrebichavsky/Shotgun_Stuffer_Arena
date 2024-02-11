extends RigidBody2D

class_name Bullet_Base

@export var damage = 1
@export var tracking = false
@export var push_back_multiplier = 10
@export var speed = 1500

var hitcount 

func _init():
	hitcount = 0

func _enemy_hit(body):
	
	
	if hitcount == 0:
		
		hitcount += 1
		$CollisionSound.play()
		$CollisionParticles.emitting = true
		$AnimatedSprite2D.visible = false
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		body.got_shot(damage, push_back)

	
func delete_bullet():
	
	$Area2D.set_deferred("monitoring",false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
