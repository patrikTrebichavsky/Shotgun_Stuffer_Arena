extends TextureRect

signal send_to_next(ammo_id)
signal send_to_previous(ammo_id)
signal empty()

@export var first_in_row : bool
var is_active : bool

@export var ammo_sprite_dictionary = {
	"id" : "path",
	1 : "res://sprites/UI/SpecialUI - Shotgun/CouchUI.png",
	2 : "res://sprites/UI/SpecialUI - Shotgun/PianoUI.png",
	3 : "res://sprites/UI/SpecialUI - Shotgun/LampUI.png",
	4 : "res://sprites/UI/SpecialUI - Shotgun/CarUI.png",
	5 : "res://sprites/UI/SpecialUI - Shotgun/HouseUI.png",
}

var current_value = 0
#sets ammout and if it already contains loaded ammo it will send it to next one
func set_ammo(ammo_id):
	if ammo_id == 0:
		pass
	elif texture == null:
		current_value = ammo_id
		texture = load(ammo_sprite_dictionary[ammo_id])
	else:
		emit_signal("send_to_next",ammo_id)
		
#moves ammo texture to previous container if its first removes the texture because ammo was shot
func move_ammo_up():
	texture = null
	if !is_active:
		emit_signal("send_to_previous",current_value)
		current_value = 0
	else:
		var temp = get_parent().get_node("ShotgunStorage")
		temp.play("reload")
	emit_signal("empty")
	
func reset():
	texture = null
	current_value = 0

func is_slot_active(state : bool):
	is_active = state
	
	if is_active:
		$highlightRect.visible = true
	else:
		$highlightRect.visible = false
