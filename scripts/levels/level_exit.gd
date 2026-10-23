extends Area2D

# Al entrar la jugadora, se cierra el nivel actual y se carga el siguiente
@export_file("*.tscn") var next_level: String
# Bloqueada no hace nada; el nivel la desbloquea cuando se cumple el objetivo
@export var locked := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if locked or not body.is_in_group("Player"):
		return
	set_deferred("monitoring", false)
	GameState.complete_level()
	get_tree().change_scene_to_file(next_level)
