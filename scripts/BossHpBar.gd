extends TextureProgressBar


# Called when the node enters the scene tree for the first time
func heal_to_full(use_tween = true,time = 0.5):
	var tween = create_tween()
	tween.tween_property(self,"value",max_value,time)
	
func update_hp(amount: int):
	value = amount
