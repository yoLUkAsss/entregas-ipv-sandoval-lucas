extends Control

signal return_selected()
signal restart_level()

## Menú de pausa genérico, abierto utilizando la acción "pause_menu"
## (por default la tecla Esc).
onready var options_menu = $OptionsMenu


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_menu") && !options_menu.visible:
		visible = !visible
		get_tree().paused = visible


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_Back_to_Menu_pressed():
	emit_signal("return_selected")


func _on_RestartButton_pressed():
	get_tree().paused = false
	emit_signal("restart_level")
