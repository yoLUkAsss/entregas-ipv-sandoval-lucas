extends Sprite2D

@onready var cannon: Sprite2D = $Cannon

@export var speed: int = 200 #Pixeles

var projectile_container: Node

func set_projectile_container(projectile_container: Node):
	cannon.projectile_container = projectile_container
	projectile_container = projectile_container

func _physics_process(delta):
	# Manera optimizada
	var direction_optimized:int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	var mouse_position: Vector2 = get_global_mouse_position()
	var origen: Vector2 = global_position
	var direction_vector: Vector2 = (mouse_position - origen).normalized()

	cannon.look_at(mouse_position)
	
	if Input.is_action_just_pressed("fire"):
		cannon.fire()
	
	position.x += direction_optimized * speed * delta
