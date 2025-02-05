extends Bullet_Base

class_name Car

@export var explo_push_back : float
@export var explo_dmg : int
@export var burn_damage : int
@export var explosion_max_size : Vector2
@export var explosion_size_increase : float

var sprite : AnimatedSprite2D
var explo_collider : Area2D
var wheels_not_shot = true
var exploaded = false


func  _ready():
	
	sprite = get_node("ExplosionSprites")
	explo_collider = get_node("CarExplosionArea")
	sprite.visible = false
	
func _physics_process(delta):


	if exploaded && explosion_max_size >= sprite.scale:
		sprite.scale *= explosion_size_increase
		explo_collider.scale = sprite.scale
		
		if explo_collider.monitoring && sprite.scale >= explosion_max_size:
			
			for body in $CarExplosionArea.get_overlapping_bodies():
				if !body.name.contains("Wall"):
					$CarSprite.visible = false
					if body == targeted_enemy:
						
						var push_back = ((body.position-position).normalized()) * push_back_multiplier
						body.got_conditioned(explo_dmg*2, push_back, false, true)
						$CriticalSound.random_pitch_play()
					else:
						body.got_conditioned(explo_dmg, "burning",true)
			
		
		if sprite.scale > explosion_max_size/2 and wheels_not_shot :
			
			for i in range(4):
				
				var temp_marker = get_node("WheelMarker"+str(i+1))
				bullet_instatiation("res://scenes/CarWheel.tscn",temp_marker.rotation,temp_marker.global_position)
				wheels_not_shot = false
			
			$BurnTimer.start()
				
func _enemy_hit(body):	
	
	#if hitcount > 4:
		#return
		#
	#if body.name.contains("Outer"):
		#return
	#if hitcount < 3 && !body.name.contains("Wall"):
		#$RunOverSound.play()
		#var push_back = linear_velocity.normalized() * push_back_multiplier
		#body.got_shot(damage, push_back)
		#
		#hitcount += 1
		
	if hitcount < 1 && !body.name.contains("Outer"):
		
		linear_velocity = Vector2.ZERO
		set_deferred("freeze",true)
		
		
		$CollisionSound.random_pitch_play()
		$CollisionParticles.emitting = true
		$CarArea.set_deferred("monitoring", false)
		$ExplosionDeletionTimer.start()
		exploaded = true

		
		explo_collider.set_deferred("monitoring", true)
		explo_collider.set_deferred("monitorable", true)
		
			
		sprite.scale = sprite.scale * 0.075
		explo_collider.scale = sprite.scale
		sprite.visible = true
		sprite.play("explosion")
		
		
		hitcount += 1
		
		if body.name.contains("Wall"):
			return
			
		sprite.global_position = body.global_position
		$CarExplosionArea.global_position = body.global_position
		
		#var push_back = linear_velocity.normalized() * push_back_multiplier
		#body.got_shot(damage, push_back)
		#
		
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _explosion_hit(body):
	
	if body.name.contains("Outer"):
		return
	elif body.name.contains("Wall"):
		body.chared()
		return
		

func burning_tick():
	if explo_collider.monitoring:
		for body in $CarExplosionArea.get_overlapping_bodies():
			if !body.name.contains("Wall"):
				if body == targeted_enemy:
					body.got_shot(burn_damage*2,Vector2.ZERO, false, true)
					$CriticalSound.random_pitch_play()
				else:
					body.got_conditioned(burn_damage, "burning",true)

func delete_bullet():
	
	$CarArea.set_deferred("monitoring",false)
	$CarArea.set_deferred("monitorable",false)
	$CarExplosionArea.set_deferred("monitoring",false)
	$CarExplosionArea.set_deferred("monitorable",false)
	sprite.visible = false
	$CarSprite.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()


func bullet_instatiation(bullet_path,extra_rotation,spawn_position):
	
	var instance = load(bullet_path).instantiate()
	
	get_parent().call_deferred("add_child",instance)
		
	instance.position = spawn_position
	instance.rotation = rotation + extra_rotation
	instance.apply_central_impulse(Vector2.RIGHT.rotated(instance.rotation)*instance.speed)
	
		
