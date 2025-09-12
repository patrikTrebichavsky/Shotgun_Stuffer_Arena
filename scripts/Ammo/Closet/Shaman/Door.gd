extends Sprite2D

@export var damage = 1
@export var push_back_multiplier = 10
@export var slot_recharge_cut = 0.1

func _enemy_hit(body):

		if !"Wall" in body.name:
			body.got_shot(damage, (body.position-global_position).normalized() * push_back_multiplier)
			$CollisionSound.random_pitch_play()
			get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)

func enable():

	visible = true
	$Area2D.monitoring = true
	
	
func disable():

	visible = false
	$Area2D.monitoring = false
