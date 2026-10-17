extends Area2D

var game_over_escena = preload("res://scenes/game_over.tscn")

func _on_body_entered(body: Node2D) -> void:
	print("¡Algo entró a la KillZone!: ", body.name)
	mostrar_pantalla_perdiste()

func mostrar_pantalla_perdiste() -> void:
	print("Ejecutando mostrar_pantalla_perdiste()...")
	var pantalla = game_over_escena.instantiate()
	get_tree().root.add_child(pantalla)
	print("Pantalla añadida al root exitosamente.")
	get_tree().paused = true
