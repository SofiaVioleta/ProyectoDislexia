extends Area2D # Zona de detección

func _on_body_entered(body): # Detecta contacto
	if body.is_in_group("Player"): # Si es jugador
		EstadoJuego.progreso.reiniciar()
		get_tree().reload_current_scene.call_deferred() # Reinicia nivel al final del frame
