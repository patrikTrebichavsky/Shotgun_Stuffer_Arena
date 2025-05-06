extends Area2D

@export var damage = 1

var targeted_enemy

var push_back

func bleed_enemy():
	
	var temp = get_overlapping_bodies()
	
	for body in temp:
		if "Wall" in body.name:
			continue
		elif targeted_enemy:
			body.got_conditioned(damage*2,push_back, false, true,"bleeding")
			$CriticalSound.play()
		else:
			body.got_conditioned(damage, push_back, false, false,"bleeding")
			$BleedSound.play()

func _on_body_entered(body: Node2D) -> void:
	
	if "Wall" in body.name:
		return
	elif targeted_enemy:
		body.got_conditioned(damage*2, push_back, false, true,"bleeding")
		$CriticalSound.play()
	else:
		body.got_conditioned(damage, push_back, false, false,"bleeding")
		$BleedSound.play()


func delete_bullet():
	queue_free()
