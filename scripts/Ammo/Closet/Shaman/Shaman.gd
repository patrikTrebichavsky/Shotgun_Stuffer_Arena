extends RigidBody2D

func summon_doors():
	var main = get_parent()
	main.get_tree().call_group("player","door_spin")
	queue_free()
