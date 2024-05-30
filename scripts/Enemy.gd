extends RigidBody2D

class_name BasicEnemy

signal enemy_killed(xp)
signal stop_homming()

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

@export var undertale_mode : bool



func _ready():
	
	speed = randi_range(speed_min,speed_max)
	
	prev_position = position
	

	var main_node = get_parent()
	player = main_node.get_node("Player")
	player.player_position.connect(update_player_position)
	

	main_node.switch_mode.connect(_switch_mode)
	nav.velocity_computed.connect(move)
	
	if undertale_mode:
		$AnimatedSprite2D.animation = "undertale_mode_running" 
		
	
func _physics_process(_delta):
	
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
	
func player_is_dead():
	
	$GruntTimer.stop()
	set_deferred("freeze",true)
	angular_velocity = 0
	set_physics_process(false)


func delete_enemy():
	get_parent().decrease_basic_enemy_counter()
	emit_signal("stop_homming")
	queue_free()


func got_shot(damage, push_back, custom_death_sprite=false):
	
	hp -= damage
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#A4A5AE", 35)
	
	if hp <= 0:
		_death(custom_death_sprite)
		apply_central_impulse(push_back)
		
	else:
		
		set_physics_process(false)
		apply_central_impulse(push_back)
		
		await get_tree().create_timer(0.2).timeout
		set_physics_process(true)

#condition variable isnt used for now its for potential new conditions 
func got_conditioned(damage, _condition,custom_death_sprite):
	
	hp -= damage
	
	
	if hp <= 0:
		_death(custom_death_sprite)
		$AnimatedSprite2D.animation = "burned"
	
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message(str(damage*10), "#e86a17", 35)

	$ConditionParticles.emitting = true 
	
	
func update_player_position(position):
	
	player_position = position


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
		
		linear_velocity = Vector2.ZERO
		set_deferred("freeze",true)
		
		set_physics_process(false)

func _enemy_fell_off_map():
	get_parent().decrease_basic_enemy_counter()
	queue_free()
