class_name Hurtbox extends Area2D

@export var health: HealthComponent
@export var invincibility_time: float = 0.0
signal invincibility_started(duration: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		health.take_damage(area.damage)
		if invincibility_time > 0:
			invincibility_started.emit(invincibility_time)
			set_deferred("monitoring", false)
			await get_tree().create_timer(invincibility_time).timeout
			set_deferred("monitoring", true)
			
