extends StaticBody2D

var is_chared = false
var is_cracked = false

# Makes walls undetectable for player
func _switch_visibility_collision():
	$CollisionShape2D.set_deferred("disabled",!$CollisionShape2D.disabled)
	visible = !visible

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
		var type_temp = randi_range(1,3)
		sprite.animation = "type_" + str(type_temp)
