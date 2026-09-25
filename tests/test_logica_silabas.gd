## Pruebas de la capa lógica del minijuego de sílabas.
## Cada prueba corresponde a un criterio de aceptación (RF9, RF12).
extends GdUnitTestSuite

# Banco fijo para que las pruebas no dependan del azar
const BANCO := [{"correcta": ["ma", "pa"], "opciones": ["ma", "na", "pa", "ba"]}]

var logica: LogicaSilabas


func before_test() -> void:
	logica = LogicaSilabas.new(BANCO, 1)
	logica.iniciar()


func test_silaba_correcta_en_orden_es_parcial() -> void:
	assert_int(logica.elegir_silaba("ma")).is_equal(LogicaSilabas.Resultado.PARCIAL)


func test_todas_las_silabas_correctas_completan_la_palabra() -> void:
	logica.elegir_silaba("ma")
	assert_int(logica.elegir_silaba("pa")).is_equal(LogicaSilabas.Resultado.PALABRA_COMPLETA)
	assert_int(logica.completadas).is_equal(1)


func test_silaba_incorrecta_es_error() -> void:
	assert_int(logica.elegir_silaba("na")).is_equal(LogicaSilabas.Resultado.ERROR)


# RF12: equivocarse no resta puntaje y permite volver a intentar
func test_error_no_resta_y_permite_reintentar() -> void:
	logica.elegir_silaba("pa")  # orden incorrecto
	assert_int(logica.completadas).is_equal(0)
	logica.elegir_silaba("ma")
	assert_int(logica.elegir_silaba("pa")).is_equal(LogicaSilabas.Resultado.PALABRA_COMPLETA)


func test_minijuego_termina_al_completar_el_total() -> void:
	logica.elegir_silaba("ma")
	logica.elegir_silaba("pa")
	assert_bool(logica.siguiente_palabra()).is_false()
