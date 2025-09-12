extends AnimatedSprite2D


func _ready() -> void:
	visible = false
# Called when the node enters the scene tree for the first time.
func load_dash() -> void:
	
	if !visible:
		visible = true
	
	play()
	await  animation_finished
	await  get_tree().create_timer(0.5).timeout
	
	if !is_playing():
		visible = false
