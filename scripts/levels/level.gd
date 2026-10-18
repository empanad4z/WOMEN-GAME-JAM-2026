extends Node2D


@export var level_id: StringName = &"nivel_1"

func _ready():
	GameState.enter_level(level_id)
	print("Recuerdos guardados: ", GameState.collected_memories)
