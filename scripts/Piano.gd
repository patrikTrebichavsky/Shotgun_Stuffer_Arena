extends Bullet_Base

class_name Piano

signal switch_mode(_name)


@export var turn : float 
@export var num_of_notes : int
var num_of_wall_bounces : int
@export var max_wall_bounces : int
func _ready():
	var main_node = get_parent()
	
	switch_mode.connect(main_node._switch_mode)

func _enemy_hit(body):

	
	if "Wall" in body.name:
		if "Outer" in body.name:
			#var ricoched_angle = global_transform.origin.direction_to(body.global_transform.origin)
			linear_velocity = linear_velocity*(-1)
			linear_velocity = linear_velocity.rotated(randf_range(0,0.7))
			look_at(position+linear_velocity)
		else:
			var ricoched_angle = global_transform.origin.direction_to(body.global_transform.origin)
			linear_velocity = ricoched_angle*speed*-1
			look_at(position+linear_velocity)
		$CollisionParticles.emitting = true
		$WallCollisionSound.play()
		num_of_wall_bounces += 1
			
		if num_of_wall_bounces < max_wall_bounces:
			return
		else:
			hitcount += 1
			if hitcount >num_of_notes:
				$BreakParticles.emitting = true
				$AnimatedSprite2D.visible = false
				$BreakingSound.play()
				$Area2D.set_deferred("monitoring",false)
				set_deferred("freeze",true)
			return
			
		
	
	hitcount += 1
	 
	if hitcount <= num_of_notes:
		
		$CollisionParticles.emitting = true
		
		if hitcount > 1:
			get_node("CollisionSound"+str(hitcount/2)).play()	
			
		var push_back = linear_velocity.normalized() * push_back_multiplier
		body.got_shot(damage, push_back)
		
		$Area2D.rotation += turn
		$AnimatedSprite2D.rotation += turn
		
		linear_velocity = linear_velocity.rotated(turn)
	
	if hitcount == num_of_notes:
		
		emit_signal("switch_mode", "This is place holder for future modes")
		
		$BreakParticles.emitting = true
		$AnimatedSprite2D.visible = false
		$BreakingSound.play()
		$Area2D.set_deferred("monitoring",false)
		set_deferred("freeze",true)
