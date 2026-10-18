extends Node2D

# Para los  objetivo Recuerdo usar algo de este estilo:
##########################################################
#var puzzle := preload("res://puzzle_recuerdo_nodos.tscn").instantiate()
#get_tree().current_scene.add_child(puzzle)
#puzzle.get_node("Centro/Tablero/Puzzle").completado.connect(_on_puzzle_completado)
#############################################################################


# Se avisa cuando se arma el puzzle y cuando se cierra
signal completado
signal cerrado

# Carpeta de donde se cargan las piezas. Podés cambiarle el nombre desde el Inspector
@export_dir var carpeta_piezas := "res://assets/puzzle_recuerdo_prueba"

# Solo se cargan los archivos que empiezan con este texto
# (así no se cuela "ilustracion.png" como si fuera una pieza más)
@export var prefijo_piezas := "pieza"

# Distancia máxima (en píxeles) a la que la pieza "se pega" a su lugar en el tablero
@export var distancia_iman := 30.0

# Distancia máxima (en píxeles) a la que una pieza "se une" con su vecina
@export var distancia_union := 25.0

# Cuánto del ancho de la pantalla ocupa el tablero (0.4 = 40%). El resto es lugar para las piezas sueltas
@export_range(0.2, 0.7) var ancho_tablero := 0.4

# Para no agrandar de más el puzzle si la ilustración es chica (1.0 = nunca más grande que el tamaño real)
@export var escala_maxima := 1.0

# Congela el resto del juego mientras el puzzle está abierto
@export var pausar_juego := true

# Muestra una silueta oscura en el lugar de cada pieza que falta
@export var mostrar_siluetas := true

# Separación (en píxeles) entre el tablero y las piezas sueltas
const SEPARACION := 20.0

# Nos sirve para guardar la pieza que está seleccionando el jugador, al principio es null porque no tiene ninguna xd
var pieza_arrastrada: Sprite2D = null

# Las piezas que se mueven junto con la que agarramos (si no está unida a nadie, es solo ella)
var grupo_arrastrado: Array = []

# Para cada pieza que arrastramos: la diferencia entre su posición y la del mouse al agarrarla
var desplazamientos := {}

# Todas las piezas del puzzle
var piezas: Array[Sprite2D] = []

# Un contador (o descontador jaja) de piezas que faltan para terminar el puzzle
var piezas_restantes := 0

# Tamaño de la ilustración completa (las piezas miden lo mismo que ella)
var tamano_ilustracion := Vector2.ZERO

# Acá van las siluetas oscuras
var contenedor_siluetas: Node2D

# Para devolver la pausa como estaba al cerrar
var estaba_pausado := false

# Lo que se ve en pantalla, en coordenadas de este nodo (acá se reparten las piezas)
var vista_local := Rect2()


# Ahora se ejecuta al iniciar la escena, cambia por otra función si necesitas que se haga en otro momento
func _ready() -> void:
	# Las siluetas van en su propio nodo, siempre por debajo de las piezas
	contenedor_siluetas = Node2D.new()
	contenedor_siluetas.z_index = -1
	add_child(contenedor_siluetas)

	# Buscamos los archivos en la carpeta.
	for nombre_archivo in ResourceLoader.list_directory(carpeta_piezas):
		if not nombre_archivo.begins_with(prefijo_piezas):
			continue
		crear_pieza(load(carpeta_piezas.path_join(nombre_archivo)))
		piezas_restantes += 1

	if piezas.is_empty():
		push_error("Puzzle: no encontré piezas en " + carpeta_piezas)
		return

	preparar_vista()


