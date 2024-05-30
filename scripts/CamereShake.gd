extends Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0	

var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade*delta)

		offset = randomOffset() 
			
func randomOffset():
	return Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))
