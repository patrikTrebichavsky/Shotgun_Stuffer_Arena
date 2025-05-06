extends RigidBody2D

class_name Smasher

signal enemy_killed(xp)
signal stop_homming()

@export var speed_normal_hunt = 650.0
@export var speed_normal = 650.0
var dash_speed_current  = 0.0
@export var dash_speed_min = 400
@export var dash_speed_max = 1000
@export var dash_speed_increase = 1.0
@export var id = 10
@export var xp = 1

var shadow_prev_position

var hp_current : int
@export var hp_max = 100
var current_velocity = 0
var prev_position : Vector2
var dash_direction : Vector2
var stuck_counter = 0
@export var player_position : Vector2 
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var target_position : Vector2
var player 
var in_arena = false
var dashing = false
var aiming = false
var crashed = false
var running = true
var can_crash = true
var can_dash = true
var feasting = false
var target_prey = null
var feast_targets_array : Array

var dead = false

var message_rotation = "middle"

var critical_parts

@export var undertale_mode : bool

func _init():
	visible = false

func _ready():
	
	hp_current = hp_max
	
	prev_position = position
	
	dash_speed_current = dash_speed_min
	
	nav.target_position = player_position
	$RayCast2D.target_position = player_position
	
	prev_position = position
	
	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	

	main_node.switch_mode.connect(_switch_mode)
	nav.velocity_computed.connect(move)
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		
	set_physics_process(true)
	
func _physics_process(_delta):
	
	if !in_arena:
		return
	
	$RayCast2D.target_position = player_position-position
	
	if target_prey == null:
		nav.target_position = player_position
	else:
		nav.target_position = target_prey.position
	
	if crashed || player_position == Vector2.ZERO || feasting:
		return
	
	
	if running && target_prey == null && in_arena :
		
		feast_targets_array = $HuntingArea.get_overlapping_bodies()
		
		for body in feast_targets_array:
			var temp_body_name = body.name.to_lower()
			if !body.is_in_group("enemy") || temp_body_name.contains("smasher"):
				continue
			if target_prey == null:
				target_prey = body
				$AnimatedSprite2D.play("chasing")
			else:
				if abs(body.position-position) < abs(target_prey.position-position):
					target_prey = body
					
		if target_prey == null:
			$AnimatedSprite2D.play("running")
				
	if target_prey != null && in_arena:
		if !target_prey.get_node("DeathTimer").is_stopped():
			target_prey = null
			return
		target_position = (nav.get_next_path_position()-global_position).normalized()
		current_velocity = target_position * speed_normal_hunt
		nav.set_velocity(current_velocity)
		$AnimatedSprite2D.look_at(nav.get_next_path_position())
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
		if get_contact_count() > 0:
			for body in get_colliding_bodies():
				var temp_body_name = body.name.to_lower()
				if body.is_in_group("enemy") && !temp_body_name.contains("smasher"):
					
					linear_velocity = Vector2.ZERO
					nav.set_velocity(Vector2.ZERO)
					body.got_shot(9999,Vector2.ZERO)
					$AnimatedSprite2D.play("feast")
					$EatingSound.play()
					feasting = true
		
			#if get_contact_count() > 0:
				
	
	elif aiming && in_arena:
		linear_velocity = Vector2.ZERO
		nav.set_velocity(Vector2.ZERO)
		$AnimatedSprite2D.look_at(player_position)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
	elif dashing && in_arena:
		
		if dash_speed_current < dash_speed_max:
			dash_speed_current += dash_speed_increase
			
		
		current_velocity = dash_direction * dash_speed_current 
		linear_velocity = current_velocity
		
		
		
		$AnimatedSprite2D/DashAfterImage2.position.x = -1*dash_speed_current/40
		$AnimatedSprite2D/DashAfterImage1.position.x = -1*dash_speed_current/20
		
		$AnimatedSprite2D.look_at(position+current_velocity)
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
		
		if get_contact_count() > 0 && !crashed:
				
			for body in get_colliding_bodies():
				
				var temp_body_name = body.name.to_lower()
				
				if body.is_in_group("enemy") && !temp_body_name.contains("smasher"):
					body.got_shot(9999,Vector2.ZERO,true)
					var temp = body.get_node("AnimatedSprite2D")
					temp.animation = "crushed"
					return
					
			$AnimatedSprite2D/DashAfterImage1.visible = false
			$AnimatedSprite2D/DashAfterImage2.visible = false
			dashing = false
			crashed = true 
			$CrashWallParticles.look_at(position+linear_velocity)
			nav.set_velocity(Vector2.ZERO)
			linear_velocity = Vector2.ZERO
			$CrashWallParticles.emitting = true
			$CrashSound.play()
			get_tree().call_group("camera","apply_shake")
			$CrashRecoveryTimer.start()
			
			
	elif  running && !$RayCast2D.is_colliding() && !$DashArea.has_overlapping_bodies() && in_arena :
		nav.set_velocity(Vector2.ZERO)
		linear_velocity = Vector2.ZERO
		running = false	
		aiming = true
		$AimingTimer.start()
		
	elif running:
		target_position = (nav.get_next_path_position()-global_position).normalized()
		current_velocity = target_position * speed_normal
		nav.set_velocity(current_velocity)
		$AnimatedSprite2D.look_at(nav.get_next_path_position())
		$CollisionShape2D.rotation = $AnimatedSprite2D.rotation
	
		var frame_pos_dif = (prev_position-position).abs().length()
			
			
		if frame_pos_dif < (speed_normal-10)*_delta:
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
	if running:
		linear_velocity = velocity
	
