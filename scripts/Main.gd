extends Node

signal switch_mode(name)

signal set_magazine_size(amount)

signal set_reload_time(amount)

signal generated_special_ammo(ammo_id)

signal player_level_changed(level)

var player_instance

var mode_running = false

var kill_counter : int

var basic_enemy_counter : int

var target_amount_of_basic_enemies : int

var current_bullet : int

var starting_game = false

var game_running = false

var game_force_ended = false
#stores windows size before cursor change
var cursor_windows_size : Vector2i

@export var target_amount_of_basic_enemies_dic= {
	"player level" : "amount of enemies",
	0: 6,
	1: 8,
	2: 8,
	3: 10,
	4: 11,
	5: 12,
	6: 4,
	7: 5,
	8: 5,
	9: 6,
	10: 6,
	11: 7,
	12: 7,
	13: 8,
	14: 8,
	15: 9,
	16: 9,
	17: 10,
	18: 10,
	19: 11,
	20: 11,
	21: 12,
	22: 12,
	23: 13,
	24: 13,
	25: 14,
	26: 14,
	27: 15,
	28: 15,
	29: 16,
	30: 16,
	31: 17,
	32: 17,
	33: 18,
	34: 18,
	35: 19,
	36: 19,
	37: 20,
	38: 20,
	39: 21,
	40: 21,
	41: 22,
	42: 22,
	43: 23,
	44: 23,
	45: 24,
	46: 24,
	47: 25,
	48: 25,
	49: 26,
	50: 26
}

@export_category("Player leveling settings")

@export var player_level = 0
var xp_needed : int
var current_xp : int

@export_category("Special Ammo Generation Settings")
@export var initial_special_ammo_time : float
@export var max_lvl_for_special_generator : int
@export var special_ammo_max_decrease: float
var special_ammo_range = 0


@export_category("Reload Time Settings")
@export var initial_reload_time : float
@export var max_lvl_for_reload_decrease : int
@export var reload_max_decrease : float

@export_category("magazine Increase Settings")
@export var lvls_needed_for_mag_increase : int

@export_category("Enemy Spawn settings")
@export var size_of_enemy_group : int
@export var max_size_of_enemy_group: int
@export var initial_enemy_spawn_time : float
@export var max_lvl_for_enemy_spawner : int
@export var enemy_spawn_max_decrease : float
@export var special_enemy_start_value : int
@export var levels_needed_for_special_increase : int

@export_category("Second Chance")
var first_game = true    
var second_chance_counter = 0;
var previous_attempt = 0;
var current_attempt = 0;
var regen_gained = false
@export var second_chance_fail_mark : int
@export var second_chance_regen_fail_mark : int

var enemy_spawn_point
var special_enemy_counter : int
var enemy_initial_spawn_storage

var boss_should_spawn = false
var boss_is_active = false
var which_boss = 0



var cursor_dict = {
	"id" : "path",
	 1 : "res://sprites/UI/Cursors/720p/CursorUndertaleMode.png",
	 2 : "res://sprites/UI/Cursors/720p/Cursor.png",
	 3 : "res://sprites/UI/Cursors/720p/CursorCouch.png",
	 4 : "res://sprites/UI/Cursors/720p/CursorPiano.png",
	 5 : "res://sprites/UI/Cursors/720p/CursorLamp.png",
	 6 : "res://sprites/UI/Cursors/720p/CursorCar.png",
	 7 : "res://sprites/UI/Cursors/720p/CursorHouse.png",	
	 11 : "res://sprites/UI/Cursors/1080p/CursorUndertaleMode.png",
	 12 : "res://sprites/UI/Cursors/1080p/Cursor.png",
	 13 : "res://sprites/UI/Cursors/1080p/CursorCouch.png",
	 14 : "res://sprites/UI/Cursors/1080p/CursoPiano.png",
	 15 : "res://sprites/UI/Cursors/1080p/CursoLamp.png",
	 16 : "res://sprites/UI/Cursors/1080p/CursorCar.png",
	 17 : "res://sprites/UI/Cursors/1080p/CursoHouse.png",
	 21 : "res://sprites/UI/Cursors/1440p/CursorUndertaleMode.png",
	 22 : "res://sprites/UI/Cursors/1440p/Cursor.png",
	 23 : "res://sprites/UI/Cursors/1440p/CursorCouch.png",
	 24 : "res://sprites/UI/Cursors/1440p/CursorPiano.png",
	 25 : "res://sprites/UI/Cursors/1440p/CursorLamp.png",
	 26 : "res://sprites/UI/Cursors/1440p/CursorCar.png",
	 27 : "res://sprites/UI/Cursors/1440p/CursorHouse.png"
}

