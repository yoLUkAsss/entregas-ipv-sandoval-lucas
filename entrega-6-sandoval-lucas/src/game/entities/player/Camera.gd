extends Camera2D

onready var player: Player = get_parent()

export (float) var max_offset_h: float
export (float) var max_offset_y: float
export (float) var offset_speed: float
export (Vector2) var min_zoom: Vector2
export (Vector2) var max_zoom: Vector2
export (float) var zoom_speed: float

var target_offset: Vector2


## Una camarita con comportamiento propio para mostrar las bondades de
## usar una cámara con zooms y offsets y demás
func _physics_process(delta: float) -> void:
	
	## Como usamos el movimiento del personaje como un factor, primero
	## podemos calcular el porcentaje de velocidad que tiene el player
	## hasta llegar a la velocidad máxima, lo que dará un valor entre 0.0 y 1.0
	var velocity_factor: float = clamp(player.velocity.x / player.H_SPEED_LIMIT, -1.0, 1.0)
	
	## Acá virtualizamos el offset que vamos a aplicar con un Vector2 que vamos
	## "deslizando" gradualmente usando el "velocity_factor"
	target_offset = target_offset.linear_interpolate(Vector2(velocity_factor * max_offset_h, abs(velocity_factor) * max_offset_y), offset_speed * delta)
	
	## Y que luego aplicamos al verdadero offset de la cámara con una interpolación
	offset = offset.linear_interpolate(target_offset, offset_speed * delta)
	
	## Luego calculamos cuál es el zoom al que vamos a calcular usando de nuevo el
	## absoluto del velocity_factor (asi nos tira positivo y zoomea a cualquier dirección)
	var max_zoom_target: Vector2 = abs(velocity_factor) * max_zoom
	
	## Evaluamos el zoom objetivo que queremos conseguir, poniendo un tope de zoom minimo
	var target_zoom: Vector2 = Vector2(max(min_zoom.x, max_zoom_target.x), max(min_zoom.y, max_zoom_target.y))
	
	## Y lo aplicamos con una interpolación entre el zoom actual y el objetivo
	zoom = lerp(zoom, target_zoom, zoom_speed * delta)
