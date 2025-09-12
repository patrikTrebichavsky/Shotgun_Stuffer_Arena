extends Control

signal bullet_choosen(String)

var mouse_on_textbubble = false

func _hide():
	visible = false

func _button_pressed():
	bullet_choosen.emit($Amunition.animation)

func _on_mouse_entered() -> void:
	mouse_on_textbubble = true
	get_tree().call_group("player", "mouse_on_ui_state", true)
	get_tree().call_group("player", "delay_enabling_of_shooting", false)

func _on_mouse_exited() -> void:
	mouse_on_textbubble = false
	get_tree().call_group("player", "mouse_on_ui_state", false)
