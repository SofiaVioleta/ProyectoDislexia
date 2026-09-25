## Capa de presentación: muestra el minijuego y envía las acciones a la lógica.
## No decide qué es correcto; eso lo hace LogicaSilabas.
extends Control

const TOTAL_A_COMPLETAR := 5
const RUTA_SONIDOS := "res://assets/audio/sonidos/"

@onready var label_pregunta = $PanelContainer/VBoxContainer/LabelPregunta
@onready var contenedor = $PanelContainer/VBoxContainer/ContenedorSilabas

var fuente = preload("res://assets/fuentes/Lexend-Regular.ttf")
var logica: LogicaSilabas


func _ready():
	logica = LogicaSilabas.new(BancoSilabas.PALABRAS, TOTAL_A_COMPLETAR)
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
	contenedor.add_theme_constant_override("separation", 6)

	# RF5: botón para volver a escuchar la instrucción
	var boton_repetir := Button.new()
	boton_repetir.text = "🔊"
	boton_repetir.tooltip_text = "Repetir instrucción"
	boton_repetir.pressed.connect(_leer_instruccion)
	$PanelContainer/VBoxContainer.add_child(boton_repetir)
	$PanelContainer/VBoxContainer.move_child(boton_repetir, 1)


func abrir():
	if logica.iniciar():
		_mostrar_palabra()
		visible = true


func _mostrar_palabra():
	label_pregunta.text = "Forma la palabra: " + logica.palabra_objetivo()
	_crear_botones()
	_leer_instruccion()


func _leer_instruccion():
	Narrador.hablar("Forma la palabra " + logica.palabra_objetivo())


func _crear_botones():
	for hijo in contenedor.get_children():
		hijo.queue_free()

	for silaba in logica.opciones():
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
	match logica.elegir_silaba(silaba):
		LogicaSilabas.Resultado.PALABRA_COMPLETA:
			label_pregunta.text = "¡Muy bien!"
			Narrador.hablar("¡Muy bien! " + logica.palabra_objetivo(), false)
			await get_tree().create_timer(1.5).timeout
			if logica.siguiente_palabra():
				_mostrar_palabra()
			else:
				_finalizar_minijuego()
		LogicaSilabas.Resultado.ERROR:
			label_pregunta.text = "¡Casi! Inténtalo de nuevo"
			Narrador.hablar("Casi. Inténtalo de nuevo", false)
			await get_tree().create_timer(1.2).timeout
			label_pregunta.text = "Forma la palabra: " + logica.palabra_objetivo()


func _finalizar_minijuego():
	label_pregunta.text = "¡LO LOGRASTE!"
	Narrador.hablar("¡Lo lograste!")
	await get_tree().create_timer(2.0).timeout
	visible = false


# Usa la grabación de la sílaba si existe; si no, la voz automática
func _reproducir_sonido(silaba):
	var ruta = RUTA_SONIDOS + silaba.to_lower() + ".ogg"
	if not ResourceLoader.exists(ruta):
		Narrador.hablar(silaba)
		return
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = load(ruta)
	audio.play()
	await audio.finished
	audio.queue_free()
