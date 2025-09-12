extends RigidBody2D

class_name Bullet_Base

@export var damage = 1
@export var tracking = false
@export var push_back_multiplier = 10
@export var speed = 1500
@export var slot_recharge_cut = 0.1

var crosshair_bodies = []
var targeted_enemy

var hitcount 

var previous_position := Vector2.ZERO

func _init():
	hitcount = 0

func _ready():
	check_crosshair()

func _process(delta):
	previous_position = position
		
func _enemy_hit(body):
	
	if hitcount == 0:
		
		hitcount += 1
		$CollisionSound.random_pitch_play()
		$CollisionParticles.emitting = true
		$AnimatedSprite2D.visible = false
		
		var push_back = linear_velocity.normalized() * push_back_multiplier
		linear_velocity = Vector2.ZERO
		position= previous_position
		
		if !"Wall" in body.name:
			if body == targeted_enemy:
				damage = damage*2
				body.got_shot(damage, push_back, false, true)
				$CriticalSound.random_pitch_play()
			else:
				body.got_shot(damage, push_back)
			
			get_tree().call_group("slots","incremement_value",damage*slot_recharge_cut)
	
# Chooses enemy that will take extra damage	
func check_crosshair():
	var mouse_placement = get_global_mouse_position()
	
	for body in crosshair_bodies:
	
		if body.name.contains("Wall"):
			continue			
		if targeted_enemy == null:
			targeted_enemy = body
		elif (targeted_enemy.global_position-mouse_placement).length() > (body.global_position-mouse_placement).length():
			targeted_enemy = body
	
	
func delete_bullet():
	
	$Area2D.set_deferred("monitoring",false)
	$AnimatedSprite2D.visible = false
	await get_tree().create_timer(1.0).timeout
	queue_free()
