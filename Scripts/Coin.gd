extends Area2D # Nodo de detección

@onready var animated_sprite=$AnimatedSprite2D # Animación moneda
@onready var collision= $CollisionShape2D # Colisión
@onready var pickup_sound=$Coin # Sonido recoger

func _on_body_entered(body): # Detecta contacto
	if body.is_in_group("Player"): # Si es jugador
		body.add_Coin() # Suma moneda
		animated_sprite.visible=false # Oculta sprite
		collision.disabled=true # Desactiva colisión
		pickup_sound.play() # Reproduce sonido
		pickup_sound.finished.connect(_on_sound_finished) # Espera fin sonido
			
func _on_sound_finished(): # Cuando termina sonido
	queue_free() # Elimina moneda
