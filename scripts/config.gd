extends Control

var music = AudioServer.get_bus_index("Music")

func _ready() -> void:
	MusicManager.play_track(preload("res://assets/audio/menu.ogg"))
	$VBoxContainer/HSlider.value = AudioServer.get_bus_volume_linear(music)

func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
