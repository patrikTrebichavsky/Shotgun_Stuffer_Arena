extends CanvasLayer


func _process(delta): 
	if Input.is_action_just_pressed("special_first"):
		
		if $Special.animation == "pressed_first":
			$Special.animation = "not_pressed"
			$ShootingText.text = " Shooting"
		else:
			$Special.animation = "pressed_first"
			$ShootingText.text = " Shooting Special"
			
	if Input.is_action_just_pressed("special_second"):
		
		if $Special.animation == "pressed_second":
			$Special.animation = "not_pressed"
			$ShootingText.text = " Shooting"
		else:
			$Special.animation = "pressed_second"
			$ShootingText.text = " Shooting Special"
					
	if Input.is_action_just_pressed("special_third"):	
		
		if $Special.animation == "pressed_third":
			$Special.animation = "not_pressed"
			$ShootingText.text = " Shooting"
		else:
			$Special.animation = "pressed_third"
			$ShootingText.text = " Shooting Special"
		
	if Input.is_action_just_pressed("dash"):
		$Dash.animation = "pressed"
	elif Input.is_action_just_released("dash"):
		$Dash.animation = "not_pressed"

	if Input.is_action_just_pressed("shoot"):
		if $ShootingText.text.contains("Special"):
			$Shooting.animation = "pressed_special"
		else:
			$Shooting.animation = "pressed"
		
	elif Input.is_action_just_released("shoot"):
		$Shooting.animation = "not_pressed"
		
	if Input.is_action_just_pressed("forward"):
		$MovementW.animation = "pressed"
	elif Input.is_action_just_released("forward"):
		$MovementW.animation = "not_pressed"
		
	if Input.is_action_just_pressed("left"):
		$MovementA.animation = "pressed"
	elif Input.is_action_just_released("left"):
		$MovementA.animation = "not_pressed"
		
	if Input.is_action_just_pressed("backward"):
		$MovementS.animation = "pressed"
	elif Input.is_action_just_released("backward"):
		$MovementS.animation = "not_pressed"

	if Input.is_action_just_pressed("right"):
		$MovementD.animation = "pressed"
	elif Input.is_action_just_released("right"):
		$MovementD.animation = "not_pressed"
	
	if visible && Input.is_action_just_pressed("force_menu"):
		visible = false

func _on_controls_button_pressed():
	visible = false
