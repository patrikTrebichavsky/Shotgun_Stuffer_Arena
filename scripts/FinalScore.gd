extends CanvasLayer

var is_skippable = false
var stored_current_boss_slain : int 
var is_finished_displaying : bool

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot") && is_skippable:
		$AnimationPlayer.stop()
		skip_anim()
	
func show_score(num_of_basic : String, current_boss_slain: int) -> void:
	
	stored_current_boss_slain = current_boss_slain
	
	$TextureRect/Kills.text = num_of_basic
	
	match current_boss_slain:
		0:
			$AnimationPlayer.play("no_boss")
		1:
			$AnimationPlayer.play("smasher")
		2:
			$AnimationPlayer.play("double_thrower")
			
	is_skippable = true
	
	await $AnimationPlayer.animation_finished
	is_finished_displaying = true
	
func skip_anim():
	$TextureRect/Kills.visible = true
	
	if stored_current_boss_slain >= 1:
		$Smasher.animation = "slain"
		if stored_current_boss_slain >= 2:
			$DoubleThrower.animation = "slain"
	
	is_skippable = false
	is_finished_displaying = true
	
func reset():
	$TextureRect/Kills.visible = false
	$Smasher.animation = "empty"
	$DoubleThrower.animation = "empty"
