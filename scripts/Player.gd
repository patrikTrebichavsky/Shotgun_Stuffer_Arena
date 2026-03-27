extends CharacterBody2D


signal player_position(position)

signal special_shot()

signal bullet_cursor(ammo_id)

signal player_died

signal dashed()


var special_messages_levels = [3, 8, 35, 50]

#After adding all the special amunition reorder it ascdending into categories
@export var bullet_dictionary = {
	"id" : "path",
	"Plate" : "res://scenes/Plate.tscn",
	"Couch" : "res://scenes/Couch.tscn",
	"Doggy" : "res://scenes/Poop.tscn",
	"Nails" : "res://scenes/Nails/Nails.tscn",
	"Lamppost" : "res://scenes/Lamppost.tscn",
	"UtilityPole" : "res://scenes/UtilityPole.tscn",
	"Piano" : "res://scenes/Piano.tscn",
	"Shotgun" : "res://scenes/SuperShotgun.tscn",
	"Car" : "res://scenes/Car.tscn",
	"Closet-BE" : "res://scenes/Closet/Closet.tscn",
	"Closet-BB" : "res://scenes/Closet/Closet.tscn",
	"Closet-SH" : "res://scenes/Closet/Closet.tscn",
	"House" : "res://scenes/House.tscn",
	1001: "res://scenes/Laser.tscn"
}


@export var shooting_sounds_dictionary = {
	"id" : "path",
	1 : "res://sounds/Player/Shooting.mp3",
	2 : "res://sounds/Bullets/Laser/Laser_Charging.mp3",
	3 : "res://sounds/Bullets/Laser/Laser_Decharging.mp3"}



@export var speed = 600.0
@export var screen_adjusment = Vector2(50,50)
@export var player_level = 0
@export var dash_distance = 1000


var choosen_special = ""

var use_special = false

var previous_best_level : int 

var just_shot = false

var reloaded = false

var screen_size : Vector2

var can_dash = true

var just_dashed = false

var charged = false

var can_switch_back = false;

var second_chance = false;

var regenrate_sec_chance = false

var second_chance_usable = false

var switch_special_ready = true

var mouse_on_ui = false

var main_node


@export var undertale_mode : bool

func _ready():
	
	main_node = get_parent()
	screen_size = get_viewport_rect().size*2
	screen_size -= screen_adjusment
	
	main_node.switch_mode.connect(_switch_mode)
	main_node.set_reload_time.connect(set_reload_time)
	main_node.player_level_changed.connect(player_level_changed)

func _physics_process(_delta):
	
	
	
	var direction = Vector2(Input.get_axis("left", "right"),Input.get_axis("forward", "backward"))
	
	$DashCollisonChecker.target_position = direction.normalized() * dash_distance
	$DashCollisonChecker/Tip.position = direction.normalized() * dash_distance
	$DashCollisonChecker/Tip.target_position = Vector2(30,30) * (direction*-1)
	$MouseRelatedNodes.global_position = get_global_mouse_position()
	
			
			
	#dash takes keyboard input and check if there are any walls in the way  with raycast. Then dashes maximum distance acordintly
	if Input.is_action_just_pressed("dash") \
	&& can_dash \
	&& (direction.x != 0 or direction.y != 0):
		
		
		can_dash = false
		just_dashed = true
		$DashSound.play()
		emit_signal("dashed")
		$PlayerArea/DashParticles.emitting = true
		
		var dash_destination = position + direction.normalized() * dash_distance
		
		var dash_collision_point = $DashCollisonChecker.get_collision_point()
		
		
		$PlayerArea/CollisionPolygon2D.set_deferred("disabled", true)
		set_collision_mask_value(5,false)
	
		var tween = get_tree().create_tween()
		if !$DashCollisonChecker/Tip.is_colliding():
			tween.tween_property(self,"position",dash_destination,0.25)
		else:
			tween.tween_property(self,"position",dash_collision_point,0.25)

		
		await tween.finished
		
		$DashCollisonChecker.target_position = Vector2.ZERO
		$PlayerArea/CollisionPolygon2D.set_deferred("disabled", false)
		set_collision_mask_value(5,true)
		just_dashed = false
	
	#Signal pozicie pre enemakov
	emit_signal("player_position", position)
	
	if !just_dashed:
		#Movement
		$PlayerArea.look_at(get_global_mouse_position())
		
		
		if direction:
		
			
			velocity = direction.normalized() * speed
			
			if !just_shot && undertale_mode && !charged:
				$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_running"
			elif !just_shot && !undertale_mode:
				$PlayerArea/AnimatedSprite2D.animation = "running"
				
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
			
			if get_node_or_null("PlayerArea/Laser") != null:
				$PlayerArea/Laser.queue_free()
			
			charged = false
			
			$PlayerArea/AnimatedSprite2D.play("undertale_mode_decharging")

	if Input.is_action_pressed("shoot") && !reloaded && !mouse_on_ui:
		
		if undertale_mode:
			undertale_shoot()
		else:
			shoot()

	
