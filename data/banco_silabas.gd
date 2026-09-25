## Capa de datos: banco de palabras del minijuego de sílabas.
## Solo contiene información, no reglas ni interfaz.
class_name BancoSilabas
extends RefCounted

const PALABRAS := [
	# Confusión de l vs t / s vs z
	{"correcta": ["so", "l"], "opciones": ["so", "l", "zo", "t"]},
	# Letras espejo: m vs n / p vs b vs d
	{"correcta": ["ma", "pa"], "opciones": ["ma", "na", "pa", "ba"]},
	# Confusión de u vs n / l vs i
	{"correcta": ["lu", "na"], "opciones": ["lu", "nu", "na", "la"]},
	# Inversión de sílabas y confusión t vs d
	{"correcta": ["pe", "lo", "ta"], "opciones": ["pe", "be", "lo", "ta", "da"]},
	# Confusión p vs b / n vs m / d vs b
	{"correcta": ["pi", "no"], "opciones": ["pi", "bi", "no", "mo", "di"]},
	# Inversión: te vs et / so vs os / ro vs or
	{"correcta": ["te", "so", "ro"], "opciones": ["te", "et", "so", "os", "ro"]},
]
