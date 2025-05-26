extends RigidBody2D

@export var speed = 600
var current_velocity = 0
var enemy = null
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var target_position : Vector2
@export var push_back_multiplier = 10

var attack = 0
var attacking = false

var damage = 3

@export var undertale_mode : bool

var  temp

var  bodies

func _ready():
	
	nav.velocity_computed.connect(move)
	
	
func _physics_process(_delta):
	
	if attacking:
		return
	
	if enemy != null:
		if enemy.hp <= 0:
			enemy = null
	
	if enemy == null:
		bodies = $DetectionArea2D.get_overlapping_bodies()
		for body in bodies:
			if "Wall" in body.name or body.name == "Guts":
				continue
			
			if enemy == null:
				enemy = body
			elif (position - body.position).abs().length() < (position - enemy.position).abs().length():
				enemy = body 
	if enemy == null:
		return
	
	var temp = (position-enemy.position).abs()
	
	if temp.x < 100 && temp.y < 100:
		self.look_at(enemy.position)
		attacking = true
		linear_velocity = Vector2.ZERO
		match  attack:
			0:
				attack = 1
				$AnimationPlayer.play("Swing")
			1:
				attack = 2
				$AnimationPlayer.play("Spin")
			2:
				attack = 0
				$AnimationPlayer.play("Overhead")
	else:
	
		nav.target_position = enemy.position
		target_position = (nav.get_next_path_position()-global_position).normalized()
		current_velocity = target_position * speed
		nav.set_velocity(current_velocity) 	
		self.look_at(nav.get_next_path_position())
	
	
func move(velocity: Vector2):

	if attacking:
		return

	linear_velocity = velocity
	
func _switch_mode(_name):
	
	undertale_mode = !undertale_mode


func attack_hit(body):

	if "Guts" in body.name or "Wall" in body.name:
		return
		
	var push_back = (body.position-position).normalized() * push_back_multiplier
	body.got_shot(damage, push_back)
	
	
func overhead():
	var bodies = $OverHeadArea2D.get_overlapping_bodies()
	
	for body in bodies:
		
		if "Wall" in body.name:
			body.cracked()
		if "Guts" in body.name:
			return
			
		var push_back = (body.position-position).normalized() * push_back_multiplier
		body.got_shot(damage*2, push_back, false , true)

func attack_finished(anim_name):
	attacking = false

func delete_guts():
	queue_free()
