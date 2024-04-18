extends Area2D

onready var animated_sprite = $AnimatedSprite
onready var tween = $Tween

var won: bool = false

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	# Prendi light mask en 15 y solo el player tambien ve esa capa
	# Con lo cual, el unico body que podria entrar es el Player
	if !won:
		won = true
		var new_scale = Vector2(animated_sprite.scale.x + 1, animated_sprite.scale.y + 1)
		var new_speed = animated_sprite.speed_scale * 7
		
		
		tween.interpolate_property(animated_sprite, "scale", animated_sprite.scale, new_scale, 1)
		tween.interpolate_property(animated_sprite, "speed_scale", animated_sprite.speed_scale, new_speed, 1)
		tween.start()
