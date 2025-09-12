extends HSlider

@export var bus_name: String
@export var audio_stream: AudioStreamPlayer
var bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	drag_ended.connect(volume_setted)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(volume):
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(volume))

func volume_setted():
	if audio_stream != null:
		audio_stream.play()
