extends Control

# Nodos
@onready var label_pregunta = $PanelContainer/VBoxContainer/LabelPregunta
@onready var contenedor = $PanelContainer/VBoxContainer/ContenedorSilabas

# Configuración del Juego
var palabras = [
	# Confusión de l vs t / s vs z
	{"correcta": ["so", "l"], "opciones": ["so", "l", "zo", "t"]},
	
	# El gran reto: m vs n / p vs b vs d (letras espejo)
	{"correcta": ["ma", "pa"], "opciones": ["ma", "na", "pa", "ba"]},
	
	# Confusión de u vs n / l vs i
	{"correcta": ["lu", "na"], "opciones": ["lu", "nu", "na", "la"]},
	
	# Inversión de sílabas y confusión t vs d
	{"correcta": ["pe", "lo", "ta"], "opciones": ["pe", "be", "lo", "ta", "da"]},
	
	# Confusión p vs b / n vs m / d vs b
	{"correcta": ["pi", "no"], "opciones": ["pi", "bi", "no", "mo", "di"]},
	
	# Reto de inversión: te vs et / so vs os / ro vs or
	{"correcta": ["te", "so", "ro"], "opciones": ["te", "et", "so", "os", "ro"]}
]

var palabra_actual = {}
var seleccionadas = []
var palabras_completadas = 0
const TOTAL_A_COMPLETAR = 5
var palabras_usadas = []

# Recursos
var fuente = preload("res://assets/fonts/Lexend-Regular.ttf")

func _ready():
	randomize()
	visible = false
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	label_pregunta.add_theme_font_override("font", fuente)
	label_pregunta.add_theme_font_size_override("font_size", 8)
	label_pregunta.add_theme_color_override("font_color", Color("#E8E6D9"))
	label_pregunta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var estilo_panel = $PanelContainer.get_theme_stylebox("panel")
	if estilo_panel is StyleBoxFlat:
		estilo_panel.content_margin_left = 10
		estilo_panel.content_margin_right = 10
		estilo_panel.content_margin_top = 10
		estilo_panel.content_margin_bottom = 10
	
	# También ajustamos el espacio ENTRE los botones (Cuadrados)
	contenedor.add_theme_constant_override("separation", 6 )

func abrir():
	palabras_completadas = 0
	palabras_usadas = []
	_seleccionar_nueva_palabra()
	visible = true

func _seleccionar_nueva_palabra():
	seleccionadas = []
	
	var posibles = []
	for p in palabras:
		if not p in palabras_usadas:
			posibles.append(p)
	
	if posibles.size() > 0 and palabras_completadas < TOTAL_A_COMPLETAR:
		palabra_actual = posibles[randi() % posibles.size()]
		palabras_usadas.append(palabra_actual)
		
		# Texto simplificado: Solo la palabra objetivo
		label_pregunta.text = "Forma la palabra: " + "".join(palabra_actual["correcta"])
		_crear_botones()
	else:
		_finalizar_minijuego()

func _crear_botones():
	
	for hijo in contenedor.get_children():
		hijo.queue_free()
	
	for silaba in palabra_actual["opciones"]:
		var boton = Button.new()
		boton.text = silaba
		boton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
		boton.add_theme_font_override("font", fuente)
		boton.add_theme_font_size_override("font_size", 8)
		boton.custom_minimum_size = Vector2(16, 16)
		
		var estilo_normal = StyleBoxFlat.new()
		estilo_normal.bg_color = Color("#316FD4") 
		estilo_normal.set_corner_radius_all(2)
		
		var estilo_hover = StyleBoxFlat.new()
		estilo_hover.bg_color = Color("#70C91E") 
		estilo_hover.set_corner_radius_all(2)
		
		boton.add_theme_stylebox_override("normal", estilo_normal)
		boton.add_theme_stylebox_override("hover", estilo_hover)
		boton.add_theme_color_override("font_color", Color("#E8E6D9"))
		boton.add_theme_color_override("font_hover_color", Color("#2E2A41"))
		
		boton.pressed.connect(_on_silaba_presionada.bind(silaba))
		contenedor.add_child(boton)

func _on_silaba_presionada(silaba):
	_reproducir_sonido(silaba)
	seleccionadas.append(silaba)
	
	var parte_correcta = palabra_actual["correcta"].slice(0, seleccionadas.size())
	
	if seleccionadas == parte_correcta:
		if seleccionadas.size() == palabra_actual["correcta"].size():
			palabras_completadas += 1
			label_pregunta.text = "¡Muy bien!" 
			await get_tree().create_timer(1.0).timeout
			_seleccionar_nueva_palabra()
	else:
		label_pregunta.text = "¡Casi! Inténtalo de nuevo"
		await get_tree().create_timer(0.8).timeout
		seleccionadas = []
		label_pregunta.text = "Forma la palabra: " + "".join(palabra_actual["correcta"])

func _finalizar_minijuego():
	label_pregunta.text = "¡LO LOGRASTE!"
	await get_tree().create_timer(2.0).timeout
	visible = false

func _reproducir_sonido(silaba):
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	var ruta = "res://assets/sonidos/" + silaba.to_lower() + ".ogg"
	if ResourceLoader.exists(ruta):
		audio.stream = load(ruta)
		audio.play()
		await audio.finished
	audio.queue_free()
