extends StaticBody2D

@onready var fire_position: Node2D = $FirePosition
@onready var fire_timer: Timer = $FireTimer
@onready var raycast: RayCast2D = $RayCast2D
@onready var body_anim: AnimatedSprite2D = $Body

@export var projectile_scene: PackedScene

var target: Node2D
var projectile_container: Node

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _ready() -> void:
	fire_timer.connect("timeout", Callable(self, "fire"))
	set_physics_process(false)
	_play_animation("idle")


func initialize(container, turret_pos, projectile_container) -> void:
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container


func fire() -> void:
	if target != null:
		var proj_instance = projectile_scene.instantiate()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(projectile_container, fire_position.global_position, fire_position.global_position.direction_to(target.global_position))
		fire_timer.start()


func _physics_process(delta: float) -> void:
	raycast.set_target_position(raycast.to_local(target.global_position))
	if raycast.is_colliding() && raycast.get_collider() == target:
		if fire_timer.is_stopped():
			fire_timer.start()
	elif !fire_timer.is_stopped():
		fire_timer.stop()


## Esta función ya no llama directamente a remove, sino que inhabilita las
## colisiones con el mundo, pausa todo lo demás y ejecuta una animación de muerte
func notify_hit() -> void:
	print("I'm turret and imma die")


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()


func _on_DetectionArea_body_entered(body: Node) -> void:
	if target == null:
		target = body
		set_physics_process(true)


func _on_DetectionArea_body_exited(body: Node) -> void:
	if body == target:
		target = null
		set_physics_process(false)


## Acá manejamos el callback de "animation finished" y procesamos qué
## lógica ejecutar a continuación, estilo grafo.
func _on_animation_finished() -> void:
	pass


## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_anim.sprite_frames.has_animation(animation):
		body_anim.play(animation)