func _ready():
	$StartMenu/Button.pressed.connect(start_game)
	$StartMenu/ExitButton.pressed.connect(_exit_game)
	$StartMenu/ControlsButton.pressed.connect(_show_controls)
	enemy_initial_spawn_storage = size_of_enemy_group
	cursor_windows_size = DisplayServer.window_get_size()
	set_cursor(0)
	
func _process(delta):
	
	
	var current_window_size = DisplayServer.window_get_size()
	if current_window_size == cursor_windows_size:
		set_cursor(current_bullet)
	if Input.is_action_just_pressed("force_menu") && game_running:
		force_menu()
	if Input.is_action_just_pressed("force_level_up") && game_running:
		leveled_up()
	
func _switch_mode(_name):

	var cursor_size = DisplayServer.window_get_size()
	
	if !mode_running:
		$SpecialModeTimer.start()
		mode_running = true
		
		set_cursor(-1)

		$EdgeWalls.animation = "undertale_wall"
		get_tree().call_group("sewage","change_sewage_state",false)
	else:
		mode_running = false
		
		if player_instance.use_special:
			player_instance.emit_signal("bullet_cursor",player_instance.stored_ammo[player_instance.special_slot_chosen])
		else:
			set_cursor(0)
			
		$EdgeWalls.animation = "wall"
		get_tree().call_group("sewage","change_sewage_state",true)
		
	$ModeBackgroundEdge.visible = !$ModeBackgroundEdge.visible
	get_tree().call_group("bullets", "delete_bullet")
	get_tree().call_group("portals","dissapear")
	emit_signal("switch_mode", name)
	
	get_tree().call_group("walls","_switch_visibility_collision")
	
	await get_tree().create_timer(0.1).timeout
	
	$NavigationRegion2D.bake_navigation_polygon()
	
	
func mode_timeout():
	_switch_mode("reset")

func recieved_xp(amount):
	
	current_xp -= amount
	kill_counter += 1
	
	$PlayerUi/StatsUI/Kills.text = str(kill_counter)
	
	if current_xp <= 0:
		leveled_up()
	else :
		$PlayerUi/StatsUI/Experience.text = "Exp: " + str(xp_needed-current_xp) + "/" + str(xp_needed)


func generate_special_ammo():
	# Player special ammo generator add new type of ammo every 5 levels
		var ammo_id = 0
		if player_level < 20:
			ammo_id = randi_range(1, special_ammo_range)
		else:
			ammo_id = randi_range(2, special_ammo_range)
		emit_signal("generated_special_ammo" , ammo_id )


