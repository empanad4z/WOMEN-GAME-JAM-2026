class_name MemoryItem extends Area2D

signal collected(memory_id)

@export var memory_id = &"recuerdo1"
@export var float_height := 3.0
@export var float_time := 0.8

var _collected = false

@onready var visual = $Visual

func _ready() -> void:
	body_entered.connect(_on_body_entered) 
	_start_effects()

func _start_effects():
	var base_y = visual.position.y
	
	# Flotar arriba y abajo
	var float_tween := create_tween().set_loops()
	float_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(visual, "position:y", base_y - float_height, float_time)
	float_tween.tween_property(visual, "position:y", base_y, float_time)

	# Brillo suave
	var glow_tween := create_tween().set_loops()
	glow_tween.tween_property(visual, "modulate", Color(1.4, 1.4, 1.4), 0.6)
	glow_tween.tween_property(visual, "modulate", Color.WHITE, 0.6)
	
func _on_body_entered(body: Node2D):
	if _collected or not body.is_in_group("Player"):
		return
	_collected = true
	set_deferred("monitoring", false)
	GameState.collect_memory(memory_id)
	print("Abrir puzle recuerdo")
	collected.emit(memory_id)
	queue_free()
