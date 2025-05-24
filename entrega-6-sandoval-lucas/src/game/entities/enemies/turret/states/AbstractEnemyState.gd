extends AbstractState
class_name AbstractEnemyState


## Manejamos los eventos de detección de cuerpo aprovechando el polimorfismo
## del parámetro "value" para pasar el cuerpo detectado
func handle_event(event: String, value = null) -> void:
	match event:
		"body_entered":
			_handle_body_entered(value)
		"body_exited":
			_handle_body_exited(value)
		"hit":
			_handle_hit(value)
		"hp_changed":
			_handle_hp_changed(value[0], value[1])


# Derivamos la detección del target que entra
func _handle_body_entered(body: Node) -> void:
	if character.target == null:
		character.target = body


# Derivamos la detección del target que sale
func _handle_body_exited(body) -> void:
	if body == character.target:
		character.target = null


func _handle_hit(amount: int) -> void:
	character._sum_hp(amount)


func _handle_hp_changed(hp: int, _max_hp: int) -> void:
	if hp == 0:
		emit_signal("finished", "dead")
