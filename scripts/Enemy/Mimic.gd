extends RigidBody2D

signal enemy_killed(xp,id)
signal stop_homming()

@export var crit_parts_pth = "res://scenes/CriticalParts.tscn"
@export var id = 11
@export var hp = 3
@export var xp = 1

var dead = false
var critical_parts 
var message_rotation = "middle"

var spawn_krtecek = false
@export var krtecek_pth = "res://scenes/Mimic/Krtecek.tscn";

func _ready() -> void:
	visible = false

func dig_out(Area2D):
	start_digging(true)
		
func dig_in(Area2D):
	start_digging(false)
	
func start_digging(player_in_range=false):
	if $AnimatedSprite2D.is_playing():
		return;
	elif player_in_range:
		$AnimatedSprite2D.play("emerge")
		if randi_range(0,1000) == 1:
			spawn_krtecek = true
		visible = true
	elif !player_in_range:
		$AnimatedSprite2D.play("hide")
	$DigSound.play()
	$DigParticles.emitting = true
	
func _spawn_krtecek():
	if spawn_krtecek && $AnimatedSprite2D.animation == "emerge" && $AnimatedSprite2D.frame == 2:
		var temp = load(krtecek_pth).instantiate()
		temp.position = position
		get_parent().add_child(temp)
		spawn_krtecek = false
		
func digging_finished():
	
	$DigParticles.emitting = false
	if $AnimatedSprite2D.animation == "emerge":
		
		if !$VissibilityArea.has_overlapping_areas():
			dig_in(null)
		else:
			$AnimatedSprite2D.animation = "stationary"
		
	elif $AnimatedSprite2D.animation == "hide":
		if $VissibilityArea.has_overlapping_areas():
			dig_out(null)
		else:
			visible = false
	
		
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

func flash():
	$AnimatedSprite2D.set_modulate(Color(100,100,100))
	if dead && 	$AnimatedSprite2D.animation != "burned":
		$AnimatedSprite2D.animation = "burned"
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color("ffffff")


func _delete_enemy(skip_fadding=false):
	
	if !skip_fadding:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0,0,0,0) , 0.5).set_ease(Tween.EASE_IN).set_delay(0.5)
	
		await tween.finished
	
	set_collision_layer_value(20,false)
	queue_free()


func _death(custom_death_sprite=false,crittical_hit=false,cond_type = "none"):
	
	if dead:
		return
		
	dead = true
	
	$CollisionShape2D.set_deferred("disabled", true)
	
		
	if crittical_hit:
				
		critical_parts.position = position
		$AnimatedSprite2D.visible = false
		
		critical_parts._launch_parts(id, true, cond_type)
		
	elif !custom_death_sprite:		
		$DeathParticles.emitting = true
		$AnimatedSprite2D.animation = "death"
			
	if $AnimatedSprite2D.get_node_or_null("PoopSticked") != null:
		var temp = $AnimatedSprite2D.get_node("PoopSticked")
		var main = get_parent()
		var area = temp.get_node("Area2D")
		temp.call_deferred("reparent",main,true)
		area.set_deferred("monitorable",true)
	
	$DeathTimer.start(0.5)
		
	$DeathSound.random_pitch_play()
	emit_signal("enemy_killed", xp, id)
	emit_signal("stop_homming")
		
