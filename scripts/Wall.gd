extends StaticBody2D

var is_chared = false
var is_cracked = false
var destroyed = false
@export var is_special_wall = false
# Makes walls undetectable for player
func _ready():
	
	var sprites = get_children()
	for sprite in sprites:
		if !sprite.name.contains("Animated"):
			continue
		sprite.visible = true
	
	$ColorRect.visible = true
	$CollisionShape2D.set_deferred("disabled",false)
	
	
func _switch_visibility_collision():
	
	if !destroyed:
		$CollisionShape2D.set_deferred("disabled",!$CollisionShape2D.disabled)
		visible = !visible
	elif visible:		
		$CollisionShape2D.set_deferred("disabled",true)
		visible = false
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
		
		if $DestoyedWallSound.is_playing():
			$DestoyedWallSound.stop()
			
func cracked():
	var sprites = get_children()
	for sprite in sprites:
		if !sprite.name.contains("Animated"):
			continue
		elif is_chared:
			sprite.animation = "type_cracked_chared" 
		elif !is_cracked:
			sprite.animation = "type_cracked"	
	is_cracked = true

func chared():
	var sprites = get_children()
	for sprite in sprites:
		if !sprite.name.contains("Animated"):
			continue
		elif is_cracked:
			sprite.animation = "type_cracked_chared" 
		elif !is_chared:
			sprite.animation = "type_chared"
		
	is_chared = true
 
func reset():
	is_chared = false
	is_cracked = false
		
	var sprites = get_children()
	for sprite in sprites:
		if !sprite.name.contains("Animated"):
			continue
		sprite.visible = true
	
	$CollisionShape2D.set_deferred("disabled",false)
	
	if is_special_wall:
		
		destroyed = false
		
		scale = Vector2(1,1)
				
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
		
		$LeftMagicParticles.emitting = false
		$RightMagicParticles.emitting = false
		$CrashParticles.emitting = false
		
		visible = true
		$ColorRect.visible = true
		


func destroy():
	if is_special_wall:
		destroyed = true
		$AnimationPlayer.active = true
		$AnimationPlayer.play("destroy")

	
func animation_destroyed_finished():
	$CollisionShape2D.set_deferred("disabled",true)
	visible = false



func camera_shake():
	get_tree().call_group("camera","apply_shake")
