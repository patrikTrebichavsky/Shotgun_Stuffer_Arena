extends RigidBody2D

class_name BasicEnemy

signal enemy_killed(xp)
signal stop_homming()
@export var crit_parts_pth = "res://scenes/CriticalParts.tscn"
@export var speed_min = 200.0 
@export var speed_max = 400
@export var id = 1
@export var hp = 3
@export var xp = 1


var speed = 0
var current_velocity = 0
var prev_position : Vector2
var stuck_counter = 0
@export var player_position : Vector2 
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var target_position : Vector2
var player 
var in_arena = false
var message_rotation = "middle"

var dead = false

var critical_parts

@export var undertale_mode : bool

@export var debug_mode = false


func _ready():
	
	speed = randi_range(speed_min,speed_max)
	
	$NavigationAgent2D.max_speed = speed
	
	prev_position = position

	if debug_mode:
		falling_down_from_wall()
		nav.velocity_computed.connect(move)
		return
	
	var main_node = get_parent()
	player = main_node.get_node("Player")
	if ! player == null:
		player.player_position.connect(update_player_position)
	

	main_node.switch_mode.connect(_switch_mode)
	nav.velocity_computed.connect(move)
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		
	
func _physics_process(_delta):
	
	if dead:
		return
		
	if debug_mode:
		update_player_position(get_global_mouse_position())
	
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
	
	linear_velocity = velocity

func scripted_movement(delete_at_finnish = false, disable_pathing_perm = true, end_point = self.position,
					 movement_duration = 1.0, trans_type = Tween.TRANS_LINEAR ):
	
	nav.velocity_computed.disconnect(move)
	$CollisionShape2D.set_deferred("disabled",true)
	var tween = get_tree().create_tween()
	
	tween.tween_property(self,"position",end_point,movement_duration).set_trans(trans_type)

	await tween.finished
	
	if delete_at_finnish:
		visible = false
		_death()
		return

	if !disable_pathing_perm:
		nav.velocity_computed.connect(move)


func player_is_dead():
	
	set_deferred("freeze",true)
	angular_velocity = 0
	set_physics_process(false)


func _delete_enemy(skip_fadding=false):
	
	if !skip_fadding:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
	
		await tween.finished
	
	set_collision_layer_value(20,false)
	emit_signal("stop_homming")
	queue_free()


func got_shot(damage, push_back = Vector2.ZERO, custom_death_sprite=false ,critical_hit = false, utility_pole = false):
	
	hp -= damage
	
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
		
	if utility_pole or $AnimatedSprite2D.has_node("UtilityPolePierced"):
		critical_hit = false
	
	
	
	if hp <= 0 and !dead:
		
		if critical_hit:
			critical_parts = load(crit_parts_pth).instantiate()
			get_parent().add_child(critical_parts)
			critical_parts.launch_vector = push_back
			
		_death(custom_death_sprite,critical_hit)
		apply_central_impulse(push_back)
		
	else:
		
		apply_push_back(push_back)



#condition variable isnt used for now its for potential new conditions 
func got_conditioned(damage,push_back = Vector2.ZERO,custom_death_sprite=false, critical_hit = false, type_cond="explosion"):
	
	hp -= damage
	
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
	elif type_cond == "bomboclat":
		instance._display_message(str(damage*10), "#80a0aa", 35)
	elif type_cond == "bleeding":
		instance._display_message(str(damage*10), "#C11B36", 35)
		

	if $AnimatedSprite2D.has_node("UtilityPolePierced"):
		critical_hit = false
		
		
	if hp <= 0 and !dead:
		if critical_hit:
			critical_parts = load(crit_parts_pth).instantiate()
			get_parent().add_child(critical_parts)
			critical_parts.launch_vector = push_back
		
		#Used also in critical parts 
		$AnimatedSprite2D.animation = "burned"
		_death(custom_death_sprite,critical_hit,type_cond)
	
		if type_cond == "explosion" or type_cond == "eletrocute":
			$ConditionParticles.emitting = true 
		elif type_cond == "bleeding":
			$DeathParticles.emitting = true
	
func update_player_position(p_position):
	
	player_position = p_position


func _on_grunt_timer_timeout():
	
	$GruntSound.play()


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


	if undertale_mode && hp > 0:
		
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		
	elif  hp > 0:
		
		$AnimatedSprite2D.animation = "running" 
		

func stuck_timeout():
		set_collision_mask_value(2,false)
		set_collision_mask_value(3,false)
		set_collision_layer_value(2,false)


func falling_down_from_wall():
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(0.8,0.8), 0.03625)
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(0.75,0.75), 0.03625)
	await  tween.finished
	
	set_collision_mask_value(10,false)
	set_collision_layer_value(10,false)
	
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)
	set_collision_layer_value(2,true)
	set_collision_layer_value(3,true)
	set_collision_layer_value(4,true)
 
	z_index = 0
	in_arena = true


func _death(custom_death_sprite=false,crittical_hit=false,cond_type = "none"):
	
	if dead:
		return
		
	dead = true
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	set_physics_process(false)
		
	if crittical_hit:
				
		critical_parts.position = position
		$AnimatedSprite2D.visible = false
		
		critical_parts._launch_parts(id, true, cond_type)
		
	elif !custom_death_sprite:		
		$DeathParticles.emitting = true
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
	
	$DeathTimer.start(0.5)
		
	$DeathSound.random_pitch_play()

	linear_velocity = Vector2.ZERO
	emit_signal("enemy_killed", xp)
	set_deferred("freeze",true)
		


func _enemy_fell_off_map():
	get_parent().decrease_basic_enemy_counter()
	queue_free()

func flash():
	$AnimatedSprite2D.set_modulate(Color(100,100,100))
	if dead && 	$AnimatedSprite2D.animation != "burned" :
		$AnimatedSprite2D.animation = "burned"
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color("ffffff")
	

func apply_push_back(push_back):
	if nav.velocity_computed.is_connected(move):
		nav.disconnect("velocity_computed",self.move)
		apply_central_impulse(push_back)
		await get_tree().create_timer(0.2).timeout
		nav.velocity_computed.connect(move)
