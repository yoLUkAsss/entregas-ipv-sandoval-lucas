extends AbstractState

## State de Dash. Solo puede ingresar si está en movimiento en una dirección,
## con una duración y posee un cooldown con un cierto tiempo.
## El dash permite no solo moverse rápido a cambio de un coste de Stamina,
## sino también ofrece invulnerabilidad por lo que dure el Dash.

onready var dash_cooldown_timer: Timer = $DashCooldown

export (float) var dash_stamina_cost: float = 2.0

export (float) var dash_time: float = 1.0
export (float) var speed_multiplier: float = 1.0
export (float) var dash_cooldown: float = 1.0

export (Color) var dash_cooldown_color: Color

var dash_timer:Timer


func _ready() -> void:
	dash_timer = Timer.new()
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.connect("timeout", self, "_on_dash_timer_timeout")
	set_process(false)


func _process(delta: float) -> void:
	var time_left: float = dash_cooldown_timer.time_left
	character.body.self_modulate = lerp(Color.white, dash_cooldown_color, time_left / dash_cooldown)
	if time_left == 0:
		set_process(false)


func enter() -> void:
	if  !dash_cooldown_timer.is_stopped() || character.stamina < dash_stamina_cost:
		emit_signal("finished", "walk")
	else:
		dash_timer.start(dash_time)
		character.sum_stamina(-dash_stamina_cost)
		character._play_animation("dash")
		dash_cooldown_timer.start(dash_cooldown)
		set_process(true)


func exit() -> void:
	dash_timer.stop()


func update(delta) -> void:
	character._handle_weapon_actions(delta)
	character.velocity = Vector2(
		clamp(
			character.velocity.x + (character.move_direction * character.ACCELERATION * speed_multiplier),
			-character.H_SPEED_LIMIT * speed_multiplier,
			character.H_SPEED_LIMIT * speed_multiplier
		),
		0.0
		)
	character._apply_movement(false)


func _on_dash_timer_timeout() -> void:
	character._handle_move_input()
	if character.move_direction == 0:
		emit_signal("finished", "idle")
	else:
		emit_signal("finished", "walk")


func handle_event(event: String, value = null) -> void:
	match event:
		"healed":
			character.sum_hp(value)
		"hp_changed":
			if value[0] == 0:
				emit_signal("finished", "dead")
