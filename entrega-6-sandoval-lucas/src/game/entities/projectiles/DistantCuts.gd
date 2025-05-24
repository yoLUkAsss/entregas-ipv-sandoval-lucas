extends Node2D

onready var direction_raycast: RayCast2D = $DirectionRaycast
onready var cuts_animation: AnimationPlayer = $CutsAnimation

export (int) var damage: int = 2.0
export (float) var push_force: float = 200.0


func initialize(container: Node, spawn_position: Vector2, direction: Vector2) -> void:
	container.add_child(self)
	global_position = spawn_position
	_determine_end_point()
	cuts_animation.play("cuts")


func _determine_end_point() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	direction_raycast.cast_to = direction_raycast.to_local(mouse_pos)
	direction_raycast.force_raycast_update()
	
	if direction_raycast.is_colliding():
		global_position = direction_raycast.get_collision_point()
	else:
		global_position = mouse_pos


func _remove() -> void:
	get_parent().remove_child(self)
	queue_free()

func _on_CutsArea_body_entered(body: Node) -> void:
	if body.has_method("notify_hit"):
		body.notify_hit(-damage)
	if "velocity" in body && body is Node2D:
		body.velocity += global_position.direction_to(body.global_position) * push_force

