extends Area2D

# --- Variables de Movimiento ---
@export var velocidad: float = 75.0
var jugador_objetivo: Node2D = null

# --- Nodos Hijos ---
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


# La función _ready se ejecuta una sola vez cuando la Sombra es creada.
func _ready() -> void:
	# --- ¡AQUÍ ESTÁ EL CAMBIO! ---
	# Conectamos la señal 'body_entered' a nuestra función _on_body_entered
	# Esta señal se dispara cuando un PhysicsBody (como el jugador) entra.
	connect("body_entered", _on_body_entered)
	# --------------------------
	
	# Buscamos en todo el juego el primer nodo que esté en el grupo "player".
	jugador_objetivo = get_tree().get_first_node_in_group("player")
	
	# Si por alguna razón no encuentra al jugador, mostrará una advertencia.
	if not jugador_objetivo:
		print("ADVERTENCIA: La Sombra no pudo encontrar al jugador en el grupo 'player'.")
	else:
		# Si lo encuentra, inmediatamente comienza la animación de correr.
		anim_player.play("run")


# La función _process se ejecuta en cada frame.
func _process(delta: float) -> void:
	# Si no tenemos un objetivo (porque no se encontró en _ready), no hacemos nada.
	if not jugador_objetivo:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		return

	# --- Lógica de Persecución Constante ---

	# 1. Calcular la dirección hacia el jugador.
	var direccion = (jugador_objetivo.global_position - self.global_position).normalized()

	# 2. Mover la Sombra.
	global_position += direccion * velocidad * delta
	
	# 3. Voltear el sprite para que mire en la dirección del movimiento.
	if direccion.x < 0:
		sprite.flip_h = true
	elif direccion.x > 0:
		sprite.flip_h = false

# ---
# ¡AQUÍ ESTÁ LA NUEVA FUNCIÓN!
# Esta función se llama automáticamente gracias a la línea que pusimos en _ready().
# ---
func _on_body_entered(body: Node2D) -> void:
	
	# 1. Verificamos si el cuerpo que entró está en el grupo "player"
	if body.is_in_group("player"):
		
		# 2. Verificamos si tiene el método "take_damage" (igual que tu otro enemigo)
		if body.has_method("take_damage"):
			
			# 3. ¡Lo llamamos con un número gigante para matarlo al instante!
			body.take_damage(99999)
