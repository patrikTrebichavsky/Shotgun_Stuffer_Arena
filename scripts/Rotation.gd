extends RigidBody2D

class_name CriticalParts

@export var rotations_per_sec = 1
@export var launch_speed = 1200
@export var launch_speed_variable = 200
@export var speed_damp = 0.85
@export var variable_launch_angle = 0.0
@export var fixed_launch_angle = 0.0

var launched = false

func _ready() -> void:
	rotations_per_sec = rotations_per_sec * 2 * PI
	variable_launch_angle = variable_launch_angle * PI / 180
	fixed_launch_angle = fixed_launch_angle * PI / 180
	
	
	
func _physics_process(delta: float) -> void:
	if	launched:
		rotation += rotations_per_sec*delta
		if rotation > 2*PI:
			rotation = 0

func _launch(launch_vector):

	var temp = position+(launch_speed-randf_range(-launch_speed_variable,launch_speed_variable))*(launch_vector.normalized())
	temp = temp.rotated(fixed_launch_angle)
	temp = temp.rotated(randf_range(-1*variable_launch_angle,variable_launch_angle))
	
	linear_damp = speed_damp
	
	linear_velocity = temp
	launched = true
	$BloodParticles.emitting = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
