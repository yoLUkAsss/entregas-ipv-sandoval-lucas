extends Node

func _ready():
	$Player.set_projectile_container(self)
	$Turret.set_values($Player, self)
	$Turret2.set_values($Player, self)
	$Turret3.set_values($Player, self)