# El centrado lo hacen los nodos: este nodo vive dentro de un "Tablero" (Control) que está dentro de
# un CenterContainer. Acá solo le decimos al Tablero cuánto mide y el contenedor lo centra solo.
func preparar_vista() -> void:
	visible = false # hasta que esté todo acomodado

	# Pausamos el juego (el puzzle sigue funcionando porque su modo es "siempre")
	if pausar_juego:
		estaba_pausado = get_tree().paused
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = true

	var tablero := get_parent() as Control
	var tamano_pantalla := get_viewport_rect().size

	# Escala para que el tablero ocupe "ancho_tablero" del ancho (y como mucho el 70% del alto)
	var escala := minf(tamano_pantalla.x * ancho_tablero / tamano_ilustracion.x, tamano_pantalla.y * 0.7 / tamano_ilustracion.y)
	escala = minf(escala, escala_maxima)
	scale = Vector2(escala, escala)

	# El Tablero mide lo mismo que la ilustración (ya escalada): el CenterContainer lo centra solo
	tablero.custom_minimum_size = (tamano_ilustracion * escala).round()

	# Esperamos a que el contenedor lo acomode
	await get_tree().process_frame
	await get_tree().process_frame

	# Lo que se ve en pantalla, en coordenadas de este nodo
	vista_local = get_global_transform_with_canvas().affine_inverse() * get_viewport_rect()

	# Piezas sueltas: una a la izquierda, otra a la derecha, siempre dentro de lo que se ve
	for i in range(piezas.size()):
		var pieza := piezas[i]
		pieza.position = posicion_inicial(pieza, i % 2 == 0)

	visible = true


# Las amontonamos todas ordenadas en un sector a la derecha del tablero
func posicion_inicial(pieza: Sprite2D, indice: int) -> Vector2:
	var tamano_pieza := pieza.texture.get_size()
	
	# Definimos el recuadro a la derecha del tablero donde se acumularán las piezas
	var x_min := tamano_ilustracion.x + SEPARACION
	var x_max := x_min + 250.0  # Ancho de la zona de piezas
	var y_min := 0.0
	var y_max := maxf(0.0, tamano_ilustracion.y - tamano_pieza.y)

	# Las distribuimos un poco al azar dentro de ese recuadro lateral para que no queden invisibles
	var pos_x := randf_range(x_min, x_max)
	var pos_y := randf_range(y_min, y_max)

	return Vector2(pos_x, pos_y).round()

# La función mágica que convierte la imagen png en una pieza jugable :D
func crear_pieza(textura_completa: Texture2D) -> Sprite2D:
	var imagen := textura_completa.get_image()
	tamano_ilustracion = textura_completa.get_size()

	# Esta es la posta, hacemos un rectangulo justo en la posición donde va cada pieza
	var rectangulo := imagen.get_used_rect()

	# Le sacamos la transparencia
	var pieza_recortada := imagen.get_region(rectangulo)

	# Creamos el sprite :3
	var pieza := Sprite2D.new()
	pieza.texture = ImageTexture.create_from_image(pieza_recortada)

	# No la centramos porque sino nos mueve la posicion.
	pieza.centered = false

	# Silueta oscura en el lugar donde va la pieza (es la misma imagen, pintada de negro)
	var silueta: Sprite2D = null
	if mostrar_siluetas:
		silueta = Sprite2D.new()
		silueta.texture = textura_completa
		silueta.centered = false
		silueta.modulate = Color(0, 0, 0, 0.5)
		contenedor_siluetas.add_child(silueta)

	# Le guardamos datos para usar después:
	pieza.set_meta("posicion", Vector2(rectangulo.position))  # su lugar correcto
	pieza.set_meta("imagen", pieza_recortada)                 # para detectar la transparencia
	pieza.set_meta("colocada", false)                         # si ya está colocada o no
	pieza.set_meta("silueta", silueta)                        # su silueta (se esconde al colocarla)
	pieza.set_meta("grupo", [pieza])                          # con quién está unida (al principio, con nadie)

	piezas.append(pieza)
	add_child(pieza) # la vemos como hija de este objeto que tiene el script
	return pieza


# Función para detectar eventos del mouse (como clicks)
func _input(evento: InputEvent) -> void:
	# Con Esc se puede salir del puzzle en cualquier momento
	if evento.is_action_pressed("ui_cancel"):
		cerrar_puzzle()
		return

	# Detectamos el click izquierdo
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed: #si ta presionado el click
			agarrar_pieza() # significa que queremos agarrar la pieza
		else: # si lo soltamos
			soltar_pieza() # queremos soltar la pieza
	elif evento is InputEventMouseMotion and pieza_arrastrada != null:
		# aca significa que estamos arrastrando con el click presionado
		var posicion_mouse := get_local_mouse_position()
		# movemos la pieza y también todas las que están unidas a ella
		for miembro: Sprite2D in grupo_arrastrado:
			miembro.position = posicion_mouse + desplazamientos[miembro]


