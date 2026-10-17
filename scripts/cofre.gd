# cofre.gd
extends DialogueTrigger

@onready var sprite: Sprite2D = $"../Sprite2D"


# Esta función se llama desde el .dialogue con "do abrir()"
func abrir() -> void:
	Dialogues.flags["cofre_abierto"] = true
	sprite.modulate = Color(0.6, 1.0, 0.6)  # placeholder: aquí cambias al sprite "abierto"
	print("¡Cofre abierto!")