func leveled_up():
	
	
	target_amount_of_basic_enemies = target_amount_of_basic_enemies_dic[player_level]
	
	player_level += 1
	
	emit_signal("player_level_changed", player_level)
	
	var temp_lvl = player_level + 1
	
	
	
	#Xp formula
	xp_needed = round(pow(0.20*temp_lvl,3) + pow(0.15*temp_lvl,2) + 7)
	current_xp = xp_needed
	$PlayerUi/StatsUI/Experience.text = "Exp: " + "0/" + str(xp_needed)
	$PlayerUi/StatsUI/Level.text = "Level: " + str(player_level)
	
	#Adds new special amunition id to range
	if special_ammo_range < 5:
		special_ammo_range = player_level/3
		if special_ammo_range > 5:
			special_ammo_range = 5
			
	if $SpecialAmmoTimer.is_stopped() and player_level > 2:
			$SpecialAmmoTimer.start()

	
	#Increase amount of special enemies that can be spawned
	if player_level%levels_needed_for_special_increase == 0:
		special_enemy_start_value = player_level/levels_needed_for_special_increase
	
	# changes amount of enemies spawn bassed on level
	if player_level > 9 && max_size_of_enemy_group > size_of_enemy_group:
		size_of_enemy_group = player_level/2
	

	if player_level <= max_lvl_for_special_generator:
		
		$SpecialAmmoTimer.wait_time = initial_special_ammo_time -((special_ammo_max_decrease/ max_lvl_for_special_generator) * player_level)
		
	if player_level % lvls_needed_for_mag_increase == 0:
		emit_signal("set_magazine_size" , $Player.magazine_size + 1)


	if player_level <= max_lvl_for_reload_decrease:
		
		var temp_reload_time = initial_reload_time -(reload_max_decrease / max_lvl_for_reload_decrease * player_level)
		
		emit_signal("set_reload_time", temp_reload_time)
		
	if player_level == 5:
		boss_should_spawn = true
		which_boss = 1
	
	if player_level == 10:
		boss_should_spawn = true
		which_boss = 2

	#if player_level <= max_lvl_for_enemy_spawner:
		#$EnemySpawnTimer.wait_time = initial_enemy_spawn_time - (enemy_spawn_max_decrease / max_lvl_for_enemy_spawner * player_level)
	#
	#else:
		#$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time/55 * 54
	#
	##$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time*(float(basic_enemy_counter)+1/float(target_amount_of_basic_enemies))
	#
#Not used because it kept breaking
func special_magazine_state_changed():
	if !$SpecialAmmoTimer.is_stopped():
		$SpecialAmmoTimer.stop()
		
	else:
		$SpecialAmmoTimer.start()


func player_died():
	
	current_attempt = player_level
	game_running = false
	
	$SoundTrack.stop()
	$SoundTrack.volume_db = 0
	$GameOverSound.play()
	
	$MeshBakerTimer.stop()
	
	#$EnemySpawnTimer.stop()
	$SpecialAmmoTimer.stop()
	
	set_cursor(0)
	
	get_tree().call_group("enemy","player_is_dead")
	get_tree().call_group("bullets","queue_free")
	
	await get_tree().create_timer(1.0).timeout
	$IntroTrack.volume_db = 0
	$IntroTrack.play()
	
	$PlayerUi.visible = false
	$StartMenu.visible = true
	if mode_running:
		_switch_mode("reset")
	
	get_tree().call_group("sewage","_reset")
	

func force_menu():

	
	$SoundTrack.stop()
	$SoundTrack.volume_db = 0
	$IntroTrack.volume_db = 0
	$IntroTrack.play()
	$MeshBakerTimer.stop()
	$SpecialAmmoTimer.stop()
	get_tree().call_group("enemy","queue_free")
	get_tree().call_group("bullets","queue_free")
	game_running = false
	$PlayerUi.visible = false
	$StartMenu.visible = true
	game_force_ended = true
	if mode_running:
		_switch_mode("reset")
		
