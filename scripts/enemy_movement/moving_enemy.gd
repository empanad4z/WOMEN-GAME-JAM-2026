extends CharacterBody2D


var is_moving_left = true
var speed = 32
@onready var pivot = $Pivot
@onready var floor_ray =  $Pivot/RayCast2D
@onready var wall_ray = $Pivot/RayCast2D2
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_character()
	detect_turn_around()
	
func move_character():
	velocity.x = -speed if is_moving_left else speed
	move_and_slide()
	
func detect_turn_around():
	#Detecta vacio y pared en frente del enemigo
	if (not floor_ray.is_colliding() or wall_ray.is_colliding()) and is_on_floor():
		turn_around()
func turn_around():
	is_moving_left = not is_moving_left
	pivot.scale.x = -pivot.scale.x
	floor_ray.force_raycast_update()
	wall_ray.force_raycast_update()
