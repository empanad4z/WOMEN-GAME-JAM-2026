extends Control

func _ready() -> void:
	MusicManager.play_track(preload("res://assets/audio/menu.ogg"))

func _on_boton_jugar_pressed() -> void:
	GameState.new_game()
	# Cambiar a ejemplo "res://scenes/Map1.tscn" por la ruta exacta del primer nivel
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_boton_config_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/config.tscn")

func _on_boton_salir_pressed() -> void:
	# Cierra la aplicación/juego por completo
	get_tree().quit()
