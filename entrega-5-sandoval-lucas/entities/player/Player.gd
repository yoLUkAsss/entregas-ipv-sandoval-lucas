extends KinematicBody2D

class_name Player

onready var cannon: Sprite = $Cannon

export (float) var ACCELERATION: float = 20.0
export (float) var H_SPEED_LIMIT: float = 600.0
export (float) var FRICTION_WEIGHT: float = 0.1
export (float) var JUMP_SPEED: float = -10
export (float) var GRAVITY: float = 2

var projectile_container: Node
var velocity: Vector2 = Vector2.ZERO

func set_projectile_container(container: Node):
	cannon.projectile_container = container
	projectile_container = container

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Rotacion del cannon
	var mouse_position: Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	# Disparar
	if Input.is_action_just_pressed("fire"):
		if projectile_container == null:
			projectile_container = get_parent()
			cannon.projectile_container = projectile_container
		cannon.fire()
	# Calcular movimiento
	var h_movement_direction:int = 	int(Input.is_action_pressed("mover_der")) - int(Input.is_action_pressed("mover_izq"))
	if h_movement_direction != 0:
		velocity.x = clamp(velocity.x + (h_movement_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
	
	velocity.y += GRAVITY
	
	move_and_slide(velocity, Vector2.UP)
	

