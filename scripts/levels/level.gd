extends Node2D


@export var level_id: StringName = &"nivel_1"
@export var fade_rect: ColorRect

func fade_from_black(duration: float):
	if not fade_rect: return
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished

func _ready():
	if fade_rect: fade_rect.modulate.a = 1.0
	GameState.enter_level(level_id)
	print("Recuerdos guardados: ", GameState.collected_memories)