func start_game():
	
	
	if starting_game:
		return
		
	starting_game = true 
	
	get_tree().call_group("player_ui","reset")
	
	get_tree().call_group("enemy","queue_free")
	
	var cursor_size = DisplayServer.window_get_size()
		
	player_level = 9
		
	kill_counter = 0
	
	basic_enemy_counter = 0
	
	special_ammo_range = 0
	
	special_enemy_counter = 0
	
	special_enemy_start_value = 0
	
	size_of_enemy_group = enemy_initial_spawn_storage
	
	target_amount_of_basic_enemies = target_amount_of_basic_enemies_dic[player_level]
	
	xp_needed = round(pow(0.1,3) + pow(0.15,2) + 4)
	
	current_xp = xp_needed
	
	boss_should_spawn = false
	
	get_tree().call_group("walls","reset")
		
	$PlayerUi.visible = true
	$PlayerUi/StatsUI/Kills.text = "O"
	$PlayerUi/StatsUI/Level.text = "Level: 0"
	$PlayerUi/StatsUI/Experience.text = "Exp: " + "0/" + str(current_xp)
	
	await get_tree().create_timer(0.5).timeout

	player_instance = load("res://scenes/Player.tscn").instantiate()
	enemy_spawn_point = $EnemySpawnPath/EnemySpawnPoint
	add_child(player_instance)
	
		
	player_instance.position = $StartPoint.position
	player_instance.player_died.connect(player_died)
	
	player_instance.shot_special.connect($PlayerUi/AmmoSpriteContainer.move_ammo_up)
	player_instance.shot_special2.connect($PlayerUi/AmmoSpriteContainer2.move_ammo_up)
	player_instance.shot_special3.connect($PlayerUi/AmmoSpriteContainer3.move_ammo_up)
		
	player_instance.is_first_special_activated.connect($PlayerUi/AmmoSpriteContainer.is_slot_active)
	player_instance.is_second_special_activated.connect($PlayerUi/AmmoSpriteContainer2.is_slot_active)
	player_instance.is_third_special_activated.connect($PlayerUi/AmmoSpriteContainer3.is_slot_active)
	
	player_instance.next_ammo.connect($PlayerUi/AmmoSpriteContainer.set_ammo)
	player_instance.bullet_cursor.connect(set_cursor)
	
	$PlayerUi/AmmoSpriteContainer.is_slot_active(false)
	$PlayerUi/AmmoSpriteContainer2.is_slot_active(false)
	$PlayerUi/AmmoSpriteContainer3.is_slot_active(false)
	
	if boss_is_active:
		boss_is_active = false
		$PlayerUi/TextureProgressBar.visible = false
	
	if !game_force_ended:
		if regen_gained:
			player_instance.second_chance_on(true)	
		else:
			if first_game:
				first_game = false
			elif current_attempt <= previous_attempt:
				second_chance_counter += 1
			elif second_chance_counter > 2:
				second_chance_counter = 2
			elif second_chance_counter > 0:
				second_chance_counter -= 1
				
			if second_chance_counter >= second_chance_regen_fail_mark:
				regen_gained = true
				player_instance.second_chance_on(true)
			elif second_chance_counter >= second_chance_fail_mark:
				player_instance.second_chance_on()
			
			if previous_attempt < current_attempt:
				previous_attempt = current_attempt
		
		player_instance.previous_best_level = previous_attempt
		
	$SpecialAmmoTimer.wait_time = initial_special_ammo_time	
	#$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time*((float(basic_enemy_counter)+1)/float(target_amount_of_basic_enemies))

	emit_signal("set_reload_time", initial_reload_time)
	
	await get_tree().create_timer(0.1).timeout
	
	$StartMenu.visible = false
	
	starting_game = false
	
	game_running = true
	
	var tween = get_tree().create_tween()
	tween.tween_property($IntroTrack,"volume_db",-20,2)
	tween.tween_property($SoundTrack,"volume_db",0,1)

	$IntroTrack.stop()
	$SoundTrack.play()

	$MeshBakerTimer.start()
	
	if player_level > 0:
		leveled_up()

	await get_tree().create_timer(3.0).timeout
	
	spawn_enemy()

	