# Cuando agarramos una pieza TENEMOS que detectar QUÉ pieza está debajo del mouse
func agarrar_pieza() -> void:
	var posicion_mouse := get_local_mouse_position() # así que tomamos la posición del mouse

	# Acá un truquito: las últimas dibujadas, son las últimas en generarse como "hijas" del objeto
	# entonces esas van a quedar "arriba" de las demas, así que recorremos de atras para adelante.
	for i in range(get_child_count() - 1, -1, -1):
		# por las dudas buscamos solo hijos que sean nodo Sprite2D
		var pieza := get_child(i) as Sprite2D

		#todas las comprobaciones posibles jaja (como chequear que no estemos agarrando una ya colocada)
		if pieza != null and not pieza.get_meta("colocada") and mouse_sobre_pieza(pieza, posicion_mouse):
			pieza_arrastrada = pieza # asignamos esa pieza a nuestra variable de ayuda

			# Agarramos a la pieza y a todas las que están unidas a ella
			grupo_arrastrado = pieza.get_meta("grupo")
			desplazamientos.clear()
			for miembro: Sprite2D in grupo_arrastrado:
				desplazamientos[miembro] = miembro.position - posicion_mouse

				# Y truquito para verlas por encima del resto de las piezas.
				move_child(miembro, -1)
			return


# Esta es una función que nos va a ayudar a estar agarrando "la pieza" y no toda la imagen (con la transparencia)
func mouse_sobre_pieza(pieza: Sprite2D, posicion_mouse: Vector2) -> bool:
	var imagen: Image = pieza.get_meta("imagen") # primero accedemos a la imagen que guardamos en "meta data" (el recorte)

	# Con esto nos fijamos qué pixel de ese recorte está siendo tocado por el mouse
	var pixel := Vector2i(posicion_mouse - pieza.position)

	# Si el mouse no está en un pixel opaco (fuera del recorte), entonces "no la estamos tocando" (aunque sí sea así jaja, pero estamos tocando transparencia)
	if pixel.x < 0 or pixel.y < 0 or pixel.x >= imagen.get_width() or pixel.y >= imagen.get_height():
		return false

	# "a" es el "alpha" ...la opacidad del píxel: 0 es transparente, 1 es opaco.
	return imagen.get_pixelv(pixel).a > 0.1 #hay que asegurarse de que no sea un pixel transparente


# Al soltar hay tres posibilidades:
#   1) quedó cerca de su lugar en el tablero  -> se pega ahí y queda fija
#   2) quedó bien puesta al lado de una vecina -> se UNEN y desde ahora se mueven juntas
#   3) ninguna de las dos                     -> se queda donde la soltamos
func soltar_pieza() -> void:
	if pieza_arrastrada == null: # nos aseguramos que tengamos una pieza agarrada jeje
		return

	# Redondeamos las posiciones: así las piezas unidas encajan justo, sin líneas entre ellas
	for miembro: Sprite2D in grupo_arrastrado:
		miembro.position = miembro.position.round()

	var grupo: Array = grupo_arrastrado

	# 1) ¿está cerca de su lugar en el tablero?
	if not intentar_colocar(grupo):
		# 2) ¿encaja con alguna vecina? (repetimos por si encaja con varias a la vez)
		var se_unio := false
		while intentar_unir(grupo):
			se_unio = true
			grupo = pieza_arrastrada.get_meta("grupo") # el grupo ahora es más grande

		if se_unio and not intentar_colocar(grupo):
			# Si ya están TODAS unidas, el puzzle está armado: lo acomodamos en su lugar y listo
			if grupo.size() == piezas.size():
				colocar_grupo(grupo, grupo[0])

	pieza_arrastrada = null # NO OLVIDAR!!!!! cuando colocamos la pieza, ya no tenemos una pieza agarrada. Así que volvemos null nuestra variable de ayuda
	grupo_arrastrado = []
	desplazamientos.clear()


