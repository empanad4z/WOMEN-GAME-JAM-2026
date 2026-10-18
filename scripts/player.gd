extends CharacterBody2D


const SPEED = 250.0
const SPRINT_SPEED = 450.0
const JUMP_VELOCITY = -550.0
const GAME_OVER_SCENE := preload("res://scenes/game_over.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hitbox: Hitbox = $Hitbox

var is_attacking := false

func _on_invincibility_started(duration: float) -> void:
	var tween := create_tween().set_loops(int(duration / 0.2))
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.2, 0.1)   # se apaga
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)   # se prende

func _on_died():
	var screen := GAME_OVER_SCENE.instantiate()
	get_tree().root.add_child(screen)
	get_tree().paused = true

func _ready() -> void:
	$Hurtbox.invincibility_started.connect(_on_invincibility_started)
	$HealthComponent.died.connect(_on_died)

func attack() -> void:
	animated_sprite_2d.play("attack")
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
	var is_attack_anim_playing := animated_sprite_2d.animation == "attack" and animated_sprite_2d.is_playing()
	if not is_attack_anim_playing:
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
