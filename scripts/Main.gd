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
var after_wave_display_special = false

var audio_tween : Tween

var config 


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

var player_level = 0
@export var initial_level = 0
var xp_needed : int
var current_xp : int

var special_slot_choosen = Node2D

@export_category("Reload Time Settings")
@export var initial_reload_time : float
@export var max_lvl_for_reload_decrease : int
@export var reload_max_decrease : float

@export_category("magazine Increase Settings")
@export var starting_magazine_size : int
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
var first_game = false   
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

var show_dialog = false

var dialog_progress = 0

var dialog_lines = {
	"id" : "Array",
	0:["Sup, Im your trusty companion","Just a quick heads up","You move with [W][A][S][D]","and shoot with LEFT MOUSE BUTTON"],
	1:["Congratulations, you unlocked DASH","You DASH with [SPACEBAR] into the direction you are running"],
	2:["Looks like you unlocked your first SPECIAL AMMUNITION","You gain SPECIAL AMMUNITION every few secconds",
		"SPECIAL AMMUNITION is stored in LINE (1,2,3,4....)",
		"You can select from first 3 possitions of that line by pressing [1][2][3] above [Q][W][E]",
		"and just SHOOT with LEFT MOUSE BUTTON ",
		"To switch to BASE AMMUNITION simply press [R]",
		"In case you forget there is MANUAL in your MENU"]
	}

var manual_progression = 0

func _ready():
	
	_load_save()
		
	$StartMenu/Button.pressed.connect(start_game)
	$StartMenu/ExitButton.pressed.connect(_exit_game)
	$StartMenu/ControlsButton.pressed.connect(_show_controls)
	$StartMenu/SaveButton.pressed.connect(_delete_save)
	$StartMenu/ManualButton.pressed.connect(_show_manual)
	
	enemy_initial_spawn_storage = size_of_enemy_group
	cursor_windows_size = DisplayServer.window_get_size()
	
	set_cursor(0)
	
	
func _process(_delta):
	
	
	var current_window_size = DisplayServer.window_get_size()
	if current_window_size == cursor_windows_size:
		set_cursor(current_bullet)
		
	if Input.is_action_just_pressed("shoot") && $FinalScore.is_finished_displaying:
		close_final_score()
		
	if game_running :
		if Input.is_action_just_pressed("force_menu"):
			force_menu()
		if Input.is_action_just_pressed("force_level_up"):
			leveled_up()
		if Input.is_action_just_pressed("force_special_mode"):
			_switch_mode_force_button()
		
		if mode_running:
			return
			
		if Input.is_action_just_pressed("special_first") && $PlayerUi/SpecialAmmoContainer.slot_ready:
			
			if !$PlayerUi/SpecialAmmoContainer.selected:
				
				special_slot_choosen = $PlayerUi/SpecialAmmoContainer
				
				special_slot_choosen.set_select(true)
				$PlayerUi/SpecialAmmoContainer2.set_select(false)
				$PlayerUi/SpecialAmmoContainer3.set_select(false)	
				player_instance.set_special(special_slot_choosen.slot_shell_name,true)
				
			elif $PlayerUi/SpecialAmmoContainer.selected:
				special_slot_choosen.set_select(false)
				player_instance.set_special()
				
				
		if Input.is_action_just_pressed("special_second") && $PlayerUi/SpecialAmmoContainer2.slot_ready:
			
			if !$PlayerUi/SpecialAmmoContainer2.selected:
				
				special_slot_choosen = $PlayerUi/SpecialAmmoContainer2
				
				special_slot_choosen.set_select(true)
				$PlayerUi/SpecialAmmoContainer.set_select(false)
				$PlayerUi/SpecialAmmoContainer3.set_select(false)
				player_instance.set_special(special_slot_choosen.slot_shell_name,true)
				
			elif $PlayerUi/SpecialAmmoContainer2.selected:
				special_slot_choosen.set_select(false)
				player_instance.set_special()
				
				
		if Input.is_action_just_pressed("special_third") && $PlayerUi/SpecialAmmoContainer3.slot_ready:
			
			if !$PlayerUi/SpecialAmmoContainer3.selected:
				
				special_slot_choosen = $PlayerUi/SpecialAmmoContainer3
				
				special_slot_choosen.set_select(true)
				$PlayerUi/SpecialAmmoContainer.set_select(false)
				$PlayerUi/SpecialAmmoContainer2.set_select(false)
				player_instance.set_special(special_slot_choosen.slot_shell_name,true)
				
			elif $PlayerUi/SpecialAmmoContainer3.selected:
				special_slot_choosen.set_select(false)
				player_instance.set_special()
		
		
		