func set_reload_time(amount):
	$ReloadTimer.wait_time = amount
	
	
func running_delay():
	just_shot = false
	
func dash_reset():
	can_dash = true	
	$DashReadySound.play()
	
func reloading():
	reloaded = false
	just_shot = false
	$ReloadingSound.random_pitch_play()
	
	
func shoot():
	
	$ReloadTimer.start()
	$PlayerArea/AnimatedSprite2D.animation = "standing_shooting"
	
	$PlayerArea/ShootgunParticles.emitting = true
	
	var bullet_path = ""
	
	$ShootingSound.random_pitch_play()

	reloaded = true
	just_shot = true

	if !use_special:
		bullet_path = bullet_dictionary["Plate"]
		
		if player_level < 3:
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 8:
			bullet_instatiation(bullet_path,0)
			await get_tree().create_timer(0.1).timeout
			$ShootingSound.random_pitch_play()
			bullet_instatiation(bullet_path,0)
			
		else:
			bullet_instatiation(bullet_path,0)
			await get_tree().create_timer(0.01).timeout
			bullet_instatiation(bullet_path,PI/32.0)
			await get_tree().create_timer(0.02).timeout
			bullet_instatiation(bullet_path,-PI/32.0)
			
	else:
		
		use_special = false
		bullet_path = bullet_dictionary[choosen_special]
		special_shot.emit()
		
		if player_level < 35:
			
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 50:
			bullet_instatiation(bullet_path,0)
			bullet_instatiation(bullet_path,PI/8.0)
			bullet_instatiation(bullet_path,-PI/8.0)
			
		else:
			for bullet_counter in range(8):
				bullet_instatiation(bullet_path,(PI/4.0)*bullet_counter)
					
#bullet is always instantiated before player extra rotation is there for adjusment
func bullet_instatiation(bullet_path,extra_rotation = 0):
	
	var instance = load(bullet_path).instantiate()
		
	instance.position = $PlayerArea/ShootingPoint.global_position
	
	if instance.name.contains("Lamp"):
		
		var instance_sprite = instance.get_node("AnimatedSprite2D")
		instance_sprite.rotation = $PlayerArea.rotation + extra_rotation
		
	elif instance.name.contains("Closet"):
		
		instance.get_node("AnimatedSprite2D").animation = choosen_special
		instance.rotation = $PlayerArea.rotation + extra_rotation
		
	else:	
		instance.rotation = $PlayerArea.rotation + extra_rotation
	
	if instance.name.contains("Nails"):
		instance.target_position = get_global_mouse_position()
	
	instance.crosshair_bodies = $MouseRelatedNodes/CrossHair.get_overlapping_bodies()
	
	if instance.tracking:
		instance.array_of_bodies = $MouseRelatedNodes/MouseCollider.get_overlapping_bodies()
		
	
	var crosshair_vector = (get_global_mouse_position()-$PlayerArea/ShootingPoint.global_position).normalized()
	if extra_rotation == 0:
		instance.apply_central_impulse(crosshair_vector*instance.speed)
	elif !extra_rotation == 0:
		instance.apply_central_impulse(crosshair_vector.rotated(extra_rotation)*instance.speed)
	
	get_parent().add_child(instance)
	instance.check_crosshair()
		
		
func set_special(name="",using=false):
	choosen_special = name
	use_special = using
		
func death(body):

	if  "Wall" in body.name:
		return
		
	elif second_chance:
		$AnimationPlayer.play("Second_Chance_Hit")
		main_node.get_tree().call_group("enemy","got_shot",100,Vector2.ZERO)
		$PlayerArea.set_deferred("monitoring",false)
		$SecondChanceExplosionSound.play()
		second_chance = false
		if regenrate_sec_chance:
			$SecChanceRegenTimer.start()
		return
		
	$PlayerArea/DeathParticles.emitting = true
	
	if(undertale_mode):
		$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_running"
	else:
		$PlayerArea/AnimatedSprite2D.animation = "running"
		
	$DeathSound.play()
	$PlayerArea.set_deferred("monitoring",false)
	set_physics_process(false)
	emit_signal("player_died")
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
	
