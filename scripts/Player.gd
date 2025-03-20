extends CharacterBody2D


signal player_position(position)

signal next_ammo(ammo_id)

signal shot_special
signal shot_special2
signal shot_special3

signal is_first_special_activated(bool)
signal is_second_special_activated(bool)
signal is_third_special_activated(bool)

signal choosen_special(special_id)

signal bullet_cursor(ammo_id)

signal player_died

signal dashed()


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
	1 : "res://sounds/Player/Shooting.mp3",
	2 : "res://sounds/Bullets/Laser/Laser_Charging.mp3",
	3 : "res://sounds/Bullets/Laser/Laser_Decharging.mp3"}



@export var speed = 600.0
@export var magazine_size = 5
@export var screen_adjusment = Vector2(100,100)
@export var player_level = 0
@export var dash_distance = 1000

var stored_ammo = []

var special_slot_chosen : int

var previous_best_level : int 

var just_shot = false

var can_reload = false

var screen_size : Vector2

var can_dash = true

var just_dashed = false

var charged = false

var use_special = false;

var can_switch_back = false;

var second_chance = false;

var regenrate_sec_chance = false

var second_chance_usable = false

var switch_special_ready = true

var mouse_on_text_box = false

var main_node


@export var undertale_mode : bool

func _ready():
	
	main_node = get_parent()
	screen_size = get_viewport_rect().size*2
	screen_size -= (screen_adjusment - Vector2(50,50))
	
	main_node.switch_mode.connect(_switch_mode)
	main_node.set_magazine_size.connect(set_magazine_size)
	main_node.generated_special_ammo.connect(store_ammo)
	main_node.set_reload_time.connect(set_reload_time)
	main_node.player_level_changed.connect(player_level_changed)
	
func _physics_process(delta):
	
	
	
	var direction = Vector2(Input.get_axis("left", "right"),Input.get_axis("forward", "backward"))
	
	$DashCollisonChecker.target_position = direction.normalized() * dash_distance
	$DashCollisonChecker/Tip.position = direction.normalized() * dash_distance
	$DashCollisonChecker/Tip.target_position = Vector2(30,30) * (direction*-1)
	$MouseRelatedNodes.global_position = get_global_mouse_position()
	
	
	if switch_special_ready:
		if !undertale_mode && (!use_special || special_slot_chosen != 0) && ((Input.is_action_just_pressed("special_first") || (Input.is_action_just_pressed("special_scroll_up") && (!use_special || special_slot_chosen == 1 )) || (Input.is_action_just_pressed("special_scroll_down") && !use_special)) && stored_ammo.size() > 0) :
			special_slot_chosen = 0
			can_switch_back = true
			use_special = true
			switch_special_ready = false
			$SpecialResetTimer.start()
			mode_switch_visuals()
			emit_signal("bullet_cursor",stored_ammo[special_slot_chosen])
			
			
			emit_signal("is_first_special_activated",true)
			emit_signal("is_second_special_activated",false)
			emit_signal("is_third_special_activated",false)
			
		elif !undertale_mode && (!use_special || special_slot_chosen != 1) && ((Input.is_action_just_pressed("special_second") || (Input.is_action_just_pressed("special_scroll_down") && special_slot_chosen == 0) || (Input.is_action_just_pressed("special_scroll_up") && special_slot_chosen == 2)  ) && stored_ammo.size() > 1): 
			special_slot_chosen = 1
			can_switch_back = true
			use_special = true
			switch_special_ready = false
			$SpecialResetTimer.start()
			mode_switch_visuals()
			emit_signal("bullet_cursor",stored_ammo[special_slot_chosen])
			
			
			emit_signal("is_first_special_activated",false)
			emit_signal("is_second_special_activated",true)
			emit_signal("is_third_special_activated",false)
			
		elif !undertale_mode && (!use_special || special_slot_chosen != 2) && ((Input.is_action_just_pressed("special_third") || (Input.is_action_just_pressed("special_scroll_down") && special_slot_chosen == 1)) && stored_ammo.size() > 2):
			special_slot_chosen = 2
			can_switch_back = true
			use_special = true
			switch_special_ready = false
			$SpecialResetTimer.start()
			mode_switch_visuals()
			emit_signal("bullet_cursor",stored_ammo[special_slot_chosen])
			
			
			emit_signal("is_first_special_activated",false)
			emit_signal("is_second_special_activated",false)
			emit_signal("is_third_special_activated",true)
				
		elif !undertale_mode && use_special && (Input.is_action_just_pressed("special_first") || Input.is_action_just_pressed("special_second") || Input.is_action_just_pressed("special_third") || Input.is_action_just_pressed("turn_off_special")):
			can_switch_back = false
			use_special = false
			mode_switch_visuals()
			emit_signal("bullet_cursor",0)
			
			emit_signal("is_first_special_activated",false)
			emit_signal("is_second_special_activated",false)
			emit_signal("is_third_special_activated",false )
			
			
	#dash takes keyboard input and check if there are any walls in the way  with raycast. Then dashes maximum distance acordintly
	if Input.is_action_just_pressed("dash") \
	&& can_dash \
	&& player_level > 0 \
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

	if Input.is_action_pressed("shoot") && !can_reload && !mouse_on_text_box:
		
		if undertale_mode:
			undertale_shoot()
		else:
			shoot()


