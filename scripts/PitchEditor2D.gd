extends AudioStreamPlayer2D

@export var min_pitch = 0.9
@export var max_pitch = 1.1
@export var min_pitch_diff = 0.05


var previous_pitch = pitch_scale


#Pitch Scalling script that ensures new pitch difference is atleast big as minimal diference
func random_pitch_play():
	
	randomize()
	pitch_scale = randf_range(min_pitch, max_pitch)
	
	if abs(pitch_scale - previous_pitch) < min_pitch_diff:
		if randi_range(1,2):
			pitch_scale = previous_pitch - min_pitch_diff
		else:
			pitch_scale = previous_pitch + min_pitch_diff
						
	previous_pitch = pitch_scale
		
	play()
	
