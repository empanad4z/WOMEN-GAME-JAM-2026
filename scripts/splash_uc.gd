extends Control

# Pantalla de financiamiento UC (obligatoria), se muestra antes del menu
const NEXT_SCENE := "res://scenes/main.tscn"

# Tiempo con el texto completamente visible, el requisito pide al menos 2 s
@export var hold_time := 2.5
@export var fade_time := 0.5

@onready var content: Control = $Content


func _ready() -> void:
	content.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(content, "modulate:a", 1.0, fade_time)
	tween.tween_interval(hold_time)
	tween.tween_property(content, "modulate:a", 0.0, fade_time)
	await tween.finished
	get_tree().change_scene_to_file(NEXT_SCENE)
