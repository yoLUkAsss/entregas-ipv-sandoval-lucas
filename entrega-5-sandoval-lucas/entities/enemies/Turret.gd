extends Sprite

export (PackedScene) var projectile_scene

onready var fire_position: Position2D = $FirePosition

var projectile_container: Node

var target

func set_values(projectile_container):
	self.projectile_container = projectile_container
	$Timer.start()

func _on_Timer_timeout():
	fire()
	
func fire():
	var projectile: Projectile = projectile_scene.instance()
	projectile_container.add_child(projectile)
	projectile.set_starting_values(fire_position.global_position, (player.global_position - fire_position.global_position).normalized())
	projectile.connect("delete_requested", self, "on_projectile_delete_requested")
	
func on_projectile_delete_requested(projectile):
	projectile_container.remove_child(projectile)
	projectile.queue_free()


func _on_DetectionArea_body_entered(body):
	if 
