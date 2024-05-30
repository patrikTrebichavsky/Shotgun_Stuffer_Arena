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
		
	#Rozrobenne enemy ma vypnute niektore funkcie v ready
	
func move(velocity: Vector2):
	if !just_jumped:
		linear_velocity = velocity
	
	
func jump():
	
	linear_velocity = Vector2.ZERO
	just_jumped = true
	jump_available = false
	
	$CollisionShape2D.set_deferred("disabled",true)
	
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


func delete_enemy():
	get_parent().decrease_special_enemy_counter()
	queue_free()

func got_shot(damage, push_back, custom_death_sprite=false):
	
	hp -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#A4A5AE", 35)
	
	if hp <= 0:
		
		$CollisionShape2D.set_deferred("disabled", true)
		$DeathParticles.emitting = true
		
		if !custom_death_sprite:		
			if(undertale_mode):
				$AnimatedSprite2D.animation = "undertale_mode_death"
			else:
				$AnimatedSprite2D.animation = "death"
		
		
		$DeathTimer.start()
		$DeathSound.play()
		
		emit_signal("enemy_killed", xp)
		
		linear_velocity = Vector2.ZERO
		set_deferred("freeze",true)
		
		set_physics_process(false)
		apply_central_impulse(push_back)
		
	else:
		
		set_physics_process(false)
		apply_central_impulse(push_back)
		
		await get_tree().create_timer(0.2).timeout
		set_physics_process(true)

#func falling_down_from_wall():
	#var tween = get_tree().create_tween()
	#tween.tween_property($AnimatedSprite2D, "scale", Vector2(0.8,0.8), 0.03625)
	#tween.tween_property($AnimatedSprite2D, "scale", Vector2(0.75,0.75), 0.03625)
	#await  tween.finished
	#
	#set_collision_mask_value(10,false)
	#set_collision_layer_value(10,false)
	#
	#set_collision_mask_value(2,true)
	#set_collision_mask_value(3,true)
	#set_collision_layer_value(2,true)
	#set_collision_layer_value(3,true)
	#set_collision_layer_value(4,true)
	#z_index = 0
	#in_arena = true

func _enemy_fell_off_map():
	get_parent().decrease_special_enemy_counter()
	queue_free()
