extends BasicEnemy


@export var just_jumped = false
@export var jump_available = true 
@export var jump_distance : int


func _ready():
	
	speed = randi_range(speed_min,speed_max)
	
	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	

	main_node.switch_mode.connect(_switch_mode)
	
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		$DropMarker.animation = "undertale_mode_drop_marker"

func _physics_process(_delta):
	
	
	var player_enemy_distance = abs((player_position-position).length())
			
	if jump_available && player_enemy_distance <= jump_distance:
		jump()
		
	elif !just_jumped:
		target_position = (player_position-global_position).normalized()
		linear_velocity = target_position * speed
		$AnimatedSprite2D.look_at(player_position)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
	#Rozrobenne enemy ma vypnute niektore funkcie v ready
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
