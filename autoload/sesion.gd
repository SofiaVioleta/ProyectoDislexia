extends Node
## Autoload "Sesion": recibe el login de la página web y carga el personaje desde la API.

signal sesion_lista(datos: Dictionary)
signal partida_guardada
signal error_sesion(mensaje: String)

const TOKEN_KEY := "dislexia_access_token"

var token: String = ""
var character_id: int = 0
var base_url: String = ""
var personaje: Dictionary = {}
var partida = null  # Dictionary con la partida guardada, o null si no tiene


func _ready() -> void:
	if not OS.has_feature("web"):
		push_warning("Sesion: el juego no corre en el navegador, se omite el login.")
		return

	base_url = str(JavaScriptBridge.eval("window.location.origin", true))
	token = str(JavaScriptBridge.eval(
		"sessionStorage.getItem('%s') || ''" % TOKEN_KEY, true))
	var id_texto := str(JavaScriptBridge.eval(
		"new URLSearchParams(window.location.search).get('character') || ''", true))
	character_id = id_texto.to_int()

	if token.is_empty() or character_id <= 0:
		volver_al_login()
		return

	cargar_personaje()


func _encabezados() -> PackedStringArray:
	return PackedStringArray([
		"Authorization: Bearer " + token,
		"Content-Type: application/json",
	])


func cargar_personaje() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_al_cargar.bind(http))
	var url := "%s/api/game/characters/%d/bootstrap" % [base_url, character_id]
	if http.request(url, _encabezados(), HTTPClient.METHOD_GET) != OK:
		http.queue_free()
		error_sesion.emit("No se pudo contactar el servidor.")


func _al_cargar(_resultado: int, codigo: int, _h: PackedStringArray,
		cuerpo: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if codigo == 401 or codigo == 422:
		volver_al_login()  # sesión vencida o inválida
		return
	if codigo != 200:
		error_sesion.emit("Error del servidor (%d)." % codigo)
		return

	var json = JSON.parse_string(cuerpo.get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		error_sesion.emit("Respuesta no válida del servidor.")
		return

	var datos: Dictionary = json.get("data", {})
	personaje = datos.get("character", {})
	partida = datos.get("save")
	sesion_lista.emit(datos)


func guardar_partida(world_id: String, checkpoint_id: String,
		progreso: Dictionary = {}, completado: bool = false) -> void:
	if token.is_empty():
		return
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_al_guardar.bind(http))
	var cuerpo := JSON.stringify({
		"world_id": world_id,
		"checkpoint_id": checkpoint_id,
		"status": "completed" if completado else "in_progress",
		"progress_data": progreso,
	})
	var url := "%s/api/characters/%d/save" % [base_url, character_id]
	http.request(url, _encabezados(), HTTPClient.METHOD_PUT, cuerpo)


func _al_guardar(_resultado: int, codigo: int, _h: PackedStringArray,
		_cuerpo: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	if codigo == 200:
		partida_guardada.emit()
	else:
		error_sesion.emit("No se pudo guardar la partida (%d)." % codigo)


func volver_al_login() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.location.href = '/login'")
