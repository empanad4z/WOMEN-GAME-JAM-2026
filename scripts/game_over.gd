extends Control

func _on_boton_reiniciar_pressed() -> void:
	# 1. Despausamos el motor para que el nivel se pueda mover al cargar
	get_tree().paused = false 
	
	# 2. Reiniciamos el nivel actual desde cero
	get_tree().reload_current_scene()
	
	# 3. Borramos esta pantalla de la memoria para que no se quede flotando
	queue_free() 

func _on_boton_menu_pressed() -> void:
	# Hacemos lo mismo si decides volver al menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	queue_free()
