extends AnimatedSprite2D

@export var damage : int

func _ready():
	play("charging")

func _on_laser_hitbox_body_entered(body):
	body.got_shot(damage,Vector2.ZERO)
	
func _on_animation_finished():
	play("shooting")