func _switch_mode_force_button():
	
	_switch_mode("Undertale")
	
	if !$SpecialModeTimer.is_stopped():
		$SpecialModeTimer.stop()
		
		
	
func _switch_mode(_name):

	if !mode_running:
		$SpecialModeTimer.start()
		mode_running = true
		$PlayerUi/SpecialAmmoContainer.set_select(false)
		$PlayerUi/SpecialAmmoContainer2.set_select(false)
		$PlayerUi/SpecialAmmoContainer3.set_select(false)
		player_instance.set_special()
		
		
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
	
	await $NavigationRegion2D.bake_finished
	
	$NavigationRegion2D.call_deferred("bake_navigation_polygon")
	
	
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

func leveled_up(increase = 1):
	
	player_level += increase
	
	emit_signal("player_level_changed", player_level)
	
	var temp_lvl = player_level + 1
	
	#This progresivly shows manual pages and stores its value into save.
	if manual_progression < 5 && manual_progression < player_level/3:
		match player_level:
			3:
				manual_progression = 1	
				$StartMenu/ManualButton.visible = true
			6:
				manual_progression = 2
				$"ManualUI/Manual1-2/Page2/Piano".visible = true
			9:
				manual_progression = 3
				$"ManualUI/Manual3-4/Page3/Lampost".visible = true
			12:
				manual_progression = 4
				$"ManualUI/Manual3-4/Page3/Car".visible = true
			15:
				manual_progression = 5
				$"ManualUI/Manual3-4/Page4/House".visible = true
				
	
	#Xp formula
	xp_needed = round(pow(0.20*temp_lvl,3) + pow(0.15*temp_lvl,2) + 7)
	current_xp = xp_needed
	$PlayerUi/StatsUI/Experience.text = "Exp: " + "0/" + str(xp_needed)
	$PlayerUi/StatsUI/Level.text = "Level: " + str(player_level)
	
	
	target_amount_of_basic_enemies = target_amount_of_basic_enemies_dic[player_level]

	#Increase amount of special enemies that can be spawned
	#if player_level%levels_needed_for_special_increase == 0:
	special_enemy_start_value = floor(player_level/levels_needed_for_special_increase)
	
	# changes amount of enemies spawn bassed on level
	if player_level > 9 && max_size_of_enemy_group > size_of_enemy_group:
		size_of_enemy_group = player_level/4

	if player_level <= max_lvl_for_reload_decrease:
		
		var temp_reload_time = initial_reload_time -(reload_max_decrease / max_lvl_for_reload_decrease * player_level)
		emit_signal("set_reload_time", temp_reload_time)
		
	if player_level == 5 && $PlayerUi/SPButtonControler.slot_num == 0 \
	or player_level == 10 && $PlayerUi/SPButtonControler.slot_num == 1 \
	or player_level == 15 && $PlayerUi/SPButtonControler.slot_num == 2:	
		after_wave_display_special = true
		if !$StartMenu/CheckpointButton.button_pressed:
			initial_level = player_level
		
	if player_level == 8:
		boss_should_spawn = true
		which_boss = 1

		if initial_level < 8 && !$StartMenu/CheckpointButton.button_pressed:
			initial_level = 8
	
	if player_level == 14:
		boss_should_spawn = true
		which_boss = 2
		
		if initial_level < 14 && !$StartMenu/CheckpointButton.button_pressed: 
			initial_level = 14
		

