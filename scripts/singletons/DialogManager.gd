extends Node

@onready var text_box_scene = preload("res://scenes/TextBox.tscn")


var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false


signal dialog_finished()


func _ready() -> void:
	var main = get_tree().root.get_node("Main")
	if main != null:
		dialog_finished.connect(main.dialog_finished)


func start_dialog(position: Vector2, lines: Array[String]):
	#This is entirely for testing purposes since dialog should not appear when player is dead/inactive 
	
	var main = get_tree().root.get_node("Main")
	if !main.has_node("Player"):
		return

	if is_dialog_active:		
		return
	
	dialog_lines = lines
	text_box_position = position
	is_dialog_active = true
	_show_text_box()

	
	
func _show_text_box():
		
	var main = get_tree().root.get_node("Main")

	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	main.get_node("PlayerUi").add_child(text_box)
	text_box.position = text_box_position
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false



func _on_text_box_finished_displaying():
	can_advance_line = true
	


func _unhandled_input(event: InputEvent) -> void:
		
	if event.is_action_pressed("shoot") \
	&& is_dialog_active \
	&& can_advance_line \
	&& text_box.mouse_on_textbubble:
		
		get_tree().call_group("player", "delay_enabling_of_shooting", false)
		text_box.mouse_exited.disconnect(text_box._on_mouse_exited)
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			emit_signal("dialog_finished")
			await get_tree().create_timer(0.2).timeout
			get_tree().call_group("player", "mouse_on_text_box_state", false)
			return
		
		_show_text_box()
		
	elif event.is_action_pressed("shoot") \
	&& is_dialog_active \
	&& text_box.mouse_on_textbubble: 
			
		text_box.skip_filling()

func reset_dialog_manager():
	
	if text_box != null:
		text_box.queue_free()
	is_dialog_active = false
	current_line_index = 0
