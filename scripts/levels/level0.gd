extends "res://scripts/levels/level.gd"

# Límite derecho de la cámara cuando se abre la puerta
@export var opened_camera_limit_right: int = 8800
@export var camera: Camera2D
@export var closed_door: StaticBody2D
@export var open_door: Node2D
@export var aux_power_off: Node2D
@export var aux_power_on: Node2D
@export var memory_fragment: MemoryItem
# Salida al nivel 1, bloqueada hasta recoger el fragmento
@export var level_exit: Area2D
# Capa con el flash blanco y la imagen del recuerdo, oculta hasta usarla
@export var memory_flash: CanvasLayer
@export var flash_rect: ColorRect
@export var memory_image: TextureRect

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


func collect_fragment() -> void:
	memory_fragment.collect()
	level_exit.locked = false


# El .dialogue espera a que termine (los "do" con await bloquean la línea siguiente)
func show_memory_flash() -> void:
	var base_position := memory_image.position
	flash_rect.modulate.a = 1.0
	memory_image.modulate = Color(1, 1, 1, 0)
	memory_flash.show()

	var tween := create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(memory_image, "modulate:a", 0.85, 0.3)
	# Temblor con cambio de tono para que se vea distorsionada
	for i in 10:
		var offset := Vector2(randf_range(-14, 14), randf_range(-6, 6))
		var tint := Color(0.7, 1.0, 1.2, 0.85) if i % 2 == 0 else Color(1.2, 0.8, 1.0, 0.6)
		tween.tween_property(memory_image, "position", base_position + offset, 0.07)
		tween.parallel().tween_property(memory_image, "modulate", tint, 0.07)
	tween.tween_property(memory_image, "position", base_position, 0.07)
	tween.tween_property(memory_image, "modulate:a", 0.0, 0.5)
	await tween.finished

	memory_flash.hide()
