extends CharacterBody2D


signal player_position(position)

signal next_ammo(ammo_id)

signal shot_special

signal player_died

var special_messages_levels = [1, 2, 3, 5, 6, 9, 12, 15, 35, 50]

@export var bullet_dictionary = {
	"id" : "path",
	0 : "res://scenes/Plate.tscn",
	1 : "res://scenes/Couch.tscn",
	2 : "res://scenes/Piano.tscn",
	3 : "res://scenes/Lamppost.tscn",
	4 : "res://scenes/Car.tscn",
	5 : "res://scenes/House.tscn",
	1001: "res://scenes/Laser.tscn"
}


@export var shooting_sounds_dictionary = {
	"id" : "path",
	1 : "res://sounds/Shooting.mp3",
	2 : "res://sounds/Bullets/Laser/Laser_Charging.mp3",
	3 : "res://sounds/Bullets/Laser/Laser_Decharging.mp3"
}


@export var speed = 600.0
@export var magazine_size = 5
@export var screen_adjusment = Vector2(100,100)
@export var player_level = 0
@export var dash_distance = 1000

var stored_ammo = []
var just_shot = false
var can_reload = false
var screen_size : Vector2
var can_dash = true
var just_dashed = false
var charged = false

@export var undertale_mode : bool

func _ready():
	
	var main_node = get_parent()
	screen_size = get_viewport_rect().size*2
	screen_size -= screen_adjusment
	
	main_node.switch_mode.connect(_switch_mode)
	main_node.set_magazine_size.connect(set_magazine_size)
	main_node.generated_special_ammo.connect(store_ammo)
	main_node.set_reload_time.connect(set_reload_time)
	main_node.player_level_changed.connect(player_level_changed)
	
func _physics_process(delta):
	
	var direction = Vector2(Input.get_axis("left", "right"),Input.get_axis("forward", "backward"))
	
	$MouseCollider.global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("dash") && can_dash && player_level > 0:
		can_dash = false
		just_dashed = true
		$DashSound.play()
		$DashTimer.start()
		$Area2D/DashParticles.emitting = true
		var tween = get_tree().create_tween()
		var dash_destination = position + direction * dash_distance
		
		$Area2D/CollisionPolygon2D.set_deferred("disabled", true)
		
		tween.tween_property(self,"position",dash_destination,0.25)
		
		await tween.finished
		
		$Area2D/CollisionPolygon2D.set_deferred("disabled", false)
		just_dashed = false
	
	#Signal pozicie pre enemakov
	emit_signal("player_position", position)
	
	if !just_dashed:
		#Movement
		$Area2D.look_at(get_global_mouse_position())
		
		
		if direction:
		
			
			velocity = direction.normalized() * speed
			
			if !just_shot && undertale_mode && !charged:
				$Area2D/AnimatedSprite2D.animation = "undertale_mode_running"
			elif !just_shot && !undertale_mode:
				$Area2D/AnimatedSprite2D.animation = "running"
				
		else:
			
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.y = move_toward(velocity.y, 0, speed)
			
		move_and_slide()
		
		#Camera 
		position = position.clamp(screen_adjusment, screen_size)
	
	if !Input.is_action_pressed("shoot") && undertale_mode:
		
		if charged:
			
			$ShootingSound.stream = load(shooting_sounds_dictionary[3])
			$ShootingSound.play()
			
			if get_node_or_null("Area2D/Laser") != null:
				$Area2D/Laser.queue_free()
			
			charged = false
			
			$Area2D/AnimatedSprite2D.play("undertale_mode_decharging")

	if Input.is_action_just_pressed("shoot") && !can_reload:
		
		if undertale_mode:
			undertale_shoot()
		else:
			shoot()


func store_ammo(ammo_id):
		


	if stored_ammo.size() != magazine_size:
		stored_ammo.append(ammo_id)
		emit_signal("next_ammo",ammo_id)
	
	
func set_magazine_size(amount):
	magazine_size = amount
	
	
func set_reload_time(amount):
	$ReloadTimer.wait_time = amount
	
	
func running_delay():
	just_shot = false
	
func dash_reset():
	can_dash = true	
	$DashReadySound.play()
	
func reloading():
	$ReloadingSound.playing = true
	can_reload = false
	if stored_ammo.size() > 2:
		emit_signal("next_ammo",stored_ammo[2])
	
	
