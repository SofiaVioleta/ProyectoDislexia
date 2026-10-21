extends Node2D

func _ready() -> void:
	Sesion.sesion_lista.connect(_on_sesion_lista)
	Sesion.error_sesion.connect(_on_error_sesion)


func _on_sesion_lista(_datos: Dictionary) -> void:
	print("Jugando con: ", Sesion.personaje.get("name", ""))
	if Sesion.partida != null:
		print("Tiene partida guardada: ", Sesion.partida)


func _on_error_sesion(mensaje: String) -> void:
	push_error(mensaje)
