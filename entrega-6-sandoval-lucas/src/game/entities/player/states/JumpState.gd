extends AbstractState

export (int) var jumps_limit:int = 1

var jumps:int = 0


func enter() -> void:
	character.snap_vector = Vector2.ZERO
	character.velocity.y = -character.jump_speed
	character._play_animation("jump")


func exit() -> void:
	jumps = 0


func handle_input(event:InputEvent) -> void:
	if event.is_action_pressed("dash") && character.move_direction != 0:
		emit_signal("finished", "dash")
	elif event.is_action_pressed("jump") && jumps < jumps_limit:
		jumps += 1
		character.velocity.y = -character.jump_speed
		character._play_animation("jump")


func update(delta: float) -> void:
	character._handle_weapon_actions(delta)
	character._handle_move_input()
	if character.move_direction == 0:
		character._handle_deacceleration(delta)
	character._apply_movement()
	if character.is_on_floor():
		if character.move_direction == 0:
			emit_signal("finished", "idle")
		else:
			emit_signal("finished", "walk")
	else:
		if character.velocity.y > 0:
			character._play_animation("fall")
		else:
			character._play_animation("jump")


func handle_event(event: String, value = null) -> void:
	match event:
		"hit", "healed":
			character.sum_hp(value)
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "dead")
