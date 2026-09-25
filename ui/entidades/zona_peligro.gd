extends Area2D # Zona de detección

func _on_body_entered(body): # Detecta contacto
	if body.is_in_group("Player"): # Si es jugador
		get_tree().reload_current_scene() # Reinicia nivell
