extends Control

func _on_boton_jugar_pressed() -> void:
	GameState.new_game()
	# Cambiar a ejemplo "res://scenes/Map1.tscn" por la ruta exacta del primer nivel
	get_tree().change_scene_to_file("res://scenes/tests/test_player.tscn")

func _on_boton_salir_pressed() -> void:
	# Cierra la aplicación/juego por completo
	get_tree().quit()
