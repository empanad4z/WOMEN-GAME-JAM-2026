extends CanvasLayer

func _on_boton_siguiente_pressed() -> void:
	# 1. Quitamos la pausa para que el juego vuelva a correr
	get_tree().paused = false 
	
	# 2. Cambiamos al siguiente nivel (Asegúrate de que este archivo exista)
	# Si aún no creas el Map2, cámbialo temporalmente a Map1.tscn
	get_tree().change_scene_to_file("res://scenes/Map1.tscn")
	
	# 3. Borramos la interfaz de victoria
	queue_free()
