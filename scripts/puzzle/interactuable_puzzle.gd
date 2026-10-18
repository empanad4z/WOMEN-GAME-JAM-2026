extends Area2D
##############################################################
# OPCIONAL!!!!!!!!!:

# solo sirve para tener un objeto que abre un puzzle al apretar un interactuable
# Y AUN NO TIENE SU PROPIO SCRIPT.
# Si ya se tiene objetos interactuables (SI TIENE SCRIPT), no hace falta: basta con llamar
#   Puzzle.abrir(self, "res://assets/mi_puzzle") VER puzzle.gd
############################################################

@export_dir var carpeta_puzzle := ""
@export var un_solo_uso := true

var resuelto := false


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("interactuar") and has_overlapping_bodies():
		abrir_puzzle()


func abrir_puzzle() -> void:
	if (resuelto and un_solo_uso) or carpeta_puzzle.is_empty():
		return
	var puzzle := Puzzle.abrir(self, carpeta_puzzle)
	if puzzle == null:
		return # ya hay un puzzle abierto
	puzzle.completado.connect(_on_puzzle_completado)


func _on_puzzle_completado() -> void:
	resuelto = true
	print("Puzzle resuelto, acá va lo que quieras que pase")
