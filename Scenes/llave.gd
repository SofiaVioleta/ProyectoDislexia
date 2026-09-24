extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		body.tiene_llave = true
		print("llave recogida, tiene_llave: ", body.tiene_llave)
		queue_free()
