## Este estado hereda de un State intermedio llamado AbstractEnemyState
## que extiende la interfaz de State con comportamientos específicos
## (se puede abrir el script con Ctrl+click)
extends AbstractEnemyState

# Usamos un Timer para controlar cuánto tiempo queda in Idle
onready var idle_timer:Timer = $IdleTimer


func enter() -> void:
	# Seteamos la velocidad a (0,0) para que no se mueva
	character.velocity = Vector2.ZERO
	
	# Chequeamos si debe estar con la guardia en alto o no
	if character.target != null:
		character._play_animation("idle_alert")
	else:
		character._play_animation("idle")
	# Iniciamos el Timer para salir del estado
	idle_timer.start()


func update(delta:float) -> void:
	# Primero detenemos el character para que no se mueva más
	character._handle_deacceleration(delta)
	# Aplicamos el movimiento en el personaje
	character.apply_movement()
	
	# Y si notamos que puede "ver" al objetivo, entramos en Alert
	if character._can_see_target():
		emit_signal("finished", "alert")


# Al salir, nos aseguramos de limpiar el timer de Idle
func exit() -> void:
	idle_timer.stop()


# Cuando termina el timer, transiciona al estado Walk
func _on_IdleTimer_timeout() -> void:
	emit_signal("finished", "walk")


func _handle_body_entered(body: Node) -> void:
	._handle_body_entered(body)
	
	## No se ejecuta directamente el "idle_alert", sino que se ejecuta una
	## animación de transición
	character._play_animation("alert")


func _handle_body_exited(body) -> void:
	._handle_body_exited(body)
	
	## No se ejecuta directamente el "idle", sino que se ejecuta una
	## animación de transición
	character._play_animation("go_normal")


# Manejamos la transicion de animaciones "intermedias" a animaciones finales
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"alert":
			character._play_animation("idle_alert")
		"go_normal":
			character._play_animation("idle")
