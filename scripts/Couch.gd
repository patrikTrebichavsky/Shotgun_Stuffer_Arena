extends Bullet_Base

@export var steer_force = 50.0

var vel = Vector2.ZERO
var acceleration = Vector2.ZERO
var destination : Vector2
var no_target = true
var mouse_placement
var target = null
var array_of_bodies = []

func _ready():
	
	mouse_placement = get_global_mouse_position()
	vel = transform.x * speed

	for body in array_of_bodies:
	
		if body.name.contains("Wall"):
			continue			
		if target == null:
			target = body
			no_target = false
			$MarkerSprite2D.visible = true
			linear_velocity = Vector2.ZERO
		elif (target.global_position-mouse_placement).length() > (body.global_position-mouse_placement).length():
			target = body
		
		body.stop_homming.connect(target_died)
		
	
func seek():
	var steer = Vector2.ZERO
	if target != null:
		var desired = (target.global_position - position).normalized() * speed	
		steer = (desired - vel).normalized() * steer_force
	return steer
	
func _process(delta):
		
	if !no_target and hitcount == 0:
			$MarkerSprite2D.global_position = target.global_position
			acceleration += seek()
			vel += acceleration * delta
			vel = vel.limit_length(speed)
			rotation = vel.angle()
			position += vel * delta
			
func _enemy_hit(body):
	
	if no_target or body == target:
		if hitcount == 0:

			$MarkerSprite2D.visible = false
			hitcount += 1
			$CollisionSound.random_pitch_play()
			$CollisionParticles.emitting = true
			$AnimatedSprite2D.visible = false
			
			var push_back = linear_velocity.normalized() * push_back_multiplier
			if !"Wall" in body.name:
				if body == targeted_enemy:
					damage = damage*2
					body.got_shot(damage, push_back, false, true)
					$CriticalSound.random_pitch_play()
				else:
					body.got_shot(damage, push_back)
			
			
func target_died():
	no_target = true
	apply_central_impulse(Vector2.RIGHT.rotated(rotation)*speed)
	$MarkerSprite2D.visible = false
 
