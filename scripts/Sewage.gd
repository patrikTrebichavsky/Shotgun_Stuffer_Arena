extends Area2D

signal player_entered(player)

var can_be_used = true

func _on_area_entered(area):
		
	if can_be_used == true && area.name == "PlayerArea":
		emit_signal("player_entered", area.get_parent())
		can_be_used = false
		$AnimatedSprite2D.play("closing")
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)

func _reset():
	can_be_used = true
	$AnimatedSprite2D.play("closed")
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)


func transport_player(player):
	
	player.went_trough_sewage()
		
	player.position = $ExitMarker.global_position
	can_be_used = false
	$AnimatedSprite2D.play("closing")
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)

func change_sewage_state(state: bool):
	visible = state
	set_deferred("monitoring",state)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled",state)
