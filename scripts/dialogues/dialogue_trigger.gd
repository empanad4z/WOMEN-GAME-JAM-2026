# dialogue_trigger.gd
class_name DialogueTrigger
extends Area2D

enum Mode { INTERACT, ON_ENTER, MANUAL }

@export var dialogue: DialogueResource
@export var title: String = "start"
@export var mode: Mode = Mode.INTERACT
@export var once: bool = false
@export var interact_action: StringName = &"interact"
@export var player_group: StringName = &"player"
@export var balloon_scene: PackedScene          # opcional: globo propio
@export var prompt: CanvasItem                  # opcional: icono "E para hablar"

var _player_inside: bool = false
var _done: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt:
		prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if mode == Mode.INTERACT and _player_inside and event.is_action_pressed(interact_action):
		get_viewport().set_input_as_handled()
		trigger()


func trigger(extra_states: Array = []) -> void:
	if _done or Dialogues.is_active:
		return
	if once:
		_done = true
	if prompt:
		prompt.hide()
	# [self] permite que el .dialogue llame a funciones/variables de este nodo
	Dialogues.play(dialogue, title, [self] + extra_states, balloon_scene)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(player_group):
		return
	_player_inside = true
	if mode == Mode.ON_ENTER:
		trigger()
	elif prompt and not _done:
		prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group(player_group):
		return
	_player_inside = false
	if prompt:
		prompt.hide()
