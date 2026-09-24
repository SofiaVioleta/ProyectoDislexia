extends CanvasLayer # Capa de interfaz

@onready var Coin_label=$Control/Label # Texto monedas

func set_Coin(amount): # Actualiza valor
	Coin_label.text=str(amount) # Muestra cantidad