func player_died():
	
	current_attempt = player_level
	game_running = false
	
	$SoundTrack.stop()
	$SoundTrack.volume_db = -50
	audio_tween.stop()
	$GameOverSound.play()
	
	$MeshBakerTimer.stop()
	
	$CheckForSpawning.stop()
	
	set_cursor(0)
	
	get_tree().call_group("enemy","player_is_dead")
	get_tree().call_group("bullets","queue_free")
	
	$PlayerUi/DashIndicator.visible = false
	
	$FinalScore.reset()
	
	await get_tree().create_timer(1.0).timeout
	$PlayerUi.visible = false
	$FinalScore.visible = true
	
	var boss_slayin = 0
	show_dialog = false
	
	if boss_is_active or boss_should_spawn:
		boss_slayin = which_boss -1
	else:
		boss_slayin = which_boss
		
	if boss_is_active && which_boss == 2:
				
		$InsideWalls/WallLeftTop.destroyed = false
		$InsideWalls/WallLeftBottom.destroyed = false
		$InsideWalls/WallRightTop.destroyed = false
		$InsideWalls/WallRightBottom.destroyed = false
		
		
	$FinalScore.show_score($PlayerUi/StatsUI/Kills.text, boss_slayin)
	
func close_final_score():
	$FinalScore.is_finished_displaying = false
	$IntroTrack.volume_db = 0
	$IntroTrack.play()
	
	$StartMenu.visible = true
	if mode_running:
		_switch_mode("reset")
	
	get_tree().call_group("sewage","_reset")
	#get_tree().call_group("walls","reset")
	
	


func force_menu():

	
	$SoundTrack.stop()
	$SoundTrack.volume_db = -50
	$IntroTrack.volume_db = 0
	$IntroTrack.play()
	audio_tween.stop()
	$MeshBakerTimer.stop()
	$CheckForSpawning.stop()
	get_tree().call_group("enemy","queue_free")
	get_tree().call_group("bullets","queue_free")
	
	if initial_level> 10 && !$StartMenu/CheckpointButton.button_pressed:
		get_tree().call_group("non_broken_walls","reset")
	else:
		get_tree().call_group("walls","reset")
		
	$PlayerUi.visible = false
	$PlayerUi/DashIndicator.visible = false
	$PlayerUi/ShotgunDialog.visible = false
	$StartMenu.visible = true
	
	game_running = false
	game_force_ended = true
	boss_should_spawn = false
	
	if boss_is_active && which_boss == 2:
				
		$InsideWalls/WallLeftTop.destroyed = false
		$InsideWalls/WallLeftBottom.destroyed = false
		$InsideWalls/WallRightTop.destroyed = false
		$InsideWalls/WallRightBottom.destroyed = false
		
	boss_is_active = false
	show_dialog = false
	DialogManager.reset_dialog_manager()
		
	boss_killed(true)
	if mode_running:
		_switch_mode("reset")
	
		
