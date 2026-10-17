extends CharacterBody2D


const SPEED = 250.0
const SPRINT_SPEED = 450.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: Hitbox = $Hitbox

var is_attacking := false

func attack() -> void:
	is_attacking = true
	hitbox_shape.set_deferred("disabled", false)
	await get_tree().create_timer(0.15).timeout
	hitbox_shape.set_deferred("disabled", true)
	is_attacking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
	# attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	# Flip the sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
		hitbox.position.x = abs(hitbox.position.x)
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		hitbox.position.x = -abs(hitbox.position.x)
		
	# Player animations
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
	
	# Apply movement
	if direction:
		var current_speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
