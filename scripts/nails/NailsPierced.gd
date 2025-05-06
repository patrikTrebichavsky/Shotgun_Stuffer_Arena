extends Node2D

@export var damage = 1

var nailed_enemy
var targeted_enemy

var push_back

func bleed_enemy():
	
	if nailed_enemy.id == 10:
		if nailed_enemy.hp_current < 0:
			$DamageTimer.stop()
			return
	else:
		if nailed_enemy.hp < 0:
			$DamageTimer.stop()
			return
	
	if targeted_enemy:
		nailed_enemy.got_conditioned(damage*2, push_back, false, true,"bleeding")
		$CriticalSound.play()
	else:
		nailed_enemy.got_conditioned(damage, push_back, false, false,"bleeding")
		$BleedSound.play()
	
func delete_bullet():
	queue_free()
