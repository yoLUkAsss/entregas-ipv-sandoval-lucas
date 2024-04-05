extends Sprite

export (float) var SPEED: float = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction: int = 0
	
	if Input.is_action_pressed("mover_izq"):
		direction = -1
	elif Input.is_action_pressed("mover_der"):
		direction = 1
	
	position.x += direction * delta * SPEED
	

