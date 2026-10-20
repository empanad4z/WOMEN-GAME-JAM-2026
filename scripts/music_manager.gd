extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

# Cambia de musica solo si no es lo que ya estaba sonando.
func play_track(stream: AudioStream) -> void:
	if player.stream == stream and player.playing:
		return
	player.stream = stream
	player.play()
