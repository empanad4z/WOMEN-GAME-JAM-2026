extends CanvasLayer

func _on_boton_reiniciar_pressed() -> void:
	# 1. Quitamos la pausa para que el juego vuelva a procesar
	print("¡Se presionó el botón de reiniciar!")
	get_tree().paused = false 
	
	# 2. Reiniciamos la escena actual o cargamos Map1 directamente
	get_tree().reload_current_scene()
	# O bien: get_tree().change_scene_to_file("res://scenes/Map1.tscn")
	
	# 3. Borramos la pantalla de Game Over
	queue_free()

func _on_boton_menu_pressed() -> void:
	get_tree().paused = false
	# Ajusta la ruta a tu menú si tienes uno, o a Map1
	get_tree().change_scene_to_file("res://scenes/Map1.tscn") 
	queue_free()
