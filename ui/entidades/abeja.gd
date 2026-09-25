extends Node2D

@export var mensaje: String = ""
@export var audio_palabra: AudioStream = null

var fuente = preload("res://assets/fuentes/Lexend-Regular.ttf")

func _ready():
	$Label.visible = false
	$Label.text = mensaje
	
	$Label.add_theme_font_override("font", fuente)
	$Label.add_theme_font_size_override("font_size", 5)
	$Label.position = Vector2(-50, -20)
	$Label.autowrap_mode = TextServer.AUTOWRAP_WORD
	$Label.custom_minimum_size = Vector2(80, -2)
	$Label.reset_size()
	
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0, 0, 0, 0.75)
	estilo.set_corner_radius_all(5)
	estilo.set_content_margin_all(3)
	$Label.add_theme_stylebox_override("normal", estilo)
	
	$Timer.wait_time = 5.0
	$Timer.one_shot = true
	$Timer.timeout.connect(_on_timer_timeout)
	
	$AreaDeteccion.body_entered.connect(_on_jugador_cerca)
	$AreaDeteccion.body_exited.connect(_on_jugador_lejos)
	
	# ✅ Verificación segura
	if has_node("AudioPlayer") and audio_palabra != null:
		$AudioPlayer.stream = audio_palabra

func _on_jugador_cerca(body):
	if body.is_in_group("Player"):
		if body.global_position.y > global_position.y:
			$Label.visible = true
			$Timer.start()
			_reproducir_audio()

func _on_jugador_lejos(body):
	if body.is_in_group("Player"):
		$Timer.start()

func _on_timer_timeout():
	$Label.visible = false

func _reproducir_audio():
	# ✅ Nunca crashea aunque falte el nodo o el audio
	if has_node("AudioPlayer") and $AudioPlayer.stream != null:
		$AudioPlayer.stop()
		$AudioPlayer.play()
