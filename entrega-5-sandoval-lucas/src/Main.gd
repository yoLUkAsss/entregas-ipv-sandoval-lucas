extends Node


func _ready() -> void:
	randomize()


## Agregamos un botoncito primitivo de reset. Por default es la "R".
func _input(event: InputEvent) -> void:
	if event.is_action("reset"):
		get_tree().reload_current_scene()
