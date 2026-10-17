# dialogues.gd
extends Node

signal started
signal finished

var is_active: bool = false
var flags: Dictionary = {}  # ej: Dialogues.flags["tiene_llave"] = true


func play(resource: DialogueResource, title: String = "start", extra_states: Array = [], balloon_scene: PackedScene = null) -> void:
	if is_active or resource == null:
		return
	is_active = true
	started.emit()

	if balloon_scene:
		DialogueManager.show_dialogue_balloon_scene(balloon_scene, resource, title, extra_states)
	else:
		DialogueManager.show_dialogue_balloon(resource, title, extra_states)

	await DialogueManager.dialogue_ended
	is_active = false
	finished.emit()