func shoot():
	
	$Area2D/AnimatedSprite2D.animation = "standing_shooting"
	
	$Area2D/ShootgunParticles.emitting = true
	$ShootingSound.playing = true
	
	
	var bullet_path = ""

	if stored_ammo.size() == 0:
		bullet_path = bullet_dictionary[0]
		
		if player_level < 2:
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 5:
			bullet_instatiation(bullet_path,0)
			just_shot = true
			await get_tree().create_timer(0.1).timeout
			$ShootingSound.playing = true
			bullet_instatiation(bullet_path,0)
			
		else:
			bullet_instatiation(bullet_path,0)
			bullet_instatiation(bullet_path,PI/8)
			bullet_instatiation(bullet_path,-PI/8)
			
	else:
		emit_signal("shot_special")
		
		if stored_ammo.size() > 3:
			emit_signal("next_ammo",stored_ammo[3])
		
		bullet_path = bullet_dictionary[stored_ammo.pop_front()]
		
		if player_level < 35:
			
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 50:
			bullet_instatiation(bullet_path,0)
			bullet_instatiation(bullet_path,PI/8)
			bullet_instatiation(bullet_path,-PI/8)
			
		else:
			for bullet_counter in range(8):
				bullet_instatiation(bullet_path,(PI/8)*bullet_counter)
			
	just_shot = true
	can_reload = true
		
	$RunningAnimTimer.start()
	$ReloadTimer.start()
	
#bullet is always instantiated before player extra rotation is there for adjusment
func bullet_instatiation(bullet_path,extra_rotation):
	
	var instance = load(bullet_path).instantiate()
		
	instance.position = $Area2D/ShootingPoint.global_position
	instance.rotation = $Area2D.rotation + extra_rotation
	
	if instance.tracking:
		instance.array_of_bodies = $MouseCollider.get_overlapping_bodies()
	
	instance.apply_central_impulse(Vector2.RIGHT.rotated($Area2D.rotation + extra_rotation)*instance.speed)
	
	get_parent().add_child(instance)
		
		
func death(body):
	
	$Area2D/DeathParticles.emitting = true
	
	if(undertale_mode):
		$Area2D/AnimatedSprite2D.animation = "undertale_mode_running"
	else:
		$Area2D/AnimatedSprite2D.animation = "running"
		
	$DeathSound.play()
	set_physics_process(false)
	emit_signal("player_died")
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
	
func undertale_shoot():
	
	if !just_shot:
		
		$ShootingSound.stream = load(shooting_sounds_dictionary[2])
		$ShootingSound.play()
		
		$Area2D/AnimatedSprite2D.animation = "undertale_mode_charging"
		$Area2D/AnimatedSprite2D.play()
		just_shot = true
	
	
func _on_animated_sprite_2d_animation_finished():
	
	if undertale_mode :
		
		if $Area2D/AnimatedSprite2D.animation == "undertale_mode_charging":
			
			charged = true
			
			$Area2D/AnimatedSprite2D.animation = "undertale_mode_shooting"
			$Area2D/AnimatedSprite2D.play()
			
			var bullet_path = bullet_dictionary[1001]
			var instance = load(bullet_path).instantiate()
		
			instance.position += $Area2D/ShootingPoint.position
			$Area2D.add_child(instance)

		if	$Area2D/AnimatedSprite2D.animation == "undertale_mode_decharging":
			
			$Area2D/AnimatedSprite2D.animation = "undertale_mode_running"
			just_shot = false


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode
	
	if undertale_mode:
		$Area2D/AnimatedSprite2D.animation = "undertale_mode_running" 

	else:
		
		$ShootingSound.stream = load(shooting_sounds_dictionary[1])
		$Area2D/AnimatedSprite2D.animation = "running" 
		
		if get_node_or_null("Area2D/Laser") != null:
			$Area2D/Laser.queue_free()
		

func player_level_changed(level):
	
	
	$LevelUpSound.play()
	var instance = load("res://scenes/TextPopUp.tscn").instantiate()
	add_child(instance)
	instance._display_message("Level UP", "#8A4FFF", 25)
	
	player_level = level
	
	if special_messages_levels.find(player_level) != -1:
		
		await get_tree().create_timer(1.0).timeout
		
		var display_text = ""
		
		instance = load("res://scenes/TextPopUp.tscn").instantiate()
		instance.set_display_time(1.5)
		
		add_child(instance)
		
		match player_level:
			1:
				display_text = "Dash Unlocked (space)"
			2:
				display_text = "Burst Mode Set"
			3:
				display_text = "Couch Special Unlocked"
			5:
				display_text = "Triple Shot Set"
			6:
				display_text = "Piano Special Unlocked"
			9:
				display_text = "Lamp Post Special Unlocked"
			12:
				display_text = "Car Special Unlocked"
			15:
				display_text = "House Special Unlocked"
			35:
				display_text = "Special Triple Barrel Set"
			50:
				display_text = "Uhm.... What the F#$@ Setd"
				
		instance._display_message(display_text, "#FF495C", 20)
	
	
