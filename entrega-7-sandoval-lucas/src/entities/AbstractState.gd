## Interfaz base para todos los estados: No hace nada en si mismo
## pero fuerza a pasar los argumentos correctos a los métodos
## de abajo y se asegura de que cada objeto State tenga todos
## estos métodos
extends Node
class_name AbstractState


## Señal que se llama al terminar el estado actual y que recibe como
## parámetro el estado siguiente a transicionar
signal finished(next_state_name)


## ID del estado. Debe de ser único entre todos los estados
## que conforman a la máquina de estados actual.
export (String) var state_id: String

var character


# Inicializa el estado. Por ej, cambiar la animación
func enter() -> void:
	return


# Limpia el estado. Por ej, reiniciar valores de variables o detener timers
func exit() -> void:
	return


# Callback derivado de _input
func handle_input(event: InputEvent) -> void:
	return


# Callback derivado de _physics_process
func update(delta: float) -> void:
	return


# Callback cuando finaliza una animación en tiempo del estado actual
func _on_animation_finished(anim_name: String) -> void:
	return


# Callback genérico para eventos manejados como strings.
func handle_event(event: String, value = null) -> void:
	return