func player_is_dead():
	
	$SpawnAddsTimer.stop()
	set_deferred("freeze",true)
	angular_velocity = 0
	set_physics_process(false)


func delete_enemy():
	
	var tween = create_tween()
	
	tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
	await tween.finished
	
	emit_signal("stop_homming")
	get_parent().boss_killed()
	queue_free()


func got_shot(damage, push_back = Vector2.ZERO, custom_death_sprite=false ,critical_hit = false):
	
	hp_current -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	
	match message_rotation:
		"left":
			instance.rotation_degrees = -25
			instance.position.x = -30
			message_rotation = "right"
		"middle":
			instance.rotation_degrees =  0
			message_rotation = "left"
		"right":
			instance.rotation_degrees = 25
			instance.position.x = 30
			message_rotation = "middle"
	
	if critical_hit:
		instance._display_message(str(damage*10)+"!", "#C33149", 55)
	else:
		instance._display_message(str(damage*10), "#A4A5AE", 35)
		
	
	get_tree().call_group("hp_bar","update_hp",hp_current)
	
	if hp_current <= 0:
		
		if critical_hit:
			critical_parts = load("res://scenes/CriticalParts.tscn").instantiate()
			get_parent().add_child(critical_parts)
			critical_parts.launch_vector = push_back
			
		_death(custom_death_sprite, critical_hit)
		apply_central_impulse(push_back)
	

#condition variable isnt used for now its for potential new conditions 
func got_conditioned(damage,push_back = Vector2.ZERO,custom_death_sprite=false, critical_hit = false,  type_cond="explosion"):
	
	hp_current -= damage
	
	get_tree().call_group("hp_bar","update_hp",hp_current)
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	
	match message_rotation:
		"left":
			instance.rotation_degrees = -25
			instance.position.x = -30
			message_rotation = "right"
		"middle":
			instance.rotation_degrees =  0
			message_rotation = "left"
		"right":
			instance.rotation_degrees = 25
			instance.position.x = 30
			message_rotation = "middle"

	if critical_hit:
		instance._display_message(str(damage*10)+"!", "#C33149", 55)
	elif type_cond == "explosion":
		instance._display_message(str(damage*10), "#e86a17", 35)
	elif type_cond == "electrocute":
		instance._display_message(str(damage*10), "#e2d80d", 35)
	elif type_cond == "bleeding":
		instance._display_message(str(damage*10), "#C11B36", 35)


	if hp_current <= 0 and !dead:
		if critical_hit:
			critical_parts = load("res://scenes/CriticalParts.tscn").instantiate()
			get_parent().add_child(critical_parts)
			critical_parts.launch_vector = push_back
		
		#Used also in critical parts 
		_death(custom_death_sprite,critical_hit)
	
		if type_cond == "explosion" or type_cond == "eletrocute":
			$AnimatedSprite2D.animation = "burned"
			$ConditionParticles.emitting = true 
		elif type_cond == "bleeding":
			$DeathParticles.emitting = true
	
	
func update_player_position(position):
	
	player_position = position


func _on_grunt_timer_timeout():
	
	$GruntSound.play()


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


	if undertale_mode && hp_current > 0:
		
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		
	elif  hp_current > 0:
		
		$AnimatedSprite2D.animation = "running" 
		

func stuck_timeout():
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_layer_value(2,false)

func fallen_down():
	
	get_tree().call_group("camera","apply_shake")
	$FallParticles.emitting = true
	
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	set_collision_layer_value(2,true)
	set_collision_layer_value(3,true)
	set_collision_layer_value(4,true)
	
	await get_tree().create_timer(1.0).timeout
	

	z_index = 0
	in_arena = true

func _death(custom_death_sprite=false,crittical_hit=false):
	
	dead = true
	
	$CollisionShape2D.set_deferred("disabled", true)
	$DeathParticles.emitting = true
	
	if crittical_hit:
		
		critical_parts.position = position
		$AnimatedSprite2D.visible = false
				
		critical_parts._launch_parts(id, true)
	
	if !custom_death_sprite:		
		if(undertale_mode):
			$AnimatedSprite2D.animation = "undertale_mode_death"
		else:
			$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.get_node_or_null("PoopSticked") != null:
		var temp = $AnimatedSprite2D.get_node("PoopSticked")
		var main = get_parent()
		var area = temp.get_node("Area2D")
		temp.call_deferred("reparent",main,true)
		area.set_deferred("monitorable",true)
	
	$DeathTimer.start()
	$DeathSound.play()
	
	linear_velocity = Vector2.ZERO
	set_deferred("freeze",true)

	set_physics_process(false)
	
	get_parent().leveled_up()
		

func dash():
	dash_speed_current = dash_speed_min
	$AnimatedSprite2D/DashAfterImage1.visible = true
	$AnimatedSprite2D/DashAfterImage2.visible = true
	$DashSound.play()
	dash_direction = (player_position - position).normalized()
	dashing = true
	aiming = false
	
	
func crash_recovery():
	running = true
	await get_tree().create_timer(0.2).timeout
	crashed = false


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "feast":
		feasting = false
		target_prey == null
		$AnimatedSprite2D.animation = "running"
		
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message("HP++", "#E80000", 35)
	hp_current = hp_current+hp_max/4
	$HealingSound.play()
	get_tree().call_group("hp_bar","heal_to_full", true, 0.5, hp_current)
	
func start_add_timer():
	$SpawnAddsTimer.start()

func _spawn_adds():
	get_parent().spawn_smasher_adds()
