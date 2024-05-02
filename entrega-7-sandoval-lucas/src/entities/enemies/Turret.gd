extends KinematicBody2D
class_name EnemyTurret

signal hit(amount)

onready var fire_position: Node2D = $FirePosition
onready var raycast: RayCast2D = $RayCast2D
onready var body_anim: AnimatedSprite = $Body

export (PackedScene) var projectile_scene: PackedScene

export (NodePath) var pathfinding_path: NodePath
onready var pathfinding: PathfindAstar = get_node_or_null(pathfinding_path)

export (Vector2) var wander_radius: Vector2 = Vector2(10.0, 10.0)
export (float) var speed: float = 10.0
export (float) var max_speed: float = 100.0
export (float) var pathfinding_step_threshold: float = 5.0

var target: Node2D
var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container


func _fire() -> void:
	if target != null:
		var proj_instance: Node = projectile_scene.instance()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(
			projectile_container,
			fire_position.global_position,
			fire_position.global_position.direction_to(target.global_position)
		)


func _look_at_target() -> void:
	## Damos vuelta el cuerpo para que mire al objetivo en el eje x
	## y usamos la dirección a la que se casteó el raycast
	## Otra manera sería hacer (target.global_position - global_position).x < 0
	body_anim.flip_h = raycast.cast_to.x < 0
	
	
func _apply_movement() -> void:
	velocity = move_and_slide(velocity, Vector2.UP)

func _can_see_target() -> bool:
	if target == null:
		return false
		
	raycast.set_cast_to(raycast.to_local(target.global_position))
	raycast.force_raycast_update()
	return raycast.is_colliding() && raycast.get_collider() == target

## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
## dependiendo de si el enemigo esta o no alerta
func notify_hit(amount: int = 1) -> void:
	emit_signal("hit", amount)

func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()


## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.frames.has_animation(animation):
		body_anim.play(animation)

func get_current_animation() -> String:
	return body_anim.animation
