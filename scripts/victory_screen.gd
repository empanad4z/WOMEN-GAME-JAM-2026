extends Control

func _on_boton_siguiente_pressed() -> void:
	# 1. Quitamos la pausa para que el próximo nivel funcione
	get_tree().paused = false 
	
	# 2. Cambiamos a la escena del siguiente nivel 
	# (Cambia esta ruta por la de tu nivel 2, o por el menú principal si no tienes más)
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")
	
	# 3. Limpiamos esta pantalla de la memoria
	queue_free()
