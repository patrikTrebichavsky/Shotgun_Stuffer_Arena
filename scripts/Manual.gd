extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func switchpageto12():
	$"Manual1-2".visible = true	
	$"Manual3-4".visible = false	
	
func switchpageto34():
	$"Manual1-2".visible = false
	$"Manual3-4".visible = true

func hide_manual():
	visible = false
