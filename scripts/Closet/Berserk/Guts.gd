extends RigidBody2D

func _ready() -> void:
	
	
	$AirParticles.emitting = false
	
	await get_tree().create_timer(5).timeout
	
	$AnimationPlayer.play("Overhead")
	
