extends AbstractState

export (int) var jumps_limit: int = 1

var jumps: int = 0

# Al entrar se activa primero la animación "idle"
func enter() -> void:
	character.snap_vector = Vector2.ZERO
	character.velocity.y -= character.jump_speed
	character._play_animation("jump")

func handle_input(event: InputEvent) -> void:
	print("JUMPS:")
	print(jumps)
	if event.is_action_pressed("jump") && jumps < jumps_limit:
		jumps = jumps + 1
		character.velocity.y -= character.jump_speed
		emit_signal("finished", "jump")

# En esta función vamos a manejar las acciones apropiadas para este estado
func update(delta: float) -> void:
	# Vamos a querer que se pueda disparar
	character._handle_weapon_actions()
	
	character._handle_move_input()
	
	if character.move_direction == 0:
		character._handle_deacceleration()

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
		"hit":
			character._handle_hit(value)
			if character.dead:
				emit_signal("finished", "dead")

func exit() -> void:
	jumps = 0
