extends "res://scripts/levels/level.gd"

# Límite derecho de la cámara cuando se abre la puerta
@export var opened_camera_limit_right: int = 8800
@export var camera: Camera2D
@export var closed_door: StaticBody2D
@export var open_door: Node2D
@export var aux_power_off: Node2D
@export var aux_power_on: Node2D

# Los .dialogue leen estas variables y llaman a estas funciones directamente,
# porque Dialogue Manager incluye la escena actual en su estado
var aux_power_connected: bool = false
var doors_open: bool = false  


func connect_aux_power() -> void:
	aux_power_connected = true
	aux_power_off.hide()
	aux_power_on.show()


func open_doors() -> void:
	doors_open = true
	closed_door.hide()
	# Deshabilitado, el StaticBody2D sale de la física y deja de bloquear
	closed_door.process_mode = Node.PROCESS_MODE_DISABLED
	open_door.show()
	camera.limit_right = opened_camera_limit_right
