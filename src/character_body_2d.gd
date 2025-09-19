extends CharacterBody2D

# --- Variables de Movimiento ---
# Puedes ajustar estos valores en el Inspector
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0

# Obtenemos la gravedad definida en la configuración del proyecto.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float):
	# --- Gravedad ---
	# Añadimos gravedad en cada fotograma si no estamos en el suelo.
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- Salto ---
	# Si presionamos la tecla de salto y estamos en el suelo...
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity # ...aplicamos una velocidad vertical hacia arriba.

	# --- Movimiento Horizontal ---
	# Obtenemos la dirección del input (-1 para izquierda, 1 para derecha, 0 si no hay).
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Aplicamos la velocidad horizontal.
	if direction:
		velocity.x = direction * speed
	else:
		# Si no presionamos nada, frenamos poco a poco.
		velocity.x = move_toward(velocity.x, 0, speed)

	# --- Aplicar el Movimiento ---
	# move_and_slide() es la función mágica que mueve al personaje
	# y gestiona las colisiones con el suelo y las paredes.
	move_and_slide()
