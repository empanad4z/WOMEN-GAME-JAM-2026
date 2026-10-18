extends Node2D

@export var level_id: StringName = &"nivel_1"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.enter_level(level_id)
	var health_enemy: HealthComponent = $Enemy/HealthComponent
	health_enemy.health_changed.connect(func(current: int, max_health: int): print("vida enemigo 1: ", current, "/", max_health))
	health_enemy.died.connect(func(): print("murió el enemigo 1"))
	
	var health_player: HealthComponent = $Player/HealthComponent
	health_player.health_changed.connect(func(current: int, max_health: int): print("vida player: ", current, "/", max_health))
	health_player.died.connect(func(): print("murió el player"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
