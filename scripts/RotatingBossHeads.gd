extends RigidBody2D

@export var radius_min : float
@export var radius_max : float
@export var radius_decrease : float
var radius_current : float

@export var num_of_rotations_ps : float
var speed
@export var lap_offset : float
var lap_progress : float

func _ready():
	radius_current = radius_max
	speed = num_of_rotations_ps * 2 *PI
	
func _process(delta):
	lap_progress += delta 
	
	if radius_current > radius_min:
		radius_current = radius_current - (radius_decrease*delta)
		
	lap_offset = (lap_offset *2 *PI) / speed
	
	look_at(get_global_mouse_position())
	
	position = Vector2(
		sin((lap_progress+lap_offset) * speed) * radius_current,
		cos((lap_progress+lap_offset) * speed) * radius_current
	)+ get_global_mouse_position()
