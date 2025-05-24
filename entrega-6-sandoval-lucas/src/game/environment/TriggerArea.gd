extends Area2D

## Implementación de trigger genérico de eventos. Puede llamar a
## N nodos, con M métodos con L parámetros o con M variables.

## Una implementación más compleja con Timers podría permitir cosas como,
## por ejemplo, un sistema de cinemáticas, moviendo los parámetros
## de la Camera de forma custom en tiempos determinados e inmovilizando
## al Player.

export (Array, NodePath) var nodes_affected: Array
export (Array, PoolStringArray) var methods_list: Array
export (Array, Array, Array) var parameters: Array


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	for i in nodes_affected.size():
		var node: Node = get_node(nodes_affected[i])
		var methods: PoolStringArray = methods_list[i]
		var params: Array = parameters[i]
		for m in methods.size():
			var method: String = methods[m]
			if node.has_method(method):
				node.callv(method, params[m])
			elif method in node && !params[m].empty():
				node.set(method, params[m][0])
