extends Bullet_Base

class_name Car

@export var explo_push_back : float
@export var explo_dmg : int
@export var burn_damage : int
@export var explosion_max_size : Vector2
@export var explosion_size_increase : Vector2

var sprite : AnimatedSprite2D
var explo_collider : Area2D


func  _ready():
	
	sprite = get_node("AnimatedSprite2D")
	explo_collider = get_node("ExplosionArea")
	
func _process(delta):
	
	if hitcount > 0 && explosion_max_size >= sprite.scale:
		sprite.scale += explosion_size_increase
		explo_collider.scale += explosion_size_increase
		
		
func _enemy_hit(body):
	
	
	if hitcount == 0:
		
		hitcount += 1

		$CollisionSound.play()
		$CollisionParticles.emitting = true
		$CollisionArea.set_deferred("monitoring", false)
		$ExplosionDeletionTimer.start()
		
		for i in range(4):
			var temp_marker = get_node("WheelMarker"+str(i+1))
			bullet_instatiation("res://scenes/CarWheel.tscn",temp_marker.rotation,temp_marker.global_position)
		
		
		sprite.animation = "explosion"
		explo_collider.set_deferred("monitoring", true)
		
		sprite.global_position = body.position
		explo_collider.global_position = body.position
		
		explo_collider.scale = explo_collider.scale * 0.01 
		sprite.scale = sprite.scale * 0.01
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		body.got_shot(damage, push_back)
		
		linear_velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _explosion_hit(body):
	
	if(explosion_max_size >= sprite.scale):
		var push_back = (body.global_position - $ExplosionArea/ExplosionCenter.global_position).normalized() * explo_push_back
		body.got_shot(explo_dmg, push_back)
	else:
		body.got_conditioned(1, "burning")


func delete_bullet():
	
	$CollisionArea.set_deferred("monitoring",false)
	$ExplosionArea.set_deferred("monitoring",false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()


func bullet_instatiation(bullet_path,extra_rotation,spawn_position):
	
	var instance = load(bullet_path).instantiate()
	
	get_parent().call_deferred("add_child",instance)
		
	instance.position = spawn_position
	instance.rotation = rotation + extra_rotation
	instance.apply_central_impulse(Vector2.RIGHT.rotated(instance.rotation)*instance.speed)
	
		
