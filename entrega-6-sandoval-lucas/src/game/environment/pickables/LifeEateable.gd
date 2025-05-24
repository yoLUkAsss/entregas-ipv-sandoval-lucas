extends Node2D

export (float) var life_recovery: float = 2

class_name LifeEatable


func _on_Area2D_body_entered(body):
	if body is Player:
		body.sum_hp(life_recovery)
		queue_free()
