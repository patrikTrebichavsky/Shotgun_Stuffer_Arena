extends RigidBody2D

signal destination_reached_signal()
signal body_reached()

var player_position : Vector2
var circle_center : Vector2

var phase_one = true

var start : Vector2
var destination : Vector2
var chase = true
var destination_reached : bool
var limb_in_tween : bool
var speed : float

@export var speed_initial : float
@export var speed_min : float
@export var speed_frame_change: float
@export var undertale_mode : bool

@export_category("Second Phase head settings")

var player_in_boundries = true

@export var radius_min : float
@export var radius_max : float
@export var radius_decrease : float
var radius_current : float

@export var num_of_rotations_ps : float
var rotation_speed : float
@export var lap_offset : float
var lap_progress : float

func _ready():
	visible = false
	
	var main_node = get_parent()
	main_node.switch_mode.connect(_switch_mode)
	
	var player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	
	
	if undertale_mode:
		$Sprite.animation = "undertale_head"

func _integrate_forces(state: PhysicsDirectBodyState2D):
		
		if limb_in_tween :
			return
		
		var target_position : Vector2
		
		if phase_one:
			
			if chase:
				target_position = (destination-global_position).normalized()
		
			else:
				target_position = (start-global_position).normalized()
				
			linear_velocity = target_position * speed
			
			
		
		 
func _physics_process(delta):
	
	if limb_in_tween :
		return

	
	if phase_one:	

		var pos_des_diference
		
		if chase:
			if speed > speed_min:
				speed -= speed_frame_change*delta
				
			pos_des_diference = position - destination
			
			if pos_des_diference .x + 20 >= 0 \
			and pos_des_diference .y + 20 >= 0 \
			and pos_des_diference .x - 20 <= 0 \
			and pos_des_diference .y - 20 <= 0:	
				destination_reached = true
				speed = 0
				emit_signal("destination_reached_signal")
		else:
			if speed < speed_initial:
				speed += speed_frame_change*delta
			
			pos_des_diference = position - start
			
			if pos_des_diference .x + 20 >= 0 \
			and pos_des_diference .y + 20 >= 0 \
			and pos_des_diference .x - 20 <= 0 \
			and pos_des_diference .y - 20 <= 0:	
				emit_signal("body_reached")
				queue_free()
	else:
		if player_in_boundries:
			lap_progress += delta 
			
			if radius_current > radius_min:
				radius_current = radius_current - (radius_decrease*delta)
				
			lap_offset = (lap_offset *2 *PI) / rotation_speed
			
			
			position = Vector2(
				sin((lap_progress+lap_offset) * rotation_speed) * radius_current,
				cos((lap_progress+lap_offset) * rotation_speed) * radius_current
			) + circle_center
			
			
		elif !player_in_boundries:
				
				var target_position = (player_position-global_position).normalized()
				linear_velocity = target_position * speed
				look_at(player_position)
		
func _switch_mode(_name):
	 
	undertale_mode = !undertale_mode

	if undertale_mode :
		$Sprite.animation = "undertale_head" 
		
	else:
		$Sprite.animation = "head_default" 
		
		
	
func _launch():
	visible = true
	speed = speed_initial

 
func _return():
	chase = false
	speed = speed_min
	look_at(start)

func update_player_position(position):
	
	player_position = position
	
func _tween_movement(destination, time):
	
	limb_in_tween = true
	phase_one = false
	
	radius_current = radius_max
	rotation_speed = num_of_rotations_ps*2*PI
	
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite, "global_position", destination, time)
	await tween.finished
	
	position = destination
	$Sprite.position = Vector2.ZERO
	
	limb_in_tween = false
	
	
	get_parent().get_tree().call_group("boss","heads_ready_phase_two")
	player_in_boundries = true
	
	
func player_outside_boundries():
	speed = speed_initial
	player_in_boundries = false
