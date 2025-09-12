extends AnimatedSprite2D

@export var damage : int
@export var slot_recharge_cut  = 0.1


func _ready():
	play("charging")
	
	
func _physics_process(delta):	
	for body in $Area2D.get_overlapping_bodies():
		if "Wall" in body.name:
			return
		
		var bodys_timer = body.get_node("LaserDamageTimer")
	
		if bodys_timer.is_stopped():
			body.got_shot(damage,Vector2.ZERO)
			get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)
			bodys_timer.start()


func edge_hit(body):
	
	if "Wall" in body.name:
		return
	
	var bodys_timer = body.get_node("LaserDamageTimer")
	
	if bodys_timer.is_stopped():
		body.got_shot(damage,Vector2.ZERO)
		bodys_timer.start()


func _on_animation_finished():
	play("shooting")
