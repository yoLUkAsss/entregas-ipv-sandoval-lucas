extends KinematicBody2D
class_name Player

## Señales que sirven para comunicar el estado del Player
## a los elementos conectados. Se puede utilizar tanto para
## comunicar estados a la State Machine (sin incluir código
## de la state machine directamente) como para comunicarse,
## por ejemplo, con el entorno del nivel.
signal hit(amount)
signal healed(amount)

signal hp_changed(current_hp, max_hp)
signal mana_changed(current_mana, max_mana)
signal stamina_changed(current_stamina, max_stamina)
signal dead()

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 4.0
const SLOPE_THRESHOLD: float = deg2rad(46)

onready var weapon_manager: Node = $WeaponManager
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var body: Sprite = $"%Body"
onready var floor_raycasts: Array = $FloorRaycasts.get_children()

## Estas variables de exportación podríamos abstraerlas a cada
## estado correspondiente de la state machine, pero como queremos
## poder modificar estos valores desde afuera de la escena del Player,
## los exponemos desde el script de Player.
export (float) var ACCELERATION: float = 60.0
export (float) var H_SPEED_LIMIT: float = 600.0
export (int) var jump_speed: int = 500
export (float) var FRICTION_WEIGHT: float = 6.25
export (int) var gravity: int = 10

var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO
var snap_vector: Vector2 = SNAP_DIRECTION * SNAP_LENGTH
var stop_on_slope: bool = true
var move_direction: int = 0

export (int) var max_hp: int = 10
var hp: int = max_hp

export (float) var max_mana: float = 5.0
var mana: float = max_mana

export (float) var mana_recovery_time: float = 5.0
export (float) var mana_recovery_delay: float = 1.0

export (float) var max_stamina: float = 10.0
var stamina: float = max_stamina

export (float) var stamina_recovery_time: float = 5.0
export (float) var stamina_recovery_delay: float = 0.5


func _ready() -> void:
	initialize()


func initialize(projectile_container: Node = get_parent()) -> void:
	self.projectile_container = projectile_container
	weapon_manager.projectile_container = projectile_container
	for weapon_scene in GameState.weapons_stash:
		add_weapon(weapon_scene)
	GameState.set_current_player(self)


## Se extrae el comportamiento de manejo del disparo del arma a
## una función para ser llamada apropiadamente desde la state machine
func _handle_weapon_actions(delta: float, can_attack: bool = true) -> void:
	weapon_manager.update_weapon(delta, self, can_attack)


## Se extrae el comportamiento del manejo del movimiento horizontal
## a una función para ser llamada apropiadamente desde la state machine
func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x += move_direction * ACCELERATION
		## Para aprovechar la posibilidad de darle impulsos al personaje,
		## replanteamos la desaceleración en caso de superar el límite
		## de velocidad, en vez de hacer un clamp, lo vamos realentizando
		## frame a frame con una interpolación lineal.
		if abs(velocity.x) > H_SPEED_LIMIT:
			## Esto es una interpolación que va desde el punto actual a la
			## misma velocidad horizontal pero con el límite aplicado.
			velocity.x = lerp(
				velocity.x,
				sign(velocity.x) * H_SPEED_LIMIT,
				0.2)
		body_pivot.scale.x = 1 - 2 * float(move_direction < 0)


## Se extrae el comportamiento del manejo de la aplicación de fricción
## a una función para ser llamada apropiadamente desde la state machine
func _handle_deacceleration(delta: float) -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT * delta) if abs(velocity.x) > 1 else 0


## Se extrae el comportamiento de la aplicación de gravedad y movimiento
## a una función para ser llamada apropiadamente desde la state machine
func _apply_movement(with_gravity: bool = true) -> void:
	velocity.y += gravity * float(with_gravity)
	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, stop_on_slope, 4, SLOPE_THRESHOLD)
	if is_on_floor() && snap_vector == Vector2.ZERO:
		snap_vector = SNAP_DIRECTION * SNAP_LENGTH


## Función que pisa la función is_on_floor() ya existente
## y le agrega el chequeo de raycasts para expandir la ventana
## de chequeo de piso
func is_on_floor() -> bool:
	var is_colliding: bool = .is_on_floor()
	for raycast in floor_raycasts:
		## Al tener deshabilitados los raycasts por default
		## ya que queremos que solamente se procesen en esta
		## función, debemos forzar una actualización
		raycast.force_raycast_update()
		is_colliding = is_colliding || raycast.is_colliding()
	return is_colliding


## Esta función ya no llama directamente a remove, sino que deriva
## el handleo a la state machine emitiendo una señal. Esto es para
## los casos de estados en los cuales no se manejan hits
func notify_hit(amount: int = 1) -> void:
	emit_signal("hit", amount)


func sum_hp(amount: int) -> void:
	hp = clamp(hp + amount, 0, max_hp)
	emit_signal("hp_changed", hp, max_hp)
	print("hp_changed %s %s" % [hp, max_hp])


var mana_regen_tween: SceneTreeTween

func sum_mana(amount: float) -> void:
	_update_passive_prop(
		clamp(mana + amount, 0.0, max_mana),
		max_mana,
		"mana",
		"mana_changed"
	)
	if mana < max_mana:
		if mana_regen_tween:
			mana_regen_tween.kill()
		mana_regen_tween = create_tween()
		var duration: float = (max_mana - mana) * mana_recovery_time / max_mana
		mana_regen_tween.tween_method(
			self,
			"_update_passive_prop",
			mana, max_mana, duration,
			[max_mana, "mana", "mana_changed"]
		).set_delay(mana_recovery_delay)


var stamina_regen_tween: SceneTreeTween

func sum_stamina(amount: float) -> void:
	_update_passive_prop(
		clamp(stamina + amount, 0.0, max_stamina),
		max_stamina,
		"stamina",
		"stamina_changed"
	)
	if stamina < max_stamina:
		if stamina_regen_tween:
			stamina_regen_tween.kill()
		stamina_regen_tween = create_tween()
		var duration: float = (max_stamina - stamina) * stamina_recovery_time / max_stamina
		stamina_regen_tween.tween_method(
			self,
			"_update_passive_prop",
			stamina,
			max_stamina,
			duration,
			[max_stamina, "stamina", "stamina_changed"]
		).set_delay(stamina_recovery_delay)


func _update_passive_prop(amount, max_amount, property: String, updated_signal) -> void:
	set(property, amount)
	emit_signal(updated_signal, amount, max_amount)



# El llamado a remove final
func _remove() -> void:
	set_physics_process(false)
	collision_layer = 0


## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)


# Interfaz para agregar un arma nueva, delega al WeaponManager.
func add_weapon(weapon_scene: PackedScene) -> void:
	weapon_manager.add_weapon(weapon_scene)
