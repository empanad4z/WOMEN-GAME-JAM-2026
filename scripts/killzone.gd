extends Area2D

#var game_over_escena = preload("res://scenes/game_over.tscn")

func _on_body_entered(body: Node2D) -> void:
	print("¡Algo entró a la KillZone!: ", body.name)
	var health := body.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.take_damage(health.health)

#el player cuando muere lo instancia
#func mostrar_pantalla_perdiste() -> void:
#	print("Ejecutando mostrar_pantalla_perdiste()...")
#	var pantalla = game_over_escena.instantiate()
#	get_tree().root.add_child(pantalla)
#	print("Pantalla añadida al root exitosamente.")
#	get_tree().paused = true
