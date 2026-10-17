class_name	HealthComponent extends Node

signal health_changed(current: int, max_health:int )
signal died

@export var max_health : int = 3
var health : int

func take_damage(amount : int):
	if health <= 0: return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	if health <= 0:
		died.emit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
