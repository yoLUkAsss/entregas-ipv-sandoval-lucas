extends Node
class_name GameLevel


## Esta escena no debería cargarse de manera directa en runtime,
## solo para testeo mediante "Reproducir Escena" (F6).
## En versión final, el LevelManager debería encargarse de ello.

## Este script y su clase deberían ser el mismo para todos los niveles.


## Tenemos la interfaz básica de señales de control de estado
## del nivel

# Regresa al menu principal
signal return_requested()
# Reinicia el nivel
signal restart_requested()
# Inicia el siguiente nivel
signal next_level_requested()


func _ready() -> void:
	randomize()


# Funciones que hacen de interfaz para las señales
func _on_level_won() -> void:
	emit_signal("next_level_requested")


func _on_return_requested() -> void:
	emit_signal("return_requested")


func _on_restart_requested() -> void:
	emit_signal("restart_requested")
