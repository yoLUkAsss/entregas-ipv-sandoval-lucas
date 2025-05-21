extends Node2D

onready var weapon_tip: Node2D = $WeaponTip
onready var fx_anim: AnimationPlayer = $FXAnim

export (PackedScene) var projectile_scene: PackedScene

var projectile_container: Node
var fire_tween: SceneTreeTween


## Acá solo me mantengo apuntando si tengo habilitada esa función.
## Esto es como corrección de apuntado para compensar por el delay
## aplicado por la animación de disparo.
func process_input() -> void:
	if fx_anim.is_playing():
		rotation = (get_global_mouse_position() - global_position).angle()


func fire() -> void:
	if !fx_anim.is_playing():
		## Mato al tween antes de disparar para que no me cambie la rotación
		if fire_tween != null:
			fire_tween.kill()
		
		## No disparo de inmediato, sino que delego a una animación de disparo
		fx_anim.play("fire")


## La animación de disparo llama a esta función que va a ser la que instancie
## el proyectil
func _fire() -> void:
	projectile_scene.instance().initialize(projectile_container, weapon_tip.global_position, global_position.direction_to(weapon_tip.global_position))
	
	## Y por último animo el retorno a la posición de inicio del arma
	fire_tween = create_tween()
	
	## Cálculo del demonio, podría haber sido mucho más sencillo utilizando
	## vectores y sacando los ángulos circulares.
	## Lo que hace es toma el ángulo relativo más cercano, ya que después de cierto
	## punto, en vez de rotar correctamente hacia arriba, da toda la vuelta.
#	var final_angle: float = deg2rad(-90.0 + 360.0 * float(rotation > deg2rad(90)))
	
	## Me enculé y lo hice de esta manera. Parece chino también, pero básicamente
	## toma un vector con rotación 0 (los radianes SIEMPRE toman como rotación 0
	## mirar a la izquierda, osea, (1, 0)) y le aplica la rotación actual, le pide el ángulo
	## hacia la dirección que queremos que vaya, y luego se lo suma a la rotación actual.
	var final_angle: float = rotation + Vector2.LEFT.rotated(rotation).angle_to(Vector2.DOWN)
	
	## Y acá se anima programáticamente utilizando el ángulo actual del arma hacia
	## el ángulo final al que debe rotar.
	fire_tween.tween_property(self, "rotation", final_angle, 0.5).set_delay(0.5)
