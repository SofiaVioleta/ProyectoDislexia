## Servicio de narración por voz (RF5).
## Usa las voces del sistema operativo, sin necesidad de grabar audios.
extends Node

const IDIOMA := "es"
const VOLUMEN := 80
const VELOCIDAD := 0.85  # un poco más lento, pensado para niños

var disponible: bool = false
var _voz: String = ""


func _ready() -> void:
	var voces := DisplayServer.tts_get_voices_for_language(IDIOMA)
	print("Narrador - voces en español: ", voces)
	if voces.is_empty():
		push_warning("Narrador: no hay voces en español instaladas. Se usará solo apoyo visual.")
		return
	_voz = voces[0]
	disponible = true


## Lee un texto en voz alta.
## interrumpir = true corta lo que se esté diciendo; false lo pone en fila.
func hablar(texto: String, interrumpir: bool = true) -> void:
	if not disponible:
		return
	DisplayServer.tts_speak(texto, _voz, VOLUMEN, 1.0, VELOCIDAD, 0, interrumpir)


func detener() -> void:
	if disponible:
		DisplayServer.tts_stop()
