extends RigidBody2D

@export var speed = 400
var current_velocity = 0
@export var enemy_position = Vector2(1920,1080)
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var target_position : Vector2

var attack = 0
var attacking = false

@export var undertale_mode : bool

var  temp

func _ready():
	
	nav.velocity_computed.connect(move)
	
	
func _physics_process(_delta):
	
	if attacking:
		return
	
	var temp = (position-enemy_position).abs()
	
	if temp.x < 100 && temp.y <100:
		self.look_at(enemy_position)
		attacking = true
		linear_velocity = Vector2.ZERO
		match  attack:
			0:
				attack = 1
				$AnimationPlayer.play("SwingLeft")
			1:
				attack = 2
				$AnimationPlayer.play("Spin")
			2:
				attack = 0
				$AnimationPlayer.play("Overhead")
	else:
	
		nav.target_position = enemy_position
		target_position = (nav.get_next_path_position()-global_position).normalized()
		current_velocity = target_position * speed
		nav.set_velocity(current_velocity) 	
		self.look_at(nav.get_next_path_position())

	
func move(velocity: Vector2):

	if attacking:
		return

	linear_velocity = velocity
	

	
func update_enemy_position(position):
	
	enemy_position = position


func _switch_mode(_name):
	
	undertale_mode = !undertale_mode

func attack_finished(anim_name):
	attacking = false
