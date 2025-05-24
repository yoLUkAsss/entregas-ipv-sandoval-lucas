extends AbstractStateMachine


func notify_body_entered(body: Node) -> void:
	current_state.handle_event("body_entered", body)


func notify_body_exited(body: Node) -> void:
	current_state.handle_event("body_exited", body)


func notify_hit(amount: int) -> void:
	current_state.handle_event("hit", amount)


func _on_Turret_hp_changed(hp: int, max_hp: int) -> void:
	current_state.handle_event("hp_changed", [hp, max_hp])


func _on_Body_animation_finished() -> void:
	_on_animation_finished(character.get_current_animation())
