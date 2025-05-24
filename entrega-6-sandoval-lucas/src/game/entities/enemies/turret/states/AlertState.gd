## Este estado hereda de un State intermedio llamado AbstractEnemyState
## que extiende la interfaz de State con comportamientos específicos
## (se puede abrir el script con Ctrl+click)
extends AbstractEnemyState


func enter() -> void:
	# Luego triggereamos un disparo y reproducimos la animación
	fire()


func update(delta) -> void:
	# Solo nos encargamos de mirar al "target" (o el último punto que se lo vio)
	character._look_at_target()
	
	# Primero detenemos el character para que no se mueva más
	character._handle_deacceleration(delta)
	# Aplicamos el movimiento en el personaje
	character.apply_movement()


# Abstraemos el proceso de "disparar"
func fire() -> void:
	character._fire()
	character._play_animation("attack")


## Usamos la duración de las animaciones como "trigger" para iniciar otras
## acciones. Quizás no sea lo óptimo, pero genera una sensación de "progresión".
## Se podría meter un Timer para manejarlo de otra manera también
func _on_animation_finished(anim_name: String) -> void:
	# Si el objetivo salio del rango de disparo, regresamos a Idle
	if character.target == null:
		emit_signal("finished", "idle")
	else:
		match anim_name:
			## Si terminó la animación de ataque, entramos en "alert" que
			## permite meter un "cooldown" al ataque en si
			"attack":
				character._play_animation("alert")
			## Si terminó la animación de "cooldown", determinamos si
			## podemos seguir disparando o regresamos a Idle
			"alert":
				if character._can_see_target():
					fire()
				else:
					emit_signal("finished", "idle")


func _handle_body_exited(body) -> void:
	._handle_body_exited(body)
	
	## Este paso es interesante y hace sinergia con el callback de _on_animation_finished
	## si no hay personaje, y no esta en animación de "cooldown", regresa a Idle
	## sino, no hace nada y deja que corra la animación su curso hasta que termine
	## de esa manera genera una sensación de flujo más "natural"
	if character.target == null:
		if character.get_current_animation() != "attack":
			emit_signal("finished", "idle")
