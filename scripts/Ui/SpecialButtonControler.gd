extends Control

signal special_ammo_chosen()

@export var slots : Array[Node]

var visible_nodes = []
var slot_num = 0

func _ready() -> void:
		
	visible_nodes = find_children("SPButton*")
	reset_slots()
	for node in visible_nodes:
		if node.name.contains("Row"):
			continue
		else:
			node.bullet_choosen.connect(ammo_choosen)

func set_buttons(choices_arr):
		
	for n in range(choices_arr.size()): 
		match  n:
			0:
				$RowsContainer/SPButtonFirstRow/SPButtonOne/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonFirstRow/SPButtonOne.visible = true
				$RowsContainer/SPButtonFirstRow.visible = true
			1:
				$RowsContainer/SPButtonFirstRow/SPButtonTwo/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonFirstRow/SPButtonTwo.visible = true	
			2:
				$RowsContainer/SPButtonFirstRow/SPButtonThree/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonFirstRow/SPButtonThree.visible = true	
			3:
				$RowsContainer/SPButtonFirstRow/SPButtonFour/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonFirstRow/SPButtonFour.visible = true	
			4:
				$RowsContainer/SPButtonSecondRow/SPButtonOne/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonSecondRow/SPButtonOne.visible = true	
				$RowsContainer/SPButtonSecondRow.visible = true
			5:
				$RowsContainer/SPButtonSecondRow/SPButtonTwo/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonSecondRow/SPButtonTwo.visible = true	
			6:
				$RowsContainer/SPButtonSecondRow/SPButtonThree/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonSecondRow/SPButtonThree.visible = true	
			7:
				$RowsContainer/SPButtonSecondRow/SPButtonFour/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonSecondRow/SPButtonFour.visible = true	
			8:
				$RowsContainer/SPButtonThirdRow/SPButtonOne/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonThirdRow/SPButtonOne.visible = true	
				$RowsContainer/SPButtonThirdRow.visible = true
			9:
				$RowsContainer/SPButtonThirdRow/SPButtonTwo/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonThirdRow/SPButtonTwo.visible = true	
			10:
				$RowsContainer/SPButtonThirdRow/SPButtonThree/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonThirdRow/SPButtonThree.visible = true	
			11:
				$RowsContainer/SPButtonThirdRow/SPButtonFour/Amunition.animation = choices_arr[n]
				$RowsContainer/SPButtonThirdRow/SPButtonFour.visible = true	

	$ShotgunBottomBarrel.visible = true
	$AnimationPlayer.play("show_buttons")
	
	await $AnimationPlayer.animation_finished

	$AnimationPlayer.play("shotgun_floats")
func reset_buttons():
	for object in visible_nodes:
		object.visible = false 
	
	if !$AnimationPlayer.is_playing():
		$ShotgunBottomBarrel.visible = false
		$ColorRect.visible = false
	

func ammo_choosen(name):
	$SelectedSound.play()
	$Path2D/PathFollow2D/Shell.animation = name
	$AnimationPlayer.play("bullet_choosen")
	reset_buttons()
	
	await $AnimationPlayer.animation_finished
	
	$ShotgunBottomBarrel.visible = false
	$ColorRect.visible = false
	
	slots[slot_num].set_shell(name)
	slot_num += 1
	special_ammo_chosen.emit()
	
func reset_slots():
	for slot in slots:
		slot.clear_slot()
		
	reset_buttons()
	slot_num = 0
