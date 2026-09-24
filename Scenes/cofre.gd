extends Area2D

var panel_escena = preload("res://Scenes/minijuego_panel.tscn")
var panel = null
var minijuego_completado = false # Nueva variable para controlar el estado

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificamos que sea el jugador y que el juego no se haya completado ya
	if body.name == "CharacterBody2D" and not minijuego_completado:
		print("Intento de abrir cofre. ¿Tiene llave?: ", body.tiene_llave)
		
		if body.tiene_llave:
			# Si el panel no existe en la escena, lo creamos
			if panel == null:
				panel = panel_escena.instantiate()
				get_tree().root.add_child(panel)
				
				# OPCIONAL: Conectar una señal si quieres que el cofre 
				# cambie de animación a "Abierto" cuando el niño gane.
			
			panel.abrir()
			
			# Marcamos como completado para que no se abra el panel 
			# una y otra vez mientras el niño está parado sobre el cofre.
			minijuego_completado = true
			
			# Si quieres que el jugador no se mueva mientras juega:
			# get_tree().paused = true 
		else:
			print("El niño necesita encontrar la llave primero")
			# Aquí podrías poner un mensaje flotante que diga "Busca la llave"
