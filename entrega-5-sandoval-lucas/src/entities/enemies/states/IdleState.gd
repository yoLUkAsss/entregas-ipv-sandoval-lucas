extends AbstractEnemyState

onready var idle_timer = $IdleTimer

func enter():
	character.velocity = Vector2.ZERO
	if character.target != null:
		character._play_animation("idle_alert")
	else:
		character._play_animation("idle")
	
	idle_timer.start()

func update(delta: float) -> void:
	character._apply_movement()
	
	if character._can_see_target():
		emit_signal("finished", "alert")

func exit() -> void:
	idle_timer.stop()

func _on_IdleTimer_timeout():
	emit_signal("finished", "walk")

func _handle_body_entered(value = null) -> void:
	._handle_body_entered(value)
	character._play_animation("alert")

func _handle_body_exited(value = null) -> void:
	._handle_body_exited(value)
	character._play_animation("go_normal")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"alert":
			character._play_animation("idle_alert")
		"go_normal":
			character._play_animation("idle")
