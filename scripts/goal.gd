extends Area2D

# Cargamos la escena de la interfaz de victoria
var victoria_escena = preload("res://scenes/victory_screen.tscn")

func _on_body_entered(body: Node2D) -> void:
	# Al igual que antes, verificamos si es el jugador mediante su grupo
	if body.is_in_group("Player"):
		mostrar_pantalla_victoria()

func mostrar_pantalla_victoria() -> void:
	# 1. Instanciamos la pantalla de ganaste
	var pantalla = victoria_escena.instantiate()
	
	# 2. La pegamos al root para que se centre en el monitor del jugador
	get_tree().root.add_child(pantalla)
	
	# 3. Pausamos el juego para que los enemigos no te golpeen mientras celebras
	get_tree().paused = true
