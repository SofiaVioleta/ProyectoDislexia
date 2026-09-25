extends CharacterBody2D # Nodo con físicas

const SPEED = 125 # Velocidad
const JUMP_VELOCITY = -300 # Fuerza salto

@onready var anim = $Sprite2D # Animaciones

var Coin=0 # Contador monedas
var tiene_llave = false

@onready var hud = get_node("/root/Map/CanvasLayer") # HUD

@onready var jump_sound=$AudioStreamPlayer2D # Sonido salto

func add_Coin(): # Sumar moneda
	Coin+=1 # +1 moneda
	hud.set_Coin(Coin) # Actualiza HUD
	
func _physics_process(delta: float) -> void: # Loop físico
	
	if not is_on_floor(): # En el aire
		velocity += get_gravity() * delta # Aplica gravedad
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): # Salto
		velocity.y = JUMP_VELOCITY # Ejecuta salto
		jump_sound.play() # Sonido
	
	var direction := Input.get_axis("ui_left", "ui_right") # Dirección
	
	if direction: # Si se mueve
		velocity.x = direction * SPEED # Movimiento X
		anim.flip_h=direction<0 # Voltea sprite
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # Frenado
	
	move_and_slide() # Movimiento + colisión
	
	if not is_on_floor() && velocity.y < 0: # Subiendo
		anim.play("Jump") # Anim salto
	elif direction != 0: # Caminando
		anim.play("Walk") # Anim caminar
	else:
		anim.play("Idle") # Anim idle
