extends Node2D

# Carpeta de donde se cargan las piezas. Podés cambiarle el nombre desde el Inspector
@export_dir var carpeta_piezas := "res://assets/puzzle_recuerdo_prueba"

# Nos sirve para guardar la pieza que está seleccionando el jugador, al principio es null porque no tiene ninguna xd
var pieza_arrastrada: Sprite2D = null

# Un contador (o descontador jaja) de piezas que faltan para terminar el puzzle
var piezas_restantes := 0

# Distancia máxima (en píxeles) a la que la pieza "se pega" a su lugar
@export var distancia_iman := 30.0


# Ahora se ejecuta al iniciar la escena, cambia por otra función si necesitas que se haga en otro momento
func _ready() -> void:
	var tamano_pantalla := get_viewport_rect().size

	# Buscamos los archivos en la carpeta. 
	for nombre_archivo in ResourceLoader.list_directory(carpeta_piezas):
		var pieza := crear_pieza(load(carpeta_piezas.path_join(nombre_archivo)))

		# Esto después cambialo, ahora las ubicamos de manera al azar en la pantalla (lugar desde donde se agarran las piezas)
		pieza.position = Vector2(randf() * tamano_pantalla.x * 0.8, randf() * tamano_pantalla.y * 0.8)
		piezas_restantes += 1


# La función mágica que convierte la imagen png en una pieza jugable :D
func crear_pieza(textura_completa: Texture2D) -> Sprite2D:
	var imagen := textura_completa.get_image()

	# Esta es la posta, hacemos un rectangulo justo en la posición donde va cada pieza
	var rectangulo := imagen.get_used_rect()

	# Le sacamos la transparencia
	var pieza_recortada := imagen.get_region(rectangulo)

	# Creamos el sprite :3
	var pieza := Sprite2D.new()
	pieza.texture = ImageTexture.create_from_image(pieza_recortada)

	# No la centramos porque sino nos mueve la posicion.
	pieza.centered = false

	# Le guardamos datos para usar después:
	pieza.set_meta("posicion", Vector2(rectangulo.position))  # su lugar correcto
	pieza.set_meta("imagen", pieza_recortada)                 # para detectar la transparencia
	pieza.set_meta("colocada", false)                         # si ya está colocada o no

	add_child(pieza) # la vemos como hija de este objeto que tiene el script
	return pieza


# Función para detectar eventos del mouse (como clicks)
func _input(evento: InputEvent) -> void:
	# Detectamos el click izquierdo
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT: 
		if evento.pressed: #si ta presionado el click
			agarrar_pieza() # significa que queremos agarrar la pieza
		else: # si lo soltamos
			soltar_pieza() # queremos soltar la pieza
	elif evento is InputEventMouseMotion and pieza_arrastrada != null: 
		# aca significa que estamos arrastrando con el click presionado
		pieza_arrastrada.position = get_local_mouse_position() # arrastramos la pieza a la posicion del mouse 


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

			# Y truquito para verla por encima del resto de las piezas.
			move_child(pieza, -1)
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


# Acá tenemos que ver si donde soltamos la imagen, es la posición correcta (o cercana) para "colocarla"
func soltar_pieza() -> void:
	if pieza_arrastrada == null: # nos aseguramos que tengamos una pieza agarrada jeje
		return

	var posicion_correcta: Vector2 = pieza_arrastrada.get_meta("posicion") # ¿te acordas que guardamos la posicion correcta? bueno, la obtenemos

	# y acá chequeamos si estamos cerca de esa posición (+-30 pixeles)
	if pieza_arrastrada.position.distance_to(posicion_correcta) < distancia_iman:
		pieza_arrastrada.position = posicion_correcta # si estamos, le asignamos la misma posicion para dar ese efecto de "iman"
		pieza_arrastrada.set_meta("colocada", true) # le cambiamos su estado de "colocada"

		# truquito para que quede "por debajo" de las otras piezas que vamos a agarrar
		move_child(pieza_arrastrada, 0)

		# usamos nuestro "descontador" para chequear si terminamos de colocar o no.
		piezas_restantes -= 1
		if piezas_restantes == 0:
			al_completar_puzzle() # y acá sería el "ganar"... despues reemplazar por lo que realmente queres que haga

	pieza_arrastrada = null # NO OLVIDAR!!!!! cuando colocamos la pieza, ya no tenemos una pieza agarrada. Así que volvemos null nuestra variable de ayuda
.

# Por ahora solo voy a debuggear para que pruebes, luego lo reemplazas
func al_completar_puzzle() -> void:
	print("Listirijillo, puzzle completadísimo")
