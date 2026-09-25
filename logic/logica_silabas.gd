## Capa lógica: reglas del minijuego de sílabas (RF9, RF12).
## No sabe nada de botones ni pantallas, solo decide qué es correcto.
class_name LogicaSilabas
extends RefCounted

enum Resultado { PARCIAL, PALABRA_COMPLETA, ERROR }

var total_a_completar: int
var completadas: int = 0
var palabra_actual: Dictionary = {}

var _banco: Array
var _usadas: Array = []
var _seleccionadas: Array = []


func _init(banco: Array, total: int = 5) -> void:
	_banco = banco
	total_a_completar = total


## Reinicia el minijuego. Devuelve false si no hay palabras.
func iniciar() -> bool:
	_usadas.clear()
	completadas = 0
	return siguiente_palabra()


## Elige una palabra no usada. Devuelve false si el minijuego terminó.
func siguiente_palabra() -> bool:
	_seleccionadas.clear()
	if completadas >= total_a_completar:
		return false
	var posibles := _banco.filter(func(p): return not p in _usadas)
	if posibles.is_empty():
		return false
	palabra_actual = posibles.pick_random()
	_usadas.append(palabra_actual)
	return true


func palabra_objetivo() -> String:
	return "".join(palabra_actual["correcta"])


func opciones() -> Array:
	return palabra_actual["opciones"]


## Evalúa la sílaba elegida por el niño.
func elegir_silaba(silaba: String) -> Resultado:
	_seleccionadas.append(silaba)
	var correcta: Array = palabra_actual["correcta"]
	if _seleccionadas != correcta.slice(0, _seleccionadas.size()):
		_seleccionadas.clear()  # RF12: vuelve a intentar sin penalización
		return Resultado.ERROR
	if _seleccionadas.size() < correcta.size():
		return Resultado.PARCIAL
	completadas += 1
	return Resultado.PALABRA_COMPLETA
