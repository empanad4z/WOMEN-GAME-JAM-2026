extends CharacterBody2D
var is_moving_left = true
var speed = 32;

func _process(delta):
	move_character()
	detect_turn_around()

func move_character():
	velocity.x = -speed if is_moving_left else speed
	
	move_and_slide()

#Funcion que detecta si deja de tocar el piso o si se encuentra pared
#Requiere de uso correcto de Layers de colisiones
func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
	elif $RayCast2D2.is_colliding() and is_on_floor():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
