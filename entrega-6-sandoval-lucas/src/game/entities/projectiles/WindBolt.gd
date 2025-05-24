extends Node2D

## Proyectil de empuje de viento. Bajo daño pero empuje fuerte.
## Funciona como "proyectil" en interfaz, pero opera como un efecto
## de un solo uso.

onready var effect_anim: AnimationPlayer = $EffectAnim

export (float) var push_force: float = 700.0
export (int) var push_damage: int = 1

var direction: Vector2


func initialize(container: Node, spawn_position: Vector2, direction: Vector2) -> void:
	container.add_child(self)
	self.direction = direction
	global_position = spawn_position
	rotation = direction.angle()
	effect_anim.play("effect")


func _on_EffectArea_body_entered(body: Node) -> void:
	if body.has_method("notify_hit"):
		body.notify_hit(-push_damage)
	if "velocity" in body:
		body.velocity += direction * push_force


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()
