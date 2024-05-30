extends Area2D



func _on_body_entered(body):
	
	if body.name.to_lower().contains("enmemy"):
		body._enemy_fell_off_map()
