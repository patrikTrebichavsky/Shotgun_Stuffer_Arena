extends Node

signal switch_mode(name)

signal set_magazine_size(amount)

signal set_reload_time(amount)

signal generated_special_ammo(ammo_id)

signal player_level_changed(level)


var mode_running = false

var kill_counter : int

var basic_enemy_counter : int

var target_amount_of_basic_enemies : int

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

var enemy_spawn_point
var special_enemy_counter : int
var enemy_initial_spawn_storage

var cursor_dict = {
	"id" : "path",
	 1 : "res://sprites/UI/Cursor.png",
	 2 : "res://sprites/UI/CursorUndertaleMode.png"
}

func _ready():
	$Control/Button.pressed.connect(start_game)
	enemy_initial_spawn_storage = size_of_enemy_group
	
func _switch_mode(_name):
	
	if !mode_running:
		$SpecialModeTimer.start()
		mode_running = true
		Input.set_custom_mouse_cursor(load(cursor_dict[2]))
	else:
		mode_running = false
		Input.set_custom_mouse_cursor(load(cursor_dict[1]))
		
	$ModeBackgroundEdge.visible = !$ModeBackgroundEdge.visible
	get_tree().call_group("bullets", "delete_bullet")
	emit_signal("switch_mode", name)
	
	
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
		elif player_level <  40:
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
		

	if player_level <= max_lvl_for_enemy_spawner:
		$EnemySpawnTimer.wait_time = initial_enemy_spawn_time - (enemy_spawn_max_decrease / max_lvl_for_enemy_spawner * player_level)
	
	else:
		$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time/55 * 54
	
	#$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time*(float(basic_enemy_counter)+1/float(target_amount_of_basic_enemies))
	
#Not used because it kept breaking
func special_magazine_state_changed():
	if !$SpecialAmmoTimer.is_stopped():
		$SpecialAmmoTimer.stop()
		
	else:
		$SpecialAmmoTimer.start()


func player_died():
	
	
	$EnemySpawnTimer.stop()
	$SpecialAmmoTimer.stop()
	
	get_tree().call_group("enemy","player_is_dead")
	
	await get_tree().create_timer(1.0).timeout
	$PlayerUi.visible = false
	$Control.visible = true
		
func start_game():
	
	$Control.visible = false
	
	get_tree().call_group("player_ui","reset")
	
	get_tree().call_group("enemy","queue_free")
		
	player_level = 0
		
	kill_counter = 0
	
	basic_enemy_counter = 0
	
	special_ammo_range = 0
	
	special_enemy_counter = 0
	
	special_enemy_start_value = 0
	
	size_of_enemy_group = enemy_initial_spawn_storage
	
	target_amount_of_basic_enemies = target_amount_of_basic_enemies_dic[player_level]
	
	print(target_amount_of_basic_enemies)
	
	xp_needed = round(pow(0.1,3) + pow(0.15,2) + 4)
	
	current_xp = xp_needed
	
	$PlayerUi.visible = true
	$PlayerUi/StatsUI/Kills.text = "O"
	$PlayerUi/StatsUI/Level.text = "Level: 0"
	$PlayerUi/StatsUI/Experience.text = "Exp: " + "0/" + str(current_xp)
	
	
	var player_instance = load("res://scenes/Player.tscn").instantiate()
	enemy_spawn_point = player_instance.get_node("EnemySpawnPath/EnemySpawnPoint")
	add_child(player_instance)
		
	player_instance.position = $StartPoint.position
	player_instance.player_died.connect(player_died)
	
	player_instance.shot_special.connect($PlayerUi/AmmoSpriteContainer.move_ammo_up)
	player_instance.next_ammo.connect($PlayerUi/AmmoSpriteContainer.set_ammo)
	
	$SpecialAmmoTimer.wait_time = initial_special_ammo_time
	$EnemySpawnTimer.wait_time = initial_enemy_spawn_time
	
	#$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time*((float(basic_enemy_counter)+1)/float(target_amount_of_basic_enemies))

	emit_signal("set_reload_time", initial_reload_time)
	
	$EnemySpawnTimer.start()

	if player_level > 0:
		leveled_up()
	
	
	
func spawn_enemy():
	
	enemy_spawn_point.progress_ratio = randf()
	
	var spawned_special = false
	
	for x in size_of_enemy_group:
		
		var enemy_instance
		
		enemy_instance = load("res://scenes/EnemyThrower.tscn").instantiate()
		
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
			
		add_child(enemy_instance)
		var position_adjusment = Vector2(randi_range(-250,250),randi_range(-250,250))
		enemy_instance.position = enemy_spawn_point.global_position + position_adjusment
		enemy_instance.enemy_killed.connect(recieved_xp)
		
		if mode_running:
			enemy_instance._switch_mode("undertale")		
		
	#$EnemySpawnTimer.wait_time = initial_enemy_spawn_time - (enemy_spawn_max_decrease / max_lvl_for_enemy_spawner * player_level)
	#$EnemySpawnTimer.wait_time = $EnemySpawnTimer.wait_time*(float(basic_enemy_counter+1)/float(target_amount_of_basic_enemies))
	#
	if basic_enemy_counter >= target_amount_of_basic_enemies+player_level/3:
		$EnemySpawnTimer.stop()
			
func decrease_basic_enemy_counter():
	basic_enemy_counter -= 1
	if basic_enemy_counter < target_amount_of_basic_enemies-player_level/3:
		$EnemySpawnTimer.start()
	
func decrease_special_enemy_counter():
	special_enemy_counter -= 1
