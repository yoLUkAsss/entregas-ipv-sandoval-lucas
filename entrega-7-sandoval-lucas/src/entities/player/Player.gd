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
signal dead()

const FLOOR_NORMAL: Vector2 = Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGTH: float = 32.0
const SLOPE_THRESHOLD: float = deg2rad(46)

onready var weapon: Node = $"%Weapon"
onready var body_animations: AnimationPlayer = $BodyAnimations
onready var body_pivot: Node2D = $BodyPivot
onready var floor_raycasts: Array = $FloorRaycasts.get_children()

## Estas variables de exportación podríamos abstraerlas a cada
## estado correspondiente de la state machine, pero como queremos
## poder modificar estos valores desde afuera de la escena del Player,
## los exponemos desde el script de Player.
export (float) var ACCELERATION: float = 60.0
export (float) var H_SPEED_LIMIT: float = 600.0
export (int) var jump_speed: int = 500
export (float) var FRICTION_WEIGHT: float = 0.1
export (int) var gravity: int = 10

var projectile_container: Node

var velocity: Vector2 = Vector2.ZERO
var snap_vector: Vector2 = SNAP_DIRECTION * SNAP_LENGTH
var stop_on_slope: bool = true
var move_direction: int = 0

## Flag de ayuda para saber identificar el estado de actividad
var dead: bool = false


func _ready() -> void:
	initialize()


func initialize(projectile_container: Node = get_parent()) -> void:
	self.projectile_container = projectile_container
	weapon.projectile_container = projectile_container


## Se extrae el comportamiento de manejo del disparo del arma a
## una función para ser llamada apropiadamente desde la state machine
func _handle_weapon_actions() -> void:
	weapon.process_input()
	if Input.is_action_just_pressed("fire_weapon"):
		if projectile_container == null:
			projectile_container = get_parent()
		if weapon.projectile_container == null:
			weapon.projectile_container = projectile_container
		weapon.fire()


## Se extrae el comportamiento del manejo del movimiento horizontal
## a una función para ser llamada apropiadamente desde la state machine
func _handle_move_input() -> void:
	move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if move_direction != 0:
		velocity.x = clamp(velocity.x + (move_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
		body_pivot.scale.x = 1 - 2 * float(move_direction < 0)


## Se extrae el comportamiento del manejo de la aplicación de fricción
## a una función para ser llamada apropiadamente desde la state machine
func _handle_deacceleration() -> void:
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0


## Se extrae el comportamiento de la aplicación de gravedad y movimiento
## a una función para ser llamada apropiadamente desde la state machine
func _apply_movement() -> void:
	velocity.y += gravity
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


## Y acá se maneja el hit final. Como aun no tenemos una "cantidad" de HP,
## sino una flag, el hit nos mata instantaneamente y tiramos una notificación.
## Esta signal tranquilamente podría llamarse "dead", pero como esa la utilizamos
## para otras cosas, y como sabemos que incorporaremos una barra de salud después
## es apropiado manejarlo de esta manera.
func _handle_hit(amount: int = 1) -> void:
	dead = true
	emit_signal("hp_changed", 0, 1)


# El llamado a remove final
func _remove() -> void:
	set_physics_process(false)
	collision_layer = 0


## Wrapper sobre el llamado a animación para tener un solo punto de entrada controlable
## (en el caso de que necesitemos expandir la lógica o debuggear, por ejemplo)
func _play_animation(animation: String) -> void:
	if body_animations.has_animation(animation):
		body_animations.play(animation)
