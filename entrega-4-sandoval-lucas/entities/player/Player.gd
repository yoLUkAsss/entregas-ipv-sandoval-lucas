extends Sprite

onready var cannon: Sprite = $Cannon

export (float) var SPEED: float = 50

var projectile_container: Node

func set_projectile_container(container: Node):
	cannon.projectile_container = container
	projectile_container = container

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction: int = 0
	
	if Input.is_action_pressed("mover_izq"):
		direction = -1
	elif Input.is_action_pressed("mover_der"):
		direction = 1
		

	var mouse_position: Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	
	if Input.is_action_just_pressed("fire"):
		cannon.fire()
	
	position.x += direction * delta * SPEED
	

