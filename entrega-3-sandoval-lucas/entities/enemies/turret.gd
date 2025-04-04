extends Sprite2D

@export var projectile_scene: PackedScene

@onready var fire_position: Marker2D = $FirePosition

var player: Node
var projectile_container: Node

func set_values(player, projectile_container):
	self.player = player
	self.projectile_container = projectile_container
	$FireTimer.start()

func _on_fire_timer_timeout() -> void:
	fire()

func fire():
	var projectile: Projectile = projectile_scene.instantiate()
	projectile_container.add_child(projectile)
	projectile.set_starting_values(fire_position.global_position, (player.global_position - fire_position.global_position).normalized())
	projectile.delete_requested.connect(on_projectile_delete_requested.bind(projectile))

func on_projectile_delete_requested(projectile: Projectile):
	projectile_container.remove_child(projectile)
	projectile.queue_free()
