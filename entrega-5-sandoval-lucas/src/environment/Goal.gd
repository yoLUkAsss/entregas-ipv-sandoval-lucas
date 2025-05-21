extends Area2D

onready var portal: AnimatedSprite = $Portal

var won: bool = false


func _ready() -> void:
	portal.play("idle")
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	if !won:
		print("You win!")
		won = true
		portal.play("open")


func _on_Portal_animation_finished() -> void:
	if portal.animation == "open":
		portal.play("idle_open")