func start_game():
	
	
	if starting_game:
		return
		
	starting_game = true 
	
	get_tree().call_group("player_ui","reset")
	
	get_tree().call_group("enemy","queue_free")
	
	if $StartMenu/CheckpointButton.button_pressed:
		player_level = 0
	else:
		player_level = initial_level
		
	kill_counter = 0
	
	basic_enemy_counter = 0
	
	
	special_enemy_counter = 0
	
	special_enemy_start_value = 0
	
	size_of_enemy_group = enemy_initial_spawn_storage
	
	target_amount_of_basic_enemies = target_amount_of_basic_enemies_dic[player_level]
	
	xp_needed = 4
	
	current_xp = xp_needed
	
	boss_should_spawn = false
	
	#get_tree().call_group("walls","reset")
		
	$FinalScore.visible = false
	
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
	player_instance.special_shot.connect(special_shot)

	player_instance.dashed.connect($PlayerUi/DashIndicator.load_dash)
	
	$PlayerUi/DashIndicator.animation_finished.connect(player_instance.dash_reset)

	
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
		
	emit_signal("set_reload_time", initial_reload_time)
	
	await get_tree().create_timer(0.1).timeout
	
	$StartMenu.visible = false
	
	starting_game = false
	
	game_running = true
	
	if player_level > 0:
		leveled_up(0)
	
	audio_tween = get_tree().create_tween()
	
	audio_tween.set_ease(Tween.EASE_IN)
	$SoundTrack.play()
	audio_tween.tween_property($IntroTrack,"volume_db",-50,3)
	audio_tween.set_parallel()
	audio_tween.tween_property($SoundTrack,"volume_db",0,3)

	await audio_tween.finished
	$IntroTrack.stop()
	

	$MeshBakerTimer.start()
	
	
	await get_tree().create_timer(1.0).timeout
	
		
	#if show_dialog && dialog_progress == 0:
		#start_dialog()
	#else:	
	if game_running:
		spawn_enemy()

		if !boss_is_active and !boss_should_spawn:
			$CheckForSpawning.start()
	
func spawn_enemy():
	
	if after_wave_display_special:
		if !$CheckForSpawning.is_stopped():
			$CheckForSpawning.stop()
		show_special_choices()
		return
		
	#if show_dialog && dialog_progress > 0 && player_level != 0:
		#if !$CheckForSpawning.is_stopped():
			#$CheckForSpawning.stop()
		#start_dialog()
		#return	
		#
	if !game_running || boss_is_active:
		return
		
	if boss_should_spawn:
		spawn_boss()
		return
		
	
	#Calculates amount of special enemies that should be in each group Rounded up	

	var numb_of_groups = target_amount_of_basic_enemies /  float(size_of_enemy_group) 
	var numb_of_specials_per_group = special_enemy_start_value / numb_of_groups
	
	while basic_enemy_counter < target_amount_of_basic_enemies:
		
		enemy_spawn_point.progress_ratio = randf()
	
		var num_of_specials_in_current_group = 0
		
		for x in size_of_enemy_group:
			await get_tree().create_timer(0.0025).timeout
			
			var enemy_instance
			
			
			if special_enemy_counter < special_enemy_start_value && num_of_specials_in_current_group < numb_of_specials_per_group:
				match randi_range(1,2):
					1:
						enemy_instance = load("res://scenes/EnemyJumper.tscn").instantiate()
					2:
						enemy_instance = load("res://scenes/EnemyThrower.tscn").instantiate()
				special_enemy_counter +=1
				num_of_specials_in_current_group += 1

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

			
			if basic_enemy_counter == target_amount_of_basic_enemies:
				break
	
	
func spawn_boss():
	
	$PlayerUi/TextureProgressBar.boss_spawned() 
	
	var enemy_instance
	
	match which_boss:
		1:
			enemy_instance = load("res://scenes/BossSmasher.tscn").instantiate()
			$PlayerUi/TextureProgressBar.texture_progress = load("res://sprites/UI/Boss/HealthBar/Progress.png")
		2:
			$CheckForSpawning.stop()
			enemy_instance = load("res://scenes/BossDoubleThrower.tscn").instantiate()
			
			if mode_running:
				enemy_instance._switch_mode("Undertale")
				$InsideWalls/WallLeftTop.destroyed = true
				$InsideWalls/WallLeftBottom.destroyed = true
				$InsideWalls/WallRightTop.destroyed = true
				$InsideWalls/WallRightBottom.destroyed = true
			else:
				get_tree().call_group("second_boss_arena","destroy") 
			$PlayerUi/TextureProgressBar.texture_progress = load("res://sprites/UI/Boss/HealthBar/DoubleThrowerProgress.png")
		3:
			enemy_instance = null

	call_deferred("add_child",enemy_instance)
	
	boss_should_spawn = false
	boss_is_active = true
	$PlayerUi/TextureProgressBar.max_value = enemy_instance.hp_max
	$PlayerUi/TextureProgressBar.value = enemy_instance.hp_max
	
	if !mode_running && which_boss == 2:
		await get_tree().create_timer(3.5).timeout
		$NavigationRegion2D.call_deferred("bake_navigation_polygon")
		
	
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
	
	$CheckForSpawning.start()