func undertale_shoot():	
	
	if !just_shot:
		
		$ShootingSound.stream = load(shooting_sounds_dictionary[2])
		$ShootingSound.play()
		
		$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_charging"
		$PlayerArea/AnimatedSprite2D.play()
		just_shot = true
	
	
func _on_animated_sprite_2d_animation_finished():
	
	if undertale_mode :
		
		if $PlayerArea/AnimatedSprite2D.animation == "undertale_mode_charging":
			
			charged = true
			
			$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_shooting"
			$PlayerArea/AnimatedSprite2D.play()
			
			var bullet_path = bullet_dictionary[1001]
			var instance = load(bullet_path).instantiate()
		
			instance.position += $PlayerArea/ShootingPoint.position
			$PlayerArea.add_child(instance)

		if	$PlayerArea/AnimatedSprite2D.animation == "undertale_mode_decharging":
			
			$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_running"
			just_shot = false


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode
	
	if undertale_mode:
		$PlayerArea/AnimatedSprite2D.animation = "undertale_mode_running" 
	else:
		
		$ShootingSound.stream = load(shooting_sounds_dictionary[1])
		$PlayerArea/AnimatedSprite2D.animation = "running" 
		
		if get_node_or_null("PlayerArea/Laser") != null:
			$PlayerArea/Laser.queue_free()
		

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
			3:
				display_text = "Burst Mode Set"
			8:
				display_text = "Better Burst Mode Set"
			35:
				display_text = "Special Triple Barrel Set"
			50:
				display_text = "Uhm.... What the F#$@ Set"
				
		instance._display_message(display_text, "#FF495C", 20)
		
		await get_tree().create_timer(1.5).timeout
		
		if player_level > previous_best_level and second_chance_usable and !regenrate_sec_chance:
			second_chance_usable = false
			instance = load("res://scenes/TextPopUp.tscn").instantiate()
			instance.set_display_time(2.5)
			add_child(instance)
			instance._display_message("Second chance lost",  "#FFD000", 20)

func mode_switch_visuals():
		
	if use_special:
		$SpecialModeSound.stream = load("res://sounds/Player/SpecialModeOn.wav")
		var instance = load("res://scenes/TextPopUp.tscn").instantiate()
		add_child(instance)
		instance._display_message(choosen_special, "#8A4FFF", 25)
	
	else:
		$SpecialModeSound.stream = load("res://sounds/Player/SpecialModeOff.wav")
		var instance = load("res://scenes/TextPopUp.tscn").instantiate()
		add_child(instance)
		instance._display_message("Special Off", "#8A4FFF", 25)
	
	$SpecialModeSound.play()
	
	
func second_chance_on(regen = regenrate_sec_chance):
	
	regenrate_sec_chance = regen
	
	second_chance = true
	
	second_chance_usable = true
	
	var	instance = load("res://scenes/TextPopUp.tscn").instantiate()
	instance.set_display_time(1.5)
	add_child(instance)
	
	if regenrate_sec_chance:
		instance._display_message("Regenerating Second Chance Gained", "#FFD000", 20)
	else:
		instance._display_message("Second Chance Gained", "#FFD000", 20)
	
	$PlayerArea/SecondChance.visible = true
	$AnimationPlayer.play("SecondChance")	
	$SecondChanceAquired.play()
	
func reset_special_switch():
	switch_special_ready = true

func mouse_on_ui_state(on = true):
	mouse_on_ui = on

func delay_enabling_of_shooting(on = true):
	if on:
		$BulletEnabledDelayTimer.start()
	elif !on:
		$BulletEnabledDelayTimer.stop()

func went_trough_sewage():
	$PlayerArea.monitoring = false
	$AnimationPlayer.play("invulnerable")

func door_spin():
	
	
	$DoorEnabledSound.random_pitch_play()
	
	$Doors/Door1.enable()
	$Doors/Door2.enable()
	$Doors/Door3.enable()
	
	var tweener = get_tree().create_tween()

	tweener.tween_property($Doors,"rotation_degrees",3600,10)
	await tweener.finished
	
	$Doors/Door1.disable()
	$Doors/Door2.disable()
	$Doors/Door3.disable()
	
	$Doors.rotation = 0
