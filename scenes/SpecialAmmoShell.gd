extends TextureProgressBar

var shell_types = {
	"Name":"Field With Values (Animation,Empty,Filled)",
	
	"Couch":[5,"res://sprites/UI/SpecialUi - Shells/Couch/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Couch/Filled.png"]
	,
	"Piano":[10,"res://sprites/UI/SpecialUi - Shells/Piano/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Piano/Filled.png"]
	,
	"Lamp":[10,"res://sprites/UI/SpecialUi - Shells/Lamp/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Lamp/Filled.png"]
	,
	"Car":[25,"res://sprites/UI/SpecialUi - Shells/Car/Depleated.png", "res://sprites/UI/SpecialUi - Shells/Car/Filled.png"]
	,
	"House":[50,"res://sprites/UI/SpecialUi - Shells/House/Depleated.png", "res://sprites/UI/SpecialUi - Shells/House/Filled.png"]
	,
	"Empty":[0, "res://sprites/UI/SpecialUi - Shells/Empty.png", "res://sprites/UI/SpecialUi - Shells/Empty.png"]
	}






func set_shell(shell_name = "Empty"):
	$SelectedAnimation.animation = shell_name

	var temp = shell_types[shell_name]

	texture_under = load(temp[1])
	texture_progress = load(temp[2])
	
	value = 0
	max_value = temp[0]
	$Counter.text = str(int(value)) + " / " +str(int(max_value))
	
	
func incremement_value():
	value += 1
	
	$Counter.text = str(int(value)) + " / " +str(int(max_value))
	
	if max_value == value:
		$Counter.add_theme_color_override("font_color",Color.RED)

func set_select(selected = false):
	if selected:
		$SelectedAnimation.visible = true
		$SelectedAnimation.play()
	else:
		$SelectedAnimation.visible = false
		$SelectedAnimation.stop()
	

func _ready() -> void:
	
	await get_tree().create_timer(4).timeout
	set_shell("Piano")
	
	while max_value > value:
		await get_tree().create_timer(1).timeout
		incremement_value()
	
	await  get_tree().create_timer(3).timeout
	set_select(true)
	await  get_tree().create_timer(3).timeout
	set_select()
