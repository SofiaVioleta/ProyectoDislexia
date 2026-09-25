## Capa lógica: progreso del niño dentro de un mundo (monedas y llave).
## Emite señales para que la interfaz se actualice sola.
class_name ProgresoMundo
extends RefCounted

signal monedas_cambiadas(total: int)
signal llave_obtenida

var monedas: int = 0
var tiene_llave: bool = false


func agregar_moneda() -> void:
	monedas += 1
	monedas_cambiadas.emit(monedas)


func obtener_llave() -> void:
	tiene_llave = true
	llave_obtenida.emit()


func reiniciar() -> void:
	monedas = 0
	tiene_llave = false
	monedas_cambiadas.emit(monedas)
