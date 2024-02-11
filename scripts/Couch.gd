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
	
	if array_of_bodies.size() > 0: 
		linear_velocity = Vector2.ZERO

		for body in array_of_bodies:
			
			if target == null:
				target = body
				
			elif (target.global_position-mouse_placement).length() > (body.global_position-mouse_placement).length():
				target = body
				
		no_target = false
		
		
func seek():
	var steer = Vector2.ZERO
	if target != null:
		var desired = (target.global_position - position).normalized() * speed	
		steer = (desired - vel).normalized() * steer_force
	return steer
	
func _process(delta):
	
	
	if !no_target:
		#position = destination
		acceleration += seek()
		vel += acceleration * delta
		vel = vel.limit_length(speed)
		rotation = vel.angle()
		position += vel * delta
	
	
func _enemy_hit(body):
	
	if no_target or body == target:
		if hitcount == 0:
			
			hitcount += 1
			$CollisionSound.play()
			$CollisionParticles.emitting = true
			$AnimatedSprite2D.visible = false
			
			var push_back = linear_velocity.normalized() * push_back_multiplier
			body.got_shot(damage, push_back)
		
