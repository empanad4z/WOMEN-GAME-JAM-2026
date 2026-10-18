extends Area2D

# Cargamos la escena de la pantalla de victoria que creaste antes
var victory_screen_escena = preload("res://scenes/victory_screen.tscn")

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si el que entró a la zona es el jugador
	if body.is_in_group("player") or body.name == "Player":
		mostrar_pantalla_victoria()

func mostrar_pantalla_victoria() -> void:
	GameState.complete_level()
	print("Recuerdos guardados: ", GameState.collected_memories)
	# 1. Instanciamos la pantalla de victoria
	var pantalla = victory_screen_escena.instantiate()
	
	# 2. La añadimos a la raíz del juego para que se dibuje por encima de todo
	get_tree().root.add_child(pantalla)
	
	# 3. Pausamos el juego para congelar al personaje y enemigos
	get_tree().paused = true
	
	# 4. Desconectamos o borramos la zona para que no se active dos veces
	queue_free()