# Si alguna pieza del grupo está cerca de su lugar correcto, todo el grupo se pega ahí
func intentar_colocar(grupo: Array) -> bool:
	for pieza: Sprite2D in grupo:
		var posicion_correcta: Vector2 = pieza.get_meta("posicion") # ¿te acordas que guardamos la posicion correcta? bueno, la obtenemos

		# y acá chequeamos si estamos cerca de esa posición
		if pieza.position.distance_to(posicion_correcta) < distancia_iman:
			colocar_grupo(grupo, pieza)
			return true
	return false


# Acomoda todo el grupo en su lugar (usando "referencia" para saber cuánto moverlo) y lo deja fijo
func colocar_grupo(grupo: Array, referencia: Sprite2D) -> void:
	var diferencia: Vector2 = referencia.get_meta("posicion") - referencia.position

	for pieza: Sprite2D in grupo:
		pieza.position += diferencia # si estamos, le asignamos la misma posicion para dar ese efecto de "iman"
		pieza.set_meta("colocada", true) # le cambiamos su estado de "colocada"

		var silueta = pieza.get_meta("silueta") # ya no hace falta la sombra
		if silueta != null:
			silueta.hide()

		# truquito para que quede "por debajo" de las otras piezas que vamos a agarrar
		move_child(pieza, 0)

	# usamos nuestro "descontador" para chequear si terminamos de colocar o no.
	piezas_restantes -= grupo.size()
	if piezas_restantes == 0:
		al_completar_puzzle() # y acá sería el "ganar"... despues reemplazar por lo que realmente queres que haga


# Busca una pieza vecina (de otro grupo) que esté bien ubicada respecto a alguna del grupo.
# Si la encuentra, mueve el grupo para que encaje justo y los une. Devuelve true si unió algo.
func intentar_unir(grupo: Array) -> bool:
	for pieza: Sprite2D in grupo:
		var casa_pieza: Vector2 = pieza.get_meta("posicion")
		var zona_pieza := Rect2(casa_pieza, pieza.texture.get_size()).grow(distancia_union)

		for otra in piezas:
			# nos salteamos las del propio grupo y las que ya están fijas en el tablero
			if grupo.has(otra) or otra.get_meta("colocada"):
				continue

			# ¿son vecinas en la imagen completa?
			var casa_otra: Vector2 = otra.get_meta("posicion")
			if not zona_pieza.intersects(Rect2(casa_otra, otra.texture.get_size())):
				continue

			# ¿está "pieza" donde tendría que estar respecto a "otra"?
			var esperada: Vector2 = otra.position + (casa_pieza - casa_otra)
			if pieza.position.distance_to(esperada) < distancia_union:
				# movemos todo el grupo para que encaje justo y las unimos
				var diferencia := esperada - pieza.position
				for miembro: Sprite2D in grupo:
					miembro.position += diferencia
				unir_grupos(grupo, otra.get_meta("grupo"))
				return true
	return false


# Junta dos grupos en uno solo: desde ahora, agarrar cualquiera de sus piezas mueve a todas
func unir_grupos(grupo_a: Array, grupo_b: Array) -> void:
	var nuevo_grupo: Array = grupo_a + grupo_b
	for pieza: Sprite2D in nuevo_grupo:
		pieza.set_meta("grupo", nuevo_grupo)


# Por ahora solo voy a debuggear para que pruebes, luego lo reemplazas
func al_completar_puzzle() -> void:
	print("Listirijillo, puzzle completadísimo")
	completado.emit()
	# Acá mostrá la ilustración con la frase y, cuando el jugador la cierre, llamá a cerrar_puzzle()


# Devuelve la pausa como estaba y elimina todo el puzzle (la escena completa)
func cerrar_puzzle() -> void:
	if pausar_juego:
		get_tree().paused = estaba_pausado
	cerrado.emit()
	if owner != null:
		owner.queue_free()
	else:
		queue_free()
