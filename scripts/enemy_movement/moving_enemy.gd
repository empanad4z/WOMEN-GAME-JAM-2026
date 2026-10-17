extends CharacterBody2D


var is_moving_left = true
var speed = 10
var target: Node2D = null
@onready var pivot = $Pivot
@onready var floor_ray =  $Pivot/RayCast2D
@onready var wall_ray = $Pivot/RayCast2D2
@onready var health_component = $HealthComponent
@onready var detection = $Detection

func _ready() -> void:
	health_component.died.connect(queue_free)
	detection.body_entered.connect(_on_body_entered)
	detection.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	#move_character()
	#detect_turn_around()
	#
	#Ahora enemigo tiene caminata segun si detecta o no al player
	if target and is_instance_valid(target):
		chase()
	else:
		patrol()
	move_and_slide()

func patrol():
	if is_on_floor() and (not floor_ray.is_colliding() or wall_ray.is_colliding()):
		face(not is_moving_left)
	velocity.x = -speed if is_moving_left else speed
	
func chase():
	#print("Detecta a player")
	var dir = target.global_position.x - global_position.x
	if absf(dir) < 4.0:
		velocity.x = 0
		return
	face(dir < 0)
	if  is_on_floor() and (not floor_ray.is_colliding() or wall_ray.is_colliding()):
		velocity.x = 0
	else:
		velocity.x = signf(dir) * speed
#Funcion actualizada para voltear segun colisiones o player	
func face(left):
	if left == is_moving_left:
		return
	is_moving_left = left
	pivot.scale.x = absf(pivot.scale.x) * (1 if left else -1)
	floor_ray.force_raycast_update()
	wall_ray.force_raycast_update()
#Player entra
func _on_body_entered(body):
	print("Entró: ", body.name, " | grupos: ", body.get_groups())
	if body.is_in_group("Player"):
		target = body
#Player sale
func _on_body_exited(body):
	if body == target:
		target = null
