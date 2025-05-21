
## Primera aparición de esta keyword. Esto va como freebie.
## La keyword "tool" denota scripts que se pueden ejecutar
## tanto en runtime como en el editor.
tool
extends Node2D

export (PackedScene) var turret_scene: PackedScene
export (int) var amount: int
export (Vector2) var extents: Vector2 setget _set_extents ## Definicion de setter para variable

export (NodePath) var pathfinding_path: NodePath
onready var pathfinding: Node = get_node_or_null(pathfinding_path)


func _ready() -> void:
	## "Engine.editor_hint" es una flag que le permite al script saber en qué
	## contexto se está ejecutando, si en runtime del juego o en el contexto
	## del editor.
	if Engine.editor_hint:
		update()
	else:
		call_deferred("_initialize")


## Fijarse como esta función se ejecuta tranquilamente, ya que controlamos
## de nunca llamarla en contexto del editor, solo en runtime.
func _initialize() -> void:
	for i in amount:
		var turret_instance: EnemyTurret = turret_scene.instance()
		var turret_pos: Vector2 = Vector2(rand_range(global_position.x, global_position.x + extents.x), rand_range(global_position.y, global_position.y + extents.y))
		turret_instance.initialize(self, turret_pos, self)
		turret_instance.pathfinding = pathfinding


## Al definir el setter, se pueden asignar las variables en contexto de
## "tool" en el editor y utilizarlas.
func _set_extents(value: Vector2) -> void:
	extents = value
	
	## Aquí decimos "si estás en contexto del editor, manda un aviso de redibujado"
	if Engine.editor_hint:
		update()


## Función primitiva de dibujo
func _draw() -> void:
	if Engine.editor_hint:
		draw_rect(Rect2(Vector2.ZERO, extents), Color.blue, false)
