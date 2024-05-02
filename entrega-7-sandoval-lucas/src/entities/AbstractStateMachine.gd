## Interfaz base para una máquina de estados genérica
## Maneja la inicialización, configurar la máquina de estados
## activa o no, delegar llamados de _physics_process e _input
## a los nodos de Estado, y cambiar el estado actual/activo
extends Node
class_name AbstractStateMachine

signal state_changed(current_state)


## Path al nodo de personaje a controlar. Si no se asigna,
## la máquina de estado no se inicializa.
export (NodePath) var character_path: NodePath
var character: Node setget _set_character


## Es necesario asignar un nodo inicial desde el inspector o
## en el nodo que herede de esta interfaz de máquina de estado.
## No realizarlo crashea el juego (a propósito, así no olvidas
## inicializarlo en la máquina de estados)
export (NodePath) var START_STATE


## La lista completa de nodos de estado que conforman la máquina.
## Si un nodo no se agrega a la lista, no se lo tendrá en cuenta.
export (Array, NodePath) var STATES_LIST
var states_map = {}

var current_state = null
var _active: bool = false setget set_active


func _ready() -> void:
	set_active(false)
	call_deferred("_initialize")


func _initialize() -> void:
	# Se mapean los estados con sus ids correspondientes (sin ids repetidos)
	for state_path in STATES_LIST:
		var state: AbstractState = get_node(state_path)
		states_map[state.state_id] = state
	
	# Se chequea que se haya asignado un character a controlar
	if !character_path.is_empty():
		var ch: Node = get_node_or_null(character_path)
		if ch != null:
			## Al setear la variable de esta manera se llama
			## a su función setter. Equivalente a hacer _set_character(ch)
			self.character = ch


# Setter de la variable character que da el puntapie a la state machine
func _set_character(_character: Node) -> void:
	character = _character
	if not START_STATE:
		START_STATE = get_child(0).get_path()
	for child in get_children():
		child.connect("finished", self, "_change_state")
		child.character = character
	initialize(get_node(START_STATE))


# Pone en marcha la state machine con un primer estado asignado
func initialize(start_state) -> void:
	set_active(true)
	current_state = start_state
	current_state.enter()

# Función toggle que activa o desactiva la state machine
func set_active(active: bool) -> void:
	_active = active
	set_physics_process(active)
	set_process_input(active)
	if not _active:
		current_state = null


# Delega el manejo de inputs al estado actual
func _input(event:InputEvent) -> void:
	current_state.handle_input(event)


# Delega los updates de _physics_process al estado actual
func _physics_process(delta: float) -> void:
	current_state.update(delta)


# Notifica al estado actual de la finalización de una animación
func _on_animation_finished(anim_name: String = "") -> void:
	if !_active:
		return
	current_state._on_animation_finished(anim_name)


# Función de cambio de estado
func _change_state(state_name: String) -> void:
	if !_active:
		return
	# Sale del estado actual activo
	current_state.exit()
	# Reemplaza el estado actual por el indicado
	current_state = states_map[state_name]
	## Primero notifica del cambio de estado, por si algun
	## componente quiere hacer cambios en medio
	emit_signal("state_changed", current_state)
	# Y se activa el estado nuevo
	current_state.enter()