func spawn_enemy():
	
	if !game_running :
		return
		
	if boss_should_spawn:
		spawn_boss()
		return
		
	while basic_enemy_counter < target_amount_of_basic_enemies:
		
		enemy_spawn_point.progress_ratio = randf()
		var spawned_special = false
	
		
		for x in size_of_enemy_group:
			await get_tree().create_timer(0.0025).timeout
			
			var enemy_instance
			
			if special_enemy_counter < special_enemy_start_value:
				match randi_range(1,2):
					1:
						enemy_instance = load("res://scenes/EnemyJumper.tscn").instantiate()
					2:
						enemy_instance = load("res://scenes/EnemyThrower.tscn").instantiate()
				special_enemy_counter +=1
				spawned_special = true
			else:			
				enemy_instance = load("res://scenes/Enemy.tscn").instantiate()
				if player_level < 8:
					enemy_instance.hp = 3
				basic_enemy_counter += 1
				
			call_deferred("add_child",enemy_instance)
			var position_adjusment = Vector2(randi_range(-250,250),randi_range(-250,250))
			enemy_instance.position = enemy_spawn_point.global_position + position_adjusment
			enemy_instance.enemy_killed.connect(recieved_xp)
			
			if mode_running:
				enemy_instance._switch_mode("undertale")		

		if basic_enemy_counter >= target_amount_of_basic_enemies+player_level/3:
			$EnemySpawnTimer.stop()
		
	
func spawn_boss():
	
	$PlayerUi/TextureProgressBar.smasher_spawned() 
	
	var enemy_instance
	
	match which_boss:
		1:
			enemy_instance = load("res://scenes/BossSmasher.tscn").instantiate()
			$PlayerUi/TextureProgressBar.texture_progress = load("res://sprites/UI/Boss/HealthBar/Progress.png")
		2:
			enemy_instance = load("res://scenes/BossDoubleThrower.tscn").instantiate()
			$PlayerUi/TextureProgressBar.texture_progress = load("res://sprites/UI/Boss/HealthBar/DoubleThrowerProgess.png")
		3:
			enemy_instance = null

	call_deferred("add_child",enemy_instance)
	enemy_spawn_point.progress_ratio = randf()

	enemy_instance.position = enemy_spawn_point.global_position
	boss_should_spawn = false
	boss_is_active = true
	$PlayerUi/TextureProgressBar.max_value = enemy_instance.hp_max
	$PlayerUi/TextureProgressBar.value = enemy_instance.hp_max
	
	
func spawn_smasher_adds():
	
	var enemy_instance
	for x in 4:
		enemy_instance = load("res://scenes/Enemy.tscn").instantiate()
		call_deferred("add_child",enemy_instance)
		
		enemy_spawn_point.progress_ratio = 0.25*(x+1)
		enemy_instance.position = enemy_spawn_point.global_position
		enemy_instance.speed = 400
		enemy_instance.hp = 1
		basic_enemy_counter += 1


func boss_killed():
	boss_is_active = false
	$PlayerUi/TextureProgressBar.visible = false
	spawn_enemy()
	
	
func decrease_basic_enemy_counter():
	if !$EnemiesInArea.has_overlapping_bodies():
		special_enemy_counter = 0
		basic_enemy_counter = 0
		if boss_is_active:
			get_tree().call_group("smasher","start_add_timer")
			return
			
		if boss_should_spawn:
			spawn_boss()
		else:
			spawn_enemy()

	
func decrease_special_enemy_counter():
	if !$EnemiesInArea.has_overlapping_bodies():
		special_enemy_counter = 0
		basic_enemy_counter = 0
		if boss_should_spawn:
			spawn_boss()
		else:
			spawn_enemy()

func set_cursor(bullet_id):
	var cursor_size = DisplayServer.window_get_size()
	
	if cursor_size.y < 900:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+2]),0,Vector2(18,18))
	elif cursor_size.y < 1340:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+12]),0,Vector2(36,36))
	else:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+22]),0,Vector2(54,54))
	
	current_bullet = bullet_id

func _bake_mesh():
	$NavigationRegion2D.bake_navigation_polygon(true)


func _entering_arena(body):
	body.falling_down_from_wall()

func _exit_game():
	get_tree().quit()

func _show_controls():
	$Controls.visible = true
