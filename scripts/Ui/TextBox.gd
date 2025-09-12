extends MarginContainer


enum STATES {EMPTY, FILLING, SKIP_FILLING, FILLED}


@onready var label = $MarginContainer/DisplayedText
@onready var timer = $LetterDisplayTimer
@onready var audio = $DialogSoundEffect


const MAX_WIDTH = 1600


var displayed_text = ""
var letter_index = 0
var mouse_on_textbubble = false

@export var letter_time : float
@export var space_time : float
@export var punctuation_time : float

var label_state = STATES.EMPTY 

signal finished_displaying()



func display_text(text_to_display: String):
	
	var default_heigth = size.y
	
	label_state = STATES.FILLING
	displayed_text = text_to_display
	label.text = text_to_display
	
	await resized
	custom_minimum_size.x =	min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:  
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		await resized
		await resized
		custom_minimum_size.y =	size.y
		
	if size.y > default_heigth:
		position.y -= (size.y-default_heigth)/2
	
	label.text = ""       
	_display_letter()
	audio.stream.loop = true 
	audio.play()


func _display_letter():
	
	
	if label_state == STATES.SKIP_FILLING:
		label.text = displayed_text
		letter_index = displayed_text.length()
	else:	
		label.text += displayed_text[letter_index]
		letter_index += 1
	
		
	if letter_index >= displayed_text.length():
		emit_signal("finished_displaying")
		audio.stream.loop = false
		return
			
	match displayed_text[letter_index]:
		"!",".",",","?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)


func skip_filling(): 
	label_state = STATES.SKIP_FILLING

func _on_mouse_entered() -> void:
	mouse_on_textbubble = true
	get_tree().call_group("player", "mouse_on_ui_state", true)
	get_tree().call_group("player", "delay_enabling_of_shooting", false)


func _on_mouse_exited() -> void:
	mouse_on_textbubble = false
	get_tree().call_group("player", "mouse_on_ui_state", false)
