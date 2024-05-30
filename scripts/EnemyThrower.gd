extends BasicEnemy


var has_head = true
var aiming = false
var dead = false
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

	else:
		linear_velocity = Vector2.ZERO

func move(velocity: Vector2):
	if has_head:
		linear_velocity = velocity
	

func delete_enemy():
	get_parent().decrease_special_enemy_counter()
	queue_free()


func got_shot(damage, push_back, custom_death_sprite=false):
	
	hp -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#A4A5AE", 35)
	
	if hp <= 0:
		
		dead = true	
		$CollisionShape2D.set_deferred("disabled", true)
		$DeathParticles.emitting = true
		
		if !custom_death_sprite:
			if undertale_mode && $AnimatedSprite2D.animation.contains("headless"):
				$AnimatedSprite2D.animation = "undertale_mode_death_headless"
				
			elif $AnimatedSprite2D.animation.contains("headless"):
				$AnimatedSprite2D.animation = "death_headless"
				
			elif undertale_mode:
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

func got_conditioned(damage, _condition,custom_death_sprite):
	
	hp -= damage
	
	
	if hp <= 0:
		_death(custom_death_sprite)
		if has_head:
			$AnimatedSprite2D.animation = "burned"
		else:
			$AnimatedSprite2D. animation = "burned_headless"
			
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#e86a17", 35)

	$ConditionParticles.emitting = true 
	
	

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
	head.get_node("AnimationPlayer").play("spin")
	
	head.body_reached.connect(head_returned) 
	
	
func head_returned():
	
	if !dead:
		if undertale_mode:
			$AnimatedSprite2D.animation = "undertale_mode_running"
		else:
			$AnimatedSprite2D.animation = "running"
		has_head = true


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


	if undertale_mode && hp > 0:
		
		if has_head:
			$AnimatedSprite2D.animation = "undertale_mode_running" 
		else:
			$AnimatedSprite2D.animation = "undertale_mode_running_headless" 
			
	elif  hp > 0:
		
		if has_head:
			$AnimatedSprite2D.animation = "running" 
		else:
			$AnimatedSprite2D.animation = "running_headless" 


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
