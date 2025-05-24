extends Camera2D

## Script ultra genérico para seguir al mouse con la cámara
## y triggerear efectos de Parallax.

export (float) var movement_strength: float


func _process(delta: float) -> void:
	global_position = get_global_mouse_position() * movement_strength
