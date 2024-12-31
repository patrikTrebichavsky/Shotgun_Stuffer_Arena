extends CanvasLayer


func _process(delta): 
	
	if !visible:
		return
	#This is for Entire Specials controls Scroll/ Keys / Reset
	
	if $ScrollDelay.is_stopped():
		
		if Input.is_action_just_pressed("special_scroll_up"):
			$ShootingText.text = " Shooting Special"
			$SpecialScroll.animation = "scrolled_up"
			$ScrollDelay.start()
			match $Special.animation:
				"not_pressed":
					$Special.animation = "pressed_first"
				"pressed_second":
					$Special.animation = "pressed_first"
				"pressed_third":	
					$Special.animation = "pressed_second"
					
		elif Input.is_action_just_pressed("special_scroll_down"):
			$ShootingText.text = " Shooting Special"
			$SpecialScroll.animation = "scrolled_down"
			$ScrollDelay.start()
			match $Special.animation:
				"not_pressed":
					$Special.animation = "pressed_first"
				"pressed_first":
					$Special.animation = "pressed_second"
				"pressed_second":	
					$Special.animation = "pressed_third"
		else:
			$SpecialScroll.animation = "not_scrolled"
			
	if Input.is_action_just_pressed("ammo_switch"):
		$Special.animation = "not_pressed"
		$SpecialScroll.animation = "not_scrolled"
		$ShootingText.text = " Shooting"
		$Reset.animation = "pressed"
	elif Input.is_action_just_released("ammo_switch"):
		$Reset.animation = "not_pressed"
		
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
	

	
	#This is for additional controlos Dash/Shooting
	
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
		
	#This part is for Basic WASD movement
	
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
