extends BasicEnemy

@export var hp_max = 150

var throw_speed_current : int
@export var throw_speed_decrease : int
@export var throw_speed_initial : int 

var heads = []
var has_head = true
var num_of_heads = 2

var has_arms = true
var num_of_arms = 4

var aiming = false
var thrown = false
var dead = false
var update_position = true
var body_destination : Vector2

var phase_one = true
var phase_two_centred = false
@export var throw_distance : int

# Called when the node enters the scene tree for the first time.
func _ready():

	speed = randi_range(speed_min,speed_max)
	
	prev_position = position
	
	hp = hp_max

	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	nav.velocity_computed.connect(move)

	main_node.switch_mode.connect(_switch_mode)
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 

func _physics_process(_delta):
	
	if phase_one:
		
		var player_enemy_distance = abs((player_position-position).length())
		
		
		$RayCast2D.look_at(player_position)

		if hp_max/2 > hp && has_head:
			return_arms()
			phase_one = false	
			return


		if in_arena && has_head && player_enemy_distance <= throw_distance && !$RayCast2D.is_colliding():
			freeze = true
			has_head = false
			num_of_heads = 0
			aiming = true
			linear_velocity = Vector2.ZERO
			$AnimatedSprite2D.look_at(player_position)
			$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
			
			if !undertale_mode:
				$AnimatedSprite2D.play("throwing")
			else:
				$AnimatedSprite2D.play("undertale_mode_throwing")
				
		elif  aiming:
			
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

		elif thrown:
		
			if update_position:
				body_destination = player_position
				
				
			nav.target_position = body_destination
			target_position = (nav.get_next_path_position()-global_position).normalized()
			current_velocity = target_position * throw_speed_current
			nav.set_velocity(current_velocity)
			throw_speed_current -= throw_speed_decrease
			
			#Difference between positon of main body and body destination
			var pos_des_diference = position - body_destination
			
			#Since vector comparision works bit wierd it will be compared separetly 
			if pos_des_diference .x + 40 >= 0 \
			and pos_des_diference .y + 40 >= 0 \
			and pos_des_diference .x - 40 <= 0 \
			and pos_des_diference .y - 40 <= 0:
				
				throw_arms()
			
		else:
			linear_velocity = Vector2.ZERO
	
	else:
		
		if !phase_two_centred:
			
			nav.target_position = Vector2(1920,1080)
			target_position = (nav.get_next_path_position()-global_position).normalized()
			current_velocity = target_position * speed * 4
			nav.set_velocity(current_velocity)
			$AnimatedSprite2D.look_at(nav.get_next_path_position())
			$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
			
			var pos_des_diference = position - Vector2(1920,1080)
			
			if pos_des_diference .x + 20 >= 0 \
			and pos_des_diference .y + 20 >= 0 \
			and pos_des_diference .x - 20 <= 0 \
			and pos_des_diference .y - 20 <= 0:
				
				instantiate_head_circle()
				
				
func throw_self():
	
	aiming = false
	heads.resize(0)
	num_of_heads = 0
	
	body_destination = player_position
	
	freeze = false
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_headless"
	else:	
		$AnimatedSprite2D.animation = "headless"
		
	var head_1_spawn = $AnimatedSprite2D/Head1Spawn.global_position
	var head_2_spawn = $AnimatedSprite2D/Head2Spawn.global_position
	
	heads.append(instantiate_head(head_1_spawn,"res://scenes/BossHeads.tscn"))
	await get_tree().create_timer(0.1)
	heads.append(instantiate_head(head_2_spawn,"res://scenes/BossHeads.tscn"))
	
	for head in heads:
		head.visible = true
	
	$AnimationPlayer.play("Spin")
	
	set_collision_mask_value(2,false)
	set_collision_mask_value(3,false)
	set_collision_mask_value(5,false)
	
	throw_speed_current = throw_speed_initial
	
	body_destination = player_position
	
	thrown = true
	update_position = true
	$StopChaseTimer.start(1.0)
		

