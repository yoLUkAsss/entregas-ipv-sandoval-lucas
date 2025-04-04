extends Sprite2D

@onready var fire_position: Marker2D = $FirePosition

@export var projectile_scene: PackedScene

var projectile_container: Node

func fire():
	var projectile_instance: Projectile = projectile_scene.instantiate()
	projectile_container.add_child(projectile_instance)
	projectile_instance.set_starting_values(fire_position.global_position, (fire_position.global_position - global_position).normalized())
	projectile_instance.delete_requested.connect(on_projectile_delete_requested.bind(projectile_instance))

func on_projectile_delete_requested(projectile: Projectile):
	print("removed")
	projectile_container.remove_child(projectile)
	projectile.queue_free()
