extends TextureProgressBar

var slot_ready = false
var selected = false
var slot_unlocked = false
var slot_shell_name = "Empty"

var shell_types = {
	"Name":"Field With Values (Cooldown,Special Ammo Empty,Special Ammo Filled)",
	
	"Couch":[5.0,"res://sprites/UI/SpecialUi - Shells/Couch/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Couch/Filled.png"]
	,
	
	"Nails":[10.0,"res://sprites/UI/SpecialUi - Shells/Nails/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Nails/Filled.png"]
	,
	
	"Doggy":[10.0,"res://sprites/UI/SpecialUi - Shells/Doggy/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Doggy/Filled.png"]
	,
	
	"Piano":[15.0,"res://sprites/UI/SpecialUi - Shells/Piano/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Piano/Filled.png"]
	,
	
	"Lamppost":[15.0,"res://sprites/UI/SpecialUi - Shells/Lamp/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Lamp/Filled.png"]
	,
	
	"UtilityPole":[15.0,"res://sprites/UI/SpecialUi - Shells/UtilityPole/Depleated.png", "res://sprites/UI/SpecialUi - Shells/UtilityPole/Filled.png"]
	,
	
	"Car":[25.0,"res://sprites/UI/SpecialUi - Shells/Car/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Car/Filled.png"]
	,
	"Shotgun":[20.0,"res://sprites/UI/SpecialUi - Shells/Shotgun/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Shotgun/Filled.png"]
	,
	
	"Closet-BE":[35.0,"res://sprites/UI/SpecialUi - Shells/Closet/Berserk/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Closet/Berserk/Filled.png"]
	,
	"Closet-BB":[35.0,"res://sprites/UI/SpecialUi - Shells/Closet/Bomboclat/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Closet/Bomboclat/Filled.png"]
	,
	"Closet-SH":[35.0,"res://sprites/UI/SpecialUi - Shells/Closet/Shaman/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Closet/Shaman/Filled.png"]
	,
	
	"House":[50.0,"res://sprites/UI/SpecialUi - Shells/House/Depleated.png", "res://sprites/UI/SpecialUi - Shells/House/Filled.png"]
	,
	
	"Empty":[0, "res://sprites/UI/SpecialUi - Shells/Empty.png", "res://sprites/UI/SpecialUi - Shells/Empty.png"]
	}	

func _physics_process(delta: float) -> void:
	if !slot_ready && slot_unlocked:
		incremement_value(delta)

func set_shell(shell_name = "Empty"):
	
	if shell_name == "Empty":
		return
	
	var temp = []
	
	
	if shell_name.contains("Closet"):
		$SelectedAnimation.animation = "Closet"
		temp = shell_types["Closet-BE"]
		slot_shell_name = "Closet-BE"
	else:
		$SelectedAnimation.animation = shell_name
		temp = shell_types[shell_name]
		slot_shell_name = shell_name
		
	texture_under = load(temp[1])
	texture_progress = load(temp[2])
	
	value = 0
	max_value = temp[0]
	$Shadow/Counter.text = "[center]" + str(int(value)) + " / " +str(int(max_value)) + "[/center]"
	slot_unlocked = true
	visible = true 
	
	
func incremement_value(inc_modifier):
	
	if !slot_unlocked:
		return
	
	value += 1 * inc_modifier
	
	$Shadow/Counter.text = "[center]" + str(int(value)) + " / " +str(int(max_value)) + "[/center]"
	
	if max_value == value:
		$Shadow/Counter.add_theme_color_override("default_color",Color.RED)
		slot_ready = true

func set_select(temp_selected = false):
	selected = temp_selected	
	if selected:
		$SelectedAnimation.visible = true
		$SelectedAnimation.play()
	else:
		$SelectedAnimation.visible = false
		$SelectedAnimation.stop()

func slot_used():
	
	$SelectedAnimation.visible = false
	$SelectedAnimation.stop()
	value = 0
	slot_ready = false
	selected = false
	$Shadow/Counter.add_theme_color_override("default_color",Color.WHITE_SMOKE)
	
	match slot_shell_name:
		"Closet-BE":
			slot_shell_name = "Closet-BB"
		"Closet-BB":
			slot_shell_name = "Closet-SH"
		"Closet-SH":
			slot_shell_name = "Closet-BE"

func clear_slot():
	visible = false
	$SelectedAnimation.stop()
	value = 0
	slot_ready = false
	selected = false
	slot_shell_name = "Empty"
	slot_unlocked = false
	
