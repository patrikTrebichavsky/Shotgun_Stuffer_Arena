extends RigidBody2D

var targeted_enemy 

@export var push_back_multiplier : float
@export var damage : int
@export var slot_recharge_cut = 0.1


func Bomboclat() -> void:
	
	for body in $Thunder.get_overlapping_bodies():
	
		if "Wall" in body.name:
			continue
			
		if body == targeted_enemy:
			var push_back = (body.position-self.position).normalized() * push_back_multiplier
			body.got_conditioned(damage*2,push_back,false,true,"bomboclat")
			get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)

		else:
			body.got_conditioned(damage,Vector2.ZERO,true,false,"bomboclat")
			get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)

		body.flash()

func delete():
	queue_free()
	
