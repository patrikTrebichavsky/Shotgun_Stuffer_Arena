extends RigidBody2D

class_name CriticalParts

@export_category("Rotation per second")
@export var rps = 1
@export var variable_rps_min = 0.25
@export var variable_rps_max = 0.5
@export var rotation_duration = 2

@export_category("Launch Speed")
@export var part_speed_mult = 1200.0
@export var part_speed_mult_var = 200.0
@export var explosion_boost = 2
var rps_max
@export_category("Damping")
@export var speed_damp = 1

@export_category("Angle")
@export var variable_launch_angle = 0.0
@export var fixed_launch_angle = 0.0

var launched = false

func _ready() -> void:
	rps = (rps + randf_range(variable_rps_min,variable_rps_max)) * 2 * PI
	variable_launch_angle = variable_launch_angle * PI / 180
	fixed_launch_angle = fixed_launch_angle * PI / 180
	
	rps_max = rps
	
func _physics_process(delta: float) -> void:
	if	launched:
		rotation += rps*delta
		if rotation > 2*PI:
			rotation = 0
		
		if rps > 0:
			rps -= (rps_max/rotation_duration)*delta
			

func _launch(launch_vector, enemy_id = 1, cond_type = "none"):
		
	#EnemyID is set to 0 in case of double thrower because he has only one animation 
		
	if cond_type == "explosion" or cond_type == "electrocute" :
		$Sprite.animation = "burned"
	elif enemy_id == 1:
		$Sprite.animation = "basic"
	elif enemy_id == 2:
		$Sprite.animation = "jumper"
	elif enemy_id == 3:
		$Sprite.animation = "thrower"
	elif enemy_id == 10:
		$Sprite.animation = "smasher"

	var temp = position+(part_speed_mult-randf_range(-part_speed_mult_var,part_speed_mult_var))*(launch_vector)
	
	if cond_type == "explosion":
		temp = temp * explosion_boost
	
	temp = temp.rotated(fixed_launch_angle)
	temp = temp.rotated(randf_range(-1*variable_launch_angle,variable_launch_angle))
	
	linear_damp = speed_damp
	
	linear_velocity = temp
	launched = true
	$BloodParticles.emitting = true
	
	await get_tree().create_timer(0.5).timeout
	z_index = 11
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
