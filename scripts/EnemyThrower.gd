extends BasicEnemy


var has_head = true
var aiming = false
var head_destination : Vector2
@export var throw_distance : int

func _ready():
	speed = randi_range(speed_min,speed_max)
	
	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	
	main_node.switch_mode.connect(_switch_mode)
	nav.velocity_computed.connect(move)
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		

	$DeathSound.pitch_scale = randf_range(0.9,1.1)

func _physics_process(_delta):
	
	var player_enemy_distance = abs((player_position-position).length())
	
	#
	#var temp_pos = nav.get_next_path_position().length() - player_position.length()
	$RayCast2D.look_at(player_position)
	if has_head && player_enemy_distance <= throw_distance && !$RayCast2D.is_colliding() && in_arena:
		freeze = true
		has_head = false
		aiming = true
		linear_velocity = Vector2.ZERO
		$AnimatedSprite2D.look_at(player_position)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
		if !undertale_mode:
			$AnimatedSprite2D.play("throwing")
		else:
			$AnimatedSprite2D.play("undertale_mode_throwing")
			
	elif aiming:
		
		$AnimatedSprite2D.look_at(player_position)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
	elif has_head:
		
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
		
		
	else:
		linear_velocity = Vector2.ZERO

func move(velocity: Vector2):
	if has_head:
		linear_velocity = velocity
	
	
#func got_conditioned(damage, _condition,custom_death_sprite=false):
	#
	#hp -= damage
	#
	#
	#if hp <= 0:
		#_death(custom_death_sprite)
		#if has_head:
			#$AnimatedSprite2D.animation = "burned"
		#else:
			#$AnimatedSprite2D.animation = "burned_headless"
			#
	#var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	#add_child(instance)
	#instance._display_message(str(damage*10), "#e86a17", 35)
#
	#$ConditionParticles.emitting = true 
	

func got_conditioned(damage,push_back = Vector2.ZERO,custom_death_sprite=false, critical_hit = false):
	
	hp -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	if critical_hit:
		instance._display_message(str(damage*10)+"!", "#C33149", 55)
	else:
		instance._display_message(str(damage*10), "#e86a17", 35)
	
	if hp <= 0:
		if critical_hit:
			critical_parts = load("res://scenes/CriticalParts.tscn").instantiate()
			get_parent().add_child(critical_parts)
			critical_parts.launch_vector = push_back
		
			$AnimatedSprite2D.animation = "burned"
			
		elif has_head:
			$AnimatedSprite2D.animation = "burned"
			
		else:
			$AnimatedSprite2D.animation = "burned_headless"
			
		_death(custom_death_sprite,critical_hit)

	$ConditionParticles.emitting = true 
	
	
func _death(custom_death_sprite=false,crittical_hit=false):
	
	if dead:
		return
			
	dead = true
	
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathParticles.emitting = true
	
	if crittical_hit:
		critical_parts.position = position
		$AnimatedSprite2D.visible = false
		$MagicParticles.emitting = false
		
		var exploded = $AnimatedSprite2D.animation == "burned"
		
		critical_parts._launch_parts(id,has_head,exploded)
	
	elif !custom_death_sprite:
		if undertale_mode && $AnimatedSprite2D.animation.contains("headless"):
			$AnimatedSprite2D.animation = "undertale_mode_death_headless"
				
		elif $AnimatedSprite2D.animation.contains("headless"):
			$AnimatedSprite2D.animation = "death_headless"
		
		elif undertale_mode:
			$AnimatedSprite2D.animation = "undertale_mode_death"
			
		else:
			$AnimatedSprite2D.animation = "death"
		
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
		
	$DeathTimer.start()
	$DeathSound.random_pitch_play()
	
	emit_signal("enemy_killed", xp)
	
	linear_velocity = Vector2.ZERO
	set_deferred("freeze",true)
		
	set_physics_process(false)


func throw():
	
	aiming = false
	
	head_destination = position + ((player_position - position).normalized())*throw_distance
	
	freeze = false
	
	var head = load("res://scenes/Head.tscn").instantiate()
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running_headless"
		head.undertale_mode = true
	else:	
		$AnimatedSprite2D.animation = "running_headless"
	
	get_parent().add_child(head)
		
	head.start = position
	head.position = position
	head.destination = head_destination
	
	head.body_reached.connect(head_returned) 
	$MagicParticles.emitting = true
	
		
func head_returned():
	
	if !dead:
		if undertale_mode:
			$AnimatedSprite2D.animation = "undertale_mode_running"
		else:
			$AnimatedSprite2D.animation = "running"
		has_head = true
		$MagicParticles.emitting = false

func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


	if undertale_mode && hp > 0:
		
		if has_head:
			$AnimatedSprite2D.animation = "undertale_mode_running" 
		else:
			$AnimatedSprite2D.animation = "undertale_mode_running_headless" 
		
		$MagicParticles.process_material = load("res://particles/Undertale_HeadMagicMaterial.tres")
				
	elif  hp > 0:
		
		if has_head:
			$AnimatedSprite2D.animation = "running" 
		else:
			$AnimatedSprite2D.animation = "running_headless" 
		
		$MagicParticles.process_material = load("res://particles/HeadMagicMaterial.tres")
