extends RigidBody2D

func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
