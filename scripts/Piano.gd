extends Bullet_Base

class_name Piano

signal switch_mode(_name)

@export var turn : float 
@export var num_of_notes : int
	
func _ready():
	var main_node = get_parent()
	
	switch_mode.connect(main_node._switch_mode)

func _enemy_hit(body):
	
	hitcount += 1
	 
	if hitcount <= num_of_notes:
		
		$CollisionParticles.emitting = true
		
		get_node("CollisionSound"+str(hitcount)).play()	
		$BreakingSound.play()
			
		var push_back = linear_velocity.normalized() * push_back_multiplier
		body.got_shot(damage, push_back)
		
		$Area2D.rotation += turn
		$AnimatedSprite2D.rotation += turn
		
		linear_velocity = linear_velocity.rotated(turn)
	
	if hitcount == num_of_notes:
		
		emit_signal("switch_mode", "This is place holder for future modes")
		
		$BreakParticles.emitting = true
		$AnimatedSprite2D.visible = false