func boss_killed(by_menu=false):
	boss_is_active = false
	$PlayerUi/TextureProgressBar.visible = false
	recieved_xp(0)
	
	if $CheckForSpawning.is_stopped() && game_running:
		$CheckForSpawning.start()
	
	if !by_menu && !$StartMenu/CheckpointButton.button_pressed:
		if initial_level == 8:
				initial_level = 9
		elif initial_level == 14:
			initial_level = 15
	
	
	
func check_for_alive_enemies():
	
	if !$EnemiesInArea.has_overlapping_bodies():
		special_enemy_counter = 0
		basic_enemy_counter = 0
		
		if boss_is_active:	
			
			if which_boss == 2:
				return
			
			var temp = self.get_node("BossSmasher")
			temp = temp.get_node("SpawnAddsTimer")
		
			if temp.is_stopped():
				get_tree().call_group("smasher","start_add_timer")
				$CheckForSpawning.stop()
				return
				
		else:
			spawn_enemy()


func set_cursor(bullet_id):
	var cursor_size = DisplayServer.window_get_size()
	
	if cursor_size.y < 900:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+2]),Input.CursorShape.CURSOR_ARROW,Vector2(18,18))
	elif cursor_size.y < 1340:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+12]),Input.CursorShape.CURSOR_ARROW,Vector2(36,36))
	else:
		Input.set_custom_mouse_cursor(load(cursor_dict[bullet_id+22]),Input.CursorShape.CURSOR_ARROW,Vector2(54,54))
	
	current_bullet = bullet_id


func _bake_mesh():
	$NavigationRegion2D.bake_navigation_polygon(true)


func _entering_arena(body):
	body.falling_down_from_wall()

#Temp to convert generic array into Array[String] so the Dialog manager shuts the fuck up
func start_dialog():
	var temp : Array[String]
	temp.assign(dialog_lines[dialog_progress])
	$PlayerUi/ShotgunDialog.visible = true
	DialogManager.start_dialog(Vector2(200,800),temp)

func show_special_choices():
	after_wave_display_special = false
	match $PlayerUi/SPButtonControler.slot_num:
		0:
			$PlayerUi/SPButtonControler.set_buttons(["Couch","Doggy","Nails"])
		1:
			$PlayerUi/SPButtonControler.set_buttons(["Lamppost","UtilityPole","Piano"])
		2:
			$PlayerUi/SPButtonControler.set_buttons(["Shotgun","Car","Closet"])
	
	await $PlayerUi/SPButtonControler.special_ammo_chosen
	spawn_enemy()
	if $CheckForSpawning.is_stopped():
		$CheckForSpawning.start()


func dialog_finished():
	$PlayerUi/ShotgunDialog.visible = false
	show_dialog = false
	dialog_progress += 1
	$CheckForSpawning.start()


func _exit_game():
	_save()
	get_tree().quit()


func _show_controls():
	$Controls.visible = true


func _show_manual():
	$ManualUI.visible = true


