extends BasicEnemy

@export var just_jumped = false
@export var jump_available = false
@export var jump_distance : int

func _ready():
	
	speed = randi_range(speed_min,speed_max)
	
	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	nav.velocity_computed.connect(move)

	main_node.switch_mode.connect(_switch_mode)
	
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		$DropMarker.animation = "undertale_mode_drop_marker"


func _physics_process(_delta):
	
	if dead:
		return
	
	var player_enemy_distance = abs((player_position-position).length())
			
	if jump_available && player_enemy_distance <= jump_distance && in_arena:
		$AnimatedSprite2D.look_at(player_position)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		jump()
		
	elif !just_jumped:
		
		nav.target_position = player_position
		target_position = (nav.get_next_path_position()-global_position).normalized()
		current_velocity = target_position * speed
		nav.set_velocity(current_velocity)
		$AnimatedSprite2D.look_at(nav.get_next_path_position())
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
		var frame_pos_dif = (prev_position-position).abs().length()
		
		
		if frame_pos_dif < (speed_min-10)*_delta:
			stuck_counter += 1* _delta
		if stuck_counter > 2:
			stuck_counter = 0
			set_collision_mask_value(2,false)
			set_collision_mask_value(3,false)
			set_collision_layer_value(2,false)
			$StuckTimer.start()
		else:
			stuck_counter = 0
		
		prev_position = position

	
func move(velocity: Vector2):
	if !just_jumped:
		linear_velocity = velocity
	
	
func jump():
	
	linear_velocity = Vector2.ZERO
	just_jumped = true
	jump_available = false
	
	#$CollisionShape2D.set_deferred("disabled",true)
	
	set_collision_mask_value(2,false)
	set_collision_mask_value(3,false)
	set_collision_layer_value(2,false)
	set_collision_layer_value(3,false)
	set_collision_layer_value(4,false)
	
	var temp = position
	position = player_position
	$AnimatedSprite2D.global_position = temp
	
	$AnimationPlayer.play("Jump_animation")
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D,"position",Vector2.ZERO, 2/$AnimationPlayer.speed_scale)
	

func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


	if undertale_mode && hp > 0:
		
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		$DropMarker.animation = "undertale_mode_drop_marker"
		
	elif  hp > 0:
		
		$AnimatedSprite2D.animation = "running" 
		$DropMarker.animation = "drop_marker"

func _on_jump_timeout_timeout():
	jump_available = true
