extends TextureProgressBar


# Called when the node enters the scene tree for the first time
func heal_to_full(use_tween = true,time = 0.5, ending =  max_value):
	var tween = create_tween()
	tween.tween_property(self, "value", ending, time)
	
	if !use_tween:
		value = ending
	
func update_hp(amount: int):
	value = amount
	
func boss_spawned():
	$"../AnimationPlayer".play("SpawnHealthBar")
	modulate = Color(1,1,1,0)
	visible = true
	