func _save(save_volume=true,overwrite_dialog_and_manual=true):
	config.set_value("game","initial_level",initial_level)
	config.set_value("game","checkpoints_enabled",$StartMenu/CheckpointButton.is_pressed())
	config.set_value("game","second_chance_counter", second_chance_counter)
	config.set_value("game","regen_gained", regen_gained)
	config.set_value("game","first_game", first_game)
	config.set_value("game","corner_walls_destroyed", $InsideWalls/WallLeftTop.destroyed)
	
	config.set_value("game","first_slot",$PlayerUi/SpecialAmmoContainer.slot_shell_name)
	config.set_value("game","second_slot",$PlayerUi/SpecialAmmoContainer2.slot_shell_name)
	config.set_value("game","third_slot",$PlayerUi/SpecialAmmoContainer3.slot_shell_name)
	config.set_value("game","slot_num",$PlayerUi/SPButtonControler.slot_num)


	if save_volume:
		config.set_value("game","sfx",$StartMenu/SFXSlider.value)
		config.set_value("game","music",$StartMenu/MusicSlider.value)
		
	if overwrite_dialog_and_manual:
		config.set_value("game","dialog_progress", dialog_progress)
		config.set_value("game","manual_progression",manual_progression)
		
	config.save("user://scores.cfg")
	
	
func _load_save():
	
	config = ConfigFile.new()
	
	if FileAccess.file_exists("user://scores.cfg"):
		
		config.load("user://scores.cfg")

		initial_level = config.get_value("game","initial_level")
		second_chance_counter = config.get_value("game","second_chance_counter", second_chance_counter)
		regen_gained = config.get_value("game","regen_gained", regen_gained)
		first_game = config.get_value("game","first_game", first_game)
		dialog_progress = config.get_value("game","dialog_progress", dialog_progress)
		manual_progression = config.get_value("game","manual_progression", manual_progression)
		$StartMenu/CheckpointButton.set_pressed(config.get_value("game","checkpoints_enabled"))
		$StartMenu/SFXSlider.value = config.get_value("game","sfx")
		$StartMenu/MusicSlider.value = config.get_value("game","music")
		
		$PlayerUi/SpecialAmmoContainer.set_shell(config.get_value("game","first_slot","Empty"))
		$PlayerUi/SpecialAmmoContainer2.set_shell(config.get_value("game","second_slot","Empty"))
		$PlayerUi/SpecialAmmoContainer3.set_shell(config.get_value("game","third_slot","Empty"))
		$PlayerUi/SPButtonControler.slot_num = config.get_value("game","slot_num", 0)

		if config.get_value("game","corner_walls_destroyed") == true:
			$InsideWalls/WallLeftTop.destroyed = true
			$InsideWalls/WallLeftBottom.destroyed = true
			$InsideWalls/WallRightTop.destroyed = true
			$InsideWalls/WallRightBottom.destroyed = true
			
			$InsideWalls/WallLeftTop.animation_destroyed_finished()
			$InsideWalls/WallLeftBottom.animation_destroyed_finished()
			$InsideWalls/WallRightTop.animation_destroyed_finished()
			$InsideWalls/WallRightBottom.animation_destroyed_finished()
			
		for value in manual_progression+1:
			match value:
				1:
					$StartMenu/ManualButton.visible = true
				2:
					$"ManualUI/Manual1-2/Page2/Piano".visible = true
				3:
					$"ManualUI/Manual3-4/Page3/Lampost".visible = true
				4:
					$"ManualUI/Manual3-4/Page3/Car".visible = true
				5:
					$"ManualUI/Manual3-4/Page4/House".visible = true
				
func _delete_save():
	
	if FileAccess.file_exists("user://scores.cfg"):
		
		initial_level = 0
		second_chance_counter = 0
		show_dialog = true
		regen_gained = false
		first_game = true
		$StartMenu/CheckpointButton.button_pressed = false
		
		#This also replaces dialog and manual progresion. It is purelly for testing
		dialog_progress = 0
		manual_progression = 0
		$InsideWalls/WallLeftTop.destroyed = false
		$InsideWalls/WallLeftBottom.destroyed = false
		$InsideWalls/WallRightTop.destroyed = false
		$InsideWalls/WallRightBottom.destroyed = false		
		$PlayerUi/SPButtonControler.reset_slots()
		
		_save(false,true)
	
	get_tree().call_group("sewage","_reset")
	get_tree().call_group("walls","reset")

func special_shot():
	special_slot_choosen.slot_used()
