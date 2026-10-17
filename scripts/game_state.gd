extends Node

const levels: Array[String] = []
var level_index = 0
var current_level = &""
var collected_memories: Dictionary = {}
var level_memories: Array[StringName] = []

#Funcion para simular entrar a nivel
func enter_level(level_id: StringName):
	current_level = level_id
	level_memories.clear()
	
func collect_memory(id: StringName):
	if id not in level_memories:
		level_memories.append(id)
		
func complete_level():
	collected_memories[current_level] = level_memories.duplicate()
	
func go_to_next_level():
	complete_level()
	level_index += 1
	if level_index < levels.size():
		#Cambio de nivel
		pass
	else:
		#Final de juego
		pass
		
func new_game():
	collected_memories.clear()
	level_memories.clear()
	level_index = 0
	#Pasar a primer nivel
#Funcion para contar recuerdos recolectados
func total_memories():
	var total = 0
	for memories in collected_memories.values():
		total += memories.size()
	return total
