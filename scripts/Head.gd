extends RigidBody2D

signal body_reached()

var start : Vector2
var destination : Vector2
var destination_reached : bool
var speed : float
@export var speed_initial : float
@export var speed_min : float
@export var speed_frame_change: float
@export var undertale_mode : bool


func _ready():
	speed = speed_initial
	var main_node = get_parent()
	main_node.switch_mode.connect(_switch_mode)
	
	if undertale_mode:
		$Sprite.animation = "undertale_head"
		
func _process(delta):
		
	if !destination_reached:
		if speed > speed_min:
			speed -= speed_frame_change*delta
		var target_position = (destination-global_position).normalized()
		linear_velocity = target_position * speed
		
		if position >= destination + Vector2(-20,-20) and  position <= destination + Vector2(+20,+20):
			destination_reached = true
	else:
		if speed < speed_initial:
			speed += speed_frame_change*delta
		var target_position = (start-global_position).normalized()
		linear_velocity = target_position * speed
		
		if position >= start + Vector2(-20,-20) and  position <= start + Vector2(+20,+20):
			emit_signal("body_reached")
			queue_free()

func _switch_mode(_name):
	
	undertale_mode = !undertale_mode

	if undertale_mode :
		$Sprite.animation = "undertale_head" 
		
	else:
		$Sprite.animation = "head_default" 
