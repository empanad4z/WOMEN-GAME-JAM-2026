extends "res://scripts/levels/level.gd"

@export var enemy: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy.set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_enemy() -> void:
	enemy.show()
	enemy.set_physics_process(true)
