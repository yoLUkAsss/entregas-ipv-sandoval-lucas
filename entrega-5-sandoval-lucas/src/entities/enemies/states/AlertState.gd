extends AbstractEnemyState

func enter():
	character.velocity = Vector2.ZERO
	
	fire()
	
func fire():
	character._fire()
	character._play_animation("attack")

func update(delta: float) -> void:
	character._look_at_target()




func _on_animation_finished(anim_name: String) -> void:
	if character.target == null:
		emit_signal("finished", "idle")
	else:
		match anim_name:
			"attack":
				character._play_animation("alert")
			"alert":
				if character._can_see_target():
					fire()
				else:
					emit_signal("finished", "idle")


func _handle_body_exited(value = null) -> void:
	._handle_body_exited(value)

	if character.target == null:
		if character._get_current_animation() != "attack":
			emit_signal("finished", "idle")
