# HealthPack.gd
extends Area2D

## Cantidad de vida que se restaurará al ser recogido.
@export var heal_amount: int = 25

# --- REFERENCIAS A NODOS ---

# Referencia al nodo de animaciones (AnimationPlayer o AnimatedSprite2D).
# ¡Asegúrate de que el nombre $AnimationPlayer coincida!
@onready var animation_node = $AnimationPlayer 

# Referencia al AudioStreamPlayer2D para el sonido de recogida.
# ¡Asegúrate de que el nombre $PickupSound coincida!
@onready var pickup_sound = $PickupSound 
# --------------------------


# La función _ready() se llama automáticamente cuando el nodo
# entra en el árbol de la escena por primera vez.
func _ready():
	# Inicia la animación "idle" (asumiendo que está configurada en loop).
	animation_node.play("idle")


func _on_body_entered(body: Node2D):
	# 1. Verificar si el cuerpo entrante es el jugador y puede curarse
	if body.has_method("heal"):
		# 2. Curar al jugador
		body.heal(heal_amount)
		
		# --- LÓGICA DE REPRODUCCIÓN DE SONIDO ---
		
		# A. Desvincula el nodo de sonido de este objeto. Esto es necesario
		#    antes de cambiar su padre, y evita el error: "already has a parent".
		remove_child(pickup_sound) 
		
		# B. Adjunta el nodo de sonido al árbol raíz de la escena.
		#    Esto lo "protege" para que no se borre junto con el HealthPack.
		get_tree().root.add_child(pickup_sound)
		
		# C. Inicia la reproducción del audio.
		pickup_sound.play()
		
		# D. Conecta la señal 'finished' del audio para que el nodo de sonido 
		#    se elimine a sí mismo limpiamente una vez que el sonido termine.
		pickup_sound.finished.connect(pickup_sound.queue_free)
		
		# ----------------------------------------
		
		# 4. Eliminar el objeto de curación de la escena (Area2D y otros hijos)
		queue_free()