func store_ammo(ammo_id):
		
	#if stored_ammo.size() == 0:
		#emit_signal("bullet_cursor",ammo_id)
	if stored_ammo.size() != magazine_size:
		stored_ammo.append(ammo_id)
		
		if stored_ammo.size() < 4:
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
	can_reload = false
	$ReloadingSound.random_pitch_play()
	if stored_ammo.size() > 2:
		emit_signal("next_ammo",stored_ammo[2])
	
	
func shoot():
	
	$PlayerArea/AnimatedSprite2D.animation = "standing_shooting"
	
	$PlayerArea/ShootgunParticles.emitting = true
	
	var bullet_path = ""
	
	$ShootingSound.random_pitch_play()

	can_reload = true
	just_shot = true

	if stored_ammo.size() == 0 or !use_special:
		bullet_path = bullet_dictionary[0]
		
		if player_level < 2:
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 5:
			bullet_instatiation(bullet_path,0)
			await get_tree().create_timer(0.1).timeout
			$ShootingSound.random_pitch_play()
			bullet_instatiation(bullet_path,0)
			
		else:
			bullet_instatiation(bullet_path,0)
			await get_tree().create_timer(0.01).timeout
			bullet_instatiation(bullet_path,PI/32)
			await get_tree().create_timer(0.02).timeout
			bullet_instatiation(bullet_path,-PI/32)
	else:
		
		if stored_ammo.size() > 3:
			emit_signal("next_ammo",stored_ammo[3])
		match  special_slot_chosen:
			0:
				bullet_path = bullet_dictionary[stored_ammo.pop_front()]
				emit_signal("shot_special")
			1:
				bullet_path = bullet_dictionary[stored_ammo[1]]
				stored_ammo.remove_at(1)
				emit_signal("shot_special2")
			2:
				bullet_path = bullet_dictionary[stored_ammo[2]]
				stored_ammo.remove_at(2)
				emit_signal("shot_special3")
				
		if player_level < 35:
			
			bullet_instatiation(bullet_path,0)
			
		elif player_level < 50:
			bullet_instatiation(bullet_path,0)
			bullet_instatiation(bullet_path,PI/8)
			bullet_instatiation(bullet_path,-PI/8)
			
		else:
			for bullet_counter in range(8):
				bullet_instatiation(bullet_path,(PI/4)*bullet_counter)
				
	
	if stored_ammo.size() > special_slot_chosen and use_special:
		emit_signal("bullet_cursor",stored_ammo[special_slot_chosen])
		
	elif can_switch_back:
		
		emit_signal("is_first_special_activated",false)
		emit_signal("is_second_special_activated",false)
		emit_signal("is_third_special_activated",false)
		
		emit_signal("bullet_cursor",0)
		use_special = false
		can_switch_back = false
		mode_switch_visuals()
		
	$RunningAnimTimer.start()
	$ReloadTimer.start()
	
#bullet is always instantiated before player extra rotation is there for adjusment
func bullet_instatiation(bullet_path,extra_rotation = 0):
	
	var instance = load(bullet_path).instantiate()
		
	instance.position = $PlayerArea/ShootingPoint.global_position
	
	if instance.name.contains("Lamp"):
		
		var instance_sprite = instance.get_node("AnimatedSprite2D")
		
		instance_sprite.rotation = $PlayerArea.rotation + extra_rotation
		instance.get_node("Body").rotation = instance_sprite.rotation
		instance.get_node("Edge").rotation = instance_sprite.rotation
		instance.get_node("InitialEdge").rotation = instance_sprite.rotation
		instance.get_node("PiercedBodies").rotation = instance_sprite.rotation

	else:	
		instance.rotation = $PlayerArea.rotation + extra_rotation
	
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
			1:
				display_text = "Dash Unlocked (space)"
			2:
				display_text = "Burst Mode Set"
			3:
				display_text = "Couch Special Unlocked"
			5:
				display_text = "Better Burst Mode Set"
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
		instance._display_message(str(special_slot_chosen+1) + "  Slot", "#8A4FFF", 25)
	
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

func mouse_on_text_box_state(on = true):
	mouse_on_text_box = on

func delay_enabling_of_shooting(on = true):
	if on:
		$BulletEnabledDelayTimer.start()
	elif !on:
		$BulletEnabledDelayTimer.stop()
