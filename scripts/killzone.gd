extends Area2D

# Cargamos la escena de la interfaz desde tus archivos
var game_over_escena = preload("res://scenes/game_over.tscn")

func _on_body_entered(body: Node2D) -> void:
	# Comprobamos si el objeto que cayó pertenece al grupo "Player"
	if body.is_in_group("Player"):
		mostrar_pantalla_perdiste()

func mostrar_pantalla_perdiste() -> void:
	# RECORDAR PONER ESTA PANTALLA CUANDO
	# NO QUEDEN VIDAS 
	
	# 1. Creamos la interfaz de Game Over en el aire
	var pantalla = game_over_escena.instantiate()
	
	# 2. La añadimos directamente al 'root' del juego. 
	# Esto hace que aparezca centrada en la ventana del monitor, ignorando la cámara.
	get_tree().root.add_child(pantalla)
	
	# 3. Congelamos las físicas, enemigos y animaciones del plataformero
	get_tree().paused = true