func throw_arms():

	if player == null:
		return
	
	if	!$StopChaseTimer.is_stopped:
		$StopChaseTimer.stop()

	thrown = false
	$AnimationPlayer.stop()
	$AnimatedSprite2D.look_at(player_position)
	$CollisionShape2D.look_at(player_position)
	nav.set_velocity(Vector2.ZERO)
	linear_velocity = Vector2.ZERO
	
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	set_collision_mask_value(5,false)
	
	heads[0].start = $AnimatedSprite2D/Head1Spawn.global_position
	heads[1].start = $AnimatedSprite2D/Head2Spawn.global_position
	

	has_arms = false
	num_of_arms = 0
	var arms = []
	
	var left_side_arm_spawn = $AnimatedSprite2D/SideLeftArmSpawn.global_position
	var right_side_arm_spawn = $AnimatedSprite2D/SideRightArmSpawn.global_position
	var left_front_arm_spawn = $AnimatedSprite2D/FrontLeftArmSpawn.global_position
	var right_front_arm_spawn = $AnimatedSprite2D/FrontRightArmSpawn.global_position
	
	var destination_arm_adjusment = (player_position - left_front_arm_spawn).normalized()
	var perpedic_vector = Vector2(destination_arm_adjusment.y,destination_arm_adjusment.x*-1)
	
	var left_side_arm_destination = player_position + (player.velocity*0.5) + (perpedic_vector*speed*0.4)
	var right_side_arm_destination = player_position + (player.velocity*0.5) - (perpedic_vector*speed*0.8)
	var left_front_arm_destination = player_position + (player.velocity*0.5)
	var right_front_arm_destination = player_position + (player.velocity*0.5) - (perpedic_vector*speed*0.4)
	
	
	arms.append(instantiate_arm(left_side_arm_spawn,left_side_arm_destination ,"res://scenes/Arm.tscn",true))
	arms.append(instantiate_arm(right_side_arm_spawn,right_side_arm_destination,"res://scenes/Arm.tscn",false))
	arms.append(instantiate_arm(left_front_arm_spawn,left_front_arm_destination,"res://scenes/Arm.tscn",true))
	arms.append(instantiate_arm(right_front_arm_spawn,right_front_arm_destination,"res://scenes/Arm.tscn",false))
	
	$AnimatedSprite2D.animation = "armless"
	
	for arm in arms:
		arm._launch()
		
	
func arm_returned(): 
	num_of_arms += 1
	
	if num_of_arms == 4:
		if !dead:
			if undertale_mode:
				$AnimatedSprite2D.animation = "undertale_mode_headless"
			else:
				$AnimatedSprite2D.animation = "headless"
			has_arms = true
			return_heads()


func return_arms():
	num_of_arms += 1
	
	if num_of_arms == 4:
		var main = get_parent()
		main.get_tree().call_group("arms","_return")
		num_of_arms = 0
		
			
func head_returned():
	num_of_heads += 1
	
	if num_of_heads == 2:
		if !dead:
			if undertale_mode:
				$AnimatedSprite2D.animation = "undertale_mode_running"
			else:
				$AnimatedSprite2D.animation = "running"
			has_head = true
			
			
func return_heads():
	
	for head in heads:
		head._return()
	
	
func instantiate_head_circle():
	
	heads.resize(0)
	num_of_heads = 0
	
	$AnimatedSprite2D.look_at(position-Vector2(0,1300))
	$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
	
	linear_velocity = Vector2.ZERO
	nav.set_velocity(Vector2.ZERO)
	
	body_destination = player_position 
	
	phase_two_centred = true
	
	freeze = false
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_headless"
	else:	
		$AnimatedSprite2D.animation = "headless"
		
	var head_1_spawn = $AnimatedSprite2D/Head1Spawn.global_position
	var head_2_spawn = $AnimatedSprite2D/Head2Spawn.global_position
	
	
	heads.append(instantiate_head(head_1_spawn,"res://scenes/BossHeads.tscn"))
	heads.append(instantiate_head(head_2_spawn,"res://scenes/BossHeads.tscn"))


	heads[0].lap_progress = 0.5
	heads[0].modulate = Color(255,0,255,255)
	
	for head in heads:
		head.visible = true
		head.circle_center = position
		head.get_node("Sprite").z_index = 20
		head._tween_movement(position-Vector2(0,1200),1)

	
func heads_ready_phase_two():
	num_of_heads += 1
	
	if num_of_heads == 2:
		$SecondPhaseArea.set_deferred("monitoring", true)

func player_left_boundries(body):
	
	for head in heads:
		head.player_outside_boundries()
	
func instantiate_arm(start,destination,scene_location,left=false):
		
	var arm = load(scene_location).instantiate()
	
	arm.rotation = $AnimatedSprite2D.rotation
	
	get_parent().add_child(arm)
	
	if left:
		arm.get_node("Sprite").animation = "left"
		
	arm.start = start
	arm.position = start
	arm.destination = destination
	
	arm.body_reached.connect(arm_returned) 
	arm.destination_reached_signal.connect(return_arms)
	return arm


func instantiate_head(start,scene_location):
		
	var head = load(scene_location).instantiate()
	
	head.rotation = $AnimatedSprite2D.rotation
	
	get_parent().add_child(head)
	
	head.start = start
	head.position = start
	
	head.body_reached.connect(head_returned)
	
	head.start_floating() 
	
	return head


func _stop_body_chase():
	update_position = false


func _update_player_position(position):
	
	player_position = position
	
	
func got_shot(damage, push_back, custom_death_sprite=false):
	
	hp -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#A4A5AE", 35)
	
	get_tree().call_group("hp_bar","update_hp",hp)
	
	if hp <= 0:
		_death(custom_death_sprite)
		apply_central_impulse(push_back)
		
		
func _death(custom_death_sprite=false):
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
		set_collision_mask_value(20,false)

		linear_velocity = Vector2.ZERO
		set_deferred("freeze",true)
		
		set_physics_process(false)
		

func _delete_enemy():
	get_parent().decrease_basic_enemy_counter()
	emit_signal("stop_homming")
	
	if heads.size() > 0:
		for head in heads:
			head.queue_free()
	
	queue_free()
